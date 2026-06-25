pipeline {
    agent {
        docker { 
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    stages {
        stage('Zadanie 1 - Uname') {
            steps {
                sh 'uname -a'
            }
        }
        stage('Zadanie 3 - Docker Pull') {
            steps {
                sh 'docker pull ubuntu:latest'
            }
        }
    }
}