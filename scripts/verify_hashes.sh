#!/bin/bash
# Usage: ./verify_hashes.sh [-v|--verbose] [-q|--quick] [--cache <file>] <dir1> <dir2> [copy-script-file]

VERBOSE=0
QUICK=0
HASH_CACHE=""
ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=1
            ;;
        -q|--quick)
            QUICK=1
            ;;
        --cache)
            shift
            HASH_CACHE="$1"
            ;;
        *)
            ARGS+=("$1")
            ;;
    esac
    shift
done

DIR1="${ARGS[0]}"
DIR2="${ARGS[1]}"
COPY_SCRIPT="${ARGS[2]}"

if [ -z "$DIR1" ] || [ -z "$DIR2" ] || [ ! -d "$DIR1" ] || [ ! -d "$DIR2" ]; then
    echo "Usage: $0 [-v|--verbose] [-q|--quick] [--cache <hash-cache-file>] <directory1> <directory2> [copy-script-file]"
    exit 1
fi

DIR1=$(realpath "$DIR1")
DIR2=$(realpath "$DIR2")

# Resolve the cache to an absolute path so worker processes (which inherit the
# launch cwd) read and write the same file regardless of where it was given.
if [ -n "$HASH_CACHE" ]; then
    case "$HASH_CACHE" in
        /*) ;;
        *) HASH_CACHE="$PWD/$HASH_CACHE" ;;
    esac
fi

PARALLEL_JOBS=6

export VERBOSE QUICK DIR1 DIR2 COPY_SCRIPT HASH_CACHE

# Writes a cp command (creating the destination dir first) to the copy
# script, for a file found via ONLY IN. No-op unless a third argument was given.
write_copy_cmd() {
    if [ -z "$COPY_SCRIPT" ]; then
        return
    fi
    local src="$1" dest="$2"
    acquire_lock
    printf 'mkdir -p %q && cp %q %q\n' "$(dirname "$dest")" "$src" "$dest" >> "$COPY_SCRIPT"
    release_lock
}

# Appends a "# MISMATCH: <path>" comment to the copy script documenting a
# differing file, followed by an executable cp command overwriting the dir2
# copy with the dir1 source. No-op unless a third argument was given.
write_mismatch_comment() {
    if [ -z "$COPY_SCRIPT" ]; then
        return
    fi
    local rel="$1" src="$2" dest="$3"
    acquire_lock
    printf '# MISMATCH: %s\n' "$rel" >> "$COPY_SCRIPT"
    printf 'cp %q %q\n' "$src" "$dest" >> "$COPY_SCRIPT"
    release_lock
}

if [ -n "$COPY_SCRIPT" ]; then
    printf '#!/bin/bash\n' > "$COPY_SCRIPT"
fi

# --- Hash cache (optional, --cache <file>) --------------------------------
# A tab-separated file of "<sha256>\t<size>\t<mtime>\t<abs-path>" lines,
# letting a re-run skip re-hashing any file whose size and mtime are unchanged
# since last time. Lookups read the pre-existing cache (never written during a
# run, so lock-free); fresh entries are appended to a new cache that atomically
# replaces the old one at the end, which also compacts away stale paths.

# Echoes a cached sha256 for $file when its size+mtime match a stored entry,
# otherwise echoes nothing. No-op (miss) unless --cache was given.
cache_lookup() {
    { [ -z "$HASH_CACHE" ] || [ ! -f "$HASH_CACHE" ]; } && return
    local file="$1" size="$2" mtime="$3"
    awk -F'\t' -v p="$file" -v s="$size" -v m="$mtime" \
        '$2==s && $3==m && $4==p {print $1; exit}' "$HASH_CACHE"
}

# Appends $file's hash (with its current size/mtime) to the new cache so a
# later run can reuse it. Held under the shared lock since workers append
# concurrently. No-op unless --cache was given.
cache_store() {
    [ -z "$HASH_CACHE" ] && return
    local file="$1" size="$2" mtime="$3" hash="$4"
    acquire_lock
    printf '%s\t%s\t%s\t%s\n' "$hash" "$size" "$mtime" "$file" >> "$HASH_CACHE_NEW"
    release_lock
}

# Returns the sha256 of $file, served from the cache when its size+mtime are
# unchanged, and records the result into the new cache either way. Falls back
# to a plain sha256sum (and stores nothing) when --cache was not given.
hash_file() {
    local file="$1" size="$2" mtime="$3" hash
    hash=$(cache_lookup "$file" "$size" "$mtime")
    if [ -z "$hash" ]; then
        hash=$(sha256sum "$file" | awk '{print $1}')
    fi
    cache_store "$file" "$size" "$mtime" "$hash"
    printf '%s' "$hash"
}

# Skip AppleDouble sidecar files (._foo.txt or ._SomeFolder) only when the
# real file or folder they shadow (foo.txt or SomeFolder) exists alongside
# them, since they're junk metadata in that case.
is_apple_double_sidecar() {
    local file="$1"
    local base
    base=$(basename "$file")
    case "$base" in
        .DS_Store)
            return 0
            ;;
        ._*)
            [ -e "$(dirname "$file")/${base#._}" ]
            ;;
        *)
            return 1
            ;;
    esac
}

# Renders a progress bar to stderr, redrawing in place. Skipped entirely in
# verbose mode since per-file log lines are printed instead.
print_progress() {
    if [ "$VERBOSE" -eq 1 ]; then
        return
    fi
    local current="$1"
    local total="$2"
    local label="$3"
    local width=40
    local filled=0
    if [ "$total" -gt 0 ]; then
        filled=$((current * width / total))
    fi
    local bar
    bar=$(printf '%*s' "$filled" '' | tr ' ' '#')
    bar="${bar}$(printf '%*s' "$((width - filled))" '')"
    printf '\r%s [%s] %d/%d' "$label" "$bar" "$current" "$total" >&2
}

# While the progress bar is live, result lines are buffered to a temp file
# instead of printed immediately, so they never race with the bar's
# carriage-return redraws on stdout/stderr. flush_results dumps them once the
# bar for that phase is done. In verbose mode there's no bar, so print directly.
RESULTS_FILE=$(mktemp)
PROGRESS_FILE=$(mktemp)
HASH_CACHE_NEW=$(mktemp)
LOCK_DIR=$(mktemp -u)
trap 'rm -f "$RESULTS_FILE" "$PROGRESS_FILE" "$HASH_CACHE_NEW"; rmdir "$LOCK_DIR" 2>/dev/null' EXIT

# Phase work runs across up to $PARALLEL_JOBS worker processes (via xargs -P),
# since sha256sum dominates runtime and is independent per file. Shared state
# (RESULTS_FILE, COPY_SCRIPT, PROGRESS_FILE, the progress bar on stderr) is
# only ever mutated while holding this mkdir-based lock, since mkdir is
# atomic and flock isn't reliably available on macOS.
acquire_lock() {
    while ! mkdir "$LOCK_DIR" 2>/dev/null; do
        sleep 0.01
    done
}

release_lock() {
    rmdir "$LOCK_DIR"
}

log_line() {
    if [ "$VERBOSE" -eq 1 ]; then
        acquire_lock
        echo "$1"
        release_lock
    else
        acquire_lock
        echo "$1" >> "$RESULTS_FILE"
        release_lock
    fi
}

bump_progress() {
    local total="$1" label="$2"
    acquire_lock
    local count
    count=$(<"$PROGRESS_FILE")
    count=$((count + 1))
    echo "$count" > "$PROGRESS_FILE"
    print_progress "$count" "$total" "$label"
    release_lock
}

flush_results() {
    if [ "$VERBOSE" -eq 0 ]; then
        cat "$RESULTS_FILE"
        : > "$RESULTS_FILE"
    fi
}

export -f write_copy_cmd write_mismatch_comment cache_lookup cache_store hash_file is_apple_double_sidecar print_progress acquire_lock release_lock log_line bump_progress
export RESULTS_FILE PROGRESS_FILE HASH_CACHE_NEW LOCK_DIR

# Compares a single file from dir1 against its counterpart in dir2; run as a
# worker process, one invocation per file.
compare_file_phase1() {
    local file="$1" rel_path other_file line="" size1 size2 mtime1 mtime2 hash1 hash2
    if ! is_apple_double_sidecar "$file"; then
        rel_path="${file#$DIR1/}"
        other_file="$DIR2/$rel_path"

        if [ ! -f "$other_file" ]; then
            line="ONLY IN $DIR1: $rel_path"
            write_copy_cmd "$file" "$other_file"
        else
            size1=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
            size2=$(stat -f%z "$other_file" 2>/dev/null || stat -c%s "$other_file")
            if [ "$size1" != "$size2" ]; then
                # Different sizes guarantee different content, so flag the
                # mismatch without reading (or hashing) either file.
                line="MISMATCH: $rel_path (size $size1 vs $size2)"
                write_mismatch_comment "$rel_path" "$file" "$other_file"
            elif [ "$QUICK" -eq 1 ]; then
                [ "$VERBOSE" -eq 1 ] && line="✅ $rel_path"
            else
                mtime1=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file")
                mtime2=$(stat -f%m "$other_file" 2>/dev/null || stat -c%Y "$other_file")
                hash1=$(hash_file "$file" "$size1" "$mtime1")
                hash2=$(hash_file "$other_file" "$size2" "$mtime2")
                if [ "$hash1" != "$hash2" ]; then
                    line="MISMATCH: $rel_path ($hash1 vs $hash2)"
                    write_mismatch_comment "$rel_path" "$file" "$other_file"
                elif [ "$VERBOSE" -eq 1 ]; then
                    line="✅ $rel_path"
                fi
            fi
        fi

        [ -n "$line" ] && log_line "$line"
    fi
    bump_progress "$TOTAL1" "$LABEL1"
}
export -f compare_file_phase1

# Checks a single file from dir2 for existence in dir1; run as a worker
# process, one invocation per file.
check_file_phase2() {
    local file="$1" rel_path other_file
    if ! is_apple_double_sidecar "$file"; then
        rel_path="${file#$DIR2/}"
        other_file="$DIR1/$rel_path"

        if [ ! -f "$other_file" ]; then
            log_line "ONLY IN $DIR2: $rel_path"
            write_copy_cmd "$file" "$other_file"
        fi
    fi
    bump_progress "$TOTAL2" "$LABEL2"
}
export -f check_file_phase2

# Phase 1: files present in dir1, check against dir2
total1=$(find "$DIR1" -type f | wc -l | tr -d ' ')
export TOTAL1="$total1" LABEL1="Comparing $DIR1 -> $DIR2"
echo 0 > "$PROGRESS_FILE"
find "$DIR1" -type f -print0 | xargs -0 -P "$PARALLEL_JOBS" -n 1 bash -c 'compare_file_phase1 "$1"' _
[ "$VERBOSE" -eq 0 ] && echo "" >&2
flush_results

# Phase 2: files present in dir2 but missing from dir1
total2=$(find "$DIR2" -type f | wc -l | tr -d ' ')
export TOTAL2="$total2" LABEL2="Checking $DIR2 -> $DIR1"
echo 0 > "$PROGRESS_FILE"
find "$DIR2" -type f -print0 | xargs -0 -P "$PARALLEL_JOBS" -n 1 bash -c 'check_file_phase2 "$1"' _
[ "$VERBOSE" -eq 0 ] && echo "" >&2
flush_results

if [ -n "$COPY_SCRIPT" ]; then
    echo "Copy commands written to $COPY_SCRIPT"
fi

# Swap in the freshly built cache (full mode only — a quick run hashes nothing,
# so its empty cache must not clobber a real one).
if [ -n "$HASH_CACHE" ] && [ "$QUICK" -eq 0 ]; then
    mv "$HASH_CACHE_NEW" "$HASH_CACHE"
    echo "Hash cache updated at $HASH_CACHE"
fi

echo "Done."
