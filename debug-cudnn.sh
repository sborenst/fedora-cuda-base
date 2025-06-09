#!/bin/bash

echo "=== cuDNN Debug Script ==="
echo "Checking cuDNN installation and library paths..."
echo ""

echo "1. Checking installed cuDNN packages:"
dnf list installed | grep -i cudnn || echo "No cuDNN packages found via dnf"
echo ""

echo "2. Searching for cuDNN libraries in common locations:"
find /usr -name "*cudnn*" 2>/dev/null || echo "No cuDNN files found in /usr"
find /usr/local -name "*cudnn*" 2>/dev/null || echo "No cuDNN files found in /usr/local"
find /opt -name "*cudnn*" 2>/dev/null || echo "No cuDNN files found in /opt"
echo ""

echo "3. Checking for libcudnn.so.8 specifically:"
find / -name "libcudnn.so.8*" 2>/dev/null || echo "libcudnn.so.8 not found"
echo ""

echo "4. Checking for any libcudnn files:"
find / -name "libcudnn*" 2>/dev/null || echo "No libcudnn files found"
echo ""

echo "5. Current LD_LIBRARY_PATH:"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo ""

echo "6. Checking CUDA installation paths:"
ls -la /usr/local/cuda* 2>/dev/null || echo "No /usr/local/cuda* directories"
ls -la /usr/lib64/cuda* 2>/dev/null || echo "No /usr/lib64/cuda* directories"
echo ""

echo "7. Available CUDA repositories:"
dnf repolist | grep -i cuda
echo ""

echo "8. Available cuDNN packages in repository:"
dnf search cudnn 2>/dev/null || echo "No cuDNN packages available in repositories"
echo ""

echo "9. PyTorch CUDA detection:"
python3 -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA compiled version: {torch.version.cuda}')
print(f'CUDA runtime version: {torch.version.cuda}')
try:
    print(f'CUDA available: {torch.cuda.is_available()}')
except Exception as e:
    print(f'CUDA check failed: {e}')
"