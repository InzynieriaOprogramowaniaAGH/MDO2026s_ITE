# Laboratorium 5

## 1. Pipeline, Jenkins, izolacja etapów

### Cel
Celem zadania była instalacja serwera Jenkins, konfiguracja początkowa oraz utworzenie i uruchomienie wieloetapowego potoku (pipeline) realizującego kroki *build-test-publish-deploy* dla aplikacji Node.js (NestJS), opierając się na obrazach wypracowanych na poprzednich zajęciach.

------------------------------------------------------------------------

### Krok 1. Uruchomienie instancji Jenkins z dostępem do Dockera
Wykorzystano autorski `Dockerfile.jenkins` wspierający klienta Docker. Kontener uruchomiono z prawami roota (`-u root`) oraz wmontowano gniazdo demona Dockera hosta (socket), aby umożliwić Jenkinsowi zlecanie budowy kontenerów.

```bash
docker build -t my-jenkins -f ITE/GCL1/MD419430/Sprawozdanie1/Dockerfile.jenkins ITE/GCL1/MD419430/Sprawozdanie1/
docker run -d -u root -p 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home --name jenkins my-jenkins
```
![alt text](../img/L5/L5-01.png)


Pobrano startowe hasło administratora by ukończyć inicjalizację w UI przeglądarkowym na standardowym porcie 8080:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
![alt text](../img/L5/L5-02.png)

------------------------------------------------------------------------

### Krok 2. Zadania wstępne (Freestyle projects)
W interfejsie serwera sprawdzono elementarne operacje przygotowując 3 podstawowe projekty typu *Freestyle project*:
1. **Wyświetlający informacje o systemie** (skrypt: `uname -a`)

![alt text](../img/L5/L5-03.png)

2. **Warunkowy błąd** (zwraca exit code 1 i błąd w logach po weryfikacji nieparzystości obecnej godziny za pomocą modulo)

![alt text](../img/L5/L5-04.png)

3. **Pobierający obraz testowy** (`docker pull ubuntu`)

![alt text](../img/L5/L5-05.png)

![alt text](../img/L5/L5-06.png)
------------------------------------------------------------------------

### Krok 3. Wstępny obiekt typu Pipeline (skrypt w UI Jenkinsa)
Zestawiono proste zadanie w typie Pipeline, którego kod wklejono bezpośrednio do konfiguracji projektu. Kod ten pobiera repozytorium z domyślnego serwera zdalnego na wskazaną gałąź, a potem buduje pierwszą warstwę zależności aplikacji TypeScript.

```groovy
pipeline {
    agent any
    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'MD419430', url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
            }
        }
        stage('Build Docker') {
            steps {
                dir('ITE/GCL1/MD419430/Sprawozdanie1') {
                    sh 'docker build -t app-builder -f Dockerfile.build ./work/typescript-starter/'
                }
            }
        }
    }
}
```

![alt text](../img/L5/L5-07.png)
![alt text](../img/L5/L5-08.png)

# Laboratorium 6

## 1. Kompletny Pipeline CI/CD, izolacja etapów i publikacja

### Cel
Celem zadania było zaprojektowanie i wdrożenie pełnego procesu CI/CD (ścieżka: *clone -> build -> test -> deploy -> publish*) dla aplikacji NestJS. Konfigurację potoku zapisano w repozytorium jako kod (`Jenkinsfile`). Wykorzystano oddzielne kontenery Dockera dla poszczególnych etapów pracy.

------------------------------------------------------------------------

### Krok 1. Projektowanie procesu
W pierwszej kolejności zaplanowano architekturę. Zdecydowano się na testowanie "Black-Box". Główne procesy odbywają się w podstawowym kontenerze (C1), w którym budujemy aplikację i uruchamiamy testy jednostkowe. Następnie do weryfikacji działania programu uruchamiany jest drugi, lekki kontener (C2), który działa jak zwykły użytkownik testujący dostępność poprzez sieć.

![alt text](../img/L6/L6-diagram-uml.png)

------------------------------------------------------------------------

### Krok 2. Konfiguracja Jenkinsa

