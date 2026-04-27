# Sprawozdanie 2 #

# Lab 5 #
Wykonane kroki:
## 5.1. Przygotowanie instancji Jenkins
Pobranie i uruchomienie kontenera `docker:dind`, który pełni rolę serwera Docker dla Jenkinsa.

![docker-dind](SS-1.png)

Utworzono własny plik Dockerfile.jenkins, który rozszerza obraz jenkins/jenkins o instalację klienta Docker (docker-ce-cli) oraz wymaganych narzędzi systemowych, na podstawie instrukcji instalacji Jenkinsa: https://www.jenkins.io/doc/book/installing/docker/ .

** Kod Dockerfile.jenkins : **
![Dockerfile.jenkins](SS-2.png)

Kolejno zbudowano obraz blueocean na podstawie obrazu Jenkinsa:

![blueocean-build](SS-3.png)

Uruchomienie swojego własnego kontenera myjenkins-blueocean:

![blueocean-run](SS-4.png)


## 5.2. Konfiguracja Jenkins
Po wejściu w przeglądarce na adres `http://localhost:8080` wykonano:
** -> odblokowanie instancji za pomocą hasła z kontenera: **

![Odblokowanie Jenkinsa](SS-5.png)

** -> instalacja wtyczek **

** -> utworzenie użytkownika administratora: **

![Utworzenie admina](SS-6.png)

W celu sprawdzenia poprawnego uruchomienia serwera Jenkins wyświetlono logi kontenera poleceniem z zrzutu ekranu poniżej:

![Logi](SS-7.png)
