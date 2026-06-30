# Sprawozdanie 2

## Lab 5: Pipeline, Jenkins, izolacja etapów

**Środowisko: Maszyna wirtualna Ubuntu Server w Hyper-V na systemie operacyjnym Windows 11, Jenkins Blue Ocean w przeglądarce**  

Wymusiłam zakończenie działania kontenera jenkins-server z poprzednich zajęć, by postawić nowego Jenkinsa z Blue Ocean.  

![kill jenkins-server](<Lab5/Zrzut ekranu 2026-06-25 154206.png>)  

Uruchomiłam obraz Jenkinsa, który ma już wbudowane paczki Blue Ocean i sprawdziłam logi.   

![jenkins-blueocean](<Lab5/Zrzut ekranu 2026-06-25 155235.png>)  

Z sukcesem otworzyłam Blue Ocean w przeglądarce.  

![blue ocean](<Lab5/Zrzut ekranu 2026-06-25 155825.png>)  

Kolejne zadanie źle zrozumiałam i próbowałam je wykonać przez Jenkinsfile'a. Głównym problemem okazało się uruchomienie polecenia *docker pull*. Próbowałam rozwiązać problem z pomocą AI wklejając jako promty moje błędy zwrócone przez konsolę w Jenkinsie. Na początku dodałam Jenkinsfile do mojego githuba i połączyłam się z moją gałęzią na Jenkinsie.   

![branch indexing](<Lab5/Zrzut ekranu 2026-06-28 131023.png>)  

Większość błędów wyświetlanych przez Jenkinsa to *docker: not found*. Pierwszą próbą naprawienia było podpięcie socketa dockera.  

![socket](<Lab5/Zrzut ekranu 2026-06-28 133720.png>)  

Następnie usunęłam zbędne obrazy i komendy.  

![usunięcie mavena](<Lab5/Zrzut ekranu 2026-06-28 133916.png>)  

Okazało się jednak, że błędnie próbowałam sprecyzować agenta.  

![invalid agent type specified](<Lab5/Zrzut ekranu 2026-06-27 143258.png>)  

Pobrałam wszystkie pluginy związane z Dockerem.  

![pluginy](<Lab5/Zrzut ekranu 2026-06-25 165311.png>)  

Próbowałam również użyć obrazu ubuntu z poziomu agenta.  

![obraz ubuntu](<Lab5/Zrzut ekranu 2026-06-28 140414.png>)  

Błąd wykazał, że klient nie wysłał żądania do kontenera DinD.  

![API error](<Lab5/Zrzut ekranu 2026-06-27 143431.png>)  

Dodałam więc zmienne środowiskowe, które powinny pozwolić połączyć się klientowi z kontenerem DinD za pomocą sieci.  

![zmienne środowiskowe](<Lab5/Zrzut ekranu 2026-06-28 171120.png>)  

Wewnątrz nowo utworzonego kontenra brakowało certyfikatów TLS.  

![cert error](<Lab5/Zrzut ekranu 2026-06-27 143558.png>)  

W związku z tym, połączyłam się testowo po zwykłym porcie HTTP, by nie były wymagane certyfikaty.  

![HTTP error](<Lab5/Zrzut ekranu 2026-06-27 143603.png>)  

Po teście połączyłam się w ten sam sposób wewnątrz sieci mostkowej, wcześniej przeze mnie utworzonej.  

![jenkins-net](<Lab5/Zrzut ekranu 2026-06-28 172604.png>)  

Zadanie wykonało się poprawnie, ale błąd wystąpił wewnątrz wtyczki, prawdopodbnie przy pobraniu informacji na temat obiektów Dockera.  

![docker inspekt fail](<Lab5/Zrzut ekranu 2026-06-25 171936.png>)  

Zamiast wtyczki, spróbowałam rozwiązać wszystko poprzez bash. Dodałam zmienną środowiskową wewnątrz skryptu.  

![zmienna w bashu](<Lab5/Zrzut ekranu 2026-06-28 173501.png>)  

Otrzymałam błąd związany z demonem - klient nie był w stanie skomunikować się z nim.  

![daemon error](<Lab5/Zrzut ekranu 2026-06-27 143633.png>)  

