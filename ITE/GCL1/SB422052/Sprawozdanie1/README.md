# Sprawozdanie SB422052 - Laboratoria z konteneryzacji

## Środowisko uruchomieniowe
Wszystkie opisane w sprawozdaniu kroki i polecenia zostały wykonane w następującym środowisku:
* **Host:** macOS
* **Maszyna wirtualna:** Ubuntu Linux (dostarczona przez oprogramowanie do wirtualizacji UTM).
* **Dostęp:** Połączenie z maszyną wirtualną zrealizowano zdalnie za pomocą protokołu SSH (`ssh seb@192.168.64.2`). Nie korzystano z konsoli KVM.
* **Użytkownik:** Pracę wykonano z poziomu standardowego użytkownika (`seb`), unikając pracy bezpośrednio jako `root`. Do poleceń wymagających uprawnień używano `sudo` lub grupy `docker`.

*Historia wszystkich użytych poleceń (bash history) znajduje się w załączonym w tym samym katalogu pliku `historia_polecen.txt`.*

---

## Część I: Podstawy Docker, SSH i środowisko

### Cel zadania:
Celem było przygotowanie środowiska Ubuntu na maszynie wirtualnej, weryfikacja dostępu SSH bez hasła (klucze), instalacja silnika Docker oraz przećwiczenie podstawowych operacji na kontenerach (uruchamianie, wejście do środka, weryfikacja systemu plików).

**Dowody wykonania:**
Wszystkie punkty zrealizowane: UTM (Ubuntu), SSH, Klucze, Git Hook.
![dowod](screeny/screen.png)

1. Instalacja środowiska Docker bezpośrednio z repozytorium Ubuntu:
![instalacja](screeny/1.png)

2. Weryfikacja instalacji - uruchomienie testowego kontenera hello-world:
![hello-world](screeny/2.png)

3. Pobranie i interaktywne uruchomienie obrazu busybox oraz weryfikacja wersji:
![busybox](screeny/3.png)

4. Kontener Ubuntu - aktualizacja pakietów i instalacja procps wewnątrz systemu:
![ubuntu](screeny/4.png)

5. Utworzenie pliku Dockerfile (zastosowanie dobrych praktyk m.in. COPY zamiast git clone) i budowa własnego obrazu:
![dockerfile](screeny/5.png)

6. Weryfikacja zawartości obrazu, globalne czyszczenie środowiska (prune) i wysłanie pliku na GitHub:
![finał](screeny/6.png)

---

## Część II: Dockerfiles, kontener jako definicja etapu

### 1. Wybór projektu i ręczny build w kontenerze
**Cel:** Wybór otwartoźródłowego projektu i próba jego zbudowania oraz przetestowania wewnątrz kontenera.
Jako projekt na zajęcia wybrałem **Express.js** (popularny framework backendowy w środowisku Node.js). 
* **Repozytorium:** `https://github.com/expressjs/express.git`
* **Licencja:** otwarta (MIT).
* **Proces budowania i testów:** W środowisku Node build realizowany jest przez `npm install`, a testy poleceniem `npm test`.

Najpierw proces przetestowałem ręcznie. Uruchomiłem bazowy kontener (`docker run -it node:20 bash`), sklonowałem repozytorium, pobrałem zależności i odpaliłem testy. Raport z testów udowadnia poprawne działanie środowiska:
![Testy ręczne](screeny/test-reczny.png) 

### 2. Automatyzacja zadania (dwa pliki Dockerfile)
**Cel:** Stworzenie powtarzalnego, zautomatyzowanego procesu przy użyciu `Dockerfile`.
Proces został rozbity na dwa pliki:
1. `Dockerfile.build` - obraz bazowy pobierający kod i instalujący zależności.
2. `Dockerfile.test` - obraz korzystający z poprzedniego kroku, którego celem (ENTRYPOINT) jest uruchomienie testów.

Poniżej dowód odpalenia automatycznych testów z pliku testowego:
![Testy automatyczne z Dockerfile](screeny/7.png)

### 3. Docker Compose
**Cel:** Użycie Docker Compose do orkiestracji uruchamiania kontenerów testowych.
Stworzony został plik `docker-compose.yml`, który po wydaniu polecenia `docker compose up` automatycznie buduje i uruchamia etap testowy, zwracając logi bezpośrednio na standardowe wyjście:
![Docker Compose](screeny/8.png)

---

## Część III: Woluminy, Sieci i Jenkins

### 1. Zachowywanie stanu między kontenerami (Woluminy)
**Cel:** Przekazanie plików zbudowanej aplikacji z jednego kontenera do drugiego z wykorzystaniem woluminów bez "zaśmiecania" kontenera produkcyjnego narzędziami deweloperskimi (np. Git).

