FROM ubuntu:latest

# katalog roboczy
WORKDIR /app

# aktualizacja i instalacja gita i czyszczenie śmieci apt
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# klonowanie repozytorium z GitHub
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

# domyslna komenda po uruchomieniu kontenera
CMD ["bash"]