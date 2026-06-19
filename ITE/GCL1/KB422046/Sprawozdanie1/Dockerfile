FROM ubuntu:latest

RUN apt update && apt install -y git

WORKDIR /repository

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["/bin/bash"]