Utworzono dwa nazwane woluminy: `vol_wejsciowy` i `vol_wyjsciowy`.
Wykorzystano **kontener pomocniczy** (`alpine/git`), do sklonowania kodu (Express.js) bezpośrednio na wolumin wejściowy, po czym usunięto kontener (flaga `--rm`). 
Następnie uruchomiono główny kontener budujący (`node:20`), skompilowano aplikację z woluminu wejściowego i zapisano wyniki na wolumin wyjściowy. Poniżej weryfikacja (wylistowanie plików z woluminu przez osobny, lekki kontener alpine), udowadniająca, że stan przetrwał:
![Woluminy wyjściowe](screeny/voluminy.png)

### 2. Eksponowanie portu i łączność między kontenerami (iperf3)
**Cel:** Sprawdzenie przepustowości sieciowej między kontenerami w różnych konfiguracjach sieciowych za pomocą narzędzia `iperf3`.

* **Krok 1 (domyślna sieć mostkowa):** Uruchomiono serwer i klienta iperf3 uderzając bezpośrednio po adresie IP kontenera (np. `172.17.0.2`). Ruch symulowany był w pamięci operacyjnej maszyny wirtualnej, co dało bardzo wysoką przepustowość.
* **Krok 2 (sieć dedykowana i DNS):** Utworzono własną sieć (`docker network create iperf_siec`). Serwer i klient komunikowały się po nazwach kontenerów, a nie IP. Port serwera został wyeksponowany na hosta (`-p 5201:5201`).
![Test w dedykowanej sieci](screeny/iperf_dns.png)
* **Krok 3 (połączenie z hosta):** Narzędzie iperf3 zostało zainstalowane na hoście (środowisku Ubuntu), z którego nawiązano pomyślne połączenie z serwerem w kontenerze poprzez `127.0.0.1` dzięki przekierowaniu portów.
![Test z hosta](screeny/iperf_host.png)

### 3. Usługi w rozumieniu systemu i kontenera (SSHD)
**Cel:** Uruchomienie usługi SSH w kontenerze i omówienie wad takiego rozwiązania z perspektywy konteneryzacji.

Uruchomiono kontener oparty na Ubuntu, zainstalowano w nim serwer OpenSSH i wyeksponowano na port `2222` hosta. Logowanie do kontenera z poziomu środowiska wirtualnego zakończyło się sukcesem:
![Logowanie SSH](screeny/ssh_login.png)

**Analiza podejścia:**
Instalowanie usługi SSHD wewnątrz kontenera to uznany antywzorzec. Kontener powinien realizować pojedynczy proces biznesowy. Dodawanie SSH powiększa rozmiar obrazu, tworzy niepotrzebne luki bezpieczeństwa i kłóci się z zasadą niemutowalności środowiska (do zarządzania i inspekcji kontenera służy polecenie `docker exec`).

### 4. Przygotowanie serwera CI Jenkins (z Docker-in-Docker)
**Cel:** Wdrożenie gotowego środowiska automatyzacji CI/CD zgodnie z oficjalnymi wytycznymi twórców oprogramowania.

W oparciu o dokumentację, zestawiono dwa połączone dedykowaną siecią kontenery.
1. Kontener DinD (`docker:dind`), działający jako uprzywilejowany "pomocnik", umożliwiający używanie Dockera wewnątrz Dockera.
2. Kontener aplikacji Jenkins (`jenkins/jenkins:lts`), skonfigurowany pod połączenie z demonem DinD oraz eksponujący własny interfejs webowy (port `8080`).

Wykonano proces weryfikacji działających kontenerów:
![Działające kontenery Jenkinsa](screeny/jenkins_ps.png)

Następnie z logów woluminu pobrano początkowe hasło administratora (`initialAdminPassword`), zalogowano się poprzez przeglądarkę i zainstalowano sugerowane wtyczki. Poniżej dowód ukończenia inicjalizacji instancji:
![Panel główny Jenkinsa](screeny/jenkins_dashboard.png)


Pomoc AI 
Zapytanie:
"Przeredaguj tak aby było jednolite oraz usuń błędy ortograficzne itp." 


######################################################################################3

# Sprawozdanie: Laboratorium 5 i 6 - Pipeline CI/CD (Jenkins)

## 1. Wybrana Aplikacja i Repozytorium
Do wdrożenia wybrano prostą aplikację backendową napisaną w środowisku **Node.js** z wykorzystaniem frameworka **Express**. 
* **Licencja:** Kod ma charakter dydaktyczny, co pozwala na swobodny obrót nim na potrzeby zadania (licencja otwarta).
* **Repozytorium:** Zdecydowano się pracować na osobistej gałęzi (`SB422052`) wewnątrz istniejącego repozytorium przedmiotowego (`MDO2026s_ITE`), zamiast tworzyć pełnego forka.

