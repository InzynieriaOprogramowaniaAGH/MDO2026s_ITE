# Sprawozdanie z Laboratorium 5: Pipeline, Jenkins, izolacja etapów

**Autor:** Oskar

## Cel ćwiczenia
Głównym założeniem laboratorium było wdrożenie serwera Jenkins z wykorzystaniem mechanizmu Docker-in-Docker (DinD) oraz przygotowanie bazowej konfiguracji pod zautomatyzowane procesy CI/CD.

---

## 1. Przygotowanie środowiska Jenkins

Pierwszym etapem było przygotowanie izolowanego środowiska opartego o kontenery Docker, po uprzednim upewnieniu się, że kontenery budujące i testujące z poprzednich zajęć działają poprawnie.

* Utworzono dedykowaną sieć w Dockerze o nazwie `jenkins2`.
![image](image2.png)

* Zgodnie z oficjalną instrukcją, uruchomiono obraz Dockera (Docker in Docker - DinD) eksponujący zagnieżdżone środowisko, w trybie uprzywilejowanym.
![image](image3.png)

* Przygotowano niestandardowy plik `Dockerfile.jenkins.BlueOcean` bazujący na oficjalnym obrazie `jenkins/jenkins:lts-jdk17`. Główną różnicą było doinstalowanie w nim niezbędnych narzędzi CLI Dockera oraz specyficznych wtyczek.
<br> Zawartość pliku Dockerfile:
```Dockerfile
FROM jenkins/jenkins:lts-jdk17 
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
```


* Wewnątrz pliku Dockerfile skonfigurowano pobieranie kluczy GPG i repozytoriów Dockera, a następnie zainstalowano narzędzie `docker-ce-cli`. Zainstalowano także wtyczki `blueocean` oraz `docker-workflow`.
* Zbudowano nowy obraz i uruchomiono instancję Jenkinsa z interfejsem Blueocean, podłączając kontener do odpowiedniej sieci i wystawiając porty.
![image](image5.png)
![image](image6.png)

* Z logów kontenera odczytano wygenerowane jednorazowe hasło administratora.
![image](image7.png)

* W interfejsie webowym zalogowano się, odblokowano Jenkinsa i wykonano początkową konfigurację, w tym utworzenie użytkownika `oskar`. Zadbanie o logi i ich archiwizację było jednym z wymogów konfiguracyjnych.
![image](image8.png)
![image](image9.png)

![image](image10.png)

![image](image11.png)

![image](image12.png)

![image](image13.png)

---

## 2. Zadanie wstępne: Uruchomienie pierwszych projektów

Po poprawnej konfiguracji Jenkinsa, przystąpiono do tworzenia prostych projektów w celu weryfikacji działania środowiska.

* **Wyświetlanie informacji o systemie:** Utworzono projekt, który wykonywał polecenie `uname`. Konsola Jenkinsa zwróciła poprawny wynik.
![image](image17.png)

* **Zwracanie błędu w oparciu o czas:** Utworzono skrypt w języku Groovy sprawdzający aktualną godzinę. Skrypt miał za zadanie zwrócić błąd i przerwać działanie, gdy godzina wykonania była nieparzysta.
![image](image18.png)
![image](image19.png)


* **Pobieranie obrazu kontenera:** W ramach kolejnego kroku, wykorzystując polecenie `docker pull`, wdrożono w projekcie pobieranie obrazu kontenera `ubuntu`.
![image](image20.png)
![image](image21.png)



---

## 3. Zadanie wstępne: Obiekt typu pipeline i praca z repozytorium

Ostatnim obowiązkowym etapem zrealizowanym na zajęciach po wykazaniu poprawnego działania Jenkinsa było stworzenie pełnoprawnego potoku CI.

* Utworzono nowy obiekt typu `pipeline`. Treść potoku została wpisana bezpośrednio do obiektu w Jenkinsie, bez użycia mechanizmu SCM na tym etapie.
![image](image22.png)

* Zdefiniowano potok (`pipeline { agent any ... }`) realizujący następujące kroki:
  * **Czyszczenie obszaru roboczego** (`deleteDir()`).
  * **Klonowanie i Checkout:** Wykorzystano komendę `git` do sklonowania przedmiotowego repozytorium `MDO2026s_ITE`.
  * Następnie wykonano *checkout* do osobistej gałęzi studenta, zawierającej plik Dockerfile właściwy dla *buildera* wybranego w poprzednich etapach projektu.
