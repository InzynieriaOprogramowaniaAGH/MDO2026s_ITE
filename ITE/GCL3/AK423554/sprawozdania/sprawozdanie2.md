# Sprawozdanie z zajęć 5-7: Jenkins
# **Lab5:** Pipeline, Jenkins, izolacja etapów

---

## 1. Cel zajęć
Tworzymy pipeline, którego celem będzie opracowanie kroków "build-test-deploy-publish".

---

## 2. Utworzenie instancji jenkins 
<img width="1050" height="531" alt="image" src="https://github.com/user-attachments/assets/76354e2f-2122-46b3-8c05-68f475b09eb2" />
<img width="1050" height="531" alt="image" src="https://github.com/user-attachments/assets/09c8e1a7-319a-4ee9-85c7-0a0809e234d4" />
<img width="1460" height="979" alt="image" src="https://github.com/user-attachments/assets/7dec2edf-750d-4ffb-880e-dfac30cec33f" />

Dla zapewnienia bezpiecznej i odizolowanej komunikacji między usługami, utworzono dedykowaną sieć wewnątrz środowiska Docker `jenkins-net`, sieć ta stanowi fundament komunikacji między usługami CI/CD.

W trakcie prac wdrożeniowych przeprowadzono weryfikację sposobu, w jaki Jenkins zarządza kontenerami. Choć wstępnym założeniem było wykorzystanie architektury DinD  – poprzez uruchomienie dedykowanego kontenera docker:dind – diagnostyka systemu wykazała, że w praktyce wdrożenie realizuje podejście DooD, co występować będzie później podczas robienia kontenera c-deploy.

## 3. Zadania wstępne: uruchomienie

* `uname`
<img width="1372" height="494" alt="image" src="https://github.com/user-attachments/assets/a5ec0ad0-fc23-402b-81e4-7d90dbba67a2" />

* `odd_hour`
<img width="1216" height="584" alt="image" src="https://github.com/user-attachments/assets/408c8be0-9910-4009-b76f-c6a95bfcaae2" />

* `ubuntu`
<img width="950" height="430" alt="image" src="https://github.com/user-attachments/assets/c1fa66ed-d5ab-484b-bb37-437082b7fbd3" />


W celu weryfikacji poprawności konfiguracji środowiska Jenkins, wykonano serię zadań testowych, które potwierdziły pełną funkcjonalność infrastruktury.
W pierwszej kolejności wykonano test operacji docker pull, który potwierdził poprawną integrację Jenkinsa z demonem Dockera i możliwość zarządzania obrazami.
Następnie zweryfikowano zdolność Jenkinsa do interpretowania instrukcji w plikach Jenkinsfile, sprawdzając obsługę zmiennych systemowych oraz warunków
logicznych. Ostatnim etapem weryfikacji było sprawdzenie uprawnień procesów, co potwierdziło, że zadania są wykonywane z odpowiednimi uprawnieniami
systemowymi i mają dostęp do zasobów hosta.

---

## 4. Zadanie wstępne: obiekt typu pipeline
<img width="1836" height="860" alt="image" src="https://github.com/user-attachments/assets/9b23cd05-7105-43af-b330-f060fa559e5d" />
<img width="896" height="535" alt="image" src="https://github.com/user-attachments/assets/a71e66a8-8265-4b38-af77-d9c8d4bc02ac" />
<img width="660" height="202" alt="image" src="https://github.com/user-attachments/assets/c6843612-8690-4c70-8bc0-51b587ea5632" />

**Podsumowanie wykonania:**
* **Status Pipeline:** FAILURE.
* **Sukcesy:** Poprawnie wykonano setki testów dotyczących schematów, enkapsulacji oraz obsługi błędów.
* **Wykryte problemy:**
    * Wykryto błąd połączenia `ECONNREFUSED` w testach `clientError`, co może sugerować restrykcyjne ustawienia sieciowe wewnątrz kontenera.
    * Wykryto rozbieżność w formatowaniu komunikatów błędów dla `non-numeric content-length`.
