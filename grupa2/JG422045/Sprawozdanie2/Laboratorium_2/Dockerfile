FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
	git \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /home/projekt
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE .

CMD ["/bin/bash"]
