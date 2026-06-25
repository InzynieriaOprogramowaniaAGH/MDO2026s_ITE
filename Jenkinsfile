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
                    args '-e DOCKER_HOST=tcp://docker:2375'
                }
            }
            steps {
                sh 'docker pull ubuntu:latest'
                sh 'docker images'
            }
        }
    }
}