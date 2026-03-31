# FROM - Określa obraz bazowy (nowoczesne wydanie LTS Ubuntu)
FROM ubuntu:24.04

# RUN - Wykonuje polecenia podczas budowania warstwy. 
# Zgrupowanie poleceń update i install w jednej linijce to dobra praktyka oszczędzająca ilość warstw obrazu.
RUN apt-get update && apt-get install -y git

# WORKDIR - Ustawia katalog roboczy dla kolejnych instrukcji w kontenerze
WORKDIR /app

# RUN - Sklonowanie repozytorium przedmiotowego do katalogu roboczego
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

# CMD - Definiuje domyślny proces (powłokę), który zostanie uruchomiony po starcie kontenera
CMD ["bash"]