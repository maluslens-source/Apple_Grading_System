# Lightweight Dockerfile for Apple_Grading_System
# Usage:
#  - Build (CPU):  docker build -t apple-grader .
#  - Run:           docker run --rm -v $(pwd)/models:/app/models -v $(pwd)/output:/app/output apple-grader python grade.py images/ --save
#
# If you need GPU support, build FROM an official PyTorch CUDA image instead of the default base
# (for example: `FROM pytorch/pytorch:2.2.0-cuda11.8-cudnn8-runtime`), then remove the CPU-only torch wheel
# installation below so pip installs the already-present GPU-enabled torch.

ARG BASE_IMAGE=python:3.11-slim
FROM ${BASE_IMAGE}

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies required by OpenCV, pillow-heif, and common runtime tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgl1 \
    libheif-dev \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install Python deps
COPY requirements.txt /app/

# Upgrade pip & install requirements. If you use a CUDA-enabled base image, consider
# removing torch & torchvision from requirements.txt and installing the matching CUDA
# wheels or using the preinstalled packages from the base image.
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . /app

# Create directories for mounting models and outputs
RUN mkdir -p /app/models /app/output /app/sample_images

# Expose the output and models directories as volumes so users can mount their models
VOLUME ["/app/models", "/app/output", "/app/sample_images"]

# Default entry: show help. Override CMD/ENTRYPOINT to run grading commands.
ENTRYPOINT ["python", "grade.py"]
CMD ["--help"]
