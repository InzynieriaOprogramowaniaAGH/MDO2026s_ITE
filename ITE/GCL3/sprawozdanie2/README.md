
===lab5===

pipeline {
    agent any

    stages {
        stage('Oczyszczanie') {
            steps {
                deleteDir()
            }
        }

        stage('Klonowanie repozytorium') {
            steps {
                git branch: 'moje-imie-nazwisko', 
                    url: 'https://github.com/p_mdo_ino/MDO2025_INO.git'
            }
        }

        stage('Budowanie obrazu (Docker)') {
            steps {
                script {
                    sh 'docker build -t my-custom-builder:latest .'
                }
            }
        }

        stage('Weryfikacja buildera') {
            steps {
                sh 'docker run --rm my-custom-builder:latest --version'
            }
        }
    }
    
    post {
        always {
            echo 'Zakończono wykonywanie Pipeline.'
        }
        success {
            echo 'Sukces! Obraz został zbudowany poprawnie.'
        }
        failure {
            echo 'Coś poszło nie tak. Sprawdź logi powyżej.'
        }
    }
}