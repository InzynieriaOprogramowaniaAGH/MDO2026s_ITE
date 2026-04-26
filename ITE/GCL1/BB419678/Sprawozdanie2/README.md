# Sprawozdanie 2

Bartosz Bodulski, grupa 1, Tematy 5 - 7

## Temat 5

Cel zajęć - zainstalowanie i zapoznanie się z środowiskiem Jenkins.

Instalacja środowiska Jenkins (potrzebujemy także obrazu DIND):



![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20081231.png)

Blueocean to taki fajny wrapper graficzny na Jenkinsa, który sam jest silnikiem do tworzenia Pipeline'ów CI/CD. Pozwala na szybsze postawianie projektów osobom, które dopiero zaczynąją przygode w tym obszarze.


![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20081314.png)

Sprawdzamy działanie kontenerów:


![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20084039.png)


Robimy początkowy setup Jenkinsa - pobieramy hasło pierwszego logowania i tworzymy nasze konto admina, logując się na: http://localhost:8080

![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20084100.png)



![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20084353.png)

Podajemy nasze hasło jednorazowego dostępu:

![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20084614.png)


Po utworzeniu naszego admina wchodzimy na dashboard jenkinsa i  przystępuje do utworzenia projektu dla 1 zadania.
![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20084826.png)



![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20085241.png)


Tutaj musimy tylko pokazać wynik komendy uname w powłoce Jenkinsa.

![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20085322.png)

Wynikiem jest wersja jądra naszej maszyny wirtulanej - jak widać Jenkins
wywołuje /bin/sh zamiast /bin/bash. Należy o tym wiedzieć, gdyż poźniej się to prawdopodobnie nam przyda.


![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20085402.png)

Kolejny projekt sprawdza, czy godzina w systemie operacyjny jest nieparzysta i w związku z tym zwraca błąd. Można to zrobić za pomocą prostego skryptu powłoki (sh, nie bash!):

![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20085624.png)




![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20085939.png)

Trzeci projekt próbuje stworzyć kontener dockera na podstawie obrazu ubuntu:latest za pomocą polecenia ```docker pull```

![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20090140.png)

Polecenie kończy się sukcesem:

![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20090232.png)

Nasze projekty wyglądają tak:


![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20090244.png)

Na koniec tworzę obiekt typu pipeline, który klonuje repozytorium przedmiotu, robi ```git checkout``` na mojego brancha i buduje kontener za pomocą podanego dockerfile:

![img](../screenshots/lab5/Zrzut%20ekranu%202026-04-10%20091403.png)

```groovy
pipeline {
    agent any
    
    environment {
        // Zmienne do połączenia z silnikiem Docker in Docker (DIND)
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_CERT_PATH = '/certs/client'
        DOCKER_TLS_VERIFY = '1'
    }

    stages {
        stage('Sklonowanie repozytorium') {
            steps {
                git branch: 'BB419678', url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
            }
        }
        
        stage('Zbudowanie (Builder)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab5') {
                    sh 'docker build -t neovim-builder-jenkins -f Dockerfile.nvim.build .'
                }
            }
        }
        
        stage('Testy jednostkowe (Tester)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab5') {
                    sh 'docker build -t neovim-tester-jenkins -f Dockerfile.nvim.test .'
                    
                    // catchError pozwala potokowi isc dalej pomimo bledow dockera, ewentualnie mozna zrobic sh ... || true
                    catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                        sh 'docker run --rm neovim-tester-jenkins'
                    }
                }
            }
        }
        
        stage('Publikacja (Publish)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab5') {
                    // utworzenie tarball'a (tar.gz) z binarki
                    sh '''
                        docker create --name temp-container neovim-builder-jenkins
                        docker cp temp-container:/workspace/build/bin/nvim ./nvim-binary
                        tar -czvf neovim-artifact.tar.gz nvim-binary
                        docker rm temp-container
                    '''
                    // Publikacja w interfejsie Jenkinsa
                    archiveArtifacts artifacts: 'neovim-artifact.tar.gz', fingerprint: true
                }
            }
        }
        
        stage('Wdrożenie (Deploy)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab5') {
                    // Tworzenie ekstremalnie lekkiego obrazu Runtime (Slim)
                    sh '''
cat <<EOF > Dockerfile.nvim.runtime
FROM ubuntu:24.04
COPY nvim-binary /usr/local/bin/nvim
RUN chmod +x /usr/local/bin/nvim
CMD ["sleep", "infinity"]
EOF
                        docker build -t neovim-runtime-jenkins -f Dockerfile.nvim.runtime .
                    '''
                    
                    // Uruchomienie nieblokujące w tle
                    sh 'docker run -d --name neovim-prod --rm neovim-runtime-jenkins'
                    
                    // Program działa w nowym, docelowym kontenerze
                    sh 'docker exec neovim-prod nvim --version'
                    
                    // Zatrzymanie i posprzątanie
                    sh 'docker stop neovim-prod'
                }
            }
        }
    }
}
```


Problemem podczas tworzenia tego pipeline'u okazał się ```make unittest``` - niektóre testy nie przechodzą ze względu na systemd, dlatego trzeba owinąć stage testowania w klauzule CatchError lub dodać do polecenia powłoki ```|| true```, co nie jest optymalnym rozwiązaniem. Poprawa i rozwinięcie tego pipeline jest tematem na następne zajęcia.

![img](../screenshots/lab5/test_fail.png)

## Temat 6
Cel zajęć - modyfikacja wcześniejszego pipeline'u do wybranego oprogramowania



![img](../screenshots/lab6/Zrzut%20ekranu%202026-04-17%20092551.png)

## Temat 7
Cel zajęć - Rozbudowanie pipeline w oprogramowaniu Jenkins.


