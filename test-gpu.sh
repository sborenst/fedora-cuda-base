#!/bin/bash

echo "Testing GPU access in the Podman container..."
echo "============================================="

# Test with podman run
echo "Running CUDA test in container..."
podman run --device nvidia.com/gpu=all --rm fedora-cuda-base:latest test-cuda.sh

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ GPU test completed successfully!"
    echo "The container is ready for GPU-accelerated applications."
else
    echo ""
    echo "❌ GPU test failed. Please check:"
    echo "  1. NVIDIA drivers are installed"
    echo "  2. nvidia-container-toolkit is installed"
    echo "  3. CDI (Container Device Interface) is configured for Podman"
    echo "  4. Try alternative command: podman run --security-opt=label=disable --hooks-dir=/usr/share/containers/oci/hooks.d/ -it --rm fedora-cuda-base:latest"
fi