# Sprawozdanie 1

## Zajęcia 01 — Git, SSH i gałęzie

### Środowisko

Ćwiczenia wykonano na maszynie wirtualnej z systemem Ubuntu Server 24.04 LTS uruchomionej w Hyper-V. Do pracy zdalnej wykorzystano Visual Studio Code oraz rozszerzenie Remote - SSH.

### Konfiguracja Git i SSH

Sprawdzono dostępność klienta Git oraz SSH:

```bash
git --version
ssh -V
```

Repozytorium przedmiotowe znajduje się w katalogu:

```text
/home/daniel/MDO2026s_ITE
```

Adres zdalnego repozytorium wykorzystuje protokół HTTPS. Praca odbywa się na gałęzi:

```text
DC417539
```

Gałąź lokalna śledzi gałąź zdalną:

```text
origin/DC417539
```

![Weryfikacja Git, SSH i hooka](screenshots/S1_Z01_01_weryfikacja-git-ssh-hook.png)


### Git Hook `commit-msg`

Utworzono hook sprawdzający, czy komunikat commita rozpoczyna się od numeru identyfikacyjnego `DC417539`.

Treść skryptu:

```bash
#!/bin/bash

message=$(cat "$1")

if [[ $message != DC417539* ]]; then
    echo "Commit message must start with DC417539"
    exit 1
fi
```

Hook został zainstalowany w lokalnym katalogu repozytorium:

```text
.git/hooks/commit-msg
```

Ponieważ zawartość katalogu `.git` nie jest wersjonowana, kopię skryptu zapisano również w:

```text
Lab01/commit-msg
```

Sprawdzono działanie hooka dla nieprawidłowego komunikatu:

Hook odrzucił komunikat i zwrócił kod zakończenia `1`.


Następnie wykonano test z prawidłowym komunikatem:

Hook zaakceptował komunikat i zwrócił kod zakończenia `0`.


![Test działania Git Hooka](screenshots/S1_Z01_02_test-git-hook.png)

### Commit i synchronizacja z repozytorium

Plik Git Hooka został zatwierdzony w commicie:

```text
60dd2db DC417539 Add commit-msg hook
```

Commit został następnie wysłany na zdalną gałąź `origin/DC417539`.

![Commit i synchronizacja z repozytorium](screenshots/S1_Z01_03_commit-i-synchronizacja.png)


## Zajęcia 02 — Git i Docker

### Środowisko Docker

Ćwiczenia wykonano w systemie Ubuntu Server 24.04 LTS. Sprawdzono wersję klienta Docker oraz poprawność działania usługi:

```bash
docker --version
docker info
```

Wykorzystano Docker w wersji 29.1.3 zainstalowany z pakietów przeznaczonych dla systemu Ubuntu.

### Uruchamianie gotowych obrazów

Uruchomiono i sprawdzono obrazy:

* `hello-world`
* `busybox`
* `ubuntu`
* `nginx`
* `node`
* `mcr.microsoft.com/dotnet/runtime`
* `mcr.microsoft.com/dotnet/aspnet`
* `mcr.microsoft.com/dotnet/sdk`

Po każdym uruchomieniu sprawdzano kod zakończenia ostatniego polecenia:

```bash
echo $?
```

Kod `0` potwierdzał poprawne zakończenie działania kontenera.

![Uruchomienie hello-world](screenshots/S1_Z02_01_hello-world.png)

Sprawdzone rozmiary obrazów:

| Obraz                                     | Rozmiar |
| ----------------------------------------- | ------: |
| `hello-world:latest`                      | 10,1 kB |
| `busybox:latest`                          | 4,45 MB |
| `ubuntu:latest`                           |  100 MB |
| `nginx:latest`                            |  161 MB |
| `node:latest`                             | 1,24 GB |
| `mcr.microsoft.com/dotnet/runtime:latest` |  203 MB |
| `mcr.microsoft.com/dotnet/aspnet:latest`  |  230 MB |
| `mcr.microsoft.com/dotnet/sdk:latest`     |  883 MB |

