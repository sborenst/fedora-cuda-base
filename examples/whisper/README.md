# Whisper CUDA Container

This container extends the Fedora CUDA Base Container with OpenAI Whisper for GPU-accelerated speech recognition and transcription.

## Features

- **GPU Acceleration**: CUDA-enabled Whisper for faster transcription
- **Multiple Models**: Support for all Whisper model sizes (tiny, base, small, medium, large)
- **Audio Format Support**: WAV, MP3, M4A, FLAC, and more
- **Output Formats**: Text, SRT, VTT, TSV, JSON
- **Faster Whisper**: Includes faster-whisper for improved performance
- **Audio Processing**: FFmpeg and Python audio libraries included

## Building the Container

From the project root directory:

```bash
# Build whisper container (will build base first if needed)
./build.sh whisper
```

## Usage

### Basic Transcription

```bash
# Transcribe an audio file to text
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  whisper /workspace/audio.wav
```

### Specify Model Size

```bash
# Use medium model for better accuracy
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  whisper /workspace/audio.wav --model medium
```

### Generate Subtitles

```bash
# Generate SRT subtitles
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  whisper /workspace/audio.wav --model medium --output_format srt

# Generate VTT subtitles
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  whisper /workspace/audio.wav --model medium --output_format vtt
```

### Specify Language

```bash
# Transcribe Spanish audio
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  whisper /workspace/audio.wav --language Spanish

# Auto-detect language
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  whisper /workspace/audio.wav --language auto
```

### Interactive Mode

```bash
# Enter container for multiple operations
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest /bin/bash

# Inside container:
whisper /workspace/audio1.wav --model medium --output_format srt
whisper /workspace/audio2.wav --model large --language English
```

### Using Faster Whisper

```bash
# Use faster-whisper for improved performance
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  python3 -c "
import faster_whisper
model = faster_whisper.WhisperModel('medium', device='cuda')
segments, info = model.transcribe('/workspace/audio.wav')
for segment in segments:
    print(f'[{segment.start:.2f}s -> {segment.end:.2f}s] {segment.text}')
"
```

## Whisper Models

| Model  | Parameters | VRAM Usage | Speed | Accuracy |
|--------|------------|------------|-------|----------|
| tiny   | 39 M       | ~1 GB      | ~32x  | Good     |
| base   | 74 M       | ~1 GB      | ~16x  | Better   |
| small  | 244 M      | ~2 GB      | ~6x   | Good     |
| medium | 769 M      | ~5 GB      | ~2x   | Better   |
| large  | 1550 M     | ~10 GB     | ~1x   | Best     |

## Supported Audio Formats

- **WAV**: Uncompressed audio (recommended)
- **MP3**: Compressed audio
- **M4A**: Apple audio format
- **FLAC**: Lossless compression
- **OGG**: Open source audio format
- **WMA**: Windows Media Audio

## Output Formats

- **txt**: Plain text transcription
- **srt**: SubRip subtitle format
- **vtt**: WebVTT subtitle format
- **tsv**: Tab-separated values with timestamps
- **json**: JSON format with detailed information

## Performance Optimization

### GPU Memory Management

```bash
# For large files, use smaller model to avoid OOM
whisper /workspace/large_audio.wav --model small

# Monitor GPU memory usage
nvidia-smi
```

### Batch Processing

```bash
# Process multiple files
for file in /workspace/*.wav; do
    whisper "$file" --model medium --output_format srt
done
```

### Audio Preprocessing

```bash
# Convert to optimal format first
ffmpeg -i /workspace/input.mp3 -ar 16000 -ac 1 /workspace/processed.wav
whisper /workspace/processed.wav --model medium
```

## Troubleshooting

### Common Issues

**1. CUDA Out of Memory**
```
RuntimeError: CUDA out of memory
```
**Solution**: Use a smaller model or reduce audio file size
```bash
whisper /workspace/audio.wav --model small  # Instead of large
```

**2. Audio File Not Found**
```
FileNotFoundError: [Errno 2] No such file or directory
```
**Solution**: Ensure file is in the workspace directory and path is correct
```bash
ls /workspace/  # Check files in container
```

**3. GPU Not Detected**
```
No CUDA devices available
```
**Solution**: Ensure container is run with GPU access
```bash
podman run --device nvidia.com/gpu=all ...  # Include GPU flag
```

**4. Permission Denied**
```
PermissionError: [Errno 13] Permission denied
```
**Solution**: Check file permissions and SELinux context
```bash
chmod 644 ./workspace/audio.wav
# Use :Z flag for SELinux: -v ./workspace:/workspace:Z
```

### Performance Tips

1. **Use appropriate model size** for your GPU memory
2. **Preprocess audio** to 16kHz mono WAV for best performance
3. **Use faster-whisper** for production workloads
4. **Monitor GPU usage** with `nvidia-smi`
5. **Cache models** by keeping container running for multiple files

### Audio Quality Tips

1. **Clean audio** produces better results
2. **Remove background noise** before transcription
3. **Split long files** into smaller segments
4. **Use higher quality models** for important content

## Examples

### Complete Workflow

```bash
# 1. Build the container
./build.sh whisper

# 2. Place audio file in workspace
cp ~/my_audio.wav ./workspace/

# 3. Transcribe with medium model
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  whisper /workspace/my_audio.wav --model medium --output_format srt

# 4. Check results
ls ./workspace/  # Should show my_audio.srt
```

### Batch Processing Script

```bash
#!/bin/bash
# Process all WAV files in workspace
for audio_file in ./workspace/*.wav; do
    filename=$(basename "$audio_file" .wav)
    echo "Processing: $filename"
    
    podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
      --rm fedora-cuda-whisper:latest \
      whisper "/workspace/$filename.wav" --model medium --output_format srt
done
```

## Advanced Usage

### Custom Python Scripts

```python
# Save as ./workspace/transcribe.py
import whisper
import sys

model = whisper.load_model("medium")
result = model.transcribe(sys.argv[1])

# Print with timestamps
for segment in result["segments"]:
    start = segment["start"]
    end = segment["end"]
    text = segment["text"]
    print(f"[{start:.2f}s -> {end:.2f}s] {text}")
```

```bash
# Run custom script
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \
  -it --rm fedora-cuda-whisper:latest \
  python3 /workspace/transcribe.py /workspace/audio.wav
```

## Container Information

- **Base Image**: fedora-cuda-base:latest
- **Python Version**: 3.12
- **CUDA Version**: 11.8
- **PyTorch Version**: 2.2.0+cu118
- **Whisper Version**: Latest from PyPI
- **Working Directory**: /workspace

## Support

For issues specific to this container, check:
1. Base container functionality with `./build.sh base`
2. GPU access with `nvidia-smi` inside container
3. Audio file format and permissions
4. Available GPU memory for model size

For Whisper-specific issues, refer to the [OpenAI Whisper documentation](https://github.com/openai/whisper).