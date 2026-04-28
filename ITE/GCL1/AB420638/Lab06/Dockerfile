FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# usuwanie cache na koniec
RUN apt-get update && \
    apt-get install -y xz-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

CMD ["xz", "--help"]