Moje błędy wynikały z niezrozumienia Docker-in-Docker. Dlatego też rozwiązaniem problemu było pobranie dockera wewnątrz kontenera Jenkinsa - jest on potrzebny wewnątrz niego jako program, który wysyła polecenia do demona wewnątrz DinD. Zrezygnowałam również z Jenkinsfile'a, by powrócić do niego w momencie wyznaczonym przez instrukcję.  

![docker install](<Lab5/Zrzut ekranu 2026-06-28 125343.png>)  

Wszystkie zadania zwróciły sukces, co dowodzi temu, że Jenkins działa.    

![success](<Lab5/Zrzut ekranu 2026-06-28 125502.png>)  

Zadanie wyświtlające uname.  

![uname](<Lab5/Zrzut ekranu 2026-06-27 213503.png>)  

Zadanie zwracające błąd, gdy godzina jest nieparzysta.  

![hour even](<Lab5/Zrzut ekranu 2026-06-27 213410.png>)  

Zadanie pobierające obraz ubuntu.  

![docker pull](<Lab5/Zrzut ekranu 2026-06-28 130431.png>)  

Następnie napisałam pipeline, który sklonował repo przedmiotowe, zrobił checkout do pliku *Docker.builder* z poprzednich zajęć i zbudował go.  

![pipeline Docker.builder](<Lab5/Zrzut ekranu 2026-06-28 192132.png>)  

Za piewrszym razem pipeline wykonywał się 2 min i 8 s.

![pierwszy pipeline](<Lab5/Zrzut ekranu 2026-06-28 192149.png>)  

Za drugim uruchomieniem tylko 3.4 s. Związane jest to z cachem - Docker ma wbudowany mechanizm pamięci podręcznej, który sprawdza identyfikator obrazu oraz czy pliki w projekcie się zmieniły od ostatniego razu.  

![drugi pipeline](<Lab5/Zrzut ekranu 2026-06-28 192157.png>)  


Opracowałam pdf z wymaganym wstępnym środowiskiem do mojego projektu. Jest on związany z biblioteką JSON-java. W moim projekcie końcowym artefaktem będzie plik .jar z biblioteką i krótką aplikacją generującą plik JSON, w którym będą zapisane określone dane do weryfikacji, czy String poprawnie przekonwertował się do JSONa. W testach użyję narzędzia konsolowego *jq* do walidacji poprawności działania aplikacji.   

![środowisko](<Lab5/Zrzut ekranu 2026-06-29 223626.png>)  

Wykonałam diagramem aktywności.  

![diagram aktywności](<Lab5/Zrzut ekranu 2026-06-30 002907.png>)  

Oraz diagram wdrożeniowy.  
 
![diagram wdrożeniowy](<Lab5/Zrzut ekranu 2026-06-29 223640.png>)  

Na początku zdefiniowałam pierwszy krok pipeline'a *Collect*, dzięki któremu połączyłam się z repozytorium uczelnianym i dokonałam checkoutu pliku *Jenkinsfile*. Następnie napisałam odpowiednie pliki: Docker.build do kroku budowania, Docker.test do testowania, wcześniej opisaną krótką aplikację Main.java oraz bashowy skrypt jq_test, zapewniający weryfikację poprawności przekonwertowanego JSONa. Pipeline buduje się na dedykowanym DinD. Zapewnia to pełną izolację środowiska i bezpieczeństwo - gwarantuje build za każdym razem. Wadami jest jedynie sieciowy aspekt powiązany z koniecznością zarządzania certyfikatami TLS oraz wydajność. Gdyby z kolei kontener Jenkinsa współdzielił demona Dockera z hostem, zwiększyłaby się szybkość działania dzięki m.in. cache obrazów hosta. Wadą jest tu jednak kwestia bezpieczeństwa, gdyż wtedy kontener zyskuje uprawnienia roota na całym hoście (podatność na *code injection*).  

![Build&Test](<Lab5/Zrzut ekranu 2026-06-29 190048.png>)  