W systemie wybrano opcję **Pipeline script from SCM**. Dzięki temu Jenkins automatycznie pobiera instrukcje potoku z GitHuba, co ułatwia zarządzanie i wersjonowanie kodu.

Dodatkowo, zrezygnowano ze skomplikowanego instalowania Dockera wewnątrz Dockera. Zamiast tego Jenkins otrzymał dostęp do procesu obsługującego Dockera na głównej maszynie (`/var/run/docker.sock`).

![alt text](../img/L6/L6-scm.png)

------------------------------------------------------------------------

### Krok 3. Przygotowanie obrazu Docker (Kontener C1)
Aby zbudować program w powtarzalnych warunkach, stworzono plik `Dockerfile.ci`.
Wykorzystano obraz `node:22-bookworm-slim`.Tego samego obrazu można użyć zarówno do testowania, jak i uruchomienia gotowego programu, bez tworzenia dodatkowych plików wdrożeniowych środowiska roboczego.

Pakiety aplikacji są wgrywane opcją `npm ci`, która gwarantuje uzycie sztywnych i stałych wersji paczek z pliku konfiguracyjnego projektu. Kod aplikacji znajduje sie w docelowym folderze `/app/dist`.

```dockerfile
FROM node:22-bookworm-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "start:prod"]
```

------------------------------------------------------------------------

### Krok 4. Potok w Jenkinsie (`Jenkinsfile`)
Proces podzielono na następujące kroki:

1. **Pobieranie kodu (Clone)**: Skrypt automatycznie pobiera z GitHuba najnowszą wersje kodu.
2. **Budowanie i testowanie (C1)**: Aplikacja jest zamykana w kontenerze z unikalną nazwą powiązaną numerem kompilacji. Wykonywane są tam testy (`npm run test`). Błędy natychmiastowo przerywają działanie potoku.
3. **Uruchomienie**: Program włącza się jako usługa tła w dedykowanej wirtualnej sieci Dockera (`test-net`). Port 3000 programu ukryto wewnątrz wirtualnej prywatnej sieci i nie jest on widoczny na zewnątrz co uskutecznia oddzielenie środowiska developerskiego.
4. **Test z użyciem klienta (C2)**: Do sieci testowej dołącza kolejny mikro-kontener służący jako klient z poleceniem `curl`. Narzędzie wykonuje standardowe wywołanie HTTP do głównego kontenera aplikacji. Reakcja decyduje, czy budowa kończy się sukcesem, czy kasowana jest w obliczu rzuconego awaryjnego błędu.
5. **Publikacja aplikacji (Publish)**: Typową finalną formą dla aplikacji Node.js jest rejestr pakietów NPM. Jako scenariusz publikacji dodano użycie bezpiecznej komendy symulującej pakowanie i upload `npm publish --dry-run`. Zapobiega to wgrywaniu testowych bibliotek do rejestru publicznego wykonując poprawne operacje walidujące w bezpieczny sposób.

![alt text](../img/L6/L6-01.png) 

![alt text](../img/L6/L6-02.png)

![alt text](../img/L6/L6-03.png)

![alt text](../img/L6/L6-04.png)

------------------------------------------------------------------------

### Weryfikacja zgodnie z wytycznymi z ćwiczeń
*   **Commit/Clone**: Działa w pełni zautomatyzowanie z pomocą podłączenia pod system źródłowy SCM oraz serwera GitHub.
*   **Build**: Zrealizowano wewnątrz zmniejszonego kontenera w izolacji bazując na tagu `node:slim`.
*   **Test**: Obejmuje środowiskowe zintegrowane sprawdzenie HTTP testem dymnym (*Smoke-Test*) wykorzystujac zewnetrzny symulator klienta.
*   **Deploy**: Realizacja przebiegła bez wpływu na resztę systemu stawiając na wyłączną wirtualną łączność dockera, gdzie stworzony przedtem kontener-budowniczy spełnił sie jako środowisko wdrożeniowe.
*   **Publish**: Artefaktem stał sie sformowany z całości i sprawdzony pakiet deweloperski aplikacji node dla rejestru NPM i przetestowany próbnie dry-run'em. Posilkowano sie wersjonowaniem semanticznym wykorzystujac wpisane wartości od reki w pliki struktury aplikacji.