![Sprawdzenie obrazów i ich rozmiarów](screenshots/S1_Z02_05_obrazy.png)

### BusyBox

Uruchomiono kontener BusyBox i potwierdzono jego działanie:

```bash
docker run --name s1-z02-busybox busybox echo "BusyBox działa"
```

Następnie uruchomiono kontener interaktywnie:

```bash
docker run --rm -it busybox sh
```

Sprawdzona wersja:

```text
BusyBox v1.38.0
```

![Uruchomienie i wersja BusyBox](screenshots/S1_Z02_02_busybox.png)

### Ubuntu i procesy kontenera

Uruchomiono interaktywny kontener Ubuntu:

```bash
docker run --name s1-z02-ubuntu -it ubuntu bash
```

Sprawdzono proces o PID 1:

```bash
ps -p 1 -o pid,comm,args
```

Procesem PID 1 w kontenerze był `bash`.

W kontenerze zaktualizowano listę pakietów oraz zainstalowane pakiety:

```bash
apt update
apt upgrade -y
```

![Ubuntu — PID 1 i aktualizacja pakietów](screenshots/S1_Z02_03_ubuntu-pid1-aktualizacja.png)

Uruchomiono również pomocniczy kontener z poleceniem `sleep infinity`. Proces kontenera był widoczny na hoście za pomocą:

```bash
ps aux | grep '[s]leep infinity'
```

![Proces kontenera widoczny na hoście](screenshots/S1_Z02_04_proces-kontenera-na-hoscie.png)

### Własny obraz Docker

Utworzono plik `Dockerfile` bazujący na obrazie Ubuntu 24.04. Plik instaluje Git i certyfikaty CA, usuwa niepotrzebną pamięć podręczną APT oraz klonuje repozytorium przedmiotowe.

Treść pliku:

```dockerfile
FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["/bin/bash"]
```

Obraz zbudowano poleceniem:

```bash
docker build -t moj-test .
```

![Budowanie własnego obrazu](screenshots/S1_Z02_06_budowanie-wlasnego-obrazu.png)

![Budowanie własnego obrazu — zakończenie](screenshots/S1_Z02_07_budowanie-wlasnego-obrazu-2.png)

Następnie uruchomiono kontener w trybie interaktywnym:

```bash
docker run --name wlasny -it moj-test
```

W kontenerze potwierdzono obecność repozytorium w katalogu:

```text
/workspace/MDO2026s_ITE
```

Sprawdzono również wersję Git oraz stan sklonowanego repozytorium:

```bash
git --version
cd /workspace/MDO2026s_ITE
git status
```

Repozytorium znajdowało się na gałęzi `main`, a katalog roboczy był czysty.

![Repozytorium w kontenerze](screenshots/S1_Z02_08_repozytorium-w-kontenerze.png)

### Czyszczenie środowiska

Wyświetlono wszystkie utworzone kontenery:

```bash
docker ps -a
```

![Kontenery przed czyszczeniem](screenshots/S1_Z02_09_kontenery-przed-czyszczeniem.png)

Zakończone kontenery usunięto za pomocą:

```bash
docker container prune
```

Lokalne obrazy usunięto poleceniem:

```bash
docker image prune -a
```

Po zakończeniu sprawdzono, że listy kontenerów i obrazów były puste:

```bash
docker ps -a
docker images
```

![Środowisko po czyszczeniu](screenshots/S1_Z02_10_srodowisko-po-czyszczeniu.png)

![Pusty magazyn obrazów po czyszczeniu](screenshots/S1_Z02_11_srodowisko-po-czyszczeniu-2.png)

Plik `Dockerfile` zapisano w katalogu:

```text
ITE/GCL1/DC417539/sprawozdanie1/Lab02/Dockerfile
```

## Zajęcia 03 – Dockerfiles, kontener jako definicja etapu

### Wybór i przygotowanie projektu

Do realizacji zadania wybrano bibliotekę **Axios** w wersji `v1.20.0`. Projekt jest udostępniany na otwartej licencji MIT oraz posiada zdefiniowane procesy budowania i testowania przy użyciu środowiska Node.js i npm.

