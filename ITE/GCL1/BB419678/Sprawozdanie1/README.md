# Sprawozdanie 1

Bartosz Bodulski, grupa 1, Tematy 1 - 4

## Temat 1

Cel zajęć - przygotowanie stanowiska pracy do dalszych zajęć.

Przygotowanie odpowiednich narzędzi:

```bash
sudo apt install git openssh -y;
ssh-keygen -t ed25519;
# dodatkowo opcja -c dla ssh-keygen powiązuje klucz z podanym adresem email
```

Klonowanie repozytorium:

```bash
git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git #https
git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git #ssh
```

Wymiana plików między klientem a serwerem odbywa się za pomocą oprogramowania FileZilla. Połączenie polega na podaniu nazwy użytkownika na serwerze z jego adresem IPv4. Wymiana pilków realizowana jest protokołem SFTP za pomocą wcześniej utworzonych kluczy.

Przejście do odpowiednich branch'y:

![img1](../screenshots/Zrzut%20ekranu%202026-03-06%20173954.png)

Utworzenie nowej gałęzi:

```bash
git checkout -b BB419678;
```

Stworzenie nowego folderu:

```bash
mkdir BB419678; cd BB419678;
```

![img3](../screenshots/Zrzut%20ekranu%202026-03-06%20092930.png)

Utworzenie hook'a:

```bash
code ~/MDO2026s_ITE/.git/hooks/commit-msg;
```

![img4](../screenshots/Zrzut%20ekranu%202026-03-06%20091316.png)

```bash
chmod +x ~/MDO2026s_ITE/.git/hooks/commit-msg;
```

Testowanie hook'a dla git'a:

![img4](../screenshots/Zrzut%20ekranu%202026-03-06%20165005.png)

Próba wciągnięcią gałęzi do grupowej:

![img4](../screenshots/Zrzut%20ekranu%202026-03-06%20172309.png)

Jak widać, bez odpowiedniego formatu "commit message", nie jesteśmy w stanie spushować zmian na nasz branch w repozytorium.

## Temat 2

Cel zajęć: zestawienie środowiska skonteneryzowanego do dalszych ćwiczeń.

Instalacja środowiska docker:

Instalujemy dockera za pomocą repozytorium dystrybucji ubuntu server.

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker
```

![img5](../screenshots/Zrzut%20ekranu%202026-03-13%20081912.png)

Żeby nie pisać cały czas sudo docker ... możemy dodać siebie do specjalnej grupy docker:

![img6](../screenshots/Zrzut%20ekranu%202026-03-13%20082126.png)

Dodatkowo musimy się zalogować:

![img7](../screenshots/Zrzut%20ekranu%202026-03-13%20090233.png)

Po zalogowaniu normalnie przechodzimy do testowania kilku przykładowych obrazów.

hello-world:

![img8](../screenshots/Zrzut%20ekranu%202026-03-13%20083608.png)

Wygląda na to, że wszystko zostało poprawnie zainstalowane.

busybox:

![img9](../screenshots/Zrzut%20ekranu%202026-03-13%20084152.png)

mariadb:
![img](../screenshots/Zrzut%20ekranu%202026-03-13%20090019.png)

ubuntu:

![img](../screenshots/Zrzut%20ekranu%202026-03-13%20082418.png)

busybox interaktywnie:

![img](../screenshots/Zrzut%20ekranu%202026-03-13%20092545.png)

ubuntu interaktywnie:

![img](../screenshots/Zrzut%20ekranu%202026-03-13%20085616.png)

Dockerfile:

```Dockerfile
#dockerfile lab2
FROM ubuntu:latest
#update i instalacja gita
RUN apt-get update && \
    apt-get install -y git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
#klonowanie repozytorium gitem
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]
```

Budowanie obrazu za pomocą powyższego dockerfile:

![img](../screenshots/Zrzut%20ekranu%202026-03-13%20092021.png)

Sprawdzenie działania:

![img](../screenshots/Zrzut%20ekranu%202026-03-13%20092215.png)

Czyszczenie obrazów i kontenerów:

![img](../screenshots/Zrzut%20ekranu%202026-03-13%20092459.png)

(Dockerfile znajduje się w folderze Dockerfile_lab2).

## Temat 3

Cel zajęć: zbudowanie oprogramowania w taki sposób, aby proces był przenośny między ustrojami.

Na początku musiałem wybrać oprogramowanie, które spełnia wszystkie wymagania podane w instrukcji. Mój wybór padł na neovim, ponieważ projekt posiada licencje apache 2.0, używa make do budowania (make install) oraz do testów jednostkowych (make unittest).

Ręczna instalacja na serwerze:

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20183500.png)

Testy jednostkowe na serwerze:

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20183601.png)

Budowanie oprogramowania na kontenerze:

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20183807.png)

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20184141.png)

testy jednostkowe na kontenerze:

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20184252.png)
Należy zauważyć, że tutaj oprogramowanie nie przechodzi 6 testów jednstkowych pomimo zainstalowania zależności - odnoszą się do zmiennej $HOME - jest to logiczne, gdyż zmienna ta inaczej sie zachowuje w kontenerze.
![img](../screenshots/Zrzut%20ekranu%202026-03-26%20184416.png)

Następnie tworze dwa Dockerfile - 1 do budowania neovima, drugi do testowania.

```Dockerfile
#obraz

