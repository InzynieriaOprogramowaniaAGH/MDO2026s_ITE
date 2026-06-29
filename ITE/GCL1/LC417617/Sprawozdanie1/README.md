# Sprawozdanie 1 - Git, Gałęzie, SSH
## Zajęcia 01
Na maszynie wirtualnej z systemem Ubuntu zainstalowano klienta Git z wykorzystaniem
systemowego menedżera pakietów `apt`. Repozytorium przedmiotowe zostało najpierw
sklonowane przez HTTPS z użyciem Personal Access Token (PAT). Przed zajęciami
zainstalowano wtyczkę do Visual Studio Code dla SSH oraz skonfigurowano również

narzędzia pomocnicze (Visual Studio Code Remote-SSH oraz FileZilla do transferu SFTP).
Następnie wygenerowano nowoczesne klucze SSH (Ed25519 zabezpieczony hasłem oraz
ECDSA bez hasła), dodano klucz do platformy GitHub i sklonowano repozytorium przy
użyciu protokołu SSH.
Skonfigurowano globalne ustawienia wymagane do poprawnego podpisywania commitów:
```bash
git config --global user.name "HaatLukas"
git config --global user.email "lcurylo@student.agh.edu.pl"
```

![FileZilla](./img/L0_Start_0.png)
Rys. 1. Konfiguracja programu FileZilla i nawiązanie pomyślnego połączenia przez protokół SFTP.


![Instalacja Pluginu Visual Studio Code](./img/L0_Start_1.png)
Rys. 2. Instalacja oficjalnego rozszerzenia Remote - SSH w edytorze Visual Studio Code.


![Potwierdzenie połączenia SSH](./img/L0_Start_2.png)
Rys. 3. Weryfikacja aktywnego i stabilnego połączenia SSH z poziomu systemu hosta.

![Klonowanie nr1](./img/L0_Start_3.png)
Rys. 4. Klonowanie repozytorium.

Sklonowanie repozytorium z użyciem protokołu SSH:
```bash
git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git
```

![SSH1](./img/L0_Start_6_SSH.png)
Rys. 5. Proces generowania kluczy SSH.


![SSH2](./img/L0_Start_7_SSH.png)
Rys. 6. Dodanie klucza publicznego

![SSH3](./img/L0_Start_8_SSH.png)
Rys. 7. Pomyślne pobranie struktury projektu przy użyciu protokołu SSH.

Przygotowanie gałęzi (branches):
![Branch1](./img/L0_Start_Branche_4.png)
Rys. 8. Sprawdzenie statusu repozytorium oraz przełączenie na gałęzie main i GCL1.

![BranchSkrypt](./img/L0_Start_Branche_5.png)
Rys. 9. Tworzenie dedykowanej gałęzi osobistej LC417617 oraz wymaganej struktury folderów.


Napisano skrypt weryfikujący (Git Hook), sprawdzający poprawność wpisywanych
wiadomości:
```bash
#!/bin/bash
PREFIX="LC417617"

COMMIT_MSG=$(head -n 1 "$1")
if [[ ! $COMMIT_MSG == $PREFIX* ]]; then
echo "=========================================="
echo "BŁĄD COMMITA!"
echo "Wiadomość musi zaczynać się od '$PREFIX'."
echo "Twoja wiadomość: $COMMIT_MSG"
echo "=========================================="
exit 1
fi
exit 0
```

Skrypt został skopiowany do katalogu `.git/hooks/commit-msg` i nadano mu uprawnienia do
wykonywania poleceniem `chmod +x`. Każdy commit bez prefiksu `LC417617` jest
rygorystycznie odrzucany przez system kontroli wersji, co przetestowano w praktyce
podczas próby scalenia (merge) historii z serwera.
![Zapisanie skryptu i nadanie uprawnień](./img/L0_Start9_End.png)

Rys. 10. Zapisanie skryptu w edytorze nano, nadanie uprawnień wykonywalności i test działania blokady.


## Użycie narzędzi Generatywnej AI

W celu sprawnego przygotowania, ustrukturyzowania oraz poprawnego sformatowania dokumentacji technicznej, skonsultowano się z modelem LLM.

