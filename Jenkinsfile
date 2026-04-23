pipeline {
    agent any
    
    environment {
        // Unique network name
        NET_NAME = "hiredis-net-${BUILD_NUMBER}"
    }

    stages {
        stage('Cleanup') {
            steps {
                // Cleaning in case other build crashed and left some trash
                sh "docker rm -f redis-server-${BUILD_NUMBER} integration-client-${BUILD_NUMBER} || true"
                sh "docker network rm ${NET_NAME} || true"
            }
        }

        stage('Build Library') {
            steps {
                sh "docker build -t hiredis-builder:${BUILD_NUMBER} -f GCL1/lab3/Dockerfile.build GCL1/lab3/"
            }
        }

        stage('Integration Test') {
            steps {
                script {
                    sh "docker network create ${NET_NAME}"
                    sh "docker run -d --name redis-server-${BUILD_NUMBER} --network ${NET_NAME} redis:alpine"
                    sh "docker run -d --name integration-client-${BUILD_NUMBER} --network ${NET_NAME} hiredis-builder:${BUILD_NUMBER} sleep 300"
                    
                    try {
                        sh "docker cp GCL1/lab5/sample.c integration-client-${BUILD_NUMBER}:/sample.c"
                        sh """
                        docker exec integration-client-${BUILD_NUMBER} bash -c '
                            cd /app && make install && ldconfig && \
                            gcc /sample.c -o /app/test_app -lhiredis -I/usr/local/include/hiredis && \
                            /app/test_app
                        '
                        """
                    } finally {
                        // Always cleaning files
                        sh "docker rm -f redis-server-${BUILD_NUMBER} integration-client-${BUILD_NUMBER} || true"
                        sh "docker network rm ${NET_NAME} || true"
                    }
                }
            }
        }

        stage('4. Publish Artefact') {
            steps {
                script {
                    // Package with library
                    sh "docker create --name extract-${BUILD_NUMBER} hiredis-builder:${BUILD_NUMBER}"
                    sh "docker cp extract-${BUILD_NUMBER}:/app/libhiredis.so ."
                    sh "docker rm extract-${BUILD_NUMBER}"
                    // Wersjonujemy artefakt numerem builda Jenkinsa
                    sh "tar -czvf hiredis-v1.0-b${BUILD_NUMBER}.tar.gz libhiredis.so"
                    
                    archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
                }
            }
        }
    }
    post {
        always {
            // Po całym procesie usuwamy obraz, żeby nie zapchać dysku
            sh "docker rmi hiredis-builder:${BUILD_NUMBER} || true"
        }
    }
}
