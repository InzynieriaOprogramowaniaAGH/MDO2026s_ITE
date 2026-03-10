FROM ubuntu:latest

# aktualizacja i instalacja gita
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# katalog roboczy
WORKDIR /app

# klonowanie repa
RUN git clone -b MK421268 https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git .

#uruchomienie basha
CMD ["bash"]