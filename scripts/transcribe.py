#!/usr/bin/env python3
"""
Transcribe an audio file with the local Parakeet (NeMo Conformer-TDT) ONNX model
used by Handy, via istupakov/onnx-asr (https://github.com/istupakov/onnx-asr).

Usage:
    python3 transcribe.py <path-to-audio-file> [--model DIR] [--provider cpu|coreml]

The first run bootstraps a local .venv next to this script and installs the
required packages, then re-execs itself inside that venv. Subsequent runs are
fast because the venv already exists.

Any audio/video format ffmpeg can read works (mp3, wav, m4a, aiff, mp4, ...);
it is decoded to 16 kHz mono internally.
"""

import os
import sys
import subprocess
from pathlib import Path

# ---------------------------------------------------------------------------
# venv bootstrap: ensure deps are present, then run inside the local .venv
# ---------------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).resolve().parent
VENV_DIR = SCRIPT_DIR / ".venv"
VENV_PY = VENV_DIR / "bin" / "python"

# Homebrew python3.13 is preferred: onnxruntime ships wheels for it (3.14 may not).
PREFERRED_PYTHONS = [
    "/opt/homebrew/bin/python3.13",
    "/usr/local/bin/python3.13",
    "/opt/homebrew/bin/python3.12",
    sys.executable,
]


def _find_base_python() -> str:
    for candidate in PREFERRED_PYTHONS:
        if candidate and Path(candidate).exists():
            return candidate
    return sys.executable


def _ensure_venv() -> None:
    """Create the venv and install deps if they're not already importable."""
    if not VENV_PY.exists():
        base = _find_base_python()
        print(f"[setup] creating venv with {base} ...", file=sys.stderr)
        subprocess.run([base, "-m", "venv", str(VENV_DIR)], check=True)

    # Is onnx_asr already installed in the venv?
    probe = subprocess.run(
        [str(VENV_PY), "-c", "import onnx_asr, onnxruntime, numpy"],
        capture_output=True,
    )
    if probe.returncode == 0:
        return

    print("[setup] installing dependencies (first run only) ...", file=sys.stderr)
    pip = [str(VENV_PY), "-m", "pip", "install", "--upgrade"]
    subprocess.run(pip + ["pip"], check=True)
    req = SCRIPT_DIR / "requirements.txt"
    if req.exists():
        subprocess.run(pip + ["-r", str(req)], check=True)
    else:
        subprocess.run(pip + ["numpy", "onnxruntime", "onnx-asr"], check=True)


# Re-exec inside the venv if we're not already running under it.
if sys.prefix != str(VENV_DIR):
    _ensure_venv()
    os.execv(str(VENV_PY), [str(VENV_PY), __file__, *sys.argv[1:]])

# ---------------------------------------------------------------------------
# Below here we are guaranteed to be running inside .venv with deps available.
# ---------------------------------------------------------------------------
import argparse

import numpy as np
import onnx_asr

DEFAULT_MODEL_DIR = str(
    Path.home()
    / "Library/Application Support/com.pais.handy/models/parakeet-tdt-0.6b-v3-int8"
)
SAMPLE_RATE = 16000


def decode_audio(path: str) -> np.ndarray:
    """Decode any ffmpeg-readable file to a mono float32 array at 16 kHz."""
    result = subprocess.run(
        ["ffmpeg", "-v", "quiet", "-i", path,
         "-ac", "1", "-ar", str(SAMPLE_RATE), "-f", "f32le", "-"],
        capture_output=True,
    )
    if result.returncode != 0 or not result.stdout:
        sys.exit(f"error: ffmpeg failed to decode {path!r}\n{result.stderr.decode(errors='replace')}")
    return np.frombuffer(result.stdout, dtype=np.float32)


def segment_waveform(wav, target_s=30.0, search_s=5.0):
    """Split a long waveform into ~target_s chunks, cutting at the quietest
    point near each boundary so words are not split mid-utterance.

    Returns a list of (start_sample, end_sample) tuples.
    """
    n = len(wav)
    target = int(target_s * SAMPLE_RATE)
    search = int(search_s * SAMPLE_RATE)
    if n <= target + search:
        return [(0, n)]

    # Per-frame RMS energy (25 ms frames, 10 ms hop) for silence detection.
    frame, hop = 400, 160
    n_frames = 1 + (n - frame) // hop
    idx = np.arange(n_frames) * hop
    # Vectorized RMS over frames.
    frames = np.lib.stride_tricks.sliding_window_view(wav, frame)[::hop]
    rms = np.sqrt(np.mean(frames.astype(np.float32) ** 2, axis=1) + 1e-12)

    bounds = [0]
    pos = 0
    while n - pos > target + search:
        center = pos + target
        lo_f = max(0, (center - search) // hop)
        hi_f = min(len(rms) - 1, (center + search) // hop)
        # Quietest frame in the search window -> likely a pause.
        cut_frame = lo_f + int(np.argmin(rms[lo_f:hi_f + 1]))
        cut = int(idx[cut_frame])
        if cut <= pos:  # safety: never go backwards
            cut = center
        bounds.append(cut)
        pos = cut
    bounds.append(n)
    return list(zip(bounds[:-1], bounds[1:]))


def main() -> None:
    parser = argparse.ArgumentParser(description="Transcribe audio with the local Parakeet ONNX model.")
    parser.add_argument("audio", help="Path to the audio file (mp3, wav, m4a, ...).")
    parser.add_argument("--model", default=DEFAULT_MODEL_DIR, help="Model directory.")
    parser.add_argument("--provider", choices=["cpu", "coreml"], default="cpu",
                        help="ONNX Runtime execution provider (default: cpu).")
    args = parser.parse_args()

    if not Path(args.audio).exists():
        sys.exit(f"error: audio file not found: {args.audio!r}")
    if not Path(args.model).is_dir():
        sys.exit(f"error: model directory not found: {args.model!r}")

    providers = (
        ["CoreMLExecutionProvider", "CPUExecutionProvider"]
        if args.provider == "coreml"
        else ["CPUExecutionProvider"]
    )

    print("[info] loading model ...", file=sys.stderr)
    model = onnx_asr.load_model(
        "nemo-conformer-tdt", args.model, quantization="int8", providers=providers
    )

    print(f"[info] decoding {args.audio} ...", file=sys.stderr)
    waveform = decode_audio(args.audio)
    total_s = len(waveform) / SAMPLE_RATE
    print(f"[info] {total_s / 60:.1f} min of audio", file=sys.stderr)

    segments = segment_waveform(waveform)
    parts = []
    for i, (start, end) in enumerate(segments, 1):
        print(
            f"[info] transcribing chunk {i}/{len(segments)} "
            f"({start / SAMPLE_RATE:6.1f}s -> {end / SAMPLE_RATE:6.1f}s) ...",
            file=sys.stderr,
        )
        text = model.recognize(waveform[start:end], sample_rate=SAMPLE_RATE)
        text = (text or "").strip()
        if text:
            parts.append(text)

    # Transcript goes to stdout; all status/log noise goes to stderr.
    print(" ".join(parts))


if __name__ == "__main__":
    main()
