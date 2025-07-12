FROM python:3.11-slim

# Set environment variables for optimization
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PATH="/root/.local/bin:$PATH"
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /workspace

# Install system dependencies in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    libhdf5-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Upgrade pip and install uv
RUN pip install --no-cache-dir --upgrade pip uv

# Install STATE model
RUN uv tool install arc-state

# Install PyTorch (works for both CPU and GPU)
RUN pip install --no-cache-dir \
    torch==2.1.0 \
    torchvision==0.16.0 \
    torchaudio==2.1.0 \
    --index-url https://download.pytorch.org/whl/cpu

# Install core single-cell analysis packages
RUN pip install --no-cache-dir \
    scanpy==1.9.6 \
    anndata==0.10.3 \
    pandas==2.1.4 \
    numpy==1.24.4 \
    scipy==1.11.4 \
    scikit-learn==1.3.2 \
    matplotlib==3.8.2 \
    seaborn \
    h5py==3.10.0 \
    tables==3.9.2 \
    lightning==2.1.3

# Install Jupyter and utilities
RUN pip install --no-cache-dir \
    jupyter==1.0.0 \
    jupyterlab==4.0.9 \
    tqdm==4.66.1 \
    click==8.1.7 \
    pyyaml==6.0.1 \
    toml==0.10.2

# Clean up to reduce image size
RUN find /usr/local -name "*.pyc" -delete \
    && find /usr/local -name "__pycache__" -delete \
    && find /usr/local -name "*.pyo" -delete

# Create directory structure
RUN mkdir -p /workspace/{data,models,notebooks,scripts,results,checkpoints}

# Expose Jupyter port
EXPOSE 8888

# Set working directory
WORKDIR /workspace

