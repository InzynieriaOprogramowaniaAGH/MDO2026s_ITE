FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    zlib1g-dev \
    gzip \
    dpkg-dev && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /workspace