Repozytorium zostało sklonowane i przełączone na konkretny tag:

```bash
git clone https://github.com/axios/axios.git
cd axios
git checkout v1.20.0
```

![Wybór wersji Axios](screenshots/S1_Z03_01_wybor-wersji-axios.png)

Na hoście `server` wykorzystano Node.js `v22.23.2` oraz npm `10.9.8`.

![Wersje Node.js i npm](screenshots/S1_Z03_02_node-npm-wersje.png)

Zależności projektu zostały zainstalowane na podstawie pliku `package-lock.json`:

```bash
npm ci
```

![Instalacja zależności npm](screenshots/S1_Z03_03_npm-ci.png)

### Lokalny build programu

Proces budowania projektu został uruchomiony poleceniem:

```bash
npm run build
```

W wyniku działania procesu zostały utworzone pliki wynikowe w katalogu `dist`, między innymi wersje przeznaczone dla środowiska Node.js, przeglądarki oraz modułów ESM.

![Lokalny build Axios](screenshots/S1_Z03_04_lokalny-build.png)

Następnie uruchomiono testy jednostkowe:

```bash
npm run test:vitest:unit
```

Testy zostały wykonane przy użyciu Vitest. Wszystkie testy zakończyły się powodzeniem:

```text
Test Files  58 passed (58)
Tests       1062 passed (1062)
```

![Lokalne testy jednostkowe](screenshots/S1_Z03_05_lokalne-testy.png)

### Interaktywny build w kontenerze

Do odtworzenia procesu w izolowanym środowisku wykorzystano obraz:

```text
node:26.8.1-bookworm
```

Kontener został uruchomiony w trybie interaktywnym:

```bash
docker run -it --name axios-interactive node:26.8.1-bookworm bash
```

W kontenerze ponownie sklonowano repozytorium, wybrano wersję `v1.20.0`, zainstalowano zależności oraz wykonano build:

```bash
cd /opt
git clone https://github.com/axios/axios.git
cd axios
git checkout v1.20.0
npm ci
npm run build
```

![Build w kontenerze](screenshots/S1_Z03_06_build-w-kontenerze.png)

Podczas uruchamiania testów w kontenerze wystąpiła różnica w sposobie rozwiązywania adresu `localhost`. Problem rozwiązano przez wymuszenie preferowania IPv4 przez Node.js:

```bash
NODE_OPTIONS=--dns-result-order=ipv4first npm run test:vitest:unit
```

Po zastosowaniu tego ustawienia wszystkie testy zakończyły się powodzeniem:

```text
Test Files  58 passed (58)
Tests       1062 passed (1062)
```

![Testy w kontenerze](screenshots/S1_Z03_07_testy-w-kontenerze.png)

Po opuszczeniu kontenera sprawdzono stan obrazów i kontenerów. Obraz stanowi szablon środowiska, natomiast kontener jest jego konkretną instancją. Po wykonaniu polecenia `exit` główny proces `bash` zakończył działanie, dlatego kontener przeszedł do stanu `Exited (0)`.

![Obraz i kontener](screenshots/S1_Z03_08_obraz-i-kontener.png)

### Automatyzacja procesu – Dockerfile

W katalogu `Lab03` przygotowano dwa osobne pliki Dockerfile.

Pierwszy plik `Dockerfile.build` odpowiada za przygotowanie środowiska, pobranie kodu, instalację zależności i wykonanie builda:

```dockerfile
FROM node:26.8.1-bookworm

WORKDIR /opt

RUN git clone https://github.com/axios/axios.git

WORKDIR /opt/axios

RUN git checkout v1.20.0
RUN npm ci
RUN npm run build
```

Obraz został zbudowany poleceniem:

```bash
docker build -f Dockerfile.build -t axios-build:v1.20.0 .
```

![Budowanie obrazu build](screenshots/S1_Z03_09_dockerfile-build.png)

Drugi plik `Dockerfile.test` bazuje na wcześniej przygotowanym obrazie i nie wykonuje ponownego builda:

