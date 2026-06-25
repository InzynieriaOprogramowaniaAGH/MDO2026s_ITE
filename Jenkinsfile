pipeline {
    agent none
    stages {
        stage('Zadanie 1 - Uname') {
            agent any
            steps {
                sh 'uname -a'
            }
        }
        stage('Zadanie 3 - Docker Pull') {
            agent {
                docker { 
                    image 'docker:latest'
                    args '-e DOCKER_HOST=tcp://docker:2376 -e DOCKER_TLS_VERIFY=1 -e DOCKER_CERT_PATH=/certs/client -v jenkins-docker-certs:/certs/client:ro'
                }
            }
            steps {
                sh 'docker pull ubuntu:latest'
                sh 'docker images'
            }
        }
    }
}