## 2. Zadania Wstępne (Weryfikacja Środowiska)
W ramach rozgrzewki przygotowano projekty typu *Freestyle*, weryfikujące poprawność konfiguracji Jenkinsa:
1. `Zadanie_1_Uname` - Pomyślne wywołanie powłoki systemowej.
2. `Zadanie_2_Godzina` - Poprawne zachowanie przy błędzie (celowe przerwanie `exit 1` przy nieparzystej godzinie).
3. `Zadanie_3_Docker` - Pomyślne pobranie obrazu Ubuntu.

> **Dowód realizacji zadań wstępnych:**
> ![Widok projektów wstępnych](screeny/1.1.png)
> ![Logi błędu - zadanie z godziną](screeny/2.2.png)

## 3. Diagram Aktywności (Proces CI/CD)
Poniższy diagram UML obrazuje zaplanowany przepływ pracy w Jenkinsie:

```mermaid
graph TD
    classDef success fill:#d4edda,stroke:#28a745,stroke-width:2px,color:#000;
    classDef fail fill:#f8d7da,stroke:#dc3545,stroke-width:2px,color:#000;
    classDef info fill:#d1ecf1,stroke:#17a2b8,stroke-width:2px,color:#000;
    classDef action fill:#fff3cd,stroke:#ffc107,stroke-width:2px,color:#000;

    A([Start: Ręczny Trigger / Webhook Git]):::info --> B{Walidacja wstępna <br> }

    B -- Błąd  --> ERR1[Błąd: exit 1 <br> Przerwanie Pipeline]:::fail
    B -- Sukces --> C[Checkout SCM <br> Pobranie gałęzi SB422052]:::action

    subgraph Krok_1 [Etap 1: Build & Test środowisko DIND]
        C --> D[Budowa obrazu kontenera <br> node:18-alpine]
        D --> E[Uruchomienie środowiska testowego]
        E --> F{Wykonanie: npm test}
    end

    F -- Błąd testów --> ERR2[Sprzątanie środowiska i FAILURE]:::fail
    F -- Sukces testów --> G[Testy zaliczone]:::success

    subgraph Krok_2 [Etap 2: Publish]
        G --> H[Generowanie paczki <br> app-release.tar.gz]:::action
        H --> I[(Archiwizacja Jenkins <br> archiveArtifacts)]
    end

    subgraph Krok_3 [Etap 3: Deploy & Weryfikacja]
        I --> J[Wdrożenie na serwer <br> docker run -d express-prod-app]:::action
        J --> K[Wykonanie Smoke Testu <br> docker logs]
        K --> L{Czy serwer wstał?}
    end

    L -- Nie --> ERR3[Logowanie błędu i usunięcie kontenera]:::fail
    L -- Tak --> M[Czyszczenie środowiska <br> docker rm -f]:::action
    M --> N([Koniec: Status SUCCESS]):::success
```

4. Realizacja etapów Pipeline (Ścieżka Krytyczna)
Zgodnie z powyższym diagramem, zrealizowano potok CI/CD. Poniżej logi potwierdzające wykonanie kroków:

Krok 1: Budowa i Testowanie
Zbudowano obraz aplikacji na bazie node:18-alpine oraz przeprowadzono testy jednostkowe.

> ![logi z etapu clone](screeny/4.4.png) 
> ![logi z etapu build](screeny/build.png)
Krok 2: Publikacja Artefaktu (Publish)
Po pomyślnym przejściu testów, kod został spakowany do archiwum .tar.gz i zarchiwizowany w Jenkinsie.
> ![logi z etapu publish](screeny/publish.png)

Krok 3: Wdrożenie i Weryfikacja (Deploy & Smoke Test)
Uruchomiono kontener produkcyjny, pobrano logi w celu weryfikacji startu serwera, a następnie usunięto środowisko tymczasowe.

> ![logi z deploya i smoke testu](screeny/7.7.png)
> ![ogólny status pipelinu](screeny/6.6.png)


5. Odpowiedzi na pytania i wnioski
Format artefaktu: Wybrano archiwum .tar.gz. 

node vs node-slim: Obraz node posiada pełne środowisko kompilacji. Obraz node-slim jest go pozbawiony, co czyni go lżejszym i bezpieczniejszym na produkcji (mniejsza powierzchnia ataku)  .

Kontener Deploy: Zastosowano osobny kontener runtime, ponieważ kontener budujący zawiera zbędne zależności deweloperskie i pliki tymczasowe, które nie powinny znajdować się w środowisku docelowym.