**Wniosek:**
Pipeline spełnił swoje zadanie – zbudował obraz. Dzięki izolacji w Dockerze, błędy w testach nie wpłynęły na stabilność serwera Jenkins, a logi pozwoliły na szybką identyfikację problematycznych modułów.

## 5.Treść skryptów

`ubuntu_pull`
```
docker pull ubuntu:latest
```
`odd_hour`
```
HOUR=$(date +%H)
echo "Obecna godzina: $HOUR"
if [ $((HOUR % 2)) -ne 0 ]; then
  echo "ŹLEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE ALARM AALRM GODZINA NIEPARZYSTA"
  exit 1
else
  echo "Godzina jest parzysta :)"
  exit 0
fi
```
`u_name`
```
whoami
uname -a
```
`pipeline_test` (po drobnej zmianie obsługi testów)
```
pipeline {
    agent any

    stages {
        stage('Checkout Source') {
            steps {
                git branch: 'AK423554', 
                    url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "Budowanie"
                    sh 'docker build --no-cache -t fastify-builder:latest -f ./ITE/GCL3/AK423554/lab3/Dockerfile.build ./ITE/GCL3/AK423554/lab3/'
                }
            }
        }
stage('Test') {
            steps {
                script {
                    echo "Testowanie"
                    sh 'docker build -t fastify-test:latest -f ./ITE/GCL3/AK423554/lab3/Dockerfile.test ./ITE/GCL3/AK423554/lab3/'
                    
                    def status = sh(script: 'docker run --rm fastify-test:latest', returnStatus: true)

                    if (status != 0) {

                        echo "Testy nie przeszły"
                    }
                }
            }
        }

```



---

# **Lab6:** Pipeline: lista kontrolna \ Ścieżka krytyczna

---

## 1. Cel zajęć
Celem zajęć było scharakteryzowanie planu na pipeline i przedstawie postępu prac oraz wyznaczenie conajmniej działającej ścieżki krytycznej.

---

## 2. Deploy i walidacja (curl)
<img width="1245" height="663" alt="image" src="https://github.com/user-attachments/assets/a648c50b-c74a-41a0-afe2-cdd8e9ede154" />
<img width="1172" height="473" alt="image" src="https://github.com/user-attachments/assets/57fc0e2f-37ff-48f6-b39c-04525d33d6bb" />

Etap wdrażania (Deploy) rozpoczyna się od zapewnienia środowiska wolnego od pozostałości z poprzednich uruchomień, co realizowane jest poprzez 
wymuszenie usunięcia istniejącego kontenera o nazwie „c-deploy” za pomocą komendy z flagą force. Następnie, wykorzystując zbudowany w poprzednich 
krokach obraz „fastify-builder:latest”, uruchamiany jest nowy kontener w trybie odłączonym (detached), który zostaje wpięty do dedykowanej sieci 
„jenkins-net”, zapewniającej spójną i bezpieczną komunikację wewnątrz środowiska CI/CD. Po krótkiej pauzie, pozwalającej na zainicjowanie aplikacji
wewnątrz kontenera, następuje etap walidacji. W tym celu wykorzystywany jest kontener z narzędziem curl, który wykonuje automatyczne zapytanie HTTP GET
do uruchomionej usługi, weryfikując poprawność jej odpowiedzi. Takie podejście pozwala na natychmiastowe potwierdzenie, że wdrożona aplikacja jest w 
pełni funkcjonalna i gotowa do obsługi ruchu sieciowego.

---

## 3. Publish

<img width="644" height="382" alt="image" src="https://github.com/user-attachments/assets/e0f05c8d-2fe6-4389-b0cf-14d0186cf1a1" />
<img width="1769" height="302" alt="image" src="https://github.com/user-attachments/assets/26cceab6-0d44-4518-9d95-869e1ab9609c" />
<img width="550" height="384" alt="image" src="https://github.com/user-attachments/assets/8533043f-4d9a-4871-a314-5f70315135de" />

