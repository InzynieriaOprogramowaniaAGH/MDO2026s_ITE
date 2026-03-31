FROM ubuntu:22.04

RUN apt update && \
    apt install -y git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /repo_dir

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["bash"]
