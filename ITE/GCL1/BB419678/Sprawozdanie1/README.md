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

Wymiana plików między klientem a serwerem odbywa się za pomocą oprogramowania FileZilla. Połączenie polega na podaniu nazwy użytkownika na serwerze z jego adresem IPv4 lub nazwą maszyny. Wymiana pilków realizowana jest protokołem SFTP za pomocą wcześniej utworzonych kluczy.

Przejście do odpowiednich branch'y:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-06%20173954.png)

Utworzenie nowej gałęzi:

```bash
git checkout -b BB419678;
```

Stworzenie nowego folderu:

```bash
mkdir BB419678; cd BB419678;
```

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-06%20092930.png)

Utworzenie hook'a:

```bash
code ~/MDO2026s_ITE/.git/hooks/commit-msg;
```

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-06%20091316.png)

```bash
chmod +x ~/MDO2026s_ITE/.git/hooks/commit-msg;
```

Testowanie hook'a dla git'a:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-06%20165005.png)

Jak widać, bez odpowiedniego formatu "commit message", nie jesteśmy w stanie spushować zmian na nasz branch w repozytorium.


Próba wciągnięcią gałęzi do grupowej:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-06%20172309.png)


## Temat 2

Cel zajęć: zestawienie środowiska skonteneryzowanego do dalszych ćwiczeń.

Instalacja środowiska docker:

Instalujemy dockera za pomocą repozytorium dystrybucji ubuntu server.

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker
```

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20081912.png)

Żeby nie pisać cały czas sudo docker ... możemy dodać siebie do specjalnej grupy docker:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20082126.png)

Dodatkowo musimy się zalogować:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20090233.png)

Po zalogowaniu normalnie przechodzimy do testowania kilku przykładowych obrazów.

hello-world:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20083608.png)

Wygląda na to, że wszystko zostało poprawnie zainstalowane.

busybox:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20084152.png)

mariadb:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20090019.png)

ubuntu:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20082418.png)

busybox interaktywnie - pokazanie wersji jądra linuxa:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20092545.png)

ubuntu interaktywnie:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20085616.png)

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

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20092021.png)

Sprawdzenie działania kontenera lab2:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20092215.png)

Czyszczenie pozostałych obrazów i kontenerów:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-13%20092459.png)

(Dockerfile znajduje się w folderze Dockerfile_lab2).

## Temat 3

Cel zajęć: zbudowanie oprogramowania w taki sposób, aby proces był przenośny między ustrojami.

Na początku musiałem wybrać oprogramowanie, które spełnia wszystkie wymagania podane w instrukcji. Mój wybór padł na neovim, ponieważ projekt posiada licencje apache 2.0, używa make do budowania (make install) oraz do testów jednostkowych (make unittest).

Ręczna instalacja na serwerze:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20183500.png)

Testy jednostkowe na serwerze:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20183601.png)

Budowanie oprogramowania na kontenerze:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20183807.png)

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20184141.png)

Testy jednostkowe na kontenerze:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20184252.png)

Należy zauważyć, że tutaj oprogramowanie nie przechodzi 6 testów jednstkowych pomimo zainstalowania zależności. Testty te odnoszą się do zmiennej środowiskowej $HOME. Wyniki te mają sens, gdyż zmienna ta inaczej się zachowuje w kontenerze.

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20184416.png)

Następnie tworze dwa pliki Dockerfile - jeden do budowania neovima, drugi do testowania.

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

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20184959.png)

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20185327.png)

Dockerfile do testowania:

```Dockerfile
# z zbudowanego obrazu

FROM neovim-build:latest

WORKDIR /workspace

#wykonaj testy za pomocą make

CMD ["make", "unittest"]
```

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20185759.png)

Dostajemy podobne wyniki - testy związane z zmienną $HOME nie przechodzą, reszta tak.

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20190209.png)

### Docker compose

Czynności te (budowanie/testowanie) można zautomatyzować za pomocą narzędzia docker-compose. Portzebny jest nam plik docker-compose.yaml:

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

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20190308.png)

Wykonanie testów za pomocą docker-compose:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20190554.png)

Końcowe obrazy:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-26%20190406.png)


- Czy publikować jako kontener, czy tylko do builda?

Tylko do builda. Docker służy do izolacji, a edytor tekstu wymaga integracji. Uruchomiony w kontenerze Neovim nie będzie widział plików na dysku, schowka systemowego ani lokalnych narzędzi (np. LSP).

- Czy trzeba oczyszczać z pozostałości? (Jeden czy dwa Dockerfiles?)

Trzeba, bo kompilatory / systemy budowania ważą gigabajty. Nie używamy osobnych Dockerfiles. Stosuje się tzw. Multi-stage builds. W jednym pliku mamy etap builder (ciężki, z kompilatorami), a na końcu lekki etap docelowy, do którego tylko kopiujemy gotowy plik binarny.

- Format dystrybucji (Artefakt)

Dla programów w C/C++ (jak np. Neovim) używa się:

Tarball (.tar.gz) - uniwersalne archiwum (Neovim domyślnie to wspiera).

AppImage - jeden plik wykonywalny ze wszystkim w środku (oficjalny sposób dystrybucji Neovima).

DEB / RPM - paczki instalacyjne dla Linuxa.

- Jak zapewnić ten format i wyciągnąć go z kontenera?

Budujemy program i pakujemy go (np. do .tar.gz) wewnątrz kontenera, a potem używamy funkcji Docker BuildKit, żeby zrzucić samą paczkę na swój dysk, odrzucając kontener.

Przykład:

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

Efekt: Kompilator działa w izolowanym kontenerze, a na koniec gotowa paczka nvim.tar.gz magicznie pojawia się w folderze ./out na komputerze bez śmieciowych obrazów Dockera.

## Temat 4

### Zachowywanie stanu między kontenerami

Cel zajęć - uruchomienie instancji oprogramowania jenkins w środowisku skonteneryzowanym na podstawie dodatkowej wiedzy o interakcjach między kontenerami.

Na początku przygotowuje woluminy, jeden wejsciowy, drugi wyjsciowy, aby podzielić procedurę testowania oprogramowania na dwa różne kontenery:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20085057.png)

Pierwszy kontener pobiera gita z repozytorium alpine i sciąga projekt oprogramowania, drugi pobiera zależności tego projektu i powiązuje je z pierwszym woluminem:

```Dockerfile
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# zależności neovim bez gita

