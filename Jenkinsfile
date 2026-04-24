pipeline {
    agent any
    
    environment {
        // Unikalna nazwa sieci dla każdego buildu, aby uniknąć konfliktów
        NET_NAME = "hiredis-net-${BUILD_NUMBER}"
    }

    stages {
        stage('Cleanup') {
            steps {
                // Usuwanie pozostałości po ewentualnych przerwanych buildach
                sh "docker rm -f redis-server-${BUILD_NUMBER} integration-client-${BUILD_NUMBER} || true"
                sh "docker network rm ${NET_NAME} || true"
            }
        }

        stage('Build Library') {
            steps {
                // Build na podstawie Dockerfile.build
                sh "docker build -t hiredis-builder:${BUILD_NUMBER} -f GCL1/lab3/Dockerfile.build GCL1/lab3/"
            }
        }

        stage('Integration Test') {
            steps {
                script {
                    sh "docker network create ${NET_NAME}"
                    
                    // Uruchamianie Redisa C1 z aliasem, którego szuka sample.c
                    sh "docker run -d --name redis-server-${BUILD_NUMBER} --network ${NET_NAME} --network-alias redis-server redis:alpine"
                    
                    // Klient C2 (obraz budujący z biblioteką)
                    sh "docker run -d --name integration-client-${BUILD_NUMBER} --network ${NET_NAME} hiredis-builder:${BUILD_NUMBER} sleep 300"
                    
                    try {
                        sh "docker cp GCL1/lab5/sample.c integration-client-${BUILD_NUMBER}:/sample.c"
                        sh """
                        docker exec integration-client-${BUILD_NUMBER} bash -c '
                            cd /app && \
                            make install && \
                            ldconfig && \
                            gcc /sample.c -o /app/test_app -lhiredis -I/usr/local/include/hiredis && \
                            /app/test_app
                        '
                        """
                        echo "Test integracyjny C1 + C2 zakończony pomyślnie!"
                        
                    } finally {
                        sh "docker rm -f redis-server-${BUILD_NUMBER} integration-client-${BUILD_NUMBER} || true"
                        sh "docker network rm ${NET_NAME} || true"
                    }
                }
            }
        }

        stage('4. Publish Artefact') {
            steps {
                script {
                    // Paczka z plikiem .so
                    sh "docker create --name extract-${BUILD_NUMBER} hiredis-builder:${BUILD_NUMBER}"
                    sh "docker cp extract-${BUILD_NUMBER}:/app/libhiredis.so ."
                    sh "docker rm extract-${BUILD_NUMBER}"
                    
                    sh "tar -czvf hiredis-v1.0-b${BUILD_NUMBER}-PD420765.tar.gz libhiredis.so"
                    
                    // Archiwizacja pliku w Jenkinsie
                    archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
                }
            }
        }
    }

    post {
        always {
            sh "docker rmi hiredis-builder:${BUILD_NUMBER} || true"
        }
    }
}
