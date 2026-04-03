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