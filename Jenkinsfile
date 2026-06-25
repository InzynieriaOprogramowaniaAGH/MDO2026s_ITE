pipeline {
    agent any
    stages {
        stage('Zadanie 1 - Uname') {
            steps {
                sh 'uname -a'
            }
        }
        stage('Zadanie 3 - Docker Pull') {
            steps {
                sh 'docker -H tcp://docker:2375 pull ubuntu:latest'
            }
        }
    }
}