```dockerfile
FROM axios-build:v1.20.0

ENV NODE_OPTIONS=--dns-result-order=ipv4first

CMD ["npm", "run", "test:vitest:unit"]
```

Obraz testowy został utworzony poleceniem:

```bash
docker build -f Dockerfile.test -t axios-test:v1.20.0 .
```

![Budowanie obrazu testowego](screenshots/S1_Z03_10_dockerfile-test-build.png)

Uruchomienie kontenera utworzonego z obrazu testowego automatycznie wykonało testy:

```bash
docker run --name axios-test-run axios-test:v1.20.0
```

Wszystkie `1062` testy zostały zaliczone.

![Testy z Dockerfile.test](screenshots/S1_Z03_11_testy-z-dockerfile-test.png)

Polecenia:

```bash
docker ps -a
docker images
```

pozwoliły również potwierdzić obecność trzech obrazów oraz zakończonych kontenerów.

![Obrazy i kontenery](screenshots/S1_Z03_12_obrazy-i-kontenery.png)

### Docker Compose

Proces budowania został następnie ujęty w kompozycję Docker Compose.

Przygotowano plik `compose.yml`:

```yaml
services:
  build:
    build:
      context: .
      dockerfile: Dockerfile.build
    image: axios-build:v1.20.0

  test:
    build:
      context: .
      dockerfile: Dockerfile.test
    image: axios-test:v1.20.0
```

Poprawność konfiguracji sprawdzono poleceniem:

```bash
docker compose config
```

Pierwszy etap został zbudowany poleceniem:

```bash
docker compose build build
```

![Build za pomocą Docker Compose](screenshots/S1_Z03_13_compose-build.png)

Następnie zbudowano obraz testowy:

```bash
docker compose build test
```

Testy uruchomiono bez ręcznego wdrażania kontenera:

```bash
docker compose run --rm test
```

Wynik końcowy:

```text
Test Files  58 passed (58)
Tests       1062 passed (1062)
```

potwierdził poprawne działanie przygotowanej kompozycji.

![Testy za pomocą Docker Compose](screenshots/S1_Z03_14_compose-testy.png)


## Zajęcia 04 — Dodatkowa terminologia w konteneryzacji, instancja Jenkins

Podczas zajęć sprawdzono działanie woluminów Docker, komunikację sieciową między kontenerami, uruchamianie usługi SSHD w kontenerze oraz przygotowano instancję Jenkins współpracującą z Docker-in-Docker.

### Zachowywanie stanu między kontenerami

Utworzono dwa nazwane woluminy: `lab04-input` oraz `lab04-output`. Pierwszy służył do przechowywania kodu źródłowego Axios, a drugi do zapisywania wyników builda.

Na podstawie wcześniejszego obrazu przygotowano również wersję bez programu Git. Dzięki temu kod mógł zostać pobrany przez osobny kontener i zapisany na woluminie, a kontener buildowy zajmował się tylko budowaniem projektu.

![Weryfikacja obrazu budującego bez programu Git](screenshots/S1_Z04_01_obraz-bez-git.png)

Repozytorium Axios zostało sklonowane na wolumin `lab04-input` przy pomocy osobnego kontenera.

![Klonowanie repozytorium na wolumin wejściowy](screenshots/S1_Z04_02_klonowanie-na-wolumin-wejsciowy.png)

Następnie wykonano build projektu, a katalog `dist` zapisano na woluminie `lab04-output`. Po uruchomieniu kolejnego kontenera dane nadal były dostępne, co potwierdziło trwałość named volume niezależnie od kontenera.

![Trwałość danych na woluminie wyjściowym](screenshots/S1_Z04_03_trwalosc-woluminu-wyjsciowego.png)

Sprawdzono również drugi wariant, w którym Git znajdował się bezpośrednio w kontenerze wykonującym build. Repozytorium zostało sklonowane, projekt zbudowany, a wynik ponownie zapisany na woluminie wyjściowym.

![Klonowanie wewnątrz kontenera i zapis wyniku budowania](screenshots/S1_Z04_04_git-wewnatrz-kontenera-i-build.png)

### Eksponowanie portów i komunikacja między kontenerami