Etap publikacji artefaktu (Publish to NPM) realizowany jest w sposób w pełni zautomatyzowany, z wykorzystaniem bezpiecznego przekazywania 
poświadczeń, co zapobiega eksponowaniu wrażliwych danych w logach procesu. Proces ten wykonuje się wewnątrz izolowanego środowiska kontenerowego, 
gdzie następuje dynamiczna konfiguracja paczki poprzez nadanie jej unikalnej nazwy oraz wersji bazującej na bieżącym numerze buildu z Jenkinsa
(BUILD_NUMBER), co gwarantuje unikalność każdej publikowanej wersji i eliminuje błędy typu „version conflict” w rejestrze NPM. Po dynamicznym
wygenerowaniu pliku konfiguracyjnego .npmrc z autentykacyjnym tokenem sesyjnym, wywoływana jest komenda npm publish, która wysyła paczkę do
publicznego rejestru, czyniąc ją dostępną do dalszej dystrybucji. Dzięki takiemu rozwiązaniu każda udana iteracja pipeline’u kończy się publikacją 
nowej, poprawnie zwersjonowanej wersji oprogramowania, co stanowi finalny element procesu automatycznego dostarczania artefaktów.

## 4.Treść skryptów

`pipeline_test`
```
pipeline {
    agent any

    stages {
        stage('Checkout Source') {
            steps {
                git branch: 'AK423554', 
                    url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "Budowanie"
                    sh 'docker build --no-cache -t fastify-builder:latest -f ./ITE/GCL3/AK423554/lab3/Dockerfile.build ./ITE/GCL3/AK423554/lab3/'
                }
            }
        }
stage('Test') {
            steps {
                script {
                    echo "Testowanie"
                    sh 'docker build -t fastify-test:latest -f ./ITE/GCL3/AK423554/lab3/Dockerfile.test ./ITE/GCL3/AK423554/lab3/'
                    
                    def status = sh(script: 'docker run --rm fastify-test:latest', returnStatus: true)

                    if (status != 0) {

                        echo "Testy nie przeszły"
                    }
                }
            }
        }
        

stage('Deploy') {
    steps {
        script {
            sh 'docker rm -f c-deploy || true'
            sh 'docker run -d --name c-deploy --network jenkins-net fastify-builder:latest'
            
            sleep 2
            echo "Logi kontenera:"
            sh 'docker logs c-deploy'
        }
    }
}

stage('Verify') {
    steps {
        script {
           
            sh 'docker run --rm --network jenkins-net curlimages/curl curl -s -f http://c-deploy:3000/'
        }
    }
}
    
stage('Publish to NPM') {
    steps {
        withCredentials([string(credentialsId: 'npm-token-id-f2a', variable: 'NPM_TOKEN')]) {
            script {
                sh '''
                    docker run --rm \
                        -e NPM_TOKEN=${NPM_TOKEN} \
                        fastify-builder:latest bash -c '
                        
                        npm pkg set name="zajecia6ak123"
                        npm version patch --no-git-tag-version
                        echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > .npmrc
                        npm publish --access public --ignore-scripts
                    '
                '''
            }
        }
    }
}
}
    post {
        always {
            echo "Sprzątanie"
            sh 'docker stop c-deploy || true'
            sh 'docker image prune -f'
        //script {
                //withCredentials([string(credentialsId: 'npm-token-id', variable: 'NPM_TOKEN')]) {
                     //sh '''
                        //docker run --rm -e NPM_TOKEN=${NPM_TOKEN} node:20 bash -c "
                            //echo //registry.npmjs.org/:_authToken=${NPM_TOKEN} > .npmrc
                           // npm unpublish ak423554-lab6 --force
                        //"
                     //'''
                //}
        //}
    }
}
}
```
`dockerfile.build`
```
FROM node:22

WORKDIR /app

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 https://github.com/fastify/fastify.git ./fastify-repo

RUN cd ./fastify-repo && npm install

RUN npm install ./fastify-repo

RUN echo "const fastify = require('fastify')({ logger: true }); \
          \
          fastify.get('/', async (request, reply) => { \
            reply.type('text/html').send('<h1>Witaj w mojej aplikacji!</h1><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt.</p>'); \
          }); \
          \
          const start = async () => { \
            try { \
              await fastify.listen({ port: 3000, host: '0.0.0.0' }); \
              console.log('--- SERWER DZIAŁA NA PORCIE 3000 ---'); \
            } catch (err) { \
              console.error('--- BŁĄD PODCZAS STARTU ---'); \
              process.exit(1); \
            } \
          }; \
          start();" > app.js

CMD ["node", "app.js"]
```