FROM ubuntu:24.04

#uproszczenie instalacji

ENV DEBIAN_FRONTEND=noninteractive

#zależności

RUN apt-get update && apt-get install -y \
    ninja-build gettext cmake unzip curl git build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

#klonowanie i budowanie projektu

RUN git clone https://github.com/neovim/neovim.git .

RUN make CMAKE_BUILD_TYPE=RelWithDebInfo

CMD ["/bin/bash"]

```

Budowanie na kontenerze za pomocą dockefile'a

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20184959.png)

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20185327.png)

Dockerfile do testowania:

```Dockerfile

# z zbudowanego obrazu

FROM neovim-build:latest

WORKDIR /workspace

#wykonaj testy za pomocą make

CMD ["make", "unittest"]
```

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20185759.png)

Dostajemy podobne wyniki - testy związane z zmienną $HOME nie przechodzą, reszta tak.

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20190209.png)

### Docker compose

Czynności te można zautomatyzować za pomocą narzędzia docker-compose. Portzebny jest nam plik docker-compose.yaml:

```yaml
version: '3.8'

services:
  # budowanie kodu
  builder:
    build:
      context: .
      dockerfile: Dockerfile.nvim.build
    image: neovim-build:latest
    # kontener w trybie "idle"
    command: tail -f /dev/null

  # urachamianie testów
  tester:
    build:
      context: .
      dockerfile: Dockerfile.nvim.test
    depends_on:
      - builder
```

Budowanie wszystkiego za pomocą docker-compose

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20190308.png)

Wykonanie testów

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20190554.png)

końcowe obrazy

![img](../screenshots/Zrzut%20ekranu%202026-03-26%20190406.png)

Dyskusja:

- Czy publikować jako kontener, czy tylko do builda?

Tylko do builda. Docker służy do izolacji, a edytor tekstu wymaga integracji. Uruchomiony w kontenerze Neovim nie będzie widział plików na dysku, schowka systemowego ani lokalnych narzędzi (np. LSP).

- Czy trzeba oczyszczać z pozostałości? (Jeden czy dwa Dockerfiles?)

Trzeba, bo kompilatory ważą gigabajty. Nie używamy osobnych Dockerfiles. Stosuje się tzw. Multi-stage builds. W jednym pliku mamy etap builder (ciężki, z kompilatorami), a na końcu lekki etap docelowy, do którego tylko kopiujemy gotowy plik binarny.

- Format dystrybucji (Artefakt)

Dla programów w C/C++ (jak Neovim) używa się:

Tarball (.tar.gz) - uniwersalne archiwum (Neovim domyślnie to wspiera).

AppImage - jeden plik wykonywalny ze wszystkim w środku (oficjalny sposób dystrybucji Neovima).

DEB / RPM - paczki instalacyjne dla Linuxa.

- Jak zapewnić ten format i wyciągnąć go z kontenera?

Budujemy program i pakujemy go (np. do .tar.gz) wewnątrz kontenera, a potem używamy funkcji Docker BuildKit, żeby zrzucić samą paczkę na swój dysk, odrzucając kontener.

przykład:

```Dockerfile
# Budowanie paczki
FROM ubuntu AS builder
RUN apt install -y cmake ninja-build gettext gcc # ... itd
WORKDIR /src
RUN make CMAKE_BUILD_TYPE=Release package # Tworzy nvim.tar.gz

# Wyciągnięcie pliku na zewnątrz
FROM scratch AS exporter
COPY --from=builder /src/build/nvim.tar.gz /
```

```bash
docker build --target exporter --output type=local,dest=./out .
```

Efekt: Kompilator działa w sterylnym kontenerze, a na koniec gotowa paczka nvim.tar.gz magicznie pojawia się w folderze ./out na komputerze bez śmieciowych obrazów Dockera.

## Temat 4