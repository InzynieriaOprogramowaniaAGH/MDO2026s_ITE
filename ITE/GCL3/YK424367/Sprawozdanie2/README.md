# Sprawozdanie 2 (zajęcia 5-7)

## 1. Wstęp

Celem zajęć 5-7 było zbudowanie kompletnego pipeline'u CI/CD w Jenkinsie dla wybranej aplikacji.
Pipeline ma realizować ścieżkę krytyczną: **clone → build → test → deploy → publish**, najpierw z poziomu GUI Jenkinsa, a docelowo jako `Jenkinsfile` przechowywany w repozytorium (Pipeline script from SCM).

W moim przypadku zajęcia 6 i 7 połączyłem w jedną iterację pracy nad pipelinem, ponieważ od razu pisałem deklaratywny `Jenkinsfile` w repozytorium. Robienie tego najpierw w UI, a potem przepisywanie nie miało sensu.

## 2. Wybór aplikacji

Jako aplikację docelową wybrałem **[readme-aura](https://github.com/collectioneur/readme-aura)**, moją własną bibliotekę CLI/Node.js do generowania ozdobnych README, publikowaną na NPM.

- **Licencja**: MIT, tym bardziej że to jest moja biblioteka.
- **Fork**: nie był potrzebny, bo jestem właścicielem repo.
- **Nie dodawałem `Jenkinsfile` do repo `readme-aura`**: w `readme-aura` mam już działający pipeline na GitHub Actions, i z repo już korzystają realni użytkownicy paczki. Dorzucanie tam drugiego, równoległego pipeline'u Jenkinsa groziłoby konfliktem dwóch automatycznie publikujących workflowów na ten sam tag NPM. Zamiast tego trzymam `Jenkinsfile` w repo przedmiotowym (`MDO2026s_ITE`, w katalogu `Sprawozdanie2/`), a Jenkins klonuje sobie repo `readme-aura` w stage'u `Build` przez `Dockerfile.build`.

Dockerfile'e budujące/testujące/wdrażające `readme-aura` są w `Sprawozdanie1/` (powstały na zajęciach 2-4), więc pipeline odwołuje się do nich przez zmienną `COMPOSE_DIR`.

---

## 3. Zajęcia 5, uruchomienie Jenkinsa i pierwszy pipeline

### 3.1. Postawienie Jenkinsa

Jenkinsa postawiłem zgodnie z oficjalną instrukcją w architekturze DinD:

1. Dedykowana sieć dockerowa `jenkins`.
2. Kontener `jenkins-docker` (`docker:dind`) - daemon Dockera dla pipeline'ów.
3. Kontener `jenkins-blueocean` zbudowany z mojego `Dockerfile.jenkins` (Jenkins LTS + `docker-ce-cli` + pluginy `blueocean docker-workflow json-path-api`).

Dzięki temu pipeline w Jenkinsie ma własnego daemona Dockera, odizolowanego od hosta, ale dostępnego po sieci pod aliasem `docker:2376` z TLS-em.

### 3.2. Trzy proste skrypty (Freestyle projects)

Pierwsze zadanie polegało na sprawdzeniu, że Jenkins w ogóle wykonuje skrypty shellowe i że ma kontakt z daemonem Dockera. Zrobiłem trzy projekty typu Freestyle, każdy z innym skryptem:

**Skrypt 1 - `uname`:**
```bash
uname -a
```

**Skrypt 2 - godzina parzysta/nieparzysta:**
```bash
hour=$(date +%-H)
if [ $((hour % 2)) -eq 1 ]; then
  echo "nieparzysta ($hour)"
fi
echo "parzysta ($hour)"
```

**Skrypt 3 - `docker pull ubuntu`:**
```bash
docker pull ubuntu
```

Wszystkie trzy zadania wykonały się bez problemu, co potwierdziło, że Jenkins ma poprawne połączenie z daemonem Dockera w kontenerze DinD.

![uname, godzina, docker pull](./assets/Screenshot%202026-05-07%20at%2019.48.35.png)

![Logi z uruchomienia skryptów Freestyle](./assets/Screenshot%202026-05-07%20at%2019.50.03.png)

### 3.3. Pierwszy obiekt typu Pipeline

Następnie zrobiłem pierwszy obiekt typu **Pipeline** z definicją wpisaną bezpośrednio w UI Jenkinsa. Pipeline miał:

1. Sklonować repo przedmiotowe.
2. Zrobić checkout na moją gałąź `YK424367`.
3. Zbudować obraz na podstawie `Dockerfile.build` z `Sprawozdanie1/`.

```groovy
pipeline {
  agent any
  stages {
    stage('Clone') {
      steps {
        sh '''
          rm -rf repo || true
          git clone --depth 1 --branch YK424367 \
            https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git repo
        '''
      }
    }
    stage('Build') {
      steps {
        sh '''
          cd repo
          docker build -t ra-build-lab \
            -f ITE/GCL3/YK424367/Sprawozdanie1/Dockerfile.build .
        '''
      }
    }
  }
}
```

Klonowanie i checkout zrobiłem jednym poleceniem `git clone --depth 1 --branch YK424367` zamiast oddzielnego `git checkout`, bo to jednoznacznie pobiera tylko interesującą mnie gałąź.

![clone + build readme-aura](./assets/Screenshot%202026-03-31%20at%2009.27.04.png)

Przy drugim uruchomieniu pipeline'u zauważyłem, że Jenkins cache'uje sklonowane repo (kolejne buildy nie pobierały świeżego kodu). To była ważna obserwacja, bo cache'owanie oznacza, że pipeline może produkować wyniki na bazie nieaktualnego kodu. W finalnym pipelinie na zajęciach 6-7 rozwiązałem to przez `cleanWs()` + `--no-cache` w `docker build` tam, gdzie to istotne.

![Cache'owanie repo readme-aura przez Jenkinsa](./assets/Screenshot%202026-05-07%20at%2020.00.19.png)

---

## 4. Zajęcia 6 + 7 - pełny pipeline `readme-aura` z SCM

### 4.1. Konfiguracja w UI Jenkinsa

W Jenkinsie skonfigurowałem nowy obiekt Pipeline z opcją **Pipeline script from SCM**:

- repozytorium: `https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git`
- gałąź: `*/YK424367`
- ścieżka do skryptu: `ITE/GCL3/YK424367/Sprawozdanie2/Jenkinsfile`

Dzięki temu każda zmiana `Jenkinsfile`'a w repo (po pushu) jest automatycznie używana przy następnym buildzie, definicja pipeline'u jest częścią kodu, a nie konfiguracji Jenkinsa.

![Konfiguracja Pipeline script from SCM](./assets/Screenshot%202026-05-07%20at%2020.01.41.png)

### 4.2. Struktura pipeline'u - etap po etapie

Pełny `Jenkinsfile` znajduje się w pliku [`Jenkinsfile`](./Jenkinsfile) w tym samym katalogu. Poniżej omawiam go etapami.

#### Nagłówek

```groovy
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        skipDefaultCheckout()
    }

    environment {
        COMPOSE_DIR = 'ITE/GCL3/YK424367/Sprawozdanie1'
    }
```

- `agent any` - pozwala Jenkinsowi wybrać dowolny dostępny węzeł/executor; mam tylko jeden, więc to bezpieczny default.
- `disableConcurrentBuilds()` - blokuje równoległe uruchomienia tego samego pipelineu.
- `skipDefaultCheckout()` - wyłącza domyślny checkout SCM, żebym mógł zrobić go ręcznie po `cleanWs()`. Inaczej Jenkins najpierw automatycznie sklonowałby repo do (potencjalnie brudnego) workspace'u, a dopiero potem uruchomiłby moje stage'y.
- `COMPOSE_DIR` - wszystkie Dockerfile'e (`Dockerfile.build`, `Dockerfile.test`, `Dockerfile.deploy`) razem z `docker-compose.yml` leżą w katalogu `Sprawozdanie1/`.

#### Stage `Checkout`

```groovy
stage('Checkout') {
    steps {
        cleanWs()
        checkout scm
    }
}
```

Ręczny checkout w dwóch krokach:
1. `cleanWs()` - wyczyszczenie workspace'u Jenkinsa (usuwa wszystko, co zostało po poprzednim buildzie). To gwarantuje, że pracujemy na świeżym kodzie.
2. `checkout scm` - klonowanie repo w konfiguracji ustawionej w UI.

#### Stage `Build image`

```groovy
stage('Build image') {
    steps {
        dir("${env.COMPOSE_DIR}") {
            sh 'docker compose build readme-aura-build'
        }
    }
}
```

W tym etapie buduję obraz `mdo-ite:sprawozdanie3-build` zdefiniowany w `docker-compose.yml`:

```dockerfile
FROM node:20
WORKDIR /readme-aura
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/collectioneur/readme-aura.git .
RUN npm install
RUN npm run build
```

Obraz buildowy klonuje aktualny kod `readme-aura`, instaluje zależności i kompiluje TypeScripta. Wszystkie kolejne stage'y (`Test`, `Deploy`) bazują na nim przez `FROM mdo-ite:sprawozdanie3-build`, więc budujemy go raz.

#### Stage `Test`

```groovy
stage('Test') {
    steps {
        dir("${env.COMPOSE_DIR}") {
            sh 'docker build -t mdo-ite:sprawozdanie3-test -f Dockerfile.test . && docker run --rm mdo-ite:sprawozdanie3-test'
        }
    }
}
```

`Dockerfile.test` to dosłownie:

```dockerfile
FROM mdo-ite:sprawozdanie3-build
WORKDIR /readme-aura
CMD ["npm", "test"]
```

Świadomie **nie używam tutaj `docker compose build readme-aura-test`** - tylko ręcznego `docker build`. Powód: `docker compose build` spróbowałby na nowo zbudować zależność `readme-aura-build` (mimo że obraz już istnieje z poprzedniego stage'a), co dodawałoby kilka sekund do czasu pipeline'u. `docker build` z `FROM mdo-ite:sprawozdanie3-build` po prostu używa istniejącego obrazu z lokalnego daemona Dockera.

`docker run --rm` od razu uruchamia testy i czyści po sobie kontener. Jeśli `npm test` zwróci kod inny niż 0, cały pipeline pada.

#### Stage `Deploy`

```groovy
stage('Deploy') {
    steps {
        dir("${env.COMPOSE_DIR}") {
            sh """
                set -e
                docker build -t mdo-ite:sprawozdanie6-deploy -f Dockerfile.deploy .
                docker run --rm mdo-ite:sprawozdanie6-deploy
                docker tag mdo-ite:sprawozdanie6-deploy mdo-ite:sprawozdanie6-deploy-build-${env.BUILD_NUMBER}
            """.stripIndent()
        }
    }
}
```

Tutaj dzieją się trzy rzeczy:

1. **Build obrazu deployowego** (`Dockerfile.deploy`):
   ```dockerfile
   FROM mdo-ite:sprawozdanie3-build
   WORKDIR /readme-aura
   RUN npm pack
   CMD ["sh", "-c", \
     "mkdir -p /tmp/deploy-run && cd /tmp/deploy-run && \
      npm init -y && \
      npm install /readme-aura/*.tgz && \
      npx readme-aura init --template PurpleGlow && \
      npx readme-aura build"]
   ```
   Obraz na etapie buildu pakuje paczkę przez `npm pack` (powstaje `*.tgz`). Jego `CMD` symuluje ścieżkę realnego użytkownika końcowego: tworzy świeży projekt w `/tmp/deploy-run`, instaluje paczkę z lokalnego tarballa (tak jakby ją ściągnął z NPM), inicjalizuje konfigurację z szablonem `PurpleGlow` i buduje README przez `npx readme-aura build`.

2. **Smoke test** - `docker run --rm mdo-ite:sprawozdanie6-deploy` uruchamia ten `CMD`. Jeśli paczka z jakiegoś powodu nie działa (np. brakuje pliku w `npm pack`, broken entrypoint, nieprawidłowy `package.json`), `npx readme-aura build` zwróci błąd, kontener wyleci z niezerowym exit code i pipeline padnie. To jest weryfikacja end-to-end.

3. **Wersjonowanie obrazu** - `docker tag ... -build-${env.BUILD_NUMBER}` taguje deploy-image numerem builda Jenkinsa. Dzięki temu, jeśli kiedyś będę chciał porównać dwie wersje deployu między sobą lub wrócić do konkretnej, mam je rozróżnione w lokalnym daemonie po tagu.

`set -e` na początku gwarantuje, że jeśli `docker build` lub `docker run` zwróci błąd, kolejne komendy się nie wykonają.

#### Stage `Publish`

```groovy
stage('Publish') {
    steps {
        dir("${env.COMPOSE_DIR}") {
            sh '''
                mkdir -p artifacts
                CID=$(docker create mdo-ite:sprawozdanie6-deploy)
                docker cp ${CID}:/readme-aura/. artifacts/
                docker rm ${CID}
            '''
            archiveArtifacts artifacts: 'artifacts/*.tgz', fingerprint: true
            writeFile file: 'publish.sh', text: """#!/bin/sh
set -e
cd /readme-aura
rm -f *.tgz
VERSION=\$(node -e "process.stdout.write(require('./package.json').version)")
npm version --no-git-tag-version \${VERSION}-canary.${env.BUILD_NUMBER}
npm pack
npm config set //registry.npmjs.org/:_authToken \${NPM_TOKEN}
npm publish *.tgz --tag canary --access public
"""
            withCredentials([string(credentialsId: 'npm-token', variable: 'NPM_TOKEN')]) {
                sh """
                    docker run --rm \\
                        -e NPM_TOKEN=\${NPM_TOKEN} \\
                        -v ${env.WORKSPACE}/${env.COMPOSE_DIR}/publish.sh:/publish.sh:ro \\
                        mdo-ite:sprawozdanie6-deploy \\
                        sh /publish.sh
                """
            }
            sh 'rm -f publish.sh'
        }
    }
}
```

Najdłuższy stage, dzieli się na dwie części:

**a) Artefakt lokalny (Jenkins)** - `docker create` + `docker cp` wyciąga zawartość `/readme-aura/` z obrazu deploy do katalogu `artifacts/`. Wśród skopiowanych plików jest `*.tgz` z `npm pack` (zrobiony jeszcze w `Dockerfile.deploy`). 

**b) Publikacja na NPM** - paczka idzie do publicznego rejestru z tagiem `canary`, a nie `latest`. To było moje świadome zabezpieczenie przed ewentualnym konfliktem z drugim pipeline'em (GitHub Actions), który publikuje `latest`.

`withCredentials([string(credentialsId: 'npm-token', variable: 'NPM_TOKEN')])` - token NPM jest trzymany w Jenkins Credentials i wstrzykiwany do skryptu jako zmienna środowiskowa. Jenkins automatycznie maskuje jego wartość w outputie konsoli.

`writeFile` + bind-mount przez `-v` zamiast inline `sh -c "…"` - bo skrypt publish jest na tyle długi, że łatwiej go napisać raz do pliku i zamontować jako read-only do kontenera.

#### Stage `post`

```groovy
post {
    always {
        dir("${env.COMPOSE_DIR}") {
            sh 'rm -rf artifacts || true'
        }
    }
}
```

Po każdym buildzie (sukces albo porażka) usuwam katalog `artifacts/` z workspace'u. Pliki `*.tgz` są już zapisane przez `archiveArtifacts` w Jenkinsie, więc trzymanie ich jeszcze raz w workspace'ie może powodować konflikty przy następnym buildzie.

### 4.3. Wynik uruchomienia

Pipeline odpalony przez SCM przechodzi wszystkie pięć etapów (Checkout → Build image → Test → Deploy → Publish), żaden krok nie jest cache'owany, a logi pokazują, że każda komenda wykonuje się dokładnie raz:

![Wszystkie stage'y pipeline'u przechodzą](./assets/Screenshot%202026-05-07%20at%2019.32.23.png)

Dla potwierdzenia, że Publish faktycznie dociera do publicznego rejestru - strona paczki na NPM:

![Wersje canary readme-aura na NPM (2 udane publikacje z różnymi BUILD_NUMBER)](./assets/Screenshot%202026-05-07%20at%2019.33.48.png)

Inkrementujące się numery wersji (`-canary.N`) potwierdzają, że pipeline jest powtarzalny i że każde przejście realnie kończy się publikacją nowego, jednoznacznie zwersjonowanego artefaktu.

---

## 5. Napotkane problemy

### 5.1. Jenkins nie łączył się z DinD

Po pierwszym uruchomieniu Jenkins nie potrafił dogadać się z kontenerem `jenkins-docker` (DinD). Próby dockerowych poleceń w pipelinie kończyły się błędem typu "cannot connect to the Docker daemon". Czyszczenie konfiguracji nie pomagało, więc usunąłem całą konfiguracje i postawiłem wszystko od nowa z `Dockerfile.jenkins`. Po reinstalacji daemon DinD odpowiadał poprawnie.

### 5.2. Niedziałająca interpolacja `NPM_TOKEN`

Skrypt `publish.sh` początkowo dostawał pusty `NPM_TOKEN` i `npm publish` waliło 401. Po dopisaniu backslashy w odpowiednich miejscach (`\${NPM_TOKEN}` tam, gdzie ma to być zmienna shellowa, a `${env.BUILD_NUMBER}` tam, gdzie chcę wartość z Groovy'ego), wszystko zaczęło działać.

### 5.3. Pomoc AI

Skrypt `publish.sh` w stage `Publish` napisałem z pomocą asystenta AI - głównie dlatego, że wcześniej miałem podobne problemy w GitHub Actions z autoryzacją 2FA, i nie chciałem trzeci raz pisać tego od zera.

Również poprosiłem agenta o przepisanie i ustrukturyzowanie sprawozdania, żeby czytało się łatwiej, bo opisałem to wszystko trochę chaotycznie.

---

## 6. Definition of done

### 6.1. Czy opublikowany obraz / artefakt może być pobrany z rejestru i uruchomiony bez modyfikacji?

Tak. Po przejściu pipeline'u paczka `readme-aura@canary` jest dostępna w publicznym rejestrze NPM. Dowolny użytkownik może w pustym katalogu wykonać:

```bash
npm init -y
npm install readme-aura@canary
npx readme-aura init --template PurpleGlow
npx readme-aura build
```

i dostać działającą instalację.

Tag `canary` jest świadomym wyborem: standardowi konsumenci `readme-aura` dalej dostają stabilną wersję od pipeline'u z GitHub Actions, a kanał Jenkinsowy służy do publikacji na potrzeby tego laboratorium.

### 6.2. Czy artefakt dołączony do przejścia pipeline'u zadziała od razu na docelowej maszynie?

**Tak.** Tarball `*.tgz` archiwizowany przez `archiveArtifacts` to standardowa paczka NPM wyprodukowana przez `npm pack`. Wymaganiem środowiska docelowego jest jedynie zainstalowany Node.js:

```bash
npm install ./readme-aura-0.4.4-canary.13.tgz
npx readme-aura build
```

i paczka działa bez kompilacji.

---

## 7. Podsumowanie

Pipeline realizuje pełną ścieżkę krytyczną CI/CD wymaganą przez zajęcia 5-7:

- Jenkinsfile z SCM, a nie z UI,
- `cleanWs()` + `skipDefaultCheckout()` + ręczny `checkout scm` gwarantują pracę na świeżym kodzie,
- stage'y Build, Test, Deploy, Publish realizują kolejno: build w izolowanym kontenerze, testy w kontenerze opartym o build, smoke test deployu uruchamiający paczkę z perspektywy użytkownika końcowego, publikację do publicznego rejestru NPM,
- artefakt jest zarówno dostępny lokalnie w Jenkinsie (z `fingerprint: true`), jak i w globalnym rejestrze NPM pod tagiem `canary`,
- wersjonowanie artefaktu wykorzystuje `BUILD_NUMBER` (semver pre-release: `X.Y.Z-canary.N`),
- `withCredentials` zapewnia, że `NPM_TOKEN` nigdy nie ląduje w logach,
- `disableConcurrentBuilds()` zapobiega kolizjom równoległych przebiegów,
- pipeline może być uruchamiany dowolną liczbę razy - żadne dane nie są cache'owane.