#!/bin/bash

# Enhanced build script for Fedora CUDA Base Container System
# Supports building base container and examples

set -e  # Exit on any error

# Default target
TARGET="${1:-base}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if base image exists
check_base_image() {
    if podman image exists fedora-cuda-base:latest; then
        return 0
    else
        return 1
    fi
}

# Function to build base container
build_base() {
    print_info "Building Fedora 39 CUDA 11.8 container base"
    print_info "This build uses RHEL8 CUDA repository for better compatibility."
    echo ""

    # Build the Podman image using Containerfile
    podman build -f Containerfile -t fedora-cuda-base:latest .

    if [ $? -eq 0 ]; then
        print_success "Base container built successfully!"
        echo ""
        print_info "To run the container with GPU support, use one of these methods:"
        echo ""
        echo "Method 1 - Using podman-compose:"
        echo "  podman-compose up -d"
        echo "  podman-compose exec cuda-base /bin/bash"
        echo ""
        echo "Method 2 - Using podman run directly:"
        echo "  podman run --device nvidia.com/gpu=all -it --rm fedora-cuda-base:latest"
        echo ""
        echo "Method 3 - Alternative GPU access:"
        echo "  podman run --security-opt=label=disable --hooks-dir=/usr/share/containers/oci/hooks.d/ -it --rm fedora-cuda-base:latest"
        echo ""
        echo "Once inside the container, test CUDA with:"
        echo "  test-cuda.sh                    # Comprehensive test including nvidia-smi and PyTorch"
        echo "  nvidia-smi                      # Basic GPU detection"
        echo "  python3 /usr/local/bin/test-cuda-installation.py  # Detailed CUDA/PyTorch test"
        return 0
    else
        print_error "Base container build failed!"
        return 1
    fi
}

# Function to build whisper example
build_whisper() {
    print_info "Building Whisper example container"
    
    # Check if base image exists
    if ! check_base_image; then
        print_warning "Base image 'fedora-cuda-base:latest' not found!"
        echo ""
        read -p "Would you like to build the base image first? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Building base image first..."
            if ! build_base; then
                print_error "Failed to build base image. Cannot proceed with whisper build."
                exit 1
            fi
            echo ""
        else
            print_error "Base image is required to build whisper example."
            print_info "Run './build.sh base' first, then './build.sh whisper'"
            exit 1
        fi
    fi

    # Build whisper container
    print_info "Building whisper container from examples/whisper/"
    podman build -f examples/whisper/Containerfile -t fedora-cuda-whisper:latest examples/whisper/

    if [ $? -eq 0 ]; then
        print_success "Whisper container built successfully!"
        echo ""
        print_info "To run whisper with GPU support:"
        echo ""
        echo "Basic usage:"
        echo "  podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \\"
        echo "    -it --rm fedora-cuda-whisper:latest \\"
        echo "    whisper /workspace/audio.wav --model medium"
        echo ""
        echo "With output format:"
        echo "  podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \\"
        echo "    -it --rm fedora-cuda-whisper:latest \\"
        echo "    whisper /workspace/audio.wav --model medium --output_format srt"
        echo ""
        echo "Interactive mode:"
        echo "  podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z \\"
        echo "    -it --rm fedora-cuda-whisper:latest /bin/bash"
        echo ""
        print_info "See examples/whisper/README.md for detailed usage instructions."
        return 0
    else
        print_error "Whisper container build failed!"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [TARGET]"
    echo ""
    echo "Available targets:"
    echo "  base     Build the base CUDA container (default)"
    echo "  whisper  Build the Whisper example container"
    echo ""
    echo "Examples:"
    echo "  $0           # Build base container"
    echo "  $0 base      # Build base container (explicit)"
    echo "  $0 whisper   # Build whisper example"
    echo ""
    echo "The whisper target will automatically build the base container if it doesn't exist."
}

# Main execution logic
case "$TARGET" in
    "base")
        build_base
        ;;
    "whisper")
        build_whisper
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        print_error "Unknown target: $TARGET"
        echo ""
        show_usage
        exit 1
        ;;
esac