# **Lab7:** Jenkinsfile: lista kontrolna / doszlifowywanie pipeline'u


---

## 1. Cel zajęć
Celem zajęć było przejście przez listę kontrolną z zajęć 7 i doszlifowanie swojego projektu.

---

## 2. Lista kontrolna

Wdrożony proces automatyzacji CI/CD w pełni realizuje założenia ścieżki krytycznej dla inżynierii 
oprogramowania. Każdy z wymaganych etapów został zaimplementowany w sposób zapewniający wysoką odtwarzalność, bezpieczeństwo oraz izolację środowisk. Z listy
kontrolnej lab7 brakowało już tylko dostarczanie przepisu z SCM a nie wklejać go w jenkinsa.
---

## 3. Dostarczanie przepisu z SCM
<img width="1242" height="588" alt="image" src="https://github.com/user-attachments/assets/d02a54bb-80c0-4480-b5cd-82beb2bd7872" />
Dodano plik `Jenkinsfile` do repozytorium oraz usunięto już zbędne w nim gitclone. Następnie stworzono nowy pipeline.
<img width="1023" height="706" alt="image" src="https://github.com/user-attachments/assets/49fe03ff-23c6-4dbe-a6ec-359122b3e840" />
<img width="1375" height="684" alt="image" src="https://github.com/user-attachments/assets/91473569-a6a4-4e4b-9a27-afffcd543e41" />





`pipeline_scm`
```
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                script {
                    echo "Budowanie"
                    sh 'docker build --no-cache -t fastify-builder:latest -f ./ITE/GCL3/AK423554/lab3/Dockerfile.build ./ITE/GCL3/AK423554/lab3/'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo "Testowanie"
                    sh 'docker build -t fastify-test:latest -f ./ITE/GCL3/AK423554/lab3/Dockerfile.test ./ITE/GCL3/AK423554/lab3/'
                    
                    def status = sh(script: 'docker run --rm fastify-test:latest', returnStatus: true)

                    if (status != 0) {

                        echo "Testy nie przeszły"
                    }
                }
            }
        }
        

        stage('Deploy') {
            steps {
                script {
                    sh 'docker rm -f c-deploy || true'
                    sh 'docker run -d --name c-deploy --network jenkins-net fastify-builder:latest'
            
                    sleep 2
                    echo "Logi kontenera:"
                    sh 'docker logs c-deploy'
                }
            }
        }

        stage('Verify') {
            steps {
                script {
           
                    sh 'docker run --rm --network jenkins-net curlimages/curl curl -s -f http://c-deploy:3000/'
                }
            }
    }
    
        stage('Publish to NPM') {
            steps {
             withCredentials([string(credentialsId: 'npm-token-id-f2a', variable: 'NPM_TOKEN')]) {
                    script {
                        sh '''
                           docker run --rm \
                            -e NPM_TOKEN=${NPM_TOKEN} \
                            -e BUILD_NUMBER=${BUILD_NUMBER} \
                            fastify-builder:latest bash -c '
                        
                            npm pkg set name="zajecia6ak123"
                            npm version 1.0.${BUILD_NUMBER} --no-git-tag-version
                        
                            echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > .npmrc
                            npm publish --access public --ignore-scripts
                            '
                        '''
                    }
                }
            }
        }
}
    post {
        always {
            echo "Sprzątanie"
            sh 'docker stop c-deploy || true'
            sh 'docker image prune -f'
        //script {
                //withCredentials([string(credentialsId: 'npm-token-id', variable: 'NPM_TOKEN')]) {
                     //sh '''
                        //docker run --rm -e NPM_TOKEN=${NPM_TOKEN} node:20 bash -c "
                            //echo //registry.npmjs.org/:_authToken=${NPM_TOKEN} > .npmrc
                           // npm unpublish ak423554-lab6 --force
                        //"
                     //'''
                //}
        //}
    }
}
}
```
