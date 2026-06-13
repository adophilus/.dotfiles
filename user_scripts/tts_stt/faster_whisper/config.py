import sys
import argparse
from faster_whisper import WhisperModel
import os
import subprocess
import json


def load_prompt_template():
    """Load the prompt template from prompt.md file"""
    prompt_path = os.path.join(os.path.dirname(__file__), "prompt.md")
    try:
        with open(prompt_path, "r", encoding="utf-8") as f:
            prompt_content = f.read()
        return prompt_content
    except Exception as e:
        print(f"Error loading prompt template: {e}", file=sys.stderr)
        return None


def format_with_llm(text):
    """Process transcribed text through LLM for formatting"""
    if not text.strip():
        return text

    # Load prompt template
    prompt_template = load_prompt_template()
    if not prompt_template:
        print(
            "Warning: Could not load prompt template, returning raw text",
            file=sys.stderr,
        )
        return text

    # Extract just the user prompt part (after the separator)
    if "- User prompt:" in prompt_template:
        parts = prompt_template.split("- User prompt:", 1)
        instructions = parts[0].strip()
        user_prompt_template = parts[1].strip().strip("`")

        # Create the complete prompt with instructions + text to format
        complete_prompt = (
            f"{instructions}\n\n{user_prompt_template.replace('{{input}}', text)}"
        )
    else:
        # Fallback: simple replacement
        complete_prompt = prompt_template.replace("{{input}}", text)

    try:
        # Use opencode CLI to process the text through LLM
        result = subprocess.run(
            [
                "opencode",
                "run",
                "--model",
                "zai-coding-plan/glm-4.5",
                "--agent",
                "build",
                complete_prompt,
            ],
            capture_output=True,
            text=True,
            timeout=60,  # 60 second timeout
        )

        if result.returncode == 0:
            # Extract the relevant part from the output
            output_lines = result.stdout.strip().split("\n")
            # Find the line after the "build · glm-4.5" line
            for i, line in enumerate(output_lines):
                if "build · glm-4.5" in line:
                    # Skip the line with "build · glm-4.5" and any empty lines
                    formatted_text = "\n".join(output_lines[i + 2 :]).strip()
                    return formatted_text
            # If we can't find the expected format, return the whole output
            return result.stdout.strip()
        else:
            print(f"LLM processing error: {result.stderr}", file=sys.stderr)
            return text

    except subprocess.TimeoutExpired:
        print("LLM processing timed out, returning raw text", file=sys.stderr)
        return text
    except Exception as e:
        print(f"Error in LLM processing: {e}", file=sys.stderr)
        return text

    # Load prompt template
    prompt_template = load_prompt_template()
    if not prompt_template:
        print(
            "Warning: Could not load prompt template, returning raw text",
            file=sys.stderr,
        )
        return text

    # Replace the placeholder with actual text
    formatted_prompt = prompt_template.replace("{{input}}", text)

    try:
        # Use opencode CLI to process the text through LLM
        result = subprocess.run(
            [
                "opencode",
                "run",
                "--model",
                "zai-coding-plan/glm-4.5",
                "--agent",
                "build",
                formatted_prompt,
            ],
            capture_output=True,
            text=True,
            timeout=60,  # 60 second timeout
        )

        if result.returncode == 0:
            # Extract the relevant part from the output
            output_lines = result.stdout.strip().split("\n")
            # Find the line after the "build · glm-4.5" line
            for i, line in enumerate(output_lines):
                if "build · glm-4.5" in line:
                    # Skip the line with "build · glm-4.5" and any empty lines
                    formatted_text = "\n".join(output_lines[i + 2 :]).strip()
                    return formatted_text
            # If we can't find the expected format, return the whole output
            return result.stdout.strip()
        else:
            print(f"LLM processing error: {result.stderr}", file=sys.stderr)
            return text

    except subprocess.TimeoutExpired:
        print("LLM processing timed out, returning raw text", file=sys.stderr)
        return text
    except Exception as e:
        print(f"Error in LLM processing: {e}", file=sys.stderr)
        return text


def main():
    # --- 1. Parse Arguments ---
    parser = argparse.ArgumentParser()
    parser.add_argument("audio_path", help="Absolute path to the wav file")
    args = parser.parse_args()

    audio_file_path = args.audio_path

    # --- 2. Model Configuration ---
    # If distil-small continues to fail, change this to 'base.en' or 'small.en'
    # model_size = "distil-small.en"
    model_size = "small.en"
    device_type = "cpu"
    compute_type = "int8"

    try:
        print(f"Loading model '{model_size}'...", file=sys.stderr)
        model = WhisperModel(model_size, device=device_type, compute_type=compute_type)

        print(f"Transcribing: {audio_file_path}", file=sys.stderr)

        # --- 3. Transcription (Robust Settings) ---
        segments, info = model.transcribe(
            audio_file_path,
            beam_size=5,  # Higher beam size reduces weird loops
            language="en",
            vad_filter=True,  # Aggressively cut out silence
            vad_parameters=dict(min_silence_duration_ms=500),  # Tweak silence detection
            condition_on_previous_text=False,  # CRITICAL: Prevents loop propagation
            repetition_penalty=1.2,  # Penalizes the model for saying the same thing twice
            no_repeat_ngram_size=3,  # Hard blocks repeating 3-word phrases
        )

        # --- 4. Process and Output ---
        transcribed_parts = []
        for segment in segments:
            text = segment.text.strip()
            # Filter out tiny hallucinations (e.g. single symbols)
            if len(text) > 1 or text.isalnum():
                transcribed_parts.append(text)
                print(
                    f"  [{segment.start:.2f}s -> {segment.end:.2f}s] {text}",
                    file=sys.stderr,
                )

        final_text = " ".join(transcribed_parts).strip()

        # --- 5. Process through LLM for formatting ---
        print(
            "Processing transcribed text through LLM for formatting...", file=sys.stderr
        )
        formatted_text = format_with_llm(final_text)

        # Output the formatted text
        print(formatted_text)

    except Exception as e:
        print(f"\nFatal Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