### Treść wysłanego zapytania (Prompt):
> "Pomóż mi poprawnie sformatować i uporządkować plik README.md na potrzeby sprawozdania z zajęć z Gita. Mam przygotowaną treść oraz zrzuty ekranu o nazwach od L0_Start_0 itd. Jak poprawnie ułożyć strukturę w języku Markdown, aby całość poprawnie wyrenderowała się na GitHubie?"

### Metoda weryfikacji i modyfikacji:
Zaproponowany przez model układ dokumentu został ręcznie zweryfikowany w edytorze Visual Studio Code. Dokonano manualnej korekty ścieżek do zrzutów ekranu (dodano brakujące rozszerzenie `.png` przy pliku L0_Start_0). Bloki kodu Bash zawierające komendy konfiguracyjne tożsamości (`git config`) oraz strukturę skryptu Git Hook zostały poprawnie domknięte znacznikami Markdown, eliminując błędy formatowania tekstu ciągłego.


# Zajęcia 02 - Docker i konteneryzacja

Celem zajęć było zestawienie środowiska skonteneryzowanego do pracy nad procesami Continuous Integration (CI) oraz weryfikacja mechanizmów izolacji procesów.

## 1. Instalacja i zarządzanie obrazami

Zainstalowano pakiet `docker.io`. Pobrano i przeanalizowano podstawowe obrazy systemowe oraz aplikacyjne.

![Docker.io instalacja](./img/L1_Start_1.png)


Poniższa tabela przedstawia zestawienie pobranych obrazów wraz z ich rozmiarami oraz Exit Code po zakończeniu działania:

| Nazwa obrazu  | Rozmiar lokalny | Kod wyjścia (Exit Code) | Funkcja / Rola w systemie                  |
| :------------ | :-------------- | :---------------------- | :----------------------------------------- |
| `hello-world` | ~13 KB          | `0` (Success)           | Test weryfikacyjny poprawności instalacji  |
| `busybox`     | ~4.3 MB         | `0` (Success)           | Minimalistyczny system do zadań osadzonych |
| `ubuntu`      | ~78 MB          | `0` (Success)           | Pełny obraz bazowy dystrybucji Linux       |
| `nginx`       | ~190 MB         | - (Działa w tle)        | Serwer WWW / Reverse Proxy                 |

---

## 2. Izolacja procesów i tryb interaktywny

Uruchomiono kontener `busybox` w trybie interaktywnym (`-it`), wywołując polecenie `uname -a`. Następnie uruchomiono obraz `ubuntu`, w którym zainstalowano pakiet `procps` w celu weryfikacji drzewa procesów za pomocą `ps -ef`.

![Izolacja procesów PID1](./img/L1_Start_3.png)

*Rys. 11_1. Docker run i docker biild .*

Wewnątrz kontenera proces `/bin/bash` ma izolację środowiska. Na hoście ten sam proces widoczny był pod wysokim identyfikatorem systemowym.

![Izolacja procesów PID1](./img/L1_Start_8.png)

*Rys. 11. Drzewo procesów wewnątrz kontenera Ubuntu z widocznym procesem PID .*

---

## 3. Własny plik Dockerfile i klonowanie repozytorium

Napisano plik `Dockerfile` bazujący na warstwie `ubuntu:24.04`. Połączono instrukcje instalacji, wyczyszczono pamięć podręczną menedżera pakietów (`apt-get clean`) oraz usunięto listy pakietów w celu redukcji rozmiaru końcowego obrazu. Obraz automatycznie klonuje repozytorium projektowe do katalogu `/app`.

![Plik Dockerfile](./img/L1_Start_9.png)

*Rys. 12.1. Plik Dockerfile*

Budowanie obrazu wykonano poleceniem:

```bash
docker build -t lc-obraz .
```

![Odpal build](./img/L1_Start_10_docker_build.png)


Po uruchomieniu kontenera zweryfikowano poprawność pobrania struktur Git.

![Odpal build](./img/L1_Start_13_docker_przed_czyszczeniem.png)

*Rys. 12.2. Sprawdzenie zawartości katalogu roboczego `/app` wewnątrz własnego obrazu `lc-obraz`.*

---

## 4. Czyszczenie środowiska

Dokonano zwolnienia zasobów dyskowych poprzez usunięcie zatrzymanych kontenerów narzędziem:

```bash
docker container prune -f
```

Następnie usunięto pobrane obrazy z lokalnego magazynu poleceniem:

