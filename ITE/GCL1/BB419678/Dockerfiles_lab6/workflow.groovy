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
                dir('ITE/GCL1/BB419678/Dockerfiles_lab6') {
                    sh 'docker build -t neovim-builder-jenkins -f Dockerfile.nvim.build .'
                }
            }
        }
        
        stage('Testy jednostkowe (nieblokujące)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab6') {
                    sh 'docker build -t neovim-tester-jenkins -f Dockerfile.nvim.test .'
                    // Przywrócone || true - błędy systemd nie zatrzymają pipeline'u
                    sh 'docker run --rm neovim-tester-jenkins || true'
                }
            }
        }

        stage('Archiwizacja Artefaktów (Paczka DEB)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab6') {
                    sh '''
                        # Tworzymy tymczasowy kontener, żeby wyciągnąć plik
                        docker create --name temp-archive-container neovim-builder-jenkins
                        
                        # Znajdujemy wygenerowany plik .deb (nazwa zależy od wersji nvim)
                        DEB_NAME=$(docker exec temp-archive-container ls build | grep .deb | head -n 1)
                        
                        # Kopiujemy go do workspace jenkinsa
                        docker cp temp-archive-container:/workspace/build/$DEB_NAME ./neovim-final.deb
                        
                        docker rm temp-archive-container
                    '''
                    
                    // ARCHIVE ARTIFACTS - to jest pomarańczowa strzałka z Twojego rysunku
                    // Paczka .deb zawiera w sobie definicje zależności (np. libvterm / libtermkey)
                    archiveArtifacts artifacts: 'neovim-final.deb', fingerprint: true
                }
            }
        }
    }
}