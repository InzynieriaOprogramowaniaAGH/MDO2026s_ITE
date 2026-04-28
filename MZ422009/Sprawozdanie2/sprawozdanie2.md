# Sprawozdanie 2 #

# Lab 5 #
Wykonane kroki:
## 5.1. Przygotowanie instancji Jenkins
Pobranie i uruchomienie kontenera `docker:dind`, który pełni rolę serwera Docker dla Jenkinsa.

![docker-dind](SS-1.png)

Utworzono własny plik Dockerfile.jenkins, który rozszerza obraz jenkins/jenkins o instalację klienta Docker (docker-ce-cli) oraz wymaganych narzędzi systemowych, na podstawie instrukcji instalacji Jenkinsa: https://www.jenkins.io/doc/book/installing/docker/ .

### Kod Dockerfile.jenkins : ###
![Dockerfile.jenkins](SS-2.png)

Kolejno zbudowano obraz blueocean na podstawie obrazu Jenkinsa:

![blueocean-build](SS-3.png)

Uruchomienie swojego własnego kontenera myjenkins-blueocean:

![blueocean-run](SS-4.png)


## 5.2. Konfiguracja Jenkins
Po wejściu w przeglądarce na adres `http://localhost:8080` wykonano:

### -> odblokowanie instancji za pomocą hasła z kontenera: ###

![Odblokowanie Jenkinsa](SS-5.png)

### -> instalacja wtyczek ###

### -> utworzenie użytkownika administratora: ###

![Utworzenie admina](SS-6.png)

W celu sprawdzenia poprawnego uruchomienia serwera Jenkins wyświetlono logi kontenera poleceniem z zrzutu ekranu poniżej:

![Logi](SS-7.png)


## 5.3. Zadania testowe w Jenkins typu Freestyle project
Po uruchomieniu i skonfigurowaniu Jenkinsa utworzono kilka prostych zadań testowych, aby sprawdzić poprawność działania środowiska CI.

### Projekt wyświetlający uname ###
Utworzono zadanie typu Freestyle project, w którym wykonano polecenie `uname -a`:

![Zadanie uname](SS-8.png)
Zadanie zakończyło się poprawnie, a w logach konsoli widoczny był wynik polecenia systemowego.

### Projekt z nieparzystą godziną ###
Utworzono kolejne zadanie testowe, które miało zwracać błąd, gdy aktualna godzina jest nieparzysta. Wykorzystano prosty skrypt powłoki sprawdzający wartość godziny. Wykorzystano prosty skrypt powłoki sprawdzający wartość godziny.
```bash
HOUR=$(date +%H)
if [ $((10#$HOUR % 2)) -eq 1 ]; then
    exit 1
fi
```
W moim przypadku wykonanie zadania zakończyło się błędem, co potwierdziło poprawne działanie mechanizmu oznaczania builda jako nieudanego. Oto potwierdzenie:

![Zadanie godzina](SS-9.png)

### Projekt pobierający obraz ubuntu ###
Celem następnego zadania było pobranie obrazu kontenera ubuntu z użyciem polecenia `docker pull ubuntu` :

![Zadanie ubuntu](SS-10.png)

Otrzymany sukces zadania potwierdza, że Jenkins może wykonywać polecenia Docker i komunikować się ze środowiskiem kontenerowym.

## 5.4. Zadania testowe w Jenkins typu pipeline
Po zapoznaniu się z Jenkinsem i zadaniami typu Freestyle project, należy przejść do ćwiczeń z typem pipeline. Pierwszą i znaczącą różnicą jest wybór typu obiektu przy tworzeniu projektu, czyli `pipeline` zamiast wcześniejszego `Freestyle Project`.

### Pierwszy pipeline (bez SCM) ###
Utworzono pierwszy obiekt typu pipeline bez wykorzystania repozytorium Git (pipeline wpisany ręcznie w Jenkinsie).
Pipeline składał się z prostych etapów testowych:

`hello` – wyświetlenie komunikatu
`end` – zakończenie pipeline

![pierwszy pipeline](SS-11.png)

Wykonanie pipeline zakończyło się statusem SUCCESS, co potwierdza poprawną konfigurację środowiska Jenkins oraz działania pipeline.

 
### Dodanie do pipeline operacje Git i Docker ###
W tym etapie wcześniejszy pipeline został rozszerzony o: `klonowanie repozytorium (Clone repo)` i `budowę obrazu Docker (Build custom Dockerfile)`.

![rozszerzony pipeline](SS-12.png)

Podczas wykonania wystąpił błąd na etapie klonowania repozytorium, co spowodowało zatrzymanie pipeline. To ma pokazać jak wygląda błąd w jednym z etapów pipeline i jak to się zachowuje. W tym przypadku błąd spowodowała niepoprawna konfiguracja dostępu do repozytorium w Jenkins. 