Do sprawdzenia komunikacji sieciowej wykorzystano `iperf3`.

Najpierw dwa kontenery działały w domyślnej sieci `bridge`. Połączenie wykonano po adresie IP, uzyskując przepustowość około `25,8 Gbit/s`.

![Pomiar iperf3 w domyślnej sieci bridge](screenshots/S1_Z04_05_iperf-domyslna-siec-bridge.png)

Następnie utworzono własną sieć `lab04-net`. W tej sieci kontenery mogły komunikować się po nazwach, dlatego klient połączył się z serwerem jako `lab04-iperf-server`. Uzyskano około `21,0 Gbit/s`.

![Komunikacja po nazwie w dedykowanej sieci Docker](screenshots/S1_Z04_06_iperf-dedykowana-siec-po-nazwie.png)

Port `5201` został również opublikowany na hoście. Z komputera poza maszyną `server` sprawdzono jego dostępność przy pomocy `Test-NetConnection`.

![Połączenie do kontenera spoza hosta](screenshots/S1_Z04_07_polaczenie-spoza-hosta.png)

Na hoście wykonano także test `iperf3` do kontenera przez opublikowany port. Otrzymano wynik około `17,7 Gbit/s`.

![Pomiar przepustowości host-kontener](screenshots/S1_Z04_08_iperf-host-do-kontenera.png)

Logi serwera `iperf3` potwierdziły wykonane połączenia i uzyskane wyniki.

![Log serwera iperf3](screenshots/S1_Z04_09_log-serwera-iperf.png)

Najwyższy wynik uzyskano podczas komunikacji kontener-kontener w domyślnej sieci `bridge`. Nieco niższy wynik wystąpił w dedykowanej sieci Docker, a najniższy przy połączeniu host-kontener przez opublikowany port. Wszystkie warianty działały poprawnie.

### Usługa SSHD w kontenerze

Przygotowano obraz Ubuntu 24.04 z zainstalowanym `openssh-server`. W kontenerze utworzono użytkownika `labuser`, a port `22` udostępniono na porcie `2222` hosta.

Połączenie wykonano poleceniem:

```bash
ssh -p 2222 labuser@127.0.0.1
```

Polecenia `whoami` oraz `hostname` potwierdziły, że połączenie działało wewnątrz właściwego kontenera.

![Połączenie SSH z kontenerem](screenshots/S1_Z04_10_sshd-polaczenie-do-kontenera.png)

SSHD może być przydatny w niektórych przypadkach, ale w typowej pracy z kontenerami prostszym rozwiązaniem jest używanie `docker exec` oraz logów kontenera.

### Skonteneryzowana instancja Jenkins z Docker-in-Docker

Na końcu przygotowano środowisko Jenkins działające w Dockerze. Utworzono sieć `jenkins` oraz woluminy na dane i certyfikaty.

Uruchomiono kontener `jenkins-docker` z obrazem `docker:dind`, który udostępnia daemon Dockera dla Jenkinsa.

Właściwy Jenkins działał w kontenerze `jenkins-blueocean` na przygotowanym obrazie `myjenkins-blueocean:2.568.3-1`. Kontener został połączony z `jenkins-docker` i skonfigurowany do korzystania z jego daemona Docker.

![Działające kontenery Jenkins i Docker-in-Docker](screenshots/S1_Z04_11_jenkins-i-dind-kontenery.png)

Połączenie sprawdzono przez wykonanie `docker info` wewnątrz kontenera Jenkins. Polecenie zwróciło informacje o daemonie działającym w `jenkins-docker`, co potwierdziło poprawną komunikację między kontenerami.

![Połączenie Jenkins z Docker-in-Docker](screenshots/S1_Z04_12_jenkins-polaczenie-z-dind.png)

Po konfiguracji uzyskano działający panel Jenkins dostępny przez port `8080`.

![Ekran logowania Jenkins](screenshots/S1_Z04_13_jenkins-ekran-logowania.png)

Instancję Jenkins oraz kontener Docker-in-Docker pozostawiono uruchomione, ponieważ były potrzebne podczas kolejnych zajęć.
