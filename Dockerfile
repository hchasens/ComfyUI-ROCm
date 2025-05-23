FROM rocm/dev-ubuntu-24.04

LABEL name="comfyui-rocm"
LABEL description="A ROCm ComfyUI container"
MAINTAINER ="Hunter Chasens <admin@hunterchasens.com>"

# Install dependencies and update system
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget git && \
    rm -rf /var/lib/apt/lists/*

# Install Miniforge (Conda)
RUN wget https://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-25.3.0-3-Linux-x86_64.sh && \
    bash Miniforge3-25.3.0-3-Linux-x86_64.sh -b -p /opt/miniforge3 && \
    rm Miniforge3-25.3.0-3-Linux-x86_64.sh

# Setup conda environment and PATH
ENV PATH="/opt/miniforge3/bin:$PATH"

# Clone ComfyUI repo
RUN git clone https://github.com/comfyanonymous/ComfyUI.git --depth=1 /root/ComfyUI

WORKDIR /root/ComfyUI

# Install PyTorch ROCm and requirements via pip
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.0 && \
    pip install -r requirements.txt

# Expose port
EXPOSE 8188

# Set bind IP environment variable
ENV BIND_IP=0.0.0.0
ENV PORT=8188

# Launch ComfyUI binding to 0.0.0.0 on port 8188
ENTRYPOINT ["sh", "-c", "python3 main.py --listen $BIND_IP --port $PORT \"$@\"", "--"]
CMD []
