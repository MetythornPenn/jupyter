# Use a widely available CUDA+cudnn runtime tag
# If you prefer CUDA 12.4, we can switch to a non-cudnn runtime,
# but cudnn9 tags may not be on Docker Hub yet.
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install Python and basic build tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 \
       python3-pip \
       python3-venv \
       ca-certificates \
       curl \
       tini \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Jupyter components
RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir \
       jupyterlab \
       jupyter_server \
       notebook

# Create a working directory inside the container
RUN mkdir -p /home/hacker/work

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8888

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/start.sh"]
