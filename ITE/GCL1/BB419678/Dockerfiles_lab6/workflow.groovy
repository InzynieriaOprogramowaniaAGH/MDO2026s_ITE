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
                    sh 'docker run --rm neovim-tester-jenkins || true'
                }
            }
        }

stage('Archiwizacja Artefaktów (Paczka DEB)') {
            steps {
                dir('ITE/GCL1/BB419678/Dockerfiles_lab6') {
                    sh '''
                        # Tworzymy tymczasowy kontener (nie musi działać)
                        docker create --name temp-archive-container neovim-builder-jenkins
                        
                        # Kopiujemy cały folder build z kontenera do obecnego katalogu roboczego
                        docker cp temp-archive-container:/workspace/build ./temp_build_dir
                        
                        # Szukamy pliku .deb w skopiowanym folderze i zmieniamy mu nazwę na docelową
                        # Używamy find, żeby złapać plik niezależnie od dokładnej wersji neovima
                        cp ./temp_build_dir/*.deb ./neovim-final.deb
                        

                        echo "--- SPRAWDZANIE ZALEŻNOŚCI PACZKI ---"
                        # metadane pliku .deb
                        dpkg -I ./neovim-final.deb | grep 'Depends'

                        # Sprzątamy
                        docker rm temp-archive-container
                        rm -rf ./temp_build_dir
                    '''
                    
                    // Teraz plik neovim-final.deb istnieje w workspace
                    archiveArtifacts artifacts: 'neovim-final.deb', fingerprint: true
                }
            }
        }
    }
}