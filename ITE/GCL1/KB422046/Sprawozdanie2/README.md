# Sprawozdanie 2

#### Informacje wstępne
Stanowisko pracy obejmuje: maszynę wirtualną postawioną w Hyper-v (na bazie obrazu Ubuntu Serwer 24.04.4), edytor VS Code połączony zdalnie z maszyną oraz program FileZilla dla ułatwionego przesyłania plików.

Do realizacji laboratoriów wybrano repozytorium narzędzia [*curl*](https://github.com/curl/curl) -  posiada ono otwartą licencję, możliwość budowy kodu oraz uruchamialne testy.

Wszystkie zawarte w poniższym sprawozdaniu polecenia wykonane zostały z poziomu wbudowanego terminala VS Code lub interfejsu Jenkins'a. Szczegółowa historia poleceń została zawarta w oddzielnym [pliku](command_history.txt).

## Przeprowadzono instalację Jenkins'a zgodnie z dokumentacją:
![](1.1.png)

#### Użyto poniższego [Dockerfile'a](Dockerfile) do zbudowania obrazu Jenkins'a:
```
FROM jenkins/jenkins:2.541.3-jdk21
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"
```

#### Zbudowano obraz BlueOcean:
![](1.3.1.png)
![](1.3.2.png)

#### Uruchomiono kontener na podstawie zbudowanego obrazu:
![](1.4.png)

#### Pozyskano domyślne hasło administratora:
![](1.5.png)

#### Utworzono konto administratora:
![](1.6.png)

#### Skonfigurowano Jenkins'a:
![](1.7.png)
![](1.8.png)
![](1.9.png)

*Obraz Jenkins'a jest "bazą" dla BlueOcean, który poprzez dodatkowy zestaw pluginów poszerza funkcjonalność UI o chociażby wizualizację pipeline’ów.*

*DIND to osobny kontener działający jako daemon Docker'a, z którym Jenkins łączy się poprzez TLS (DOCKER_HOST=tcp://docker:2376). Zapewnia to m. in. izolację zasobów względem host'a.*

## Zadania wstępne:

* zadanie 1

![](1.10.1.png)
![](1.10.2.png)

*wyświetlenie wyniku wywołania polecenia uname*

* zadanie 2

![](1.11.1.png)
![](1.11.2.png)

*zwrócenie błędu, gdy aktualna godzina jest nieparzysta*

* zadanie 3

![](1.12.1.png)
![](1.12.2.png)

*pobranie obrazu ubuntu:latest*

*Zadania wstępne potwierdziły, że Jenkins poprawnie uruchamia polecenia, oraz że jego kontener ma dostęp do Dockera poprzez DIND.*

## Wstępny pipeline:
Pipeline ma za zadanie sklonować repozytorium przedmiotowe, a następnie zbudować obraz na podstawie pliku [Dockerfile.build](Dockerfile.build). Instrukcja wymagała wykorzystania pliku budującego z poprzedniego sprawozdania, jednak zmiana sposobu konfiguracji oprogramowania (obecnie należy używać *autoreconf* zamiast *buildconf*) sprawiła, że wcześniejszy [Dockerfile.build](../Sprawozdanie1/Dockerfile.build) przestał działać. W rezultacie do budowy musiał zostać wykorzystany poprawiony Dockerfile z katalogu */Sprawozdanie2*.

#### Konfiguracja pipeline:
![](1.13.1.png)

#### Efekt uruchomienia:
![](1.13.2.png)
![](1.13.3.png)

#### Efekt ponownego uruchomienia:
![](1.13.4.png)
![](1.13.5.png)

*Przy drugim uruchomieniu wykorzystane zostały dane zachowane z pierwszego. Wynika to z widocznych pod wywołanymi poleceniami komunikatach "CACHED". Dzięki temu Jenkins ukończył zadanie znacznie szybciej.*

## Kompletny pipeline
Przygotowano docelowy proces CI/CD zgodnie ze ścieżką krytyczną: *clone → build → test → deploy → publish*. Skrypt nie jest już jedynie „wklejony” w UI Jenkinsa - definicja pipeline'u znajduje się w repozytorium, skąd jest pobierana.

#### Opracowano diagramy UML opisujące środowisko oraz przebieg pipeline’u:
![](3.5.png)
![](3.4.png)

#### Skonfigurowano obiekt pipeline jako „Pipeline script from SCM”, wskazując repozytorium, gałąź oraz ścieżkę do [Jenkinsfile](Jenkinsfile):
![](2.1.1.png)
![](2.1.2.png)

#### [Jenkinsfile](Jenkinsfile)

```
pipeline {
    agent any

    environment {
        APP_NAME      = 'my-curl'
        WORK_DIR      = 'ITE/GCL1/KB422046/Sprawozdanie2'
        BUILDER_IMAGE = "${APP_NAME}-builder-${env.BUILD_ID}"
        RUNTIME_IMAGE = "${APP_NAME}-runtime-${env.BUILD_ID}"
        TEST_NET      = "test-net-${env.BUILD_ID}"
        C1_NAME       = "C1-${env.BUILD_ID}"
        C2_NAME       = "C2-${env.BUILD_ID}"
        C3_NAME       = "C3-${env.BUILD_ID}"
    }

    stages {
        stage('Build & Unit Test (WITH SSL)') {
            steps {
                dir("${env.WORK_DIR}") {
                    sh "docker build --pull --no-cache -t ${env.BUILDER_IMAGE} -f Dockerfile_ssl.build ."
                    
                    script {
                        def ver = sh(script: "docker run --rm ${env.BUILDER_IMAGE} sh -lc 'cd /repository/curl && LD_LIBRARY_PATH=/repository/curl/lib/.libs src/.libs/curl -V'", returnStdout: true).trim()
                        if (!ver.contains("https")) { error("Builder curl nadal bez HTTPS (przerywam)!") }
                    }
                    
                    sh "docker run --rm ${env.BUILDER_IMAGE} sh -lc 'cd /repository/curl && make test'"
                }
            }
        }

        stage('Extract & Build Runtime (C0)') {
            steps {
                dir("${env.WORK_DIR}") {
                    sh """
                        docker create --name extract-${env.BUILD_ID} ${env.BUILDER_IMAGE}
                        rm -rf curl-bin curl-lib
                        docker cp extract-${env.BUILD_ID}:/repository/curl/src/.libs/curl ./curl-bin
                        docker cp extract-${env.BUILD_ID}:/repository/curl/lib/.libs ./curl-lib
                        docker rm -f extract-${env.BUILD_ID}
                    """

                    sh "docker build --pull --no-cache -t ${env.RUNTIME_IMAGE} -f Dockerfile.run ."
                    
                    script {
                        def ver = sh(script: "docker run --rm ${env.RUNTIME_IMAGE} curl -V", returnStdout: true).trim()
                        if (!ver.contains("https")) { error("Runtime curl nadal bez HTTPS (zły artefakt)!") }
                    }
                }
            }
        }

        stage('Integration Tests (C1, C2, C3)') {
            steps {
                dir("${env.WORK_DIR}") {
                    sh """
                        docker network create ${env.TEST_NET}

                        # Wygenerowanie certyfikatu SSL dla C2 w bieżącym katalogu
                        docker run --rm -v "\$(pwd):/workspace" ${env.BUILDER_IMAGE} \
                            openssl req -x509 -newkey rsa:2048 -keyout /workspace/key.pem -out /workspace/cert.pem \
                            -days 1 -nodes -subj "/CN=C2"

                        # Uruchomienie mikroserwerów Pythona (skrypty ładowane bezpośrednio z katalogu bieżącego)
                        docker run -d --name ${env.C1_NAME} --network ${env.TEST_NET} --network-alias C1 -v "\$(pwd):/workspace" python:3-slim python /workspace/mock_http.py
                        docker run -d --name ${env.C2_NAME} --network ${env.TEST_NET} --network-alias C2 -v "\$(pwd):/workspace" python:3-slim python /workspace/mock_https.py
                        docker run -d --name ${env.C3_NAME} --network ${env.TEST_NET} --network-alias C3 -v "\$(pwd):/workspace" python:3-slim python /workspace/mock_rest.py
                        sleep 2
                    """

                    script {
                        def out1 = sh(script: "docker run --rm --network ${env.TEST_NET} ${env.RUNTIME_IMAGE} curl -sS http://C1:81", returnStdout: true).trim()
                        if (out1 != "HTTP_OK") { error("C1 nie OK: ${out1}") }

                        def out2 = sh(script: "docker run --rm --network ${env.TEST_NET} ${env.RUNTIME_IMAGE} curl -sS -k https://C2:82", returnStdout: true).trim()
                        if (out2 != "HTTPS_OK") { error("C2 nie OK: ${out2}") }

                        def out3 = sh(script: "docker run --rm --network ${env.TEST_NET} ${env.RUNTIME_IMAGE} curl -sS -X POST http://C3:93", returnStdout: true).trim()
                        if (out3 != "REST_OK") { error("C3 nie OK: ${out3}") }

                        echo "Integracja zakonczona! C1=HTTP, C2=HTTPS, C3=POST"
                    }
                }
            }
        }

        stage('Publish (.deb)') {
            steps {
                dir("${env.WORK_DIR}") {
                    sh """
                        rm -rf my-curl-deb *.deb
                        mkdir -p my-curl-deb/DEBIAN my-curl-deb/usr/local/bin my-curl-deb/usr/local/lib
                        cp curl-bin my-curl-deb/usr/local/bin/curl
                        cp -a curl-lib/* my-curl-deb/usr/local/lib/

                        cat > my-curl-deb/DEBIAN/control <<EOF
Package: my-custom-curl
Version: 1.0.${env.BUILD_ID}
Architecture: amd64
Maintainer: GCL1
Description: Custom curl built in Jenkins (HTTP/HTTPS/REST integration verified)
EOF
                        chmod 755 my-curl-deb/DEBIAN
                        chmod 644 my-curl-deb/DEBIAN/control

                        docker run --rm -v "\$(pwd):/workspace" ${env.BUILDER_IMAGE} dpkg-deb --build /workspace/my-curl-deb /workspace/my-custom-curl_1.0.${env.BUILD_ID}_amd64.deb
                    """
                    archiveArtifacts artifacts: "my-custom-curl_1.0.${env.BUILD_ID}_amd64.deb", allowEmptyArchive: false
                }
            }
        }
    }

    post {
        always {
            sh """
                docker rm -f ${env.C1_NAME} ${env.C2_NAME} ${env.C3_NAME} 2>/dev/null || true
                docker network rm ${env.TEST_NET} 2>/dev/null || true
            """
            dir("${env.WORK_DIR}") {
                sh "rm -rf my-curl-deb *.deb curl-bin curl-lib key.pem cert.pem 2>/dev/null || true"
            }
        }
    }
}
```

Użyte w powyższym pipeline pliki:
* [Dockerfile_ssl.build](Dockerfile_ssl.build) - nowy plik budujący ze skonfigurowaną obsługą SSL, która była wymagana do wykonania drugiego testu (HTTPS)
* [Dockerfile.run](Dockerfile.run) - buduje odchudzony obraz runtime (C0), zawierający binarkę i wymagane biblioteki, bez zależności buildowych
* [mock_http.py](mock_http.py) - serwer HTTP do testu integracyjnego (C1)
* [mock_https.py](mock_https.py) - serwer HTTPS z certyfikatem generowanym w pipeline (C2)
* [mock_rest.py](mock_rest.py) - endpoint REST obsługujący żądanie *POST* (C3)

#### Szczegółowy przebieg pipeline’u:
* *Clone* - Jenkins pobiera kod z repozytorium (SCM) wraz z plikami Dockerfile i Jenkinsfile
* *Build* i *Test* - budowa obrazu buildera z włączonym HTTPS i uruchomienie testów jednostkowych programu (*make test*) w kontenerze builder
* *Deploy* - przygotowanie środowiska uruchomieniowego: wyodrębnienie artefaktu (binarka + biblioteki) i zbudowanie odchudzonego obrazu runtime (C0) bez zależności buildowych.
* *Deploy* i testy integracyjne - uruchomienie sieci testowej oraz serwerów C1/C2/C3, weryfikacja działania *curl* na HTTP/HTTPS/REST (zgodnie z [sugestią Prowadzącego](Diagram.png))
* *Publish* - przygotowanie wersjonowanego artefaktu *.deb* i dołączenie go do builda dzięki archiwizacji poprzez Jenkins'a

*Artefaktem redystrybucyjnym jest pakiet .deb - obraz runtime (C0) pełni jedynie rolę swego rodzaju sandbox'u do weryfikacji działania, a nie docelowego artefaktu do zachowania.*

#### Pierwsze uruchomienie:
![](2.2.png)
![](3.2.png)

*Pierwsze uruchomienie zakończyło się sukcesem -  powstał wersjonowany artefakt .deb.*

#### Powtórne uruchomienie:
![](3.1.png)
![](3.3.png)

*Ponowne uruchomienie potwierdza powtarzalność procesu (pipeline działa więcej niż jeden raz) - utworzona została nowa wersja artefaktu .deb (z innym BUILD_ID).*

*Aby ograniczyć problem cache’owania, budowa obrazów wykonywana jest z --pull --no-cache, a nazwy zasobów (obrazy, sieć testowa, kontenery) oraz wersja artefaktu są powiązane z BUILD_ID. Sprzątanie środowiska testowego (sieć/kontenery oraz pliki tymczasowe) realizowane jest w bloku POST Jenkinsfile'a.*

Odpowiedzi na pytania:
* Program powinien być „zapakowany” do przenośnego formatu, ponieważ środowisko docelowe to Ubuntu (Debian-based), a *.deb* pozwala w przewidywalny sposób zainstalować binarkę wraz z bibliotekami i metadanymi paczki. Jest to też artefakt „deployable” - można go pobrać z Jenkinsa i wdrożyć na maszynie docelowej.

* Kontener buildowy nie nadaje się do roli wdrożeniowej, ponieważ zawiera szereg narzędzi, które nie są potrzebne, a ich obecność przekłada się na zwiększony rozmiar. Dlatego też zastosowano osobny obraz runtime (C0).

Adnotacja odnośnie użycia AI:
Narzędzie zostało wykorzystane do pomocy przy wprowadzaniu testów integracyjnych - zwłaszcza C2 (HTTPS). Ze względu na omylne wybranie braku obsługi SSL w budującym Dockerfile nie byłem w stanie zlokalizować źródła problemu.