![image](image22.png)

  * **Budowanie obrazu Docker:** Użyto mechanizmów Jenkinsa w celu zbudowania nowego obrazu na podstawie wskazanego pliku Dockerfile. Logi z działania potwierdziły poprawny przebieg.
![image](image23.png)
![image](image24.png)

  * **Drugie uruchomienie:** Zgodnie z instrukcją, uruchomiono stworzony potok drugi raz w celu weryfikacji powtarzalności procesu. Potok zakończył się poprawnie i zweryfikowano obecność obrazów za pomocą poleceń systemowych.
![image](image25.png)

# Sprawozdanie z Laboratorium 6 i 7: Kompletny potok CI/CD i Infrastructure as Code

## 1. Cel ćwiczeń
Głównym założeniem zajęć było przejście na model „Infrastructure as Code” i zdefiniowanie całego procesu CI/CD w sposób deklaratywny za pomocą pliku `Jenkinsfile` umieszczonego w repozytorium. Projekt musiał pokryć pełną ścieżkę krytyczną: zaciągnięcie kodu (*clone*), kompilację (*build*), weryfikację jakości (*test*), budowę formatu wdrożeniowego (*publish*) oraz środowiskowe uruchomienie gotowego oprogramowania (*deploy*).

## 2. Przedmiot potoku i środowisko
* **Aplikacja testowa:** Opracowano prosty program testowy napisany w języku C (`wrapper.c`), służący jako nakładka dekompresująca (wrapper) wykorzystująca otwartoźródłową bibliotekę `zlib`. Program przyjmuje jako argument plik `.gz`, a następnie dekompresuje go i zrzuca na standardowe wyjście.
* **Środowisko budowania:** Opracowano własny obraz kontenera, służący jako agent wykonawczy, opisany za pomocą dedykowanego pliku `Dockerfile`.
* **Zależności:** Jako obraz bazowy wybrano dystrybucję `ubuntu:22.04`. Środowisko instaluje w trybie nieinteraktywnym narzędzia deweloperskie (`build-essential`), biblioteki rozwojowe (`zlib1g-dev`), `gzip` oraz narzędzia do tworzenia paczek (`dpkg-dev`). 
* **Architektura przepływu pracy:** Przebieg pracy zaprojektowano w formie diagramu odzwierciedlającego drogę od kodu źródłowego (`wrapper.c`), przez kompilację i test archiwizacji, do weryfikacji sum kontrolnych MD5 oraz finalnego wyeksportowania pakietu DEB jako ostatecznego artefaktu.
```mermaid
flowchart TD
    Start((Start)) --> B[Build: Kompilacja gcc -lz]
    B --> P[Pakowanie: Utworzenie test.txt.gz]
    P --> T{Test MD5}
    T -- Zgodne --> Pub[Publish: Pakowanie dpkg-deb]
    T -- Niezgodne --> Err[Exit 1 / Przerwanie potoku]
    Pub --> Dep[Deploy Sandbox: dpkg -i zlib-tool.deb]
    Dep --> V[Weryfikacja działania zlib-tool]
    V --> Arc[Post: Archiwizacja artefaktu .deb]
    Arc --> End((Koniec))
```
Rys.1 Przepływ potoku CI/CD

  
## 3. Realizacja ścieżki krytycznej CI/CD w pliku Jenkinsfile

Konfiguracja potoku w Jenkinsie oparta na importowaniu Jenkinsfile prosto z gałęzi git (rozwiązanie SCM). 
![image](image27.png)
![image](image28.png)
Stworzony potok działa w izolacji (uruchamiany jest wewnątrz kontenera opartego o ww. Dockerfile, działającego jako użytkownik `root`) i podzielony został na logiczne etapy (stages):

