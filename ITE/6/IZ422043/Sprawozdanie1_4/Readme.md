# Sprawozdanie – Podsumowanie zajęć 1-4

# 1. Konfiguracja środowiska Git i maszyny wirtualnej

W pierwszej części skonfigurowano środowisko pracy wykorzystujące system Git oraz maszynę wirtualną z systemem Ubuntu. Autoryzacja dostępu do repozytoriów GitHub została wykonana przy użyciu narzędzia GitHub CLI poprzez polecenie:
```
github auth login
```
Następnie przygotowano maszynę wirtualną z kartą sieciową typu Host-Only, umożliwiającą połączenia SSH.

Dodatkowo zaimplementowano mechanizm kontroli komunikatów commitów za pomocą hooka Git commit-msg. Hook wymuszał stosowanie prefiksu:
```
IZ422043-
```
Dzięki temu wszystkie komunikaty commitów były zgodne z przyjętymi zasadami nazewnictwa. Na zakończenie wykonano proces utworzenia i obsługi Pull Requesta.

# 2. Podstawy pracy z Dockerem

Kolejne ćwiczenie obejmowało instalację i konfigurację środowiska Docker.

Wykonano:

- instalację pakietu Docker,
- uruchomienie usługi Docker,
- logowanie do Docker Hub.

Przetestowano podstawowe operacje na obrazach:
```
docker pull
docker images
```
oraz uruchamianie kontenerów:
```
docker run
```
Sprawdzono również kody zakończenia procesów za pomocą:
```
echo $?
```
Przeanalizowano działanie obrazu BusyBox oraz uruchomiono kontener Ubuntu w trybie interaktywnym, obserwując proces PID 1 i wykonując aktualizację pakietów.

# 3. Tworzenie własnych obrazów Docker

W ramach ćwiczenia przygotowano własny plik Dockerfile oparty na obrazie Ubuntu.

Obraz realizował następujące zadania:

- instalację systemu Git,
- utworzenie katalogu roboczego,
- sklonowanie repozytorium projektu.

Przykładowy proces budowania obrazu:
```
docker build -t repo-cloner .
```
Po utworzeniu obrazu uruchomiono kontener i zweryfikowano poprawność działania.

Zapoznano się również z podstawowymi poleceniami administracyjnymi:
```
docker ps -a
docker container prune
docker image prune -a
```
umożliwiającymi zarządzanie kontenerami i obrazami.

# 4. Budowanie i testowanie projektu Open Source w Dockerze

W ostatnim ćwiczeniu wykorzystano repozytorium projektu JestJS

Przygotowano dwa obrazy Docker:

### Etap budowania

Obraz bazowy:
```
FROM node:20
WORKDIR /app
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/jestjs/jest.git .
RUN yarn install
RUN yarn run build
```
Obraz pobierał kod źródłowy projektu, instalował zależności oraz budował aplikację.

### Etap testów

Drugi obraz wykorzystywał wcześniej przygotowany obraz jako bazę:
```
FROM jest-build

WORKDIR /app

CMD ["npm", "test"]
```
Następnie uruchomiono kontener wykonujący testy automatyczne oraz zweryfikowano działanie kontenera w trybie interaktywnym. Potwierdzono poprawną zależność pomiędzy obrazem budującym a obrazem testowym.

# 5. Trwałość danych i komunikacja między kontenerami

W ramach kolejnych zajęć poznano bardziej zaawansowane mechanizmy Dockera.

### Woluminy

Utworzono dwa woluminy:
```
input-vol
output-vol
```
Pierwszy służył do przechowywania kodu źródłowego projektu, natomiast drugi do przechowywania artefaktów budowania.

Repozytorium projektu zostało sklonowane do woluminu przy użyciu kontenera pomocniczego zawierającego narzędzie Git. Następnie uruchomiono kontener Maven odpowiedzialny za budowanie aplikacji oraz zapis wygenerowanego pliku JAR do woluminu wyjściowego.

Ćwiczenie pokazało, że dane zapisane w woluminach pozostają dostępne niezależnie od cyklu życia kontenerów.

### Komunikacja sieciowa

Przetestowano komunikację pomiędzy kontenerami przy użyciu narzędzia iperf3.

Przeprowadzone pomiary wykazały przepustowość na poziomie około 17,5 Gbit/s, co potwierdziło wysoką wydajność komunikacji realizowanej wewnątrz sieci Dockera.

# 6. Uruchamianie usług systemowych w kontenerach

Kolejne ćwiczenie dotyczyło uruchomienia serwera SSH wewnątrz kontenera Ubuntu.

W ramach zadania:

- zainstalowano pakiet OpenSSH Server,
- skonfigurowano usługę SSHD,
- utworzono wymagane katalogi systemowe,
- ustawiono hasło - użytkownika root,
- udostępniono port 22 na porcie 2222 hosta.

Po odpowiedniej konfiguracji możliwe było zestawienie połączenia SSH z poziomu systemu gospodarza do kontenera.

Ćwiczenie pozwoliło lepiej zrozumieć sposób działania usług sieciowych uruchamianych wewnątrz środowisk kontenerowych.

# 7. Jenkins i Continuous Integration

Ostatnim etapem było wdrożenie środowiska Continuous Integration opartego na serwerze Jenkins.

W pierwszej kolejności utworzono dedykowaną sieć Docker dla komponentów systemu.

Następnie uruchomiono usługę Docker-in-Docker (DinD), umożliwiającą wykonywanie operacji Dockerowych bezpośrednio z poziomu procesów uruchamianych przez Jenkins.