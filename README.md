# Fedora 39 CUDA Base Container (Podman)

This container is based on Fedora 39 and includes CUDA support for running GPU-accelerated applications using Podman. It serves as a base image for GPU-enabled deployments.

## Prerequisites

- Podman installed on your system
- NVIDIA GPU with compatible drivers
- nvidia-container-toolkit installed
- CDI (Container Device Interface) configured for GPU access

### Installing Prerequisites

#### Install Podman
```bash
# For Fedora/RHEL/CentOS
sudo dnf install -y podman podman-compose

# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y podman podman-compose
```

#### Install NVIDIA Container Toolkit
```bash
# For RHEL/CentOS/Fedora
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
sudo dnf install -y nvidia-container-toolkit

# For Ubuntu/Debian
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
   && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

#### Configure CDI for Podman
```bash
# Generate CDI specification
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# Verify CDI configuration
podman run --device nvidia.com/gpu=all --rm registry.access.redhat.com/ubi9/ubi:latest nvidia-smi
```

## Building the Container

Make the build script executable and run it:

```bash
chmod +x build.sh
./build.sh
```

## Running the Container

### Option 1: Using podman-compose (Recommended)

```bash
# Start the container in detached mode
podman-compose up -d

# Access the container
podman-compose exec cuda-base /bin/bash

# Stop the container when done
podman-compose down
```

### Option 2: Using podman run directly

```bash
# Method 1: Using CDI (recommended)
podman run --device nvidia.com/gpu=all -it --rm fedora-cuda-base:latest

# Method 2: Using hooks (alternative)
podman run --security-opt=label=disable --hooks-dir=/usr/share/containers/oci/hooks.d/ -it --rm fedora-cuda-base:latest
```

### Option 3: Interactive session with workspace mount

```bash
podman run --device nvidia.com/gpu=all -v ./workspace:/workspace:Z -it --rm fedora-cuda-base:latest
```

## Testing CUDA Installation

Once inside the container, test that CUDA is working:

```bash
# Test NVIDIA GPU access
nvidia-smi

# Run the comprehensive CUDA test (includes nvidia-smi + PyTorch tests)
test-cuda.sh

# Run detailed CUDA/PyTorch test only
python3 /usr/local/bin/test-cuda-installation.py

# Quick CUDA check with Python
python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA devices: {torch.cuda.device_count()}')"
```

You can also test from the host system:

```bash
chmod +x test-gpu.sh
./test-gpu.sh
```

## What's Included

- Fedora 39 base image
- CUDA Toolkit 11.8
- NCCL libraries for multi-GPU support
- Python 3 with pip
- PyTorch 2.2.0 with CUDA 11.8 support (includes bundled cuDNN 8)
- Development tools (gcc, cmake, etc.)
- Audio processing libraries (librosa, soundfile, ffmpeg-python)
- Debug script for cuDNN troubleshooting (`debug-cudnn.sh`)

## GPU Base Container

This container serves as a base for GPU-accelerated applications. It includes all necessary CUDA libraries and PyTorch for machine learning workloads.

## Workspace

The container includes a `/workspace` directory that's mapped to `./workspace` on your host system for easy file sharing.

## Troubleshooting

If you encounter GPU access issues:

1. **Verify NVIDIA drivers**: `nvidia-smi`
2. **Check CDI configuration**: `podman run --device nvidia.com/gpu=all --rm registry.access.redhat.com/ubi9/ubi:latest nvidia-smi`
3. **Regenerate CDI**: `sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml`
4. **Try alternative method**: Use the hooks-based approach in the run commands above
5. **Check SELinux**: If using SELinux, you may need `--security-opt=label=disable`

### Common Issues

- **Permission denied**: Make sure your user is in the `podman` group or run with appropriate privileges
- **CDI not found**: Ensure nvidia-container-toolkit is installed and CDI is generated
- **GPU not accessible**: Try the alternative hook-based method or check SELinux settings
- **CUDA package installation fails**: The container now uses RHEL8 CUDA repository with `--nogpgcheck` flag for better compatibility
- **dnf repository issues**: If you encounter GPG key issues, the `--nogpgcheck` flag should resolve them
- **CUDA version mismatch**: The container uses CUDA 11.8 with compatible PyTorch 2.2.0 for stability
- **cuDNN library not found**: PyTorch 2.2.0 includes bundled cuDNN 8 libraries. The container uses PyTorch's cuDNN instead of system cuDNN to avoid version conflicts. Use the included `debug-cudnn.sh` script for troubleshooting cuDNN issues

## Files Structure

- `Containerfile` - Container build definition
- `podman-compose.yml` - Podman compose configuration
- `build.sh` - Build script
- `test-gpu.sh` - GPU test script
- `workspace/` - Shared workspace directory