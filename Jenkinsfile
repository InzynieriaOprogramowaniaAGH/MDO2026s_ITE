pipeline {
    agent any

    stages {
        stage('Sanity') {
            steps {
                sh 'uname -a'
                sh 'docker version'
            }
        }

        stage('Checkout repo') {
            steps {
                git branch: 'MA423062',
                    url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
            }
        }

        stage('Build builder image') {
            steps {
                sh 'docker build -t jq-build:local -f Dockers/Dockerfile.build Dockers'
            }
        }

        stage('Build tester image') {
            steps {
                sh 'docker build -t jq-test:local -f Dockers/Dockerfile.test Dockers'
            }
        }

        stage('Run tests') {
            steps {
                sh '''
                set -o pipefail
                docker rm -f jq-test-run >/dev/null 2>&1 || true
                docker run --name jq-test-run jq-test:local 2>&1 | tee test.log
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logs jq-test-run > docker-test.log 2>&1 || true'
            sh 'docker cp jq-test-run:/opt/jq/test-suite.log test-suite.log || true'
            sh 'docker rm -f jq-test-run >/dev/null 2>&1 || true'
            archiveArtifacts artifacts: 'test.log,docker-test.log,test-suite.log', allowEmptyArchive: true, fingerprint: true
        }
    }
}
