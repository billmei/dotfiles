#!/usr/bin/env python3

import argparse
from datetime import datetime
from dotenv import load_dotenv
from openai import OpenAI
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time

def setup_openai_client():
    """Initialize and return the OpenAI client."""
    load_dotenv()
    client = OpenAI()
    client.api_key = os.getenv('OPENAI_API_KEY')
    if not client.api_key:
        print("Error: OPENAI_API_KEY not found in environment variables.", file=sys.stderr)
        sys.exit(1)
    return client

# Maximum input size to OpenAI TTS API is 4096 characters
# https://community.openai.com/t/text-to-speech-api-limit-speech-generation/558166
def chunk_text_by_sentence(text, max_length=4096):
    """Split text into chunks by sentences without exceeding the max length."""
    print("🔍 Splitting text into manageable chunks...")
    sentences = re.split(r'(?<=[.!?]) +', text)
    chunks = []
    current_chunk = ""

    for sentence in sentences:
        if len(current_chunk) + len(sentence) + 1 <= max_length:
            current_chunk += sentence + " "
        else:
            chunks.append(current_chunk.strip())
            current_chunk = sentence + " "

    if current_chunk:
        chunks.append(current_chunk.strip())

    print(f"   → Split into {len(chunks)} chunks")
    return chunks

def process_text_to_speech(client, text_chunks, temp_dir):
    """Process text chunks into speech and return list of audio files."""
    print("\n🎙️  Converting text to speech...")
    file_list_path = Path(temp_dir) / "file_list.txt"
    audio_files = []

    with open(file_list_path, 'w') as file_list:
        for index, chunk in enumerate(text_chunks, 1):
            print(f"   Processing chunk {index}/{len(text_chunks)}...", end='\r')
            audio_file_path = Path(temp_dir) / f"output-audio-{index}.mp3"
            audio_files.append(audio_file_path)

            with client.audio.speech.with_streaming_response.create(
                model="tts-1-hd",
                voice="alloy",
                instructions="Speak in a casual, informal tone like you would to a friend, not like you are trying to present something professionally.",
                input=chunk,
            ) as response:
                response.stream_to_file(audio_file_path)
            file_list.write(f"file '{audio_file_path}'\n")
    
    print("   ✓ All chunks processed")
    return file_list_path, audio_files

def combine_audio_files(file_list_path, output_path):
    """Combine audio files using ffmpeg."""
    print("\n🔊 Combining audio chunks...")
    try:
        subprocess.run([
            "ffmpeg", "-f", "concat", "-safe", "0", "-i", str(file_list_path),
            "-c", "copy", str(output_path), "-y", "-loglevel", "warning"
        ], check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Error combining audio files: {e}", file=sys.stderr)
        return False

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(
        description='Convert text to speech. Reads from a file or standard input.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''Examples:
  Read from a file:  python text-to-speech.py input.txt
  Read from pipe:    echo "Hello world" | python text-to-speech.py
  Read from clipboard (macOS): pbpaste | python text-to-speech.py'''
    )
    parser.add_argument('input_file', nargs='?', type=argparse.FileType('r'), 
                      default=sys.stdin,
                      help='Input text file (default: read from standard input)')
    args = parser.parse_args()

    print("\n🔊 Starting text-to-speech conversion")
    print("-" * 50)
    
    # Read input
    start_time = time.time()
    print("📖 Reading input...")
    input_text = args.input_file.read().strip()
    
    if not input_text:
        print("❌ Error: No input text provided.", file=sys.stderr)
        sys.exit(1)
    
    # Set up temporary directory
    project_root = Path(__file__).parent.parent
    os.makedirs(project_root / 'tmp', exist_ok=True)
    temp_dir = tempfile.mkdtemp(dir=project_root / 'tmp')
    print(f"📂 Created temporary directory: {temp_dir}")
    
    try:
        # Process text
        text_chunks = chunk_text_by_sentence(input_text)
        
        # Initialize OpenAI client
        client = setup_openai_client()
        
        # Convert text to speech
        file_list_path, audio_files = process_text_to_speech(client, text_chunks, temp_dir)
        
        # Combine audio files
        output_file = f"tts_output_{datetime.now().strftime('%Y%m%d_%H%M%S')}.mp3"
        output_path = Path(temp_dir) / output_file
        
        if combine_audio_files(file_list_path, output_path):
            duration = time.time() - start_time
            print("\n" + "=" * 50)
            print(f"✅ Success! Audio file created in {duration:.1f} seconds")
            print("=" * 50)
            print(f"\n🎧 Output file: {output_path}")
            print(f"🔈 Play with: afplay '{output_path}'")
            print(f"📂 Open with: open '{output_path}'")
            print(f"🔈 Playing audio with default application...")
            
            # Open the file with the default application
            if sys.platform == 'darwin':  # macOS
                subprocess.run(['open', str(output_path)])
            elif sys.platform == 'win32':  # Windows
                os.startfile(str(output_path))
            else:  # Linux and others
                subprocess.run(['xdg-open', str(output_path)])
    
    except Exception as e:
        print(f"\n❌ An error occurred: {str(e)}", file=sys.stderr)
        sys.exit(1)
    
if __name__ == "__main__":
    main()
