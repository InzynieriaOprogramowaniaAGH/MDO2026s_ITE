pipeline {
    agent any
    
    environment {
        // Unikalna nazwa sieci dla każdego buildu, aby uniknąć konfliktów
        NET_NAME = "hiredis-net-${BUILD_NUMBER}"
    }

    stages {
        stage('1. Cleanup') {
            steps {
                // Usuwamy pozostałości po ewentualnych przerwanych buildach
                sh "docker rm -f redis-server-${BUILD_NUMBER} integration-client-${BUILD_NUMBER} || true"
                sh "docker network rm ${NET_NAME} || true"
            }
        }

        stage('2. Build Library') {
            steps {
                // Budujemy obraz na podstawie Dockerfile.build
                sh "docker build -t hiredis-builder:${BUILD_NUMBER} -f GCL1/lab3/Dockerfile.build GCL1/lab3/"
            }
        }

        stage('3. Integration Test') {
            steps {
                script {
                    // Tworzymy dedykowaną sieć dla tego konkretnego buildu
                    sh "docker network create ${NET_NAME}"
                    
                    // Uruchamiamy Redis C1 z aliasem, którego szuka sample.c
                    sh "docker run -d --name redis-server-${BUILD_NUMBER} --network ${NET_NAME} --network-alias redis-server redis:alpine"
                    
                    // Uruchamiamy Klienta C2 (obraz budujący z biblioteką)
                    sh "docker run -d --name integration-client-${BUILD_NUMBER} --network ${NET_NAME} hiredis-builder:${BUILD_NUMBER} sleep 300"
                    
                    try {
                        // Wstrzykujemy kod przykładowy do kontenera
                        sh "docker cp GCL1/lab5/sample.c integration-client-${BUILD_NUMBER}:/sample.c"
                        
                        // Kompilacja i uruchomienie wewnątrz kontenera
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
                        // Sprzątamy kontenery i sieć w tym etapie
                        sh "docker rm -f redis-server-${BUILD_NUMBER} integration-client-${BUILD_NUMBER} || true"
                        sh "docker network rm ${NET_NAME} || true"
                    }
                }
            }
        }

        stage('4. Publish Artefact') {
            steps {
                script {
                    // Tworzymy paczkę z gotowym plikiem .so
                    sh "docker create --name extract-${BUILD_NUMBER} hiredis-builder:${BUILD_NUMBER}"
                    sh "docker cp extract-${BUILD_NUMBER}:/app/libhiredis.so ."
                    sh "docker rm extract-${BUILD_NUMBER}"
                    
                    // Nadajemy paczce unikalną nazwę z numerem buildu
                    sh "tar -czvf hiredis-v1.0-b${BUILD_NUMBER}-PD420765.tar.gz libhiredis.so"
                    
                    // Archiwizujemy plik w Jenkinsie
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