Następnie napisałam utworzyłam krok *Deploy*. W moim pipelinie polega on na skopiowaniu plików .class (zarówno biblioteki jak i aplikacji *Main.java*) z tymczasowego kontenera z obrazu testowego, by nie było potrzeby ponownej kompilacji na hoście. Następnie utowrzyłam tzw. *Fat JAR* - jeden, niezależny plik wykonywalny na aplikacji zawierający wszystkie wymagane zależności i klasy biblioteczne. Na koniec zbudowałam obraz produkcyjny na podstawie *Dockerfile.deploy* bazującym na lekkim środowisku uruchomieniowym (JRE), w którym aplikacja może zostać uruchomiona pomimo całkowitego odcięcia od środowiska produkcyjnego.  

![deploy](<Lab5/Zrzut ekranu 2026-06-29 193444.png>)  

Dyskusja:
- Program powinien być zapakowany do pliku formatu JAR - w przypadku ekosystemu Java jest to standard dystrybucyjny. Łatwo go przenieść, gdyż zawiera skompilowany kod bajtowy ready-to-run. Dzięki temu użytkownik nie ma dostępu do kodu źródłowego. 
- Program powinien być dystrybuowany jako obraz Docker, ze względu na to, że wtedy zawsze się dobrze uruchomi. Taki obraz gwarantuje powtarzalność środowiska - w moim przypadku wersja JRE, narzędzie jq oraz plik .jar z biblioteką i aplikacją. Nie powienien zawierać sklonowanego repozytorium, czyli kodów źródłowych, logów z builda czy narzędzi developerskich (Maven/Gradle). Zwiększa to podatność na ataki oraz rozmiar obrazu. 
- Obraz node zawiera pełen zestaw narzędzi programistycznych, kompilatory, biblioteki i narzędzia sieciowe, a node-slim zawiera jedynie silinik node i podstawowy system operacyjny. Pierwszy z nich stosowany jest do kompilacji, a drugi używany jest w procesie wdrożenia jako wersja produkcyjna. W ekosystemie Javy odpowiednikami node jest JDK z kompilatorem, a node-slim JRE - środowisko uruchomieniowe.  

Dopełnieniem Deployu jest Smoke Test, który wykazuje, że aplikacja działa poprawnie w lekkim środowisku JRE. Wchodzi on do wnętrza działającego kontera produkcyjnego i weryfikuje wygenerowany plik *output.json* narzędziem *jq*.  

![smoke test](<Lab5/Zrzut ekranu 2026-06-29 212856.png>)  

Ostatni etap Publish odpowiada za bezpieczeństwo oprogramowania. Za pomocą narzędzia OpenSSH wygenerowałam kryptograficzny podpis dla pliku .jar, który uniemożliwia wstrzyknięcie złośliwego kodu. Utworzyłam też plik metadanych wiążący artefakt z konkretnym numerem builda w Jenkinsie i trwale opublikowałam gotowy zestaw plików (plik .jar, metadane, podpis i produkcyjny JSON) jako oficjalne wydanie do pobrania z serwera CI/CD.  

![publish](<Lab5/Zrzut ekranu 2026-06-29 214024.png>)  


## Lab 6: Pipeline: lista kontrolna

Wykonałam każdy z kroków ścieżki krytycznej. Uruchamiałam manualnie builda w interfejsie Jenkinsa po każdym commicie do repozytorium.  

![commit](<Lab6/Zrzut ekranu 2026-06-30 150600.png>)  

