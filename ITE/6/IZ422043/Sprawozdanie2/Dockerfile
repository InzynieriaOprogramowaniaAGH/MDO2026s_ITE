FROM ubuntu:latest

RUN apt update && \
    apt install -y git && \
    apt clean

WORKDIR /repo

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]