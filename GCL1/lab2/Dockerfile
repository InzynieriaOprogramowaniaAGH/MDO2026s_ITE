FROM ubuntu
RUN apt update && apt install git -y && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git .
CMD bash