```bash
docker rmi <nazwa_obrazu>
```

oraz przeprowadzono czyszczenie nieużywanych warstw komendą:

```bash
docker image prune -a -f
```

![Czyszczenie 1](./img/L1_Start_14_czysc.png)

*Rys. 13. Czyszczenie – część 1.*


![Czyszczenie 2](./img/L1_Start_15_czysc.png)

*Rys. 14. Czyszczenie – część 2.*


---

## Użycie narzędzi Generatywnej AI (Zajęcia 02)

### Treść wysłanego zapytania (Prompt)

> 1. Jak napisać plik Dockerfile oparty na Ubuntu 24.04, który automatycznie instaluje git i klonuje repozytorium?
>
> 2. Sprawdź plik README pod kątem błędów i zgodności z wymaganiami sprawozdania.

### Metoda weryfikacji i modyfikacji

Na podstawie otrzymanych wskazówek przygotowano plik Dockerfile oraz uzupełniono dokumentację. Następnie samodzielnie zweryfikowano poprawność działania kontenera, poleceń Dockera oraz treści sprawozdania, wprowadzając ewentualnie niezbędne poprawki.



# Zajęcia 3 - Dockerfiles, kontener jako definicja etapu

## 1. Wybór oprogramowania na zajęcia
Do realizacji zadania wybrano bibliotekę **cJSON** (lekki parser JSON napisany w języku ANSI C). 
Projekt ten posiada otwartą licencję (MIT), wykorzystuje system budowania `CMake` oraz zawiera zdefiniowane testy uruchamiane za pomocą wbudowanego narzędzia `CTest`.

---

## 2. Izolacja i powtarzalność: build w kontenerze (Interaktywnie)
Proces budowania i testowania przeprowadzono początkowo wewnątrz kontenera bazowego `ubuntu:24.04`.
Zainstalowano niezbędne zależności (`git`, `cmake`, `build-essential`), sklonowano repozytorium, a następnie skompilowano projekt i uruchomiono testy.

![Instalacja](./img/L2_przygotuj_1.png)
*Rys. 1. Instalacja kontenera cz.1*


![Instalacja 2](./img/L2_przygotuj_2.png)
*Rys. 2. Instalacja kontenera cz.2*


![Wynik testów interaktywnych](./img/L2_przygotuj_3.png)
*Rys. 3. Pomyślne przejście testów jednostkowych wewnątrz interaktywnego kontenera.*


---

## 3. Automatyzacja procesu (Dockerfile)
Podzielono proces na dwa etapy, tworząc dwa osobne pliki `Dockerfile`:
1. **Dockerfile.build** – przygotowuje środowisko kompilacji, klonuje kod i buduje projekt.
2. **Dockerfile.test** – bazuje na zbudowanym obrazie i służy wyłącznie do uruchomienia testów.

![Docker1](./img/L2_DockerBuild_4.png)
*Rys. 4. Zawartość DockerBuild*

![Docker2](./img/L2_DockerTest_6.png)
*Rys. 5. Zawartość DockerTest*



---

## 4. Docker Compose
Zamiast ręcznego zarządzania kontenerami, proces zautomatyzowano przy użyciu narzędzia Docker Compose. Wdrożenie testowego kontenera realizowane jest komendą.

![Plik DockerCompose](./img/L2_DockerCompose_7.png)
*Rys. 6. Zawartość pliku DockerCompose*

![Instalacja potrzebnych pakietów](./img/L2_DockerCompose_8_install.png)
*Rys. 7. Instalacja bibliotek

![Wynik](./img/L2_DockerCompose_9_end.png)
*Rys. 8. Wynik działania kompozycji – automatyczne zbudowanie obrazu i wykonanie testów cJSON.*

---

## 5. Przygotowanie do wdrożenia (Deploy): Dyskusje
* **Czy program nadaje się do wdrażania i publikowania jako kontener?**
  Nie. Wybrane oprogramowanie (`cJSON`) jest tylko biblioteką programistyczną języka C. Dystrybuowanie jej jako "działającego kontenera" nie ma sensu. Kontener pełni tutaj wyłącznie rolę izolowanego środowiska do testowania (w procesie CI).
* **W jaki sposób miałoby zachodzić przygotowanie finalnego artefaktu?**
   Środowisko musielibyśmy oczyścić ze zbędnych elementów(narzędzia kompilacyjne typu GCC, CMake), które tylko zwiększają wagę.
