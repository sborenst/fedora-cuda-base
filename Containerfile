FROM fedora:39

# Set environment variables for CUDA
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV CUDA_VERSION=11.8

# Update system and install basic dependencies
RUN dnf update -y && \
    dnf install -y \
        wget \
        curl \
        git \
        python3 \
        python3-pip \
        python3-devel \
        gcc \
        gcc-c++ \
        make \
        cmake \
        which \
        findutils \
        dnf-plugins-core \
        && dnf clean all

# Add CUDA repo and install dependencies
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo -O /etc/yum.repos.d/cuda.repo && \
    dnf clean all && \
    dnf install -y --nogpgcheck \
        cuda-toolkit-11-8 \
        libnccl \
        libnccl-devel && \
    dnf clean all

# Set CUDA environment variables
ENV PATH=/usr/local/cuda-11.8/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:/usr/lib64:${LD_LIBRARY_PATH}
ENV CUDA_HOME=/usr/local/cuda-11.8

# Add PyTorch's cuDNN libraries to the library path after PyTorch installation
# This will be set in a later RUN command after pip install

# Install Python packages for GPU-accelerated applications
RUN pip3 install --upgrade pip && \
    pip3 install \
        torch==2.2.0+cu118 \
        torchaudio==2.2.0+cu118 \
        --index-url https://download.pytorch.org/whl/cu118 && \
    pip3 install \
        "numpy<2.0" \
        scipy \
        librosa \
        soundfile \
        ffmpeg-python

# Update LD_LIBRARY_PATH to include PyTorch's bundled cuDNN libraries
ENV LD_LIBRARY_PATH=/usr/local/lib/python3.12/site-packages/nvidia/cudnn/lib:/usr/local/cuda-11.8/lib64:/usr/lib64:${LD_LIBRARY_PATH}

# Create a working directory
WORKDIR /workspace

# Copy and install the comprehensive CUDA test script
COPY test-cuda-installation.py /usr/local/bin/test-cuda-installation.py
RUN chmod +x /usr/local/bin/test-cuda-installation.py

# Copy and install the comprehensive debug-cudnn.sh
COPY debug-cudnn.sh /usr/local/bin/debug-cudnn.sh
RUN chmod +x /usr/local/bin/debug-cudnn.sh

# Create a simple test script to verify CUDA installation
RUN echo '#!/bin/bash' > /usr/local/bin/test-cuda.sh && \
    echo 'echo "Testing NVIDIA GPU access..."' >> /usr/local/bin/test-cuda.sh && \
    echo 'nvidia-smi' >> /usr/local/bin/test-cuda.sh && \
    echo 'echo ""' >> /usr/local/bin/test-cuda.sh && \
    echo 'echo "Running comprehensive CUDA test..."' >> /usr/local/bin/test-cuda.sh && \
    echo 'python3 /usr/local/bin/test-cuda-installation.py' >> /usr/local/bin/test-cuda.sh && \
    chmod +x /usr/local/bin/test-cuda.sh

# Set default command
CMD ["/bin/bash"]