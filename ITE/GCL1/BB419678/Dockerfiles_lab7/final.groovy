pipeline {
    agent any
    
    environment {
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
        
        stage('Zbudowanie Neovima i paczki DEB') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab7') {
                    sh 'docker build -t neovim-builder-jenkins -f Dockerfile.nvim.build .'
                }
            }
        }
        
        stage('Testy jednostkowe (nieblokujące)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab7') {
                    sh 'docker build -t neovim-tester-jenkins -f Dockerfile.nvim.test .'
                    sh 'docker run --rm neovim-tester-jenkins || true'
                }
            }
        }

        stage('Wyciągnięcie paczki DEB') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab7') {
                    sh '''
                        echo "--- wyciaganie zbudowanej paczki z kontenera build ---"
                        # Tworzymy tymczasowy kontener
                        docker create --name temp-archive-container neovim-builder-jenkins
                        
                        # Kopiujemy folder build
                        docker cp temp-archive-container:/workspace/build ./temp_build_dir
                        
                        # Szukamy pliku .deb i zmieniamy mu nazwę na docelową
                        cp ./temp_build_dir/*.deb ./neovim-final.deb
                        
                        echo "--- zaleznosci paczki .deb ---"
                        # metadane pliku .deb - '|| true' żeby uchronić pipeline gdyby grep nic nie znalazł
                        dpkg -I ./neovim-final.deb | grep 'Depends' || true

                        # Sprzątamy
                        docker rm temp-archive-container
                        rm -rf ./temp_build_dir
                    '''
                }
            }
        }

        stage('Deploy i Smoke Test (CD)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab7') {
                    sh '''
                        echo "--- Tworzymy przykładowe pliki tekstowe do smoke test'u ---"
                        echo "To jest NIEZMODYFIKOWANY tekst testowy." > test_file.txt

                        echo "--- Budowanie kontenera CD (Deploy) ---"
                        # Generujemy prosty Dockerfile "w locie"
                        # EOF musi przylegać do lewej krawędzi dla prawidłowej składni Bash
                        cat << 'EOF' > Dockerfile.deploy
FROM ubuntu:24.04
COPY neovim-final.deb /tmp/
COPY test_file.txt /workspace/
WORKDIR /workspace
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y /tmp/neovim-final.deb && rm -rf /var/lib/apt/lists/*
EOF

                        # Budujemy obraz testowy
                        docker build -t neovim-cd-container -f Dockerfile.deploy .

                        # Upewniamy się, że nie ma "sierot" po przerwanych wcześniej buildach
                        docker rm -f smoke-test-run || true

                        echo "--- Wykonanie testu w kontenerze (Run & Check OUT) ---"
                        # Uruchamiamy kontener z Neovimem w trybie headless
                        docker run --name smoke-test-run neovim-cd-container nvim --headless -c '%s/NIEZMODYFIKOWANY/ZMODYFIKOWANY/g' -c 'wq' test_file.txt

                        echo "--- Weryfikacja wyniku (OUT -> OK?) ---"
                        # Pobieramy przetworzony plik z powrotem do środowiska Jenkinsa
                        docker cp smoke-test-run:/workspace/test_file.txt ./test_file_out.txt
                        
                        # Sprawdzamy czy zmiana tekstu się powiodła
                        if grep -q "ZMODYFIKOWANY" ./test_file_out.txt; then
                            echo "SMOKE TEST ZAKOŃCZONY SUKCESEM! Neovim poprawnie zedytował plik."
                        else
                            echo "BŁĄD: Plik nie został poprawnie przetworzony!"
                            exit 1
                        fi
                    '''
                }
            }
            // zawsze sprzątamy po zakonczeniu smoke testa, niezaleznie od wyniku
            post {
                always {
                    sh '''
                        echo "--- Sprzątanie po Smoke Teście ---"
                        docker rm -f smoke-test-run || true
                    '''
                }
            }
        }

        stage('Archiwizacja Artefaktów (Paczka DEB)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab7') {
                    archiveArtifacts artifacts: 'neovim-final.deb', fingerprint: true
                }
            }
        }
    }
}