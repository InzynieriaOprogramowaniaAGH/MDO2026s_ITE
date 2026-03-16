# Sprawozdanie 1

## Class 01

### Wstęp

Na wstępie sklonowanao repozytorium przedmiotu. Przełączono się na gałąź grupy, następnie do odpowiedniego kalaogu, gdzie stworzono gałąź o nazwie składającej się z inicjałów i numeru indeksu: ```MŁ420124```. Na gałęźi stworzono katalog odpowiadający nazwie gałęzi.

```bash
git fetch 
git checkout GLC3
cd ITE/GLC3
git checkout -b MŁ420124
mkdir MŁ420124
```

### Treść githooka weryfikującego commit message

```python
#!/usr/bin/env python3

import sys

commit_msg_filepath = sys.argv[1]
required_prefix = 'MŁ42012'

with open(commit_msg_filepath, 'r') as f:
    content = f.readline().strip()

if not content.startswith(required_prefix):
    print(f"ERROR! The commit message must start with prefix {required_prefix}")
    sys.exit(1)
```

### Nadanie hookowi działania

```bash
chmod +x prepare-commit-msg.py
cp ITE/GCL3/MŁ420124/prepare-commit-msg.py .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

### Weryfikacja działania hooka

![Zdjęcie 1](img/s1.png)

## Class 02

Docker to platforma zaprojektowana w celu upraszczania procesu tworzenia, dostarczania i uruchamiania aplikacji. Usprawnia dostarczanie oprogramowania poprzez konteneryzację, czyli technologię pakującą aplikację bądź jej zależności w odizolowane, uruchamialne jednostki zwane kontenerami. Rozwiązuje to problem polegający na tym, że gdy jedna z aplikacji przestanie działać, nie „zaraża” ona innych aplikacji. Jednocześnie redukuje koszty związane z izolacją, ponieważ eliminuje konieczność ponoszenia pełnego narzutu zasobów charakterystycznego dla pojedynczych maszyn wirtualnych (jądro, sterowniki, programy i aplikacje).

Obray kontenera to pakiery zawierające wszystkie pliki, pliki binarne, biblioteki oraz konfiguracje do uruchomienia kontenera. Obrazy kontenerów składają się z warstw: każda warstwa reprezentuje zestaw zmian systemu plików. Obrazy do uruchomienia lokalnie można znaleźć na Docker Hub.

### Pobieranie i uruchamianie obrazów

W celu uruchomienia aplikacji w Dockerze najpierw pobierany jest odpowiedni obraz przy użyciu polecenia ```docker pull```. Na podstawie pobranego obrazu tworzony i uruchamiany jest kontener za pomocą polecenia ```docker run```.

![Zdjęcie 2](img/s2.png)

### Przykładowy wynik uruchomienia obrazu ```hello-world```

Polecenie ```docker run hello-world``` powoduje utworzenie oraz uruchomienie kontenera na podstawie obrazu ```hello-world```.

![Zdjęcie 3](img/s3.png)

### Uruchomienie kontenera z obrazu ```busybox``` oraz wywołanie numeru sesji

![Zdjęcie 4](img/s4.png)

### Uruchomienie systemu w kontenerze

![Zdjęcie 5](img/s5.png)

### Stworzenie i uruchomienie pliku ```Dockerfile``` klonującego repozytorium przedmiotowe

```dockerfile
FROM ubuntu:22.04

RUN apt update && \
    apt install -y git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /repo_dir

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["bash"]
```

![Zdjęcie 6](img/s6.png)

### Lista uruchomionych kontenerów

![Zdjęcie 7](img/s7.png)

### Wyczyszczenie wszystkich obrazów, które nie są używane przez kontenery

![Zdjęcie 8](img/s8.png)