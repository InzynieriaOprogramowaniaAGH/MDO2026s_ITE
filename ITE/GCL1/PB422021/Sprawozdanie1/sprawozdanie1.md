Sprawozdanie nr 1

treść hooka:

#!/bin/bash
INPUT_FILE=$1
START_LINE=$(head -n 1 "$INPUT_FILE")
if [[ ! $START_LINE =~ ^PB422021 ]]; then
  echo "BŁĄD: Commit message musi zaczynać się od PB422021"
  exit 1
fi

Utworzenie własnego folderu z inicjałem i nr indeksu:
![Utworzenie własnego folderu](ss1.png)


lab2
### 1. Zapoznanie się z obrazami i ich rozmiarami
Wyświetlenie listy pobranych obrazów wraz z ich rozmiarem:
![Lista obrazów](docker_images.png)

### 2. Uruchomienie obrazów i sprawdzenie kodów wyjścia
Uruchomienie przykładowych kontenerów i weryfikacja komendą `echo $?`:
![Docker run echo](docker_run_echo.png)
![Docker run echo 2](docker_run_echo2.png)

### 3. Praca interaktywna - Busybox
Uruchomienie kontenera Busybox w trybie interaktywnym i sprawdzenie wersji:
![Busybox interaktywnie](busybox_uruchmienie_interaktywne.png)

### 4. Izolacja procesów (PID1)
Prezentacja procesu o identyfikatorze 1 wewnątrz kontenera:
![PID1 w kontenerze](PID1.png)

Prezentacja procesów Dockera widzianych z poziomu hosta:
![Procesy na hoście](procesy_dockera_na_hoście.png)

### 5. Aktualizacja systemu w kontenerze
Weryfikacja poprawności działania sieci i aktualizacji pakietów:
![Aktualizacja pakietów](aktualizacja_pakietów.png)

### 6. Własny plik Dockerfile
Zawartość przygotowanego pliku Dockerfile (screen):
![Plik Dockerfile](dockerfile.png)

Proces budowania własnego obrazu:
![Budowanie obrazu](budowanie_obrazy(dockerfile).png)

Uruchomienie i weryfikacja (ls -la) zawartości sklonowanego repozytorium:
![Weryfikacja Dockerfile](uruchomieni_i_weryfikacja_dockerfile.png)

### 7. Porządki i historia
Wyświetlenie historii wszystkich kontenerów (zarówno działających, jak i zatrzymanych):
![Historia kontenerów](historia_kontenerów.png)
