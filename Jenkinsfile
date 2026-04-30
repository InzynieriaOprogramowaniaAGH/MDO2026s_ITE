pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        REPO_URL = 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
        REPO_BRANCH = 'MA423062'

        BUILDER_IMAGE = 'jq-build:local'
        TEST_IMAGE = 'jq-test:local'
        RUNTIME_IMAGE = "jq-runtime:${BUILD_NUMBER}"
        ARTIFACT_NAME = "jq-runtime-${BUILD_NUMBER}.tar"
    }

    stages {
        stage('Clean workspace') {
            steps {
                deleteDir()
                sh '''
                    echo "Workspace after cleanup:"
                    pwd
                    ls -la
                '''
            }
        }

        stage('Checkout from SCM') {
            steps {
                git branch: "${REPO_BRANCH}",
                    url: "${REPO_URL}"

                sh '''
                    echo "Checked out commit:"
                    git log -1 --oneline

                    echo "Repository files:"
                    ls -la

                    echo "Docker files:"
                    ls -la Dockers

                    test -f Jenkinsfile
                    test -f Dockers/Dockerfile.build
                    test -f Dockers/Dockerfile.test
                    test -f Dockers/Dockerfile.runtime
                '''
            }
        }

        stage('Build builder image') {
            steps {
                sh '''
                    docker build --pull --no-cache \
                        -t ${BUILDER_IMAGE} \
                        -f Dockers/Dockerfile.build \
                        Dockers
                '''
            }
        }

        stage('Build tester image') {
            steps {
                sh '''
                    docker build --no-cache \
                        -t ${TEST_IMAGE} \
                        -f Dockers/Dockerfile.test \
                        Dockers
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail

                    docker rm -f jq-test-run >/dev/null 2>&1 || true

                    docker run --name jq-test-run ${TEST_IMAGE} 2>&1 | tee test.log
                '''
            }
        }

        stage('Build deployable image') {
            steps {
                sh '''
                    docker build --no-cache \
                        -t ${RUNTIME_IMAGE} \
                        -f Dockers/Dockerfile.runtime \
                        Dockers

                    docker image inspect ${RUNTIME_IMAGE} > runtime-image-inspect.json
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail

                    docker rm -f jq-runtime-smoke >/dev/null 2>&1 || true

                    echo '{"answer":42}' | docker run --name jq-runtime-smoke --rm -i ${RUNTIME_IMAGE} '.answer' | tee deploy-smoke.log

                    grep -qx '42' deploy-smoke.log
                '''
            }
        }

        stage('Publish') {
            steps {
                sh '''
                    mkdir -p artifacts

                    docker save ${RUNTIME_IMAGE} -o artifacts/${ARTIFACT_NAME}

                    cp test.log artifacts/test.log
                    cp deploy-smoke.log artifacts/deploy-smoke.log
                    cp runtime-image-inspect.json artifacts/runtime-image-inspect.json

                    echo "Artifact origin:" > artifacts/origin.txt
                    echo "Repository: ${REPO_URL}" >> artifacts/origin.txt
                    echo "Branch: ${REPO_BRANCH}" >> artifacts/origin.txt
                    echo "Build number: ${BUILD_NUMBER}" >> artifacts/origin.txt
                    echo "Runtime image: ${RUNTIME_IMAGE}" >> artifacts/origin.txt
                    git log -1 --oneline >> artifacts/origin.txt
                '''

                archiveArtifacts artifacts: 'artifacts/*',
                                 fingerprint: true,
                                 allowEmptyArchive: false
            }
        }
    }

    post {
        always {
            sh '''
                docker logs jq-test-run > docker-test.log 2>&1 || true
                docker cp jq-test-run:/opt/jq/test-suite.log test-suite.log 2>/dev/null || true
                docker rm -f jq-test-run >/dev/null 2>&1 || true
            '''

            archiveArtifacts artifacts: 'test.log,docker-test.log,test-suite.log',
                             fingerprint: true,
                             allowEmptyArchive: true
        }
    }
}
