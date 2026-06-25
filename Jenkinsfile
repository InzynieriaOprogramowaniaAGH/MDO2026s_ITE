pipeline {
    agent {
        docker { 
            image 'maven:3.9.6-eclipse-temurin-17' 
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
                sh 'docker images'
            }
        }
    }
}