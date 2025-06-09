#!/bin/bash

echo "Building Fedora 39 CUDA 11.8 container base"
echo "This build uses RHEL8 CUDA repository for better compatibility."
echo ""

# Build the Podman image using Containerfile
podman build -f Containerfile -t fedora-cuda-base:latest .

if [ $? -eq 0 ]; then
    echo "✅ Container built successfully!"
    echo ""
    echo "To run the container with GPU support, use one of these methods:"
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
else
    echo "❌ Build failed!"
    exit 1
fi