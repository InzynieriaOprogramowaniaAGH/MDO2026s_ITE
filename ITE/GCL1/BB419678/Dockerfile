#dockerfile lab2
FROM ubuntu:latest
#update i instalacja gita
RUN apt-get update && \
    apt-get install -y git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
#klonowanie repozytorium gitem
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]