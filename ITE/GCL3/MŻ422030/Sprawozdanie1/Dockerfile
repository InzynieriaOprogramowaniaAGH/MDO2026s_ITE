FROM ubuntu:22.04

RUN apt-get update && apt-get install -y git

WORKDIR /opt

ARG REPO="https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git"

RUN git clone "$REPO" repo || echo "nie dziala xd"

CMD ["/bin/bash"]