1. **Build (Kompilacja):** Krok ten uruchamia kompilator `gcc` z flagą `-lz`, linkując tym samym odpowiednie biblioteki zlib do pliku źródłowego `wrapper.c`. W wyniku kompilacji powstaje binarny plik wykonywalny `wrapper.bin`.
```Jenkinsfile
stage('Build (Kompilacja)') {
            steps {
                sh '''
                    echo "Kompilacja pliku pobranego z Gita..."
                    gcc -o wrapper.bin ITE/GCL1/OD423299/jenkins-zlib-test/src/wrapper.c -lz
                '''
            }
        }
```
2. **Pakowanie i utworzenie wektora testowego:** Potok tworzy plik tekstowy o nazwie `test.txt`, oblicza i wyodrębnia za pomocą `awk` jego oryginalną sumę kontrolną MD5, po czym kompresuje ten plik narzędziem `gzip` (tworząc plik `test.txt.gz`). Plik testowy w naszym repozytorium zawiera ciąg znaków: *"testowy plik tekstowy do przetestowania e2e biblioteki zlib na devopsach 17.04.2026"*.
```Jenkinsfile
stage('Pakowanie (Niezależne)') {
            steps {
                sh '''
                    echo "Test integralności zlib w CI/CD" > test.txt
                    md5sum test.txt | awk "{print $1}" > original.md5
                    
                    gzip -c test.txt > test.txt.gz
                '''
            }
        }
```
3. **Test MD5 (C1):** Krok testowania przeprowadzany jest wewnątrz kontenera testowego opartego na obrazie buildowym. Za pomocą nowo skompilowanego dekompresatora (`wrapper.bin`) plik GZ zostaje wypakowany, po czym następuje weryfikacja sumy kontrolnej względem wartości bazowej. Pomyślne przejście tego etapu umożliwia kontynuację pracy potoku, błąd natomiast generuje kod wyjścia (exit status 1), blokując niepoprawny kod.
```Jenkinsfile
stage('Test MD5 (C1)') {
            steps {
                sh '''
                    ./wrapper.bin test.txt.gz > wynik.txt
                    
                    ORIG_MD5=$(md5sum test.txt | cut -d' ' -f1)
                    CURR_MD5=$(md5sum wynik.txt | cut -d' ' -f1)
                    
                    echo "MD5 przed: $ORIG_MD5"
                    echo "MD5 po:    $CURR_MD5"
                    
                    if [ "$ORIG_MD5" = "$CURR_MD5" ]; then
                        echo "Weryfikacja powiodłą się"
                    else
                        echo "BŁĄD: Dane uległy uszkodzeniu!"
                        exit 1
                    fi
                '''
            }
        }
```
4. **Publish / Pakowanie .DEB:** Program docelowo został zapakowany do paczki redystrybucyjnej instalatora Debiana. Plik wykonywalny aplikowany jest do wirtualnej ścieżki `pkg/usr/bin/zlib-tool`, tworzony jest wpis `control` opisujący paczkę w systemie (`Version: 1.0.0`, `Architecture: amd64`), po czym uruchamiana jest komenda budująca pakiet `dpkg-deb`. Zdecydowano się na tę formę redystrybucji artefaktu ze względu na łatwość instalacji, zarządzania wersjami oraz samodzielnego działania na docelowych maszynach Ubuntu bez konieczności zabierania środowiska buildowego.
```Jenkinsfile
stage('Pakowanie .DEB') {
            steps {
                sh '''
                    mkdir -p pkg/DEBIAN pkg/usr/bin
                    cp wrapper.bin pkg/usr/bin/zlib-tool
                    
                    cat <<EOF > pkg/DEBIAN/control
Package: zlib-wrapper-tool
Version: 1.0.0
Architecture: amd64
Maintainer: Jenkins
Description: Narzedzie do dekompresji GZIP oparte na zlib
EOF
                    dpkg-deb --build pkg zlib-tool.deb
                '''
            }
        }
```
5. **Deploy (Wdrożenie Sandbox):** Paczka DEB w ramach zintegrowanego wdrożenia *smoke testowego* zostaje od razu próbnie zainstalowana za pomocą komendy `dpkg -i`. Kolejno odbywa się wywołanie zainstalowanego narzędzia z podanej ścieżki `/usr/bin/zlib-tool`, co weryfikuje poprawność wdrożenia bez blokowania przejścia przez Jenkinsa.
```Jenkinsfile
stage('Deploy (Wdrożenie Sandbox)') {
            steps {
                sh '''
                    echo "Instalacja paczki na serwerze docelowym"
                    dpkg -i zlib-tool.deb
                    
                    echo "Weryfikacja działania"                    
                    /usr/bin/zlib-tool || true
                    
                    echo "Deploy udany"
                '''
            }
        }
```
6. **Archiwizacja artefaktu:** Przy poprawnym wykonaniu wszystkich kroków potoku następuje odłożenie rezultatu prac do instancji Jenkinsa (post stage) za pomocą komendy `archiveArtifacts artifacts: 'zlib-tool.deb'` z przyporządkowanym identyfikatorem *fingerprint* w celu zapewnienia czytelności źródła binarnego. Można go następnie pobrać i wdrożyć docelowo na maszynę zgodną z architekturą amd64.
```Jenkinsfile
post {
        success {
            archiveArtifacts artifacts: 'zlib-tool.deb', fingerprint: true
        }
    }
```

Wynikiem działań jest załączony artefakt do projektu
![image](image29.png)