* **Czy dedykowany deploy-and-publish byłby oddzielną ścieżką?**
  Tak. Należałoby zastosować *Multi-stage builds*. Ostatni krok potoku CI wyodrębniłby wyłącznie skompilowaną bibliotekę z pierwszego, ciężkiego kontenera kompilacyjnego, przenosząc ją do czystego systemu bazowego lub eksportując bezpośrednio na hosta.
* **Czy zbudowany program należałoby dystrybuować jako pakiet?**
  Tak, finalnym formatem dla systemu Linux powinna być natywna paczka dystrybucyjna (np. `.deb` lub `.rpm`). Dodatkowym krokiem byłoby użycie zintegrowanego narzędzia (np. `CPack`), które automatycznie spakowałoby skompilowane pliki w instalowalną paczkę oprogramowania.


## Użycie narzędzi Generatywnej AI (Zajęcia 03)

### Treść wysłanego zapytania (Prompt)

> 1. Pomóż mi przeanalizować poniższe pytania do dyskusji na temat mojego projektu cJson na GitHubie w ramach deploya:
>    - Czy dedykowany deploy-and-publish byłby oddzielną ścieżką?
>    - Czy zbudowany program należałoby dystrybuować jako pakiet?
>
> 2. Sformatuj plik README.md pod kątem sprawozdania. Sprawdź go pod kątem błędów składniowych, aby poprawnie renderował ścieżki do zrzutów ekranu i bloki kodu na GitHubie.

### Metoda weryfikacji i modyfikacji

 Otrzymane argumenty do dyskusji zweryfikowano pod kątem logiki i zgodności z informacjami na internecie.(wzorzec multi-stage builds oraz natywna dystrybucja pakietów). Wygenerowany kod dokumentacji Markdown został poddany manualnemu sprawdzeniu, aby na 100% odpowiadał strukturze katalogów i nazwom plików graficznych w środowisku.

 ## Zajęcia 04 - Woluminy, sieci, SSHD i Jenkins

Celem zajęć było sprawdzenie dodatkowych mechanizmów konteneryzacji: woluminów, bind mountów, sieci Dockera, komunikacji między kontenerami, usługi SSHD w kontenerze oraz uruchomienie instancji Jenkinsa w środowisku skonteneryzowanym.

---

### 1. Woluminy wejściowy i wyjściowy

Na potrzeby budowania projektu przygotowano dwa woluminy:

```text
wejscie_lc417617
wyjscie_lc417617
```

Wolumin wejściowy został wykorzystany do przekazania kodu źródłowego do kontenera, a wolumin wyjściowy do zapisania wyników budowania. Dzięki temu pliki mogły przetrwać po zakończeniu działania kontenera.

Wynik polecenia `docker inspect` pokazał, że kontener `builder_vol` miał podłączone oba woluminy:

```text
builder_vol
volume: /var/lib/docker/volumes/wejscie_lc417617/_data -> /wejscie
volume: /var/lib/docker/volumes/wyjscie_lc417617/_data -> /wyjscie
```

![Woluminy i przygotowanie wariantu A](./img/L3_OpcjaA_1.png)

---

### 2. Bind mount jako alternatywa dla woluminu wejściowego

Drugim sposobem przekazania kodu do kontenera było użycie bind mounta. W tym wariancie lokalny katalog z kodem został podłączony bezpośrednio do katalogu `/wejscie` w kontenerze.

Wynik sprawdzania mountów pokazał:

```text
builder_bind
bind: /home/lukasz/MDO2026s_ITE/ITE/GCL1/LC417617/Zajecia4/src -> /wejscie
volume: /var/lib/docker/volumes/wyjscie_lc417617/_data -> /wyjscie
```

Takie rozwiązanie jest wygodne podczas pracy lokalnej, ponieważ zmiany w plikach na hoście są od razu widoczne w kontenerze.

![Powrót i sprawdzenie plików](./img/L3_powrot_2.png)

![Build z wykorzystaniem zamontowanego katalogu](./img/L3_3.png)

---

### 3. Budowanie projektu z użyciem kontenera