Lista kontrolna:
- Moja prosta aplikacja korzysta z biblioteki JSON-java napisanej w Javie, konwerując za jej pomocą tekst (String) do struktury JSONArray, a następnie generuje plik JSON służący do walidacji poprawności danych narzędziem *jq*.
- Biblioteka JSON-java jest dystrybuowana na licencji Public Domain pozwalającej na modyfikacje, reprodukcję i redystrybucję kodu bez restrykcji prawnych.
- Program buduje się za pomocą Mavena.
- Wszystkie testy jednostkowe zawarte w bibliotece oraz ten napisany przeze mnie są zakończone sukcesem.
- Zdecydowałam, że nie będę robić forku repozytorium JSON-java, gdyż nie miałam zamiaru dodawać do biblioteki żadnych nowych zależności. Ponadto użytkownik w przeciwnym wypadku nie miałby dostępu do aktualizacji biblioteki. Ta decyzja gwarantuje również czystość struktury projektowej. 
- Utworzyłam dwa diagramy UML przed rozpoczęciem tworzenia pipelinu.
- Kontenerem bazowym jest kontener budujący - korzysta potem z niego kontener testowy.
- Build został wykonany wewnątrz kontenera json-java-build na konkretnym obrazie *maven:3.9.6-eclipse-temurin-17*.
- Testy zostały wkonane wewnątrz kontenera json-java-test.
- Kontener testowy jest oparty o kontener budujący.
- Logi Jenkinsa są zapisywane automatycznie i trwale powiązane z numerem uruchomienia potoku ${BUILD_NUMBER}, który w kroku Publish jest przypisywany do artefaktu w metadanych.
- Zdefiniowałam kontener typu 'deploy' za pomocą Dockerfile.deploy, uruchamiający lekkie środowisko JRE, które zminiejsza rozmiar obrazu i zwiększa bezpieczeństwo kodu źródłowego. 
- Odrzuciłam kontener buildowy w deployu w związku z wyżej podanymi zaletami JRE.
- Wersjonowany kontener 'deploy' ze zbudowaną aplikacją jest wdrażany na instancję Dockera - zastosowałam flagę -d, co umożliwiło asynchroniczne działanie i zlikwidowało możliwość zamrożenia pipelinu. 
- Zamieściłam Smoke Test jako osobny krok, w którym wykrywa plik wynikowy i przeprowadza test *jq* - sukces oznacza, że kontener wstał prawidłowo, a aplikacja działa.
- Elementem publikowanym jako artefakt jest plik JAR.
- Kontener z plikiem JAR był najlepszą opcją, gdyż plik JAR zawiera wszystkie potrzebne klasy biblioteki i samą aplikację - potrzeba jedynie podstawowego środowiska Javy, które jest zainstalowane w kontenerze, który ma mały rozmiar dzięki lekkiemu JRE.
- Wersjonowanie artefaktów przebiega w metadanych za pomocą unikalnego numeru buildu pobieranego ze zmiennej środowiskowej Jenkinsa. Ich dostępność jest zrealizowana poprzez załączenie ich jako rezultat pomyślnego builda w Jenkinsie. 
- Identyfikowanie artefaktu przebiega poprzez weryfikacje metadanych (nazwa, data publikacji, numer buildu, suma kontrolna) oraz podpis kryptograficzny w postaci skrótu pliku JAR zaszyfrowanego przez klucz prywatny RSA.
- Treść Jenkinsfile:

```groovy
pipeline {
    agent any
    stages {
        stage('Collect') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps{
                dir('ITE/GCL1/MB421332/Sprawozdanie2'){
                    sh 'docker build -t json-java-build:latest -f Dockerfile.build .'
                }
            }
        }
        stage('Test'){
            steps{
                dir('ITE/GCL1/MB421332/Sprawozdanie2'){
                    sh '''
                        docker build -t json-java-test:latest -f Dockerfile.test .
                        docker run --name tester-run-${BUILD_NUMBER} json-java-test:latest
                        docker cp tester-run-${BUILD_NUMBER}:/usr/src/mymaven/output.json ./output.json
                    '''
                }
            }
            post {
                always {
                    sh 'docker rm -f tester-run-${BUILD_NUMBER} || true'
                }
            }
        }
        stage('Deploy'){
            steps{
                dir('ITE/GCL1/MB421332/Sprawozdanie2'){
                        sh '''
                            docker create --name extract-container json-java-test:latest
                            mkdir -p target/classes
                            docker cp extract-container:/usr/src/mymaven/target/classes/org ./target/classes/
                            docker cp extract-container:/usr/src/mymaven/Main.class ./target/classes/
                            docker rm extract-container

                            mkdir -p target
                            docker run --rm -v $(pwd):/app -w /app eclipse-temurin:17-jdk jar cvfe target/aplikacja.jar Main -C target/classes .

                            docker build -t app-deploy:latest -f Dockerfile.deploy .
                        
                            docker stop app-production-container || true
                            docker rm app-production-container || true
                            docker run -d --name app-production-container app-deploy:latest sh -c "java -jar app.jar; tail -f /dev/null"
                        '''
                }
            }
        }
        stage('Smoke Test'){
            steps{
                script{
                    dir('ITE/GCL1/MB421332/Sprawozdanie2'){
                        echo "The app is running..."
                        sh 'docker logs app-production-container'
                        try {
                            echo "Verifying generated file output.json..."
                            sh '''
                                    docker exec app-production-container test -f output.json
                                    echo "File output.json has been found! Running jq..."
                                    docker exec app-production-container jq -e '.status == "ok"' output.json
                                '''
                            sh 'docker cp app-production-container:/app/output.json ./output.json'
                        } catch (Exception e) {
                            error("File output.json hasn't been created")
                        }
                    }
                }
            }
        }
        stage('Publish'){
            steps{
                dir('ITE/GCL1/MB421332/Sprawozdanie2'){
                    sh '''
                            openssl genrsa -out private_key.pem 2048
                            openssl dgst -sha256 -sign private_key.pem -out target/aplikacja.jar.sig target/aplikacja.jar
                            
                            echo "Artifact: JSON-java App with JQ verification" > target/metadata.txt
                            echo "Jenkins build number: ${BUILD_NUMBER}" >> target/metadata.txt
                            echo "Publication date: $(date)" >> target/metadata.txt
                            echo "SHA256 checksum:" >> target/metadata.txt
                            sha256sum target/aplikacja.jar >> target/metadata.txt
                        '''
                        archiveArtifacts artifacts: 'target/aplikacja.jar, target/*.sig, target/metadata.txt, output.json', fingerprint: true
                }
            }
        }
    }
    post {
        always {
            dir('ITE/GCL1/MB421332/Sprawozdanie2') {
                sh 'docker stop app-production-container || true'
                sh 'docker rm app-production-container || true'
                sh 'docker image prune -f'
            }
        }
    }
}

```  

Treść Dockerfile.build:

```dockerfile
FROM maven:3.9.6-eclipse-temurin-17
RUN apt-get update && apt-get install -y git ca-certificates jq && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/mymaven
RUN git clone https://github.com/stleary/JSON-java.git .
RUN mvn compile
COPY Main.java .
COPY jq_test.sh .
RUN javac -cp target/classes Main.java
RUN chmod +x ./jq_test.sh
CMD ["/bin/bash"]
```

Treść Dockerfile.test
```dockerfile
FROM json-java-build:latest
WORKDIR /usr/src/mymaven
CMD ["sh", "-c", "mvn test && java -cp .:target/classes Main && ./jq_test.sh"]
```

Treść Dockerfile.deploy
```dockerfile
FROM eclipse-temurin:17-jre
WORKDIR /app
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*
COPY target/aplikacja.jar app.jar
COPY output.json .
CMD ["java", "-jar", "app.jar"]
```
- Diagram UML planowanego pipeline'u uległ zmianie. Poprawiłam go korzystając z narzędzia plantuml. Ostateczny diagram został zaktualizowany o krok Deploy, który pozwala na przygotowanie redystrybucji oraz uruchomienie odizolowanego środowiska produkcyjnego JRE. W moim pipelinie wydzieliłam również Smoke Test jako osobny krok, by sprawdzić poprawność deployu.

![diagram UML](<Lab6/Zrzut ekranu 2026-06-30 153310.png>)

Pipeline zwrócił oczekiwany wynik. Po publishu dostępne są artefakty do pobrania w Jenkinsie.  

![artifacts](<Lab6/Zrzut ekranu 2026-06-30 150432.png>)

## Lab 7: Jenkinsfile: lista kontrolna

Kroki Jenkinsfile
- Przepis dostarczam z SCM (krok *Collect*).
- Przed każdym uruchomieniem kontenera produkcyjnego stosuję czyszczenie 
![post clean](<Lab7/Zrzut ekranu 2026-06-30 163126.png>)
- 

## Promty AI
AI używałam do rozwiązywania błędów oraz doprecyzowywania zagadnień, gdy nie rozumiałam w jaki sposób dane narzędzie działa:
- Błędy związane z uruchomieniem docker pull
- Jak działa cache w pipeline
- Przekonwertuj tego jsona w stringa (przekazałam mu plik pobrany z internetu)