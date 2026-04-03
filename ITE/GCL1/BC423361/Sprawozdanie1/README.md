Pracę wykonałem na maszynie wirtualnej z systemem Ubuntu Server 24.04 LTS. Logowanie odbywało się przez SSH z poziomu zwykłego użytkownika (bez uprawnień root).
Zajęcia 01: Git, Gałęzie, SSH
Wygenerowałem klucze SSH (Ed25519)

![alt text](image.png)


![alt text](image-1.png)


Sklonowałem repozytorium z użyciem HTTPS oraz SSH.

![alt text](image-2.png)


Utworzyłem własną gałąź BC423361.

![alt text](image-3.png)


Utworzyłem skrypt walidujący wiadomości commitów.

![alt text](image-4.png)


![alt text](image-5.png)


![alt text](image-6.png)


Wysłałem zmiany na własną gałąź do zdalnego repozytorium.

![alt text](image-7.png)


Zajęcia 02: Podstawy Dockera

Zainstalowałem Dockera i pobrałem zadane obrazy.

![alt text](image-8.png)


Uruchomiłem kontener z obrazem busybox

![alt text](image-9.png)


Uruchomiłem system Ubuntu w kontenerze i sprawdziłem PID 1.

![alt text](image-10.png)


![alt text](image-11.png)


Zbudowałem obraz instalujący narzędzie Git i klonujący repozytorium.

![alt text](image-12.png)


![alt text](image-13.png)


![alt text](image-14.png)


Usunąłem nieaktywne kontenery i obrazy.

Zajęcia 03: Build i Test w kontenerach

Wybrałem do zbudowania bibliotekę fmt. Zbudowałem ją i przetestowałem lokalnie.

![alt text](image-15.png)


Powtórzyłem ten proces w kontenerze, interaktywnie.

![alt text](image-17.png)


Utworzyłem Dockerfile.build oraz Dockerfile.test.

![alt text](image-16.png)


![alt text](image-18.png)


![alt text](image-19.png)


![alt text](image-20.png)


Utworzyłem plik docker-compose.yml

![alt text](image-21.png)


![alt text](image-22.png)


![alt text](image-23.png)


Pytanie: Różnica między obrazem a kontenerem? Co tu pracuje?

Obraz to martwy szablon/przepis (kod, kompilator, skompilowane pliki). Kontener to ożywiona, uruchomiona instancja obrazu.

Zajęcia 04: Woluminy, Sieci i Jenkins

Utworzyłem wolumin wejściowy i wyjściowy.

![alt text](image-24.png)


Uruchomiłem dwa kontenery z iperf3 w dedykowanej sieci bridge_serwer

![alt text](<Zrzut ekranu 2026-03-27 091311.png>)


![alt text](<Zrzut ekranu 2026-03-27 092559.png>)


Uruchomiłem demona SSH wewnątrz kontenera testowego i połączono się z nim z zewnątrz.

![alt text](image-25.png)


Uruchomiłem Jenkinsa wraz z DinD.

![alt text](image-26.png)


![alt text](image-27.png)


![alt text](image-28.png)


![alt text](image-29.png)

