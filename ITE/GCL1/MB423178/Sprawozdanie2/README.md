# Sprawozdanie 2 (Laboratorium 5)
---

## Etap 0: Konfiguracja środowiska
Aby ułatwić pracę z kontenerami, dodałem swojego użytkownika do grupy `docker`, co eliminuje konieczność używania przedrostka `sudo` przed każdą komendą.

![Dodanie użytkownika do grupy docker](screeny/docker_lab5_0.png)

## Etap 1: Przygotowanie Jenkinsa (Architektura DIND)
Zgodnie z wymaganiami, skonfigurowałem środowisko Jenkins w architekturze Docker-in-Docker (DIND) opierając się na oficjalnej dokumentacji dostawcy.

![Dokumentacja Jenkins DIND](screeny/docker_lab5_1.png)

W pierwszej kolejności zbudowałem własny obraz bazujący na `jenkins/jenkins:lts`, instalując w nim klienta Dockera oraz sugerowaną wtyczkę Blue Ocean.

![Budowa obrazu Jenkins - cz. 1](screeny/docker_lab5_2.png)
![Budowa obrazu Jenkins - cz. 2](screeny/docker_lab5_3.png)

Następnie uruchomiłem wewnętrzny silnik Dockera (`docker:dind`) oraz powiązany z nim główny kontener Jenkinsa wewnątrz wspólnej sieci `jenkins`. Zweryfikowałem działanie woluminów odzyskując hasło startowe.

![Uruchomienie kontenerów i weryfikacja](screeny/docker_lab5_4.png)
![Odzyskanie hasła początkowego](screeny/docker_lab5_5.png)
![Ekran powitalny Jenkinsa](screeny/docker_lab5_6.png)

## Etap 2: Zadanie wstępne (Uruchomienie)
Utworzyłem i pomyślnie wykonałem trzy projekty typu Freestyle, weryfikując poprawność działania środowiska i komunikację z demonem Dockera:

**1. Wyświetlenie komendy `uname`**
![Logi zadania uname](screeny/docker_lab5_7.png)

**2. Projekt zwracający błąd przy nieparzystej godzinie**
![Logi zadania weryfikacji godziny](screeny/docker_lab5_8.png)

**3. Pobranie obrazu ubuntu (`docker pull`)**
![Logi zadania pobierania obrazu](screeny/docker_lab5_9.png)

## Etap 3: Zadanie wstępne - obiekt typu pipeline
Skonfigurowałem projekt typu "Pipeline as Code". Skrypt automatycznie pobiera repozytorium uczelniane (z mojej gałęzi) i buduje obraz zdefiniowany w pliku `Dockerfile.petClinic.build` ze Sprawozdania 1.

**Pierwsze uruchomienie (sukces kompilacji):**
![Sukces Pipeline](screeny/docker_lab5_11.png)
![Logi z pierwszego budowania](screeny/docker_lab5_10.png)

**Drugie uruchomienie (weryfikacja mechanizmu cache):**
Zgodnie z poleceniem, uruchomiłem potok po raz drugi. Logi jednoznacznie wskazują, że Docker poprawnie wykorzystał pamięć podręczną (`CACHED`), błyskawicznie kończąc zadanie.
![Logi z wykorzystaniem cache - cz. 1](screeny/docker_lab5_12.png)
![Logi z wykorzystaniem cache - cz. 2](screeny/docker_lab5_13.png)