# Sprawozdanie 1

## Class 01

### Wstęp

`Git` to darmowy i otwarty rozproszony system kontroli wersji, zaprojektowany z myślą o szybkim i wydajnym zarządzaniu projektami od małych do bardzo dużych. Jednym z narzędzi Gita jest gałąź (branch). `Branch` jest przestrzenią roboczą, w której możesz wprowadzać zmiany i testować nowe pomysły bez wpływu na projekt główny. 

Na wstępie sklonowane zostało repozytorium przedmiotu. Przełączono się na gałąź grupy, następnie do odpowiedniego kalaogu, gdzie stworzono gałąź o nazwie składającej się z inicjałów i numeru indeksu: `MŁ420124`. Na gałęźi stworzono katalog odpowiadający nazwie gałęzi.

```bash
git fetch 
git checkout GLC3
cd ITE/GLC3
git checkout -b MŁ420124
mkdir MŁ420124
```

### Treść githooka weryfikującego commit message

`Git` umożliwia uruchamianie niestandardowych skryptów w przypadku wystąpienia określonych ważnych działań. Istnieją dwie grupy Hooków: po stronie klienta i po stronie serwera. `Hooki` po stronie klienta są aktywowane przez operacje takie jak zatwierdzanie i scalanie, natomiast Hooki po stronie serwera działają w przypadku operacji sieciowych, takich jak odbieranie przesłanych zatwierdzeń.

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

W celu uruchomienia aplikacji w Dockerze najpierw pobierany jest odpowiedni obraz przy użyciu polecenia `docker pull`. Na podstawie pobranego obrazu tworzony i uruchamiany jest kontener za pomocą polecenia ```docker run```.

![Zdjęcie 2](img/s2.png)

### Przykładowy wynik uruchomienia obrazu `hello-world`

Polecenie `docker run hello-world` powoduje utworzenie oraz uruchomienie kontenera na podstawie obrazu `hello-world`.

![Zdjęcie 3](img/s3.png)

### Uruchomienie kontenera z obrazu `busybox` oraz wywołanie numeru sesji

Obraz `busybox` zawiera minimalistyczny zestaw narzędzi systemowych wykorzystywanych w systemach uniksowych.

![Zdjęcie 4](img/s4.png)

### Uruchomienie systemu w kontenerze

![Zdjęcie 5](img/s5.png)

### Stworzenie i uruchomienie pliku `Dockerfile` klonującego repozytorium przedmiotowe

Docker umożliwia uruchomienie pełnego środowiska systemowego wewnątrz kontenera na podstawie wybranego obrazu systemowego. Dzięki temu użytkownik może pracować w odizolowanym środowisku przypominającym standardową powłokę systemu operacyjnego. `Dockerfile` to dokument tekstowy zawierający wszystkie polecenia, które użytkownik może wywołać w wierszu poleceń, aby utworzyć obraz.

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

Docker umożliwia wyświetlenie listy aktualnie działających kontenerów za pomocą polecenia: `docker ps -a`. Informacje wyświetlane w terminalu zawierają między innymi informacje o: identyfikatorze kontenera, użytym obrazie, czasie działania oraz przypisanym portom.

![Zdjęcie 7](img/s7.png)

### Wyczyszczenie wszystkich obrazów, które nie są używane przez kontenery

W celu zwolnienia przestrzeni dyskowej możliwe jest usunięcie nieużywanych obrazów Docker. Polecenie: `docker image prune -a`.

![Zdjęcie 8](img/s8.png)

## Class 03

W trakcie zajęć tematem było przygotowanie środowiska buildowe aplikacji z wykorzystaniem konteneryzacji. W tym celu wykorzystano Dockera w celu jednokrotnego uruchamiania aplikacji w wyizolowanym środowisku i wyciągnięcia rezultatu. Proces miał zostać zdefiniowany w pliku `Dockerfile`.

Do realizacji zadania wybrano przykładowy opensourceowy projekt napisany w technologii `.NET`:

https://github.com/Devskiller/devskiller-sample-dotnetcore.git

Do realizacji zadania przygotowano dwa pliki `Dockerfile`: jeden odpowiad za przygotowanie środowiska i zbudowanie aplikacji, a drugi za uruchamianie testów, bazując na obrazie stworzonym przez pierwszy.

### Przygotowanie środowiska i zbudowanie aplikacji

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0

RUN apt-get update && apt-get install -y git
WORKDIR /App

RUN git clone https://github.com/Devskiller/devskiller-sample-dotnetcore.git

WORKDIR /App/devskiller-sample-dotnetcore

RUN dotnet restore
RUN dotnet build
```

### Uruchomienie testów

```dockerfile
FROM devskillerbld:latest

WORKDIR /App/devskiller-sample-dotnetcore

RUN dotnet test
```

Wewnątrz kontenera pracuje proces, który uruchomiony jest na podstawie obrazu kontenera. Celem jest wyizolowanie środowiska, które za każdym razem będzie dawać identyczny efekt builda.

```bash
sudo docker build -t devskillerbld -f ./Dockerfile.devskiller.bld .
```

Pierwszy obraz zbudował się bez żadnych problemów, dotnet zwrócił w konsoli tekst:

```bash
Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:04.85
 ---> Removed intermediate container e4c46affd6a0
 ---> d8b5a7c6f24b
Successfully built d8b5a7c6f24b
Successfully tagged devskillerbld:latest
```

Obraz jest widoczny po wpisaniu `docker images`.

![Zdjęcie 9](img/s9.png)

Podczas budowania drugiego obrazu proces został przerwany, ponieważ polecenie `dotnet test` zwróciło kod wyjścia 1. W rezultacie obraz nie otrzymał zdefiniowanego taga i pojawił się w systemie jako obraz typu `none`. Testy w repozytorium zostały napisane tak, aby nie przechodzić poprawnie.

![Zdjęcie 10](img/s10.png)