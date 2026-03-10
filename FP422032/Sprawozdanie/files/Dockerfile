FROM ubuntu:24.04
WORKDIR /sklonowane_repo
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .
CMD ["/bin/bash"]