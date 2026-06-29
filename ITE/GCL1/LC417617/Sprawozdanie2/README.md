## Zajęcia 5 — Jenkins Pipeline i Blue Ocean

Celem zajęć było uruchomienie Jenkinsa w kontenerach, wykonanie podstawowej konfiguracji oraz przygotowanie prostego pipeline. Pipeline miał kilka etapów i pokazywał zarówno poprawne, jak i błędne wykonanie zadania.

W ramach ćwiczenia użyłem Dockera, Docker Compose, Jenkinsa oraz widoku Blue Ocean.

---

### 1. Przygotowanie plików Dockera

Na początku przygotowałem pliki potrzebne do uruchomienia Jenkinsa.

Pierwszy plik to:

```text
Sprawozdanie2/Dockerfile.jenkins
```

W tym pliku został użyty obraz:

```dockerfile
FROM jenkins/jenkins:lts
```

Dodatkowo w obrazie instalowane były potrzebne pakiety oraz wtyczki, między innymi Blue Ocean.

![Dockerfile dla Jenkinsa](./img/L4_DockerJenkins_1.png)

Drugim plikiem był:

```text
Sprawozdanie2/docker-compose.yml
```

W tym pliku zostały opisane usługi potrzebne do działania Jenkinsa oraz Dockera. Konfiguracja zawierała między innymi porty:

```yaml
ports:
  - "8081:8080"
  - "50000:50000"
```

oraz wolumeny na dane Jenkinsa.

![Docker Compose dla Jenkinsa](./img/L4_DockerCompose_2.png)

---

### 2. Uruchomienie środowiska

Po przygotowaniu plików uruchomiłem środowisko poleceniem:

```bash
docker compose up -d --build
```

Polecenie zbudowało obraz Jenkinsa i uruchomiło kontenery w tle.

![Uruchamianie Docker Compose](./img/L4_Odpalanie_3.png)

Podczas uruchamiania pojawiły się drobne ostrzeżenia, ale nie zatrzymały one dalszej pracy. Następnie sprawdziłem logi Jenkinsa:

```bash
docker compose logs jenkins
```

![Logi Jenkinsa](./img/L4_lekkieErroryAleGit_4.png)

---

### 3. Pierwsze logowanie do Jenkinsa

Po uruchomieniu Jenkinsa trzeba było pobrać hasło początkowe administratora. Użyłem do tego polecenia:

```bash
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Hasła nie przepisuję w sprawozdaniu, ponieważ jest to dana dostępowa.

Następnie wkleiłem hasło w ekranie odblokowania Jenkinsa.

![Odblokowanie Jenkinsa](./img/L4_wklejonehaslodoJenkinsa_6.png)

Po odblokowaniu Jenkinsa wybrałem instalację sugerowanych wtyczek.

![Instalacja sugerowanych wtyczek](./img/L4_JenkinsLogin_7.png)

---

### 4. Utworzenie pierwszego użytkownika

Następnie utworzyłem pierwszego użytkownika administratora. Uzupełniłem login, hasło, nazwę użytkownika oraz adres e-mail.

![Tworzenie pierwszego administratora](./img/L4_JenkinsLogin2_8.png)

Po tym Jenkins poprosił o potwierdzenie adresu URL instancji. Zostawiłem adres wskazujący na uruchomionego Jenkinsa.

![Konfiguracja adresu Jenkinsa](./img/L4_JenkinsLogin3_9.png)

Po zakończeniu konfiguracji pojawił się ekran informujący, że Jenkins jest gotowy.

![Jenkins gotowy](./img/L4_JenkinsLogin4_10.png)

---

### 5. Panel główny Jenkinsa

Po zakończeniu konfiguracji wszedłem do panelu głównego Jenkinsa.

![Panel główny Jenkinsa](./img/L4_OpenBlueOcean_10.png)

Z tego miejsca można było przejść do tworzenia nowego projektu.

---

### 6. Utworzenie projektu Pipeline

Wybrałem opcję utworzenia nowego projektu.

![Nowy projekt](./img/L4_Projekt_11.png)

Jako nazwę projektu podałem:

```text
Zadanie_1_417617
```

Jako typ projektu wybrałem:

```text
Pipeline
```

![Wybór projektu Pipeline](./img/L4_Projekt2_12.png)

Po zatwierdzeniu projekt został utworzony.

![Utworzony projekt](./img/L4_Projekt3_13.png)

---

### 7. Sprawdzenie projektu i Blue Ocean

Po utworzeniu projektu sprawdziłem jego widok w Jenkinsie. Projekt był widoczny na liście zadań.

![Projekt w Jenkinsie](./img/L4_PrzedOpenBlueOceanSprawdzam_13.png)

Następnie przeszedłem do widoku Blue Ocean.

![Wejście do Blue Ocean](./img/L4_OpenBlueOcean_13.png)

W Blue Ocean projekt był widoczny na liście pipeline.

![Projekt w Blue Ocean](./img/L4_OpenBlueOcean2_14.png)

Następnie sprawdziłem widok szczegółów projektu i historię uruchomień.

![Widok Blue Ocean](./img/L4_OpenBlueOcean3_15.png)

![Szczegóły w Blue Ocean](./img/L4_OpenBlueOcean4_16.png)

---

### 8. Konfiguracja pipeline

Następnie przeszedłem do konfiguracji projektu. W sekcji Pipeline wybrałem tryb:

```text
Pipeline script
```

W tym miejscu można było wkleić skrypt pipeline bezpośrednio w konfiguracji Jenkinsa.

![Konfiguracja pipeline](./img/L4_Konfiguruj1_17.png)

Potem podmieniłem skrypt na przygotowaną wersję zadania.

![Podmiana skryptu pipeline](./img/L4_Konfiguruj2PodmianaNaZadv2_18.png)

---

### 9. Problem z repozytorium i poprawka

Podczas pierwszych prób pojawił się problem związany z brakiem potrzebnych plików albo folderu w repozytorium. Jenkins nie mógł poprawnie przejść dalej, ponieważ w repozytorium nie było jeszcze wymaganej zawartości.

![Błąd przez brak folderu w repozytorium](./img/L4_BladBoNieMaFolderuNaGicie_19.png)

Po dodaniu potrzebnych plików wykonałem commit i push na branch `LC417617`.

![Dodanie plików do repozytorium](./img/L4_PrzeslalemCoTrzeba_19.png)

Po tej poprawce projekt mógł dalej korzystać z plików w repozytorium.

![Projekt po dodaniu plików](./img/L4_IDziala_20.png)

---

### 10. Skrypt pipeline

Finalny skrypt pipeline został zapisany w pliku:

```text
Sprawozdanie2/Zajecia5/L4_Zadanie_1_skryptV3.txt
```

Pipeline miał cztery główne etapy:

```text
Checkout
Build - Uname
Test - Godzina
Deploy - Docker Pull
```

Etap `Checkout` pobierał repozytorium z brancha `LC417617`.

Etap `Build - Uname` wykonywał:

```bash
uname -a
```

Etap `Test - Godzina` sprawdzał aktualną godzinę. Jeżeli godzina była nieparzysta, pipeline kończył się błędem.

Etap `Deploy - Docker Pull` wykonywał:

```bash
docker pull ubuntu
```

Finalny skrypt wyglądał tak:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'LC417617', url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
            }
        }

        stage('Build - Uname') {
            steps {
                sh 'uname -a'
            }
        }

        stage('Test - Godzina') {
            steps {
                sh '''
                    HOUR=$(date +%H)
                    echo "Aktualna godzina: $HOUR"
                    if [ $((HOUR % 2)) -ne 0 ]; then
                        echo "BŁĄD: Godzina jest nieparzysta, przerywam!"
                        exit 1
                    fi
                '''
            }
        }

        stage('Deploy - Docker Pull') {
            steps {
                sh 'docker pull ubuntu'
            }
        }
    }
}
```