Do testów wykorzystano projekt `cJSON`. Kod był dostępny w katalogu wejściowym, a wynik budowania trafiał do katalogu wyjściowego. Kontener pełnił rolę środowiska buildowego, czyli miał narzędzia potrzebne do kompilacji projektu, ale sam kod był przekazywany przez wolumin lub bind mount.

W ten sposób można oddzielić środowisko budowania od systemu hosta. Jest to zgodne z ideą CI, ponieważ build można powtórzyć w takim samym środowisku na innym komputerze.

---

### 4. Własna sieć bridge

Utworzono własną sieć Dockera:

```text
siec_lc417617
```

Wynik `docker network ls` potwierdził jej obecność:

```text
siec_lc417617    bridge    local
```

Własna sieć bridge pozwala kontenerom komunikować się ze sobą po nazwach, a nie tylko po adresach IP. Jest to wygodniejsze i bardziej zbliżone do tego, jak działają usługi w środowiskach kontenerowych.

![Utworzenie własnej sieci](./img/L3_utworzeniesieci_4.png)

---

### 5. Komunikacja między kontenerami i iperf3

Do sprawdzenia komunikacji między kontenerami wykorzystano `iperf3`. Utworzono kontenery związane z testem komunikacji:

```text
serwer_iperf
serwer_dns
serwer_zewnetrzny
```

W trakcie pracy pojawiły się problemy z uruchomieniem lub połączeniem części kontenerów, co zostało udokumentowane. Po poprawkach możliwe było sprawdzenie konfiguracji sieci oraz komunikacji między kontenerami.

![Problemy z komunikacją](./img/L3_problemy_4.png)

![Rozwiązanie problemów](./img/L3_problemyRozwiazane_5.png)

---

### 6. SSHD w kontenerze

W ramach zadania uruchomiono również usługę SSHD w kontenerze. Kontener miał nazwę:

```text
serwer_ssh
```

Wynik `docker ps -a` pokazał, że kontener został utworzony na podstawie obrazu:

```text
linuxserver/openssh-server
```

Dla tego kontenera utworzony był również wolumin konfiguracyjny:

```text
serwer_ssh
volume: /var/lib/docker/volumes/.../_data -> /config
```

Uruchamianie SSHD w kontenerze może być przydatne w sytuacjach administracyjnych lub testowych, ale zwykle nie jest podstawową metodą pracy z kontenerami. Częściej używa się `docker exec`, ponieważ jest prostsze i nie wymaga konfigurowania dodatkowej usługi SSH wewnątrz kontenera.

---

### 7. Docker Compose

Do automatyzacji uruchamiania kontenerów wykorzystano Docker Compose. Po wejściu do katalogu `Sprawozdanie1` wykonano:

```bash
docker compose up -d
docker compose ps
```

Docker Compose uruchomił usługę testującą projekt `cJSON`:

```text
NAME                 IMAGE                        COMMAND                  SERVICE
compose_cjson_test   sprawozdanie1-cjson-tester   "ctest --output-on-f…"   cjson-tester
```

Po zakończeniu testów kontener zakończył działanie z kodem `0`, co oznacza poprawne wykonanie testów:

```text
compose_cjson_test    Exited (0)
```

![Uruchomienie Docker Compose](./img/L3_uruchomieniedockercompose_6.png)

![Wynik działania Docker Compose](./img/L3_uruchomieniedockercompose_7.png)

---

### 8. Uruchomienie Jenkinsa z Docker-in-Docker

W ramach przygotowania do pracy z Jenkinsem uruchomiono instancję Jenkinsa w kontenerze razem z kontenerem pomocniczym Docker-in-Docker.

W środowisku widoczne były kontenery:

```text
zajecia4-jenkins-1
zajecia4-jenkins-docker-1
```

Dla Jenkinsa utworzono osobne woluminy:

```text
zajecia4_jenkins-data
zajecia4_jenkins-docker-certs
```

Oraz sieć:

```text
zajecia4_jenkins
```

Wynik sprawdzenia mountów pokazał, że Jenkins miał trwały katalog domowy:

```text
zajecia4-jenkins-1
volume: /var/lib/docker/volumes/zajecia4_jenkins-data/_data -> /var/jenkins_home
volume: /var/lib/docker/volumes/zajecia4_jenkins-docker-certs/_data -> /certs/client
```

Kontener Docker-in-Docker miał dodatkowo własny katalog `/var/lib/docker`:

