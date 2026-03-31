FROM ubuntu:22.04

RUN apt update && apt install -y python3 python3-pip

WORKDIR /app

RUN --mount=type=bind,source=.,target=/src \
    pip install /src