![Finalna wersja skryptu](./img/L4_V3_21.png)

---

### 11. Przypadek błędny — godzina nieparzysta

Pipeline został uruchomiony w momencie, gdy aktualna godzina była nieparzysta. Etap `Test - Godzina` zakończył się wtedy błędem.

W logu widoczny był komunikat:

```text
BŁĄD: Godzina jest nieparzysta, przerywam!
```

oraz informacja, że skrypt zwrócił kod błędu `1`.

Było to poprawne zachowanie, ponieważ taki warunek został zapisany w pipeline.

![Pipeline zatrzymany przez nieparzystą godzinę](./img/L4_DzialaWstrzymanie_22.png)

---

### 12. Przypadek poprawny

Po kolejnym uruchomieniu pipeline przeszedł poprawnie przez wszystkie etapy. W widoku Blue Ocean wszystkie kroki były oznaczone na zielono.

Ostatni etap wykonał polecenie:

```bash
docker pull ubuntu
```

czyli pobranie obrazu `ubuntu`.

![Pipeline wykonany poprawnie](./img/L4_DzialaNormalnie_23.png)

---

### 13. Przygotowane pliki

W ramach zadania przygotowałem następujące pliki:

```text
Sprawozdanie2/Dockerfile.jenkins
Sprawozdanie2/docker-compose.yml
Sprawozdanie2/Zajecia5/L4_Zadanie_1_skrypt.txt
Sprawozdanie2/Zajecia5/L4_Zadanie_1_skryptV3.txt
```

Do sprawozdania zostały też dodane screeny z konfiguracji Jenkinsa, Blue Ocean oraz wyników pipeline.

---

### 14. Wnioski

W ramach zajęć udało się uruchomić Jenkinsa w kontenerach i przygotować prosty pipeline.

Najważniejsze wykonane elementy to:

* przygotowanie `Dockerfile.jenkins`,
* przygotowanie `docker-compose.yml`,
* uruchomienie Jenkinsa przez Docker Compose,
* odblokowanie Jenkinsa hasłem początkowym,
* instalacja wtyczek,
* utworzenie użytkownika administratora,
* utworzenie projektu typu Pipeline,
* konfiguracja skryptu pipeline,
* uruchomienie pipeline w Jenkinsie,
* sprawdzenie wyników w Blue Ocean,
* pokazanie błędnego i poprawnego przebiegu pipeline.

Najważniejszy element techniczny to etap sprawdzający godzinę. Dzięki niemu pipeline mógł zakończyć się błędem, jeżeli warunek nie był spełniony. Pokazuje to, że Jenkins może nie tylko wykonywać komendy, ale też reagować na wynik testu i zatrzymywać dalsze etapy.

---

### 15. Użycie LLM