RUN apt-get update && apt-get install -y \
    ninja-build gettext cmake unzip curl build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["/bin/bash"]
```
Budowanie drugiego konterera:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20085617.png)

Budowanie projektu i testy jednostkowe:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20085828.png)


![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20085901.png)


![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090039.png)

Następnie instaluje gita na drugim kontenerze i powtarzam te same czynności:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090118.png)


![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090321.png)


![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090358.png)

Użycie alpine/git jako kontenera pomocniczego z podpiętym woluminem to dobra praktyka. Pozwala pobrać kod bez zaśmiecania kontenera budującego narzędziami, których nie potrzebuje on do samego kompilowania. Realizuje to zasadę separacji obowiązków.

Zamiast montować woluminy przy docker run, w Dockerfile (korzystając z BuildKit) można użyć:
```Dockerfile
RUN --mount=type=bind,source=.,target=/kod
```
aby uzyskać dostęp do plików hosta tylko na czas budowania bez ich trwałego kopiowania (zmniejsza to wagę ostatecznego obrazu), lub type=cache np. do cachowania pobieranych pakietów przez apt/narzędzia budujące.

### Eksponowanie portu i łączność między kontenerami

Na początku tworzę serwer i klienta iperf3 w mojej lokalnej sieci LAN i testuje przepustowość łącza. Jak widać kontener ```serwer-iperf``` ma własny adres IPv4, który służy do komunikacji między hostem, serwerem i innymi kontenerami.

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090521.png)

Otrzymujemy przepustowość na poziomie 31 Gbit/s:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090547.png)

Następnie tworze specjalną podsieć dla dockera za pomocą polecenia  ```docker network create``` i powtarzam czynności, tym razem łącząć się za pomocą nazwy konterera, który służy jako serwer. 

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090727.png)

Tutaj wynik jest trochę mniejszy, mamy przepustowość na poziomie 28 Gbit/s, co prawdopodobnie oznacza, że docker network może tworzyć lekki "overhead" podczas komunikacji między kontenerami.

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090738.png)

Na koniec tworzę serwer w trybie detached i próbuje się z nim połączyć przy użyciu maszyny hosta:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-03-27%20090812.png)


Bitrate dla połączenia localhost-serwer wynosi około 34,5 Gbit/s. 

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20161617.png)

### Usługi w rozumieniu systemu, kontenera i klastra

W kolejnej części postawiam kontener z ssh, abym mógł się na niego zalogować za pomocą maszyny hosta:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20163858.png)

Daemon sshd został poprawnie zainstalowany, dodano klucze RSA do komunikacji oraz ```PermitRootLogin yes``` do pliku konfiguracyjnego ```/etc/ssh/sshd_config```:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20164115.png)

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20164158.png)

Logowanie na serwer:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20164230.png
)

**Zalety rozwiązania:** Pozwala na łatwe debugowanie, przypomina pracę z klasyczną maszyną wirtualną (VPS), wsparcie dla narzędzi łączących się przez SSH (np. Ansible).

**Wady rozwiązania:** To jest anty-wzorzec w platformie Docker. Kontener powinien realizować jeden proces (np. działać tylko jako serwer WWW). Dodanie sshd sprawia, że w kontenerze muszą działać minimum dwa procesy. Zwiększa to rozmiar obrazu, komplikuje zarządzanie cyklem życia kontenera, stwarza luki bezpieczeństwa i marnuje zasoby.


### Przygotowanie do uruchomienia serwera jenkins


Zgodnie z dokumentacją, instaluje Jenkins'a w konfiguracji DIND. Tworzę oddzielną siec, sciągam odpowiedni obraz i go buduję:

```bash
#kontener DIND (docker in docker)
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2

```

```bash
#kontener jenkins
docker run --name myjenkins-blueocean --rm --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkins/jenkins:lts-jdk17
```
![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20172408.png)


![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20172604.png)

Na koniec pobieram hasło pierwszego użycia i konfiguruje wszystkie zależności na pod adresem maszyny wirtualnej na porcie 8080:

![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20172653.png)


![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20172818.png)


![img](../screenshots/lab1-4/Zrzut%20ekranu%202026-04-02%20172832.png)

