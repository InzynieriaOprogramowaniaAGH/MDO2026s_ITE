FROM ubuntu:22.04

RUN apt update && apt install git -y

RUN git --version

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["/bin/bash"]