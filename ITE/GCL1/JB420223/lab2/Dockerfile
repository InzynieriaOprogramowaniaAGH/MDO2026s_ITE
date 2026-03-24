FROM ubuntu:22.04

RUN apt update && \
    apt install -y git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["/bin/bash"]