```text
zajecia4-jenkins-docker-1
volume: /var/lib/docker/volumes/.../_data -> /var/lib/docker
```

Dzięki temu Jenkins mógł korzystać z Dockera do budowania obrazów i uruchamiania kontenerów.

![Sprawdzenie adresu IP](./img/L3_sprawdzip_9.png)

![Start Jenkinsa - część 1](./img/L3_jenkinsstart_10.png)

![Start Jenkinsa - część 2](./img/L3_jenkinsstart_11.png)

![Start Jenkinsa - część 3](./img/L3_jenkinsstart_12.png)

![Start Jenkinsa - część 4](./img/L3_jenkinsstart_13.png)

![Start Jenkinsa - część 5](./img/L3_jenkinsstart_14.png)

![Ekran końcowy Jenkinsa](./img/L3_jenkinsstart_15_koniec.png)

---

### 9. Stan końcowy środowiska

Na końcu sprawdzono kontenery, woluminy i sieci Dockera.

Wśród kontenerów były widoczne między innymi:

```text
builder_vol
builder_bind
serwer_iperf
serwer_dns
serwer_zewnetrzny
serwer_ssh
zajecia4-jenkins-1
zajecia4-jenkins-docker-1
compose_cjson_test
```

Wśród woluminów były widoczne między innymi:

```text
wejscie_lc417617
wyjscie_lc417617
zajecia4_jenkins-data
zajecia4_jenkins-docker-certs
```

Wśród sieci były widoczne:

```text
siec_lc417617
sprawozdanie1_default
zajecia4_jenkins
```

Oznacza to, że wykonano część dotyczącą woluminów, bind mountów, sieci, kontenerów pomocniczych, Docker Compose oraz przygotowania Jenkinsa.

---

### 10. Dyskusja o użyciu `docker build` i `RUN --mount`

Część kroków związanych z woluminami i przekazywaniem kodu można wykonać również w trakcie budowania obrazu przez `docker build`. Do tego służy mechanizm `RUN --mount`, który pozwala tymczasowo podłączyć katalog lub cache w czasie wykonywania konkretnej instrukcji `RUN`.

W praktyce do prostych zadań laboratoryjnych wygodniejsze było użycie zwykłego `docker run` z woluminami lub bind mountami, ponieważ łatwiej było sprawdzić zawartość katalogów wejściowych i wyjściowych. `RUN --mount` byłby lepszy w bardziej uporządkowanym Dockerfile, gdzie cały proces builda miałby być zapisany jako powtarzalna instrukcja.

---

### 11. Wnioski

Zajęcia pokazały różnicę między zwykłym kontenerem, kontenerem z podłączonym woluminem oraz kontenerem korzystającym z bind mounta. Woluminy są wygodne do przechowywania danych zarządzanych przez Dockera, a bind mounty sprawdzają się wtedy, gdy chcemy bezpośrednio pracować na plikach z hosta.

Własna sieć bridge pozwoliła sprawdzić komunikację między kontenerami. Uruchomienie kontenera SSHD pokazało, że można traktować kontener podobnie jak lekką maszynę z usługą systemową, chociaż w codziennej pracy zwykle wygodniejsze jest użycie `docker exec`.

Na końcu uruchomiono środowisko Jenkinsa z Docker-in-Docker. Dzięki woluminom Jenkins mógł zachowywać swój stan, a kontener DIND pozwalał na budowanie i uruchamianie kontenerów z poziomu Jenkinsa.

---

### 12. Użycie narzędzi Generatywnej AI

Podczas pracy skorzystano z pomocy LLM przy porządkowaniu opisu wykonanych kroków oraz przy interpretacji wyników poleceń Dockera.

Przykładowe prompty:

```text
Jak opisać w README różnicę między Docker volume i bind mount?
```

```text
Jak sprawdzić mounty kontenerów Docker poleceniem docker inspect?
```

```text
Jak opisać własną sieć bridge w Dockerze i komunikację między kontenerami?
```

```text
Jak opisać uruchomienie Jenkinsa z Docker-in-Docker w sprawozdaniu?
```

Odpowiedzi LLM zostały zweryfikowane przez uruchomienie poleceń `docker ps -a`, `docker volume ls`, `docker network ls`, `docker inspect` oraz przez sprawdzenie działania Docker Compose.
