#!/bin/bash

# Local build script for Whisper example
# This can be run from the examples/whisper directory

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info "Building Whisper container from local directory"

# Check if we're in the right directory
if [ ! -f "Containerfile" ]; then
    print_error "Containerfile not found. Please run this script from examples/whisper/ directory"
    exit 1
fi

# Check if base image exists
if ! podman image exists fedora-cuda-base:latest; then
    print_error "Base image 'fedora-cuda-base:latest' not found!"
    print_info "Please build the base image first:"
    print_info "  cd ../../ && ./build.sh base"
    exit 1
fi

# Build the whisper container
print_info "Building whisper container..."
podman build -f Containerfile -t fedora-cuda-whisper:latest .

if [ $? -eq 0 ]; then
    print_success "Whisper container built successfully!"
    echo ""
    print_info "To run whisper with GPU support:"
    echo ""
    echo "  podman run --device nvidia.com/gpu=all -v ../../workspace:/workspace:Z \\"
    echo "    -it --rm fedora-cuda-whisper:latest \\"
    echo "    whisper /workspace/audio.wav --model medium"
    echo ""
    print_info "See README.md for detailed usage instructions."
else
    print_error "Whisper container build failed!"
    exit 1
fi