Podczas pracy korzystałem z pomocy LLM jako wsparcia przy porządkowaniu skryptu i opisu. Odpowiedzi modelu były sprawdzane praktycznie przez uruchamianie komend i pipeline w Jenkinsie.


```text
Jak pobrać hasło początkowe administratora Jenkinsa z kontenera?
```

Ten prompt pomógł przy znalezieniu pliku `initialAdminPassword`.


```text
Jak napisać prosty Jenkins Pipeline z etapami checkout, test i deploy?
```

Ten prompt pomógł uporządkować strukturę pipeline z blokami `pipeline`, `agent`, `stages`, `stage` i `steps`.



```text
Jak dodać etap docker pull ubuntu do Jenkins Pipeline?
```

Ten prompt pomógł przy etapie pobierania obrazu `ubuntu`.

```text
Popraw poniższy plik ReadMe pod względem ortograficznym i poprawnym językiem.
```

LLM pomógł głównie w uporządkowaniu kroków, wyjaśnieniu błędów i przygotowaniu opisu. Samo utworzenie projektu, uruchomienie pipeline, wykonanie screenów, commit i push zostały wykonane w środowisku laboratoryjnym.


## Zajęcia 6 — Pipeline CI/CD dla cJSON

Celem zajęć było przygotowanie pełniejszego pipeline CI/CD dla wybranej aplikacji. Pipeline miał obejmować pobranie kodu, budowanie aplikacji, uruchomienie testów, przygotowanie obrazu do uruchomienia, wykonanie prostego smoke testu oraz opublikowanie artefaktu w Jenkinsie.

Jako aplikację testową wybrałem bibliotekę `cJSON`. Jest to niewielki projekt napisany w języku C, który można budować przez `cmake` i testować przez `ctest`.

---

### 1. Wybór aplikacji

Do zadania została wybrana aplikacja:

```text
cJSON
```

Kod projektu został umieszczony w katalogu:

```text
Sprawozdanie2/Zajecia6/cJSON
```

Projekt posiada plik `LICENSE`, który potwierdza możliwość wykorzystania kodu na potrzeby zadania. Aplikacja nadaje się do pipeline, ponieważ posiada pliki źródłowe, konfigurację CMake oraz testy.

---

### 2. Plan procesu CI/CD

Dla pipeline przyjąłem następującą ścieżkę:

```text
manual trigger / commit
checkout
build
test
deploy
smoke test
publish
```

Oznacza to, że Jenkins pobiera kod z repozytorium, buduje aplikację w kontenerze, uruchamia testy, tworzy obraz typu `deploy`, sprawdza go przez smoke test, a na końcu zapisuje artefakt.

---

### 3. Diagram UML procesu

Dla procesu został przygotowany prosty diagram UML w formacie PlantUML.

Plik diagramu znajduje się w:

```text
Sprawozdanie2/Zajecia6/uml/pipeline.puml
```

Zawartość diagramu:

```plantuml
@startuml
start

:Manual trigger albo commit;
:Jenkins pobiera repozytorium;
:Budowa obrazu testowego;
:Uruchomienie testów cJSON;

if (Testy OK?) then (tak)
  :Budowa obrazu deploy;
  :Uruchomienie smoke testu;
  if (Smoke test OK?) then (tak)
    :Zapis obrazu jako artefakt .tar;
    :Zapis numeru builda i commita;
    :Publikacja artefaktów w Jenkinsie;
  else (nie)
    :Przerwanie pipeline;
  endif
else (nie)
  :Przerwanie pipeline;
endif

stop
@enduml
```

Diagram pokazuje, że pipeline jest przerywany, jeżeli testy albo smoke test zakończą się błędem.

![Diagram UML pipeline](./img/L5_13_uml_pipeline.png)

---

### 4. Dockerfile aplikacji

Do budowania aplikacji został przygotowany wieloetapowy `Dockerfile`.

Plik znajduje się w:

```text
Sprawozdanie2/Zajecia6/cJSON/Dockerfile
```

Zawartość pliku:

```dockerfile
FROM alpine:3.19 AS base
RUN apk add --no-cache libgcc

FROM base AS build
RUN apk add --no-cache gcc g++ make cmake
WORKDIR /app
COPY . .
RUN mkdir build && cd build && cmake .. -DENABLE_CJSON_TEST=On && make

FROM build AS test
WORKDIR /app/build
RUN ctest --output-on-failure

FROM base AS deploy
WORKDIR /app
COPY --from=build /app/build/cJSON_test /app/cJSON_test
COPY --from=build /app/build/libcjson.* /usr/lib/
CMD ["./cJSON_test"]
```

Dockerfile składa się z kilku etapów:

```text
base
build
test
deploy
```

Etap `base` zawiera minimalne zależności potrzebne do działania aplikacji.
Etap `build` instaluje narzędzia kompilacji i buduje projekt.
Etap `test` uruchamia testy przez `ctest`.
Etap `deploy` tworzy obraz przeznaczony do uruchomienia aplikacji.

![Dockerfile dla cJSON](./img/L5_DockerFile_1.png)

---

### 5. Plik `.dockerignore`

Do projektu został dodany również plik `.dockerignore`.

Plik znajduje się w:

```text
Sprawozdanie2/Zajecia6/cJSON/.dockerignore
```

Zawartość pliku:

```text
.git
build
artifacts
*.tar
```

Dzięki temu do kontekstu budowania obrazu Dockera nie są wysyłane niepotrzebne katalogi i pliki, na przykład lokalne artefakty albo katalog `.git`.

---

### 6. Jenkinsfile

Pipeline został zapisany w pliku:

```text
Sprawozdanie2/Zajecia6/Jenkinsfile
```

Zawartość pliku:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Budowa i testy') {
            steps {
                dir('ITE/GCL1/LC417617/Sprawozdanie2/Zajecia6/cJSON') {
                    sh 'docker build --target test -t cjson-app:test .'
                }
            }
        }

        stage('Deploy') {
            steps {
                dir('ITE/GCL1/LC417617/Sprawozdanie2/Zajecia6/cJSON') {
                    sh 'docker build --target deploy -t cjson-app:${BUILD_NUMBER} .'
                }
            }
        }

        stage('Smoke Test') {
            steps {
                sh 'docker rm -f smoke_test || true'
                sh 'docker run --rm --name smoke_test cjson-app:${BUILD_NUMBER}'
            }
        }

        stage('Publikacja artefaktu') {
            steps {
                dir('ITE/GCL1/LC417617/Sprawozdanie2/Zajecia6/cJSON') {
                    sh 'mkdir -p artifacts'
                    sh 'docker save -o artifacts/cjson-artifact-${BUILD_NUMBER}.tar cjson-app:${BUILD_NUMBER}'
                    sh 'git rev-parse HEAD > artifacts/git-commit-${BUILD_NUMBER}.txt'
                    sh 'echo ${BUILD_NUMBER} > artifacts/build-number-${BUILD_NUMBER}.txt'
                    archiveArtifacts artifacts: 'artifacts/*', fingerprint: true
                }
            }
        }
    }
}
```

Pipeline zawiera następujące etapy:

```text
Checkout
Budowa i testy
Deploy
Smoke Test
Publikacja artefaktu
```

Etap `Checkout` pobiera kod z repozytorium.
Etap `Budowa i testy` buduje obraz testowy i uruchamia testy.
Etap `Deploy` buduje obraz przeznaczony do uruchomienia.
Etap `Smoke Test` sprawdza, czy obraz można poprawnie uruchomić.
Etap `Publikacja artefaktu` zapisuje obraz jako plik `.tar` i publikuje go jako artefakt w Jenkinsie.

![Jenkinsfile](./img/L5_Jenkinsfile_2.png)

---

### 7. Lokalne sprawdzenie builda i testów

Przed uruchomieniem pipeline w Jenkinsie sprawdziłem lokalnie, czy Dockerfile działa poprawnie.

W katalogu:

```text
Sprawozdanie2/Zajecia6/cJSON
```

wykonałem budowanie obrazu testowego:

```bash
docker build --target test -t cjson-app:test .
```

Następnie zbudowałem obraz deploy:

```bash
docker build --target deploy -t cjson-app:manual .
```

Potem uruchomiłem smoke test:

```bash
docker run --rm --name smoke_test_manual cjson-app:manual
```

Wynik pokazał, że testy cJSON przeszły poprawnie. W logu było widoczne:

```text
100% tests passed, 0 tests failed out of 19
```

Na końcu zapisałem obraz jako artefakt:

```bash
mkdir -p artifacts
docker save -o artifacts/cjson-artifact-manual.tar cjson-app:manual
ls -lh artifacts
```

Powstał plik:

```text
cjson-artifact-manual.tar
```

![Lokalny build, testy i artefakt](./img/L5_09_lokalny_build_test_deploy.png)

---

### 8. Dodanie plików do repozytorium

Pliki projektu zostały dodane do repozytorium Git. W trakcie pracy pojawił się problem z tym, że katalog `cJSON` mógł zostać potraktowany jako osobne repozytorium. Taki przypadek należało poprawić, ponieważ Jenkins po zwykłym pobraniu repozytorium mógłby nie mieć pełnej zawartości katalogu.

Po usunięciu zagnieżdżonego katalogu `.git` z `cJSON` projekt został dodany jako zwykły katalog z plikami.

![Dodanie plików do repozytorium](./img/L5_WrzucNaGita_3.png)

---

### 9. Utworzenie projektu w Jenkinsie

W Jenkinsie został utworzony nowy projekt:

```text
ZadanieL6
```

Jako typ projektu wybrałem:

```text
Pipeline
```

![Tworzenie nowego projektu Jenkins](./img/L5_ZrobNowyProjektJenkins_4.png)

---

### 10. Konfiguracja Pipeline script from SCM

Projekt został skonfigurowany tak, aby Jenkins pobierał `Jenkinsfile` bezpośrednio z repozytorium.

W konfiguracji projektu ustawiono:

```text
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE
Credentials: git
Branch Specifier: */LC417617
Script Path: ITE/GCL1/LC417617/Sprawozdanie2/Zajecia6/Jenkinsfile
```

Dzięki temu Jenkins nie musi mieć skryptu wpisanego ręcznie w konfiguracji. Pipeline jest wersjonowany razem z kodem w repozytorium.

![Wybór credentials](./img/L5_ZrobNowyProjektJenkins_6.png)

![Konfiguracja Pipeline script from SCM](./img/L5_ZrobNowyProjektJenkins_8.png)

---

### 11. Uruchomienie pipeline

Po zapisaniu konfiguracji uruchomiłem pipeline w Jenkinsie.

Build zakończył się sukcesem. Na ekranie builda widoczny był zielony status oraz numer uruchomienia:

```text
#8
```

![Udane uruchomienie pipeline](./img/L5_10_pipeline_success.png)

---

### 12. Console Output

W logach Jenkinsa było widać wykonanie poszczególnych poleceń.

W etapie budowania i testów pojawiło się polecenie:

```bash
docker build --target test -t cjson-app:test .
```

W końcowej części logów było widać publikację artefaktów:

```bash
mkdir -p artifacts
docker save -o artifacts/cjson-artifact-8.tar cjson-app:8
git rev-parse HEAD
echo 8
```

Następnie Jenkins wykonał:

```text
Archiving artifacts
Recording fingerprints
Finished: SUCCESS
```

Oznacza to, że pipeline zakończył się poprawnie, a artefakty zostały zapisane.

![Console Output pipeline](./img/L5_11_console_output.png)

---

### 13. Artefakty w Jenkinsie

W Jenkinsie, w szczegółach builda, pojawiły się artefakty zadania.

Widoczne były między innymi pliki:

```text
build-number-8.txt
cjson-artifact-8.tar
cjson-artifact-manual.tar
git-commit-8.txt
```

Najważniejszym artefaktem jest:

```text
cjson-artifact-8.tar
```

Jest to zapisany obraz Dockera `cjson-app:8`.

Dodatkowo zapisano:

```text
build-number-8.txt
git-commit-8.txt
```

Te pliki pozwalają powiązać artefakt z konkretnym buildem oraz commitem w repozytorium.

![Artefakty w Jenkinsie](./img/L5_12_artifacts.png)

---

### 14. Wersjonowanie i pochodzenie artefaktu

Artefakt został powiązany z numerem builda Jenkinsa. Obraz Dockera otrzymał tag:

```text
cjson-app:${BUILD_NUMBER}
```

Dla builda numer `8` był to obraz:

```text
cjson-app:8
```

Z tego obrazu został utworzony plik:

```text
cjson-artifact-8.tar
```

Pochodzenie artefaktu można ustalić na podstawie dwóch elementów:

```text
build-number-8.txt
git-commit-8.txt
```

Dodatkowo w Jenkinsie włączono fingerprint dla artefaktów:

```groovy
archiveArtifacts artifacts: 'artifacts/*', fingerprint: true
```

Dzięki temu Jenkins przechowuje informację o opublikowanych plikach i ich powiązaniu z buildem.

---

### 15. Wybór typu artefaktu

Jako artefakt wybrałem obraz Dockera zapisany do pliku `.tar`.

Wybrałem takie rozwiązanie, ponieważ:

* aplikacja była budowana i uruchamiana w kontenerze,
* obraz `deploy` zawierał gotową aplikację i zależności runtime,
* plik `.tar` można łatwo zapisać jako artefakt w Jenkinsie,
* taki artefakt można później odtworzyć przez `docker load`.

Przykładowe użycie artefaktu po pobraniu z Jenkinsa:

```bash
docker load -i cjson-artifact-8.tar
docker run --rm cjson-app:8
```

---

### 16. Zgodność z checklistą

W ramach zadania wykonano najważniejsze punkty ze ścieżki krytycznej:

```text
commit / manual trigger
clone / checkout
build
test
deploy
publish
```

Dodatkowo wykonano też elementy rozszerzone:

* wybrano aplikację `cJSON`,
* sprawdzono możliwość użycia projektu na podstawie licencji,
* przygotowano kontener bazowy,
* wykonano build wewnątrz kontenera,
* wykonano testy wewnątrz kontenera,
* przygotowano etap `deploy`,
* uruchomiono smoke test obrazu deploy,
* zapisano obraz jako artefakt `.tar`,
* zapisano numer builda,
* zapisano identyfikator commita,
* opublikowano artefakty w Jenkinsie,
* przygotowano diagram UML procesu CI/CD,
* zapisano `Dockerfile` i `Jenkinsfile` jako osobne pliki w repozytorium,
* zweryfikowano zgodność działania pipeline z planem.

---

### 17. Wnioski

W ramach zajęć udało się przygotować działający pipeline CI/CD dla projektu cJSON.

Najważniejsze było rozdzielenie procesu na kilka etapów. Dzięki temu build, testy, deploy, smoke test i publikacja artefaktu są osobnymi krokami. Jeżeli jeden z etapów zakończyłby się błędem, pipeline zostałby zatrzymany.

Ważnym elementem było użycie wieloetapowego Dockerfile. Dzięki temu obraz testowy mógł zawierać narzędzia potrzebne do kompilacji i testowania, a obraz deploy był prostszy i przeznaczony tylko do uruchomienia aplikacji.

Artefakt został opublikowany w Jenkinsie jako plik `.tar`, a jego pochodzenie można ustalić dzięki numerowi builda, commitowi oraz fingerprintowi Jenkinsa.

---

### 18. Użycie LLM

Podczas pracy korzystałem z pomocy LLM jako wsparcia przy porządkowaniu pipeline, analizowaniu błędów i przygotowaniu opisów. Odpowiedzi były sprawdzane praktycznie przez uruchamianie komend lokalnie oraz przez wykonanie pipeline w Jenkinsie.

Przykładowe prompty, które mogły pojawić się podczas pracy:

```text
Jak przygotować Dockerfile multi-stage dla projektu C budowanego przez cmake?
```

Ten prompt pomógł przy podziale Dockerfile na etapy `base`, `build`, `test` i `deploy`.

```text
Jak uruchomić testy ctest wewnątrz kontenera Dockera?
```

Ten prompt pomógł przy przygotowaniu etapu `test`.

```text
Jak napisać Jenkinsfile, który pobiera kod z repozytorium i wykonuje docker build?
```

Ten prompt pomógł przy przygotowaniu struktury pliku `Jenkinsfile`.

```text
Jak w Jenkinsie skonfigurować Pipeline script from SCM?
```

Ten prompt pomógł przy ustawieniu repozytorium, brancha i ścieżki do `Jenkinsfile`.

```text
Jak zapisać obraz Dockera jako artefakt Jenkins?
```

Ten prompt pomógł przy użyciu `docker save` oraz `archiveArtifacts`.

```text
Jak powiązać artefakt z numerem builda i commitem?
```

Ten prompt pomógł przy zapisaniu plików `build-number-*.txt` oraz `git-commit-*.txt`.

```text
Jak opisać prosty pipeline CI/CD w README?
```

Ten prompt pomógł przy uporządkowaniu opisu wykonanych kroków.




# Zajęcia 07 - Jenkinsfile i przygotowanie do Ansible

Celem zajęć było przeniesienie definicji pipeline'u Jenkins do repozytorium w postaci pliku `Jenkinsfile`, a następnie sprawdzenie, czy pipeline realizuje pełną ścieżkę CI/CD: pobranie aktualnego kodu, czyszczenie workspace, build, test, deploy oraz publikację artefaktów. Drugą częścią zadania było przygotowanie lekkiej maszyny docelowej pod kolejne zajęcia z Ansible.

Do realizacji części Jenkins wykorzystano projekt `cJSON` z repozytorium:

```text
https://github.com/DaveGamble/cJSON
```

Projekt jest biblioteką napisaną w języku C, budowaną przez `CMake` i testowaną z użyciem `CTest`.

## 1. Środowisko pracy

Zadanie wykonano na głównej maszynie wirtualnej `devops-vm`, na użytkowniku `lukasz`. Jenkins był uruchomiony w kontenerach Docker na podstawie konfiguracji przygotowanej podczas poprzednich zajęć. Do obsługi Dockera w Jenkinsie wykorzystano układ z kontenerem Jenkins oraz kontenerem Docker-in-Docker.

Druga maszyna wirtualna została przygotowana jako lekka maszyna docelowa dla Ansible:

```text
hostname: ansible-target
użytkownik: ansible
system: Ubuntu Server minimized
usługi: OpenSSH server, tar
```

Pliki dla zajęć 07 zostały umieszczone w katalogu:

```text
Sprawozdanie2/Zajecia7/
```

W katalogu tym przygotowano:

```text
Jenkinsfile
Dockerfile.build
Dockerfile.test
Dockerfile.deploy
ansible/inventory.ini
```

![Pliki zajęć 07 w repozytorium](./img/S07_01_pliki_zajecia7_w_repo.png)

*Rys. 1. Pliki `Jenkinsfile`, `Dockerfile.build`, `Dockerfile.test`, `Dockerfile.deploy` oraz katalog Ansible przygotowane w repozytorium.*

Zmiany zostały dodane do gałęzi osobistej `LC417617` i wysłane do zdalnego repozytorium.

![Commit i push plików zajęć 07](./img/S07_02_commit_push_zajecia7.png)

*Rys. 2. Commit oraz wysłanie plików wymaganych do realizacji zajęć 07.*

---

## 2. Jenkinsfile pobierany z SCM

W Jenkinsie utworzono projekt typu `Pipeline`. Ważnym wymaganiem zadania było to, aby definicja pipeline'u nie była wklejana ręcznie w ustawieniach Jenkinsa, tylko była pobierana bezpośrednio z repozytorium.

W konfiguracji projektu ustawiono:

```text
Definition: Pipeline script from SCM
SCM: Git
Branch Specifier: */LC417617
Script Path: ITE/GCL1/LC417617/Sprawozdanie2/Zajecia7/Jenkinsfile
```

![Utworzenie projektu Jenkins](./img/S07_03_utworzenie_projektu_jenkins.png)

*Rys. 3. Utworzenie projektu typu Pipeline w Jenkinsie.*

![Pipeline z SCM](./img/S07_03_pipeline_z_scm.png)

*Rys. 4. Konfiguracja projektu Jenkins tak, aby `Jenkinsfile` był pobierany z repozytorium Git.*

---

## 3. Czyszczenie workspace i checkout aktualnego kodu

Pipeline rozpoczyna działanie od wyczyszczenia workspace za pomocą `deleteDir()`. Następnie Jenkins wykonuje `checkout scm`, czyli pobiera aktualny kod z repozytorium.

Dodatkowo wykonano:

```bash
git reset --hard HEAD
git clean -xfd
git rev-parse --short HEAD
git log -1 --oneline
```

Pozwala to upewnić się, że pipeline pracuje na najnowszym kodzie z repozytorium, a nie na przypadkowo pozostawionych plikach z poprzednich uruchomień.

![Czyszczenie i checkout](./img/S07_04_czyszczenie_i_checkout.png)

*Rys. 5. Czyszczenie workspace oraz pobranie aktualnej wersji kodu z gałęzi `LC417617`.*

---

## 4. Etap Build

Etap `Build` tworzy obraz buildowy dla projektu cJSON. Obraz ten bazuje na `ubuntu:24.04`, instaluje wymagane narzędzia (`git`, `cmake`, `build-essential`) oraz klonuje repozytorium cJSON.

Najważniejsza komenda wykonywana w pipeline:

```bash
docker build --pull --no-cache \
  --build-arg CJSON_REPO="$CJSON_REPO" \
  --build-arg CJSON_REF="$CJSON_REF" \
  -f "$REPORT_DIR/Zajecia7/Dockerfile.build" \
  -t "$BUILD_IMAGE" \
  "$REPORT_DIR"
```

Obraz buildowy kompiluje projekt przez `CMake`, wykonuje instalację do katalogu artefaktu oraz przygotowuje prosty program `cjson-smoke`, który później służy do sprawdzenia artefaktu w etapie deploy.

![Etap Build](./img/S07_05_etap_build.png)

*Rys. 6. Budowanie obrazu buildowego `lc417617-cjson-bldr`.*

---

## 5. Etap Test

Etap `Test` tworzy osobny obraz testowy na podstawie obrazu buildowego. Następnie uruchamia testy cJSON za pomocą `CTest`.

Najważniejsze polecenie testowe:

```bash
docker run --rm "$TEST_IMAGE"
```

Wynik testów potwierdził poprawne zbudowanie projektu i przejście testów jednostkowych.

![Etap Test](./img/S07_06_etap_test.png)

*Rys. 7. Uruchomienie testów cJSON w kontenerze testowym.*

---

## 6. Etap Deploy

Etap `Deploy` przygotowuje obraz docelowy z gotowym artefaktem. W przypadku cJSON nie jest to typowa aplikacja webowa działająca stale w kontenerze, tylko biblioteka C. Dlatego etap wdrożeniowy został zrealizowany jako obraz zawierający zainstalowany artefakt oraz program `cjson-smoke` ustawiony jako `ENTRYPOINT`.

W etapie Deploy wykonywane jest uruchomienie kontenera:

```bash
docker run --rm \
  --name "$CONTAINER_NAME" \
  "$DEPLOY_IMAGE"
```

Poprawny wynik smoke testu potwierdza, że przygotowany artefakt może zostać uruchomiony w środowisku docelowym.

![Etap Deploy](./img/S07_07_etap_deploy.png)

*Rys. 8. Przygotowanie obrazu deploy oraz uruchomienie smoke testu artefaktu.*

---

## 7. Etap Publish

Etap `Publish` zapisuje artefakty z przebiegu pipeline'u. Przygotowano między innymi archiwum artefaktu cJSON, wynik `docker inspect` oraz zapisany obraz deploy w postaci pliku `.tar.gz`.

Przykładowe artefakty:

```text
lc417617-cjson-artifact-<BUILD_NUMBER>.tar.gz
lc417617-cjson-deploy-<BUILD_NUMBER>-inspect.json
lc417617-cjson-deploy-image-<BUILD_NUMBER>.tar.gz
```

W Jenkinsie artefakty zostały dodane do historii builda przez `archiveArtifacts`.

![Publikacja artefaktów](./img/S07_08_publikacja_artefaktow.png)

*Rys. 9. Publikacja artefaktów w Jenkinsie.*

---

## 8. Ponowne uruchomienie pipeline'u

Pipeline został uruchomiony więcej niż jeden raz. Drugie udane uruchomienie potwierdziło, że proces nie działa wyłącznie dzięki przypadkowemu cache'owi lub pozostałościom po poprzednim buildzie.

![Drugie udane uruchomienie](./img/S07_09_drugie_udane_uruchomienie.png)

*Rys. 10. Kolejne udane uruchomienie pipeline'u.*

---

## 9. Przygotowanie maszyny `ansible-target`

Na potrzeby kolejnych zajęć utworzono drugą, lekką maszynę wirtualną. Maszyna otrzymała nazwę `ansible-target` i została zainstalowana w wariancie minimalnym Ubuntu Server.

![Utworzenie maszyny ansible-target](./img/S07_10_utworzenie_maszyny_ansible_target.png)

*Rys. 11. Utworzenie lekkiej maszyny wirtualnej `ansible-target`.*

Podczas instalacji skonfigurowano profil użytkownika oraz hostname maszyny.

![Profil maszyny ansible-target](./img/S07_12_profil_maszyny_ansible_target.png)

*Rys. 12. Konfiguracja profilu użytkownika `ansible` i hostname `ansible-target`.*

Po instalacji sprawdzono hostname, użytkownika, obecność programu `tar` oraz działanie usługi SSH.

![Hostname, SSH i tar](./img/S07_13_hostname_ssh_tar.png)

*Rys. 13. Weryfikacja hostname, użytkownika, programu `tar` oraz działania usługi SSH na maszynie `ansible-target`.*

---

## 10. Instalacja Ansible na głównej maszynie

Na głównej maszynie wirtualnej zainstalowano Ansible z repozytorium systemowego.

Wykonane polecenia:

```bash
sudo apt update
sudo apt install -y ansible
ansible --version
```

![Ansible na maszynie głównej](./img/S07_14_ansible_na_maszynie_glownej.png)

*Rys. 14. Instalacja i sprawdzenie wersji Ansible na głównej maszynie wirtualnej.*

---

## 11. Konfiguracja nazwy `ansible-target`

Aby możliwe było łączenie się z maszyną po nazwie `ansible-target`, na głównej maszynie uzupełniono plik `/etc/hosts`.

Następnie sprawdzono połączenie poleceniem:

```bash
ping -c 3 ansible-target
```

![Hosts i ping](./img/S07_16_hosts_i_ping.png)

*Rys. 15. Dodanie wpisu do `/etc/hosts` oraz test połączenia z maszyną `ansible-target`.*

---

## 12. Logowanie SSH

Najpierw sprawdzono pierwsze logowanie SSH na maszynę docelową z użyciem hasła:

```bash
ssh ansible@ansible-target
```

![Pierwsze logowanie SSH](./img/S07_17_pierwsze_logowanie_ssh.png)

*Rys. 16. Pierwsze logowanie SSH na użytkownika `ansible`.*

Następnie skonfigurowano logowanie za pomocą klucza publicznego, tak aby logowanie nie wymagało podawania hasła:

```bash
ssh-copy-id ansible@ansible-target
ssh ansible@ansible-target
```

![Logowanie SSH bez hasła](./img/S07_18_logowanie_ssh_bez_hasla.png)

*Rys. 17. Poprawne logowanie SSH na `ansible-target` bez podawania hasła.*

---

## 13. Inventory Ansible

W repozytorium utworzono plik inventory:

```text
Sprawozdanie2/Zajecia7/ansible/inventory.ini
```

Zawartość pliku:

```ini
[targets]
ansible-target ansible_user=ansible
```

![Plik inventory](./img/S07_19_inventory.png)

*Rys. 18. Plik `inventory.ini` wskazujący maszynę `ansible-target`.*

---

## 14. Test połączenia Ansible

Na końcu wykonano test połączenia Ansible:

```bash
ansible targets -i Sprawozdanie2/Zajecia7/ansible/inventory.ini -m ping
```

Poprawny wynik:

```text
ansible-target | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

![Ansible ping](./img/S07_20_ansible_ping.png)

*Rys. 19. Poprawny wynik modułu `ping` Ansible dla maszyny `ansible-target`.*

---

## 15. Punkt kontrolny maszyny

Po przygotowaniu maszyny `ansible-target` wykonano punkt kontrolny w Hyper-V. Pozwala to szybko wrócić do gotowego stanu maszyny przed kolejnymi zajęciami.

![Punkt kontrolny ansible-target](./img/S07_21_punkt_kontrolny_ansible_target.png)

*Rys. 20. Punkt kontrolny maszyny `ansible-target`.*

---

## 16. Listing najważniejszych poleceń

Poniżej przedstawiono najważniejsze polecenia użyte podczas realizacji zadania. Listing został przygotowany bez danych wrażliwych, tokenów i haseł.

```bash
cd ~/MDO2026s_ITE/ITE/GCL1/LC417617

mkdir -p Sprawozdanie2/Zajecia7
nano Sprawozdanie2/Zajecia7/Dockerfile.build
nano Sprawozdanie2/Zajecia7/Dockerfile.test
nano Sprawozdanie2/Zajecia7/Dockerfile.deploy
nano Sprawozdanie2/Zajecia7/Jenkinsfile

git add Sprawozdanie2/Zajecia7
git commit -m "LC417617: Zajecia 07"
git push origin LC417617

sudo apt update
sudo apt install -y ansible
ansible --version

sudo nano /etc/hosts
ping -c 3 ansible-target

ssh ansible@ansible-target
ssh-copy-id ansible@ansible-target
ssh ansible@ansible-target

mkdir -p Sprawozdanie2/Zajecia7/ansible
nano Sprawozdanie2/Zajecia7/ansible/inventory.ini
cat Sprawozdanie2/Zajecia7/ansible/inventory.ini

ansible targets -i Sprawozdanie2/Zajecia7/ansible/inventory.ini -m ping

git add Sprawozdanie2/Zajecia7
git add Sprawozdanie2/img/S07_*.png
git commit -m "LC417617 dodanie materialow do Zajec 07"
git push origin LC417617
```

---

## 17. Użycie narzędzi generatywnej AI

Podczas realizacji zadania wykorzystano model LLM jako pomoc przy uporządkowaniu kolejności działań, przygotowaniu struktury `Jenkinsfile`, analizie błędu w etapie Deploy oraz opracowaniu opisu do sprawozdania.

### Treść głównego zapytania

> Używam projektu cJSON z GitHuba. Chcę przygotować pipeline pobierany z SCM, który wykona clean, checkout, build, test, deploy i publish. Opisz kroki jakie powinienem podjąć.
> Sprawdź poniższy plik .md pod kątem błędów.
> O co chodzi z tym errorem Jenkinsa (przy próbie uruchomienia nr 1).

### Metoda weryfikacji odpowiedzi

* działanie etapu Build potwierdzono przez zbudowanie obrazu buildowego,
* działanie etapu Test potwierdzono przez poprawne przejście testów `CTest`,
* działanie etapu Deploy potwierdzono przez smoke test `cjson-smoke`,
* działanie etapu Publish potwierdzono przez obecność artefaktów w Jenkinsie,


W trakcie pracy wykryto błąd w ścieżce artefaktu w `Dockerfile.deploy`. Błąd został zweryfikowany w logach Jenkinsa i poprawiony przez zmianę sposobu instalacji artefaktu w `Dockerfile.build` oraz poprawienie ścieżki kopiowania w `Dockerfile.deploy`.
