# Sprawozdanie 2 
---

# Lab 5

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

# Lab 6

**Temat: Implementacja potoku CI/CD z weryfikacją sieciową i podpisem cyfrowym**

![odpalenie jen](screeny/lab6_1.png)

![odpalenie jenkinsa](screeny/lab6_2.png)

## 1. Konfiguracja zadania w Jenkins
Zadanie typu Pipeline zostało skonfigurowane w trybie "Pipeline script from SCM". Poniżej znajdują się zrzuty ekranu z ustawień projektu, wskazujące na repozytorium GitHub oraz ścieżkę do skryptu sterującego.

* **Definicja SCM i URL Repozytorium:**
![Definicja SCM](screeny/lab6_conf_def.png)
!https://branchapp.com/(screeny/lab6_conf_git.png)

* **Ścieżka do pliku Jenkinsfile:**
![Sciezka Jenkinsfile](screeny/lab6_conf_path.png)

## 2. Przebieg potoku (Pipeline View)
Po uruchomieniu zadania, Jenkins poprawnie wykonał wszystkie zdefiniowane etapy. Czas trwania pełnego procesu wyniósł ok. 1 min 38 sek.
![Status Pipeline](screeny/lab6_status.png)
![Szczegóły Buildu](screeny/lab6_build_details.png)

## 3. Testy automatyczne (JUnit)
Weryfikacja jednostkowa zakończyła się sukcesem. Jenkins przetworzył raporty, wskazując 55 zaliczonych testów.
![Wyniki Testów](screeny/lab6_tests.png)

## 4. Weryfikacja sieciowa (Smoke Test)
W etapie `smoke test` sprawdzono dostępność aplikacji wewnątrz Docker Network przy użyciu kontenera `curl`. Potwierdzono kod HTTP 200 oraz obecność tytułu strony PetClinic.
![Logi Smoke Test](screeny/lab6_smoke.png)

## 5. Publikacja i Artefakty
Wygenerowano zabezpieczoną paczkę aplikacji wraz z podpisem cyfrowym i metadanymi. Wszystkie pliki zostały zarchiwizowane jako artefakty zadania.
![Lista Artefaktów](screeny/lab6_artifacts.png)

---

# Lab 7
**Temat: Optymalizacja potoku CI/CD oraz przygotowanie infrastruktury Ansible**

## 1. Aktualizacja potoku (Jenkinsfile)
W pierwszej części laboratorium zoptymalizowano istniejący potok budujący aplikację Spring PetClinic. Zgodnie z założeniami zaktualizowanej listy kontrolnej, wprowadzono zmiany gwarantujące, że proces zawsze operuje na najnowszym kodzie i nie używa starych plików.

* **Czyszczenie obszaru roboczego (Clean Workspace):**
  Przed etapem pobrania kodu z repozytorium (SCM) dodano krok wykorzystujący dyrektywę `deleteDir()`. Skutecznie usuwa ona pozostałości po poprzednich buildach.
  ![Czyszczenie obszaru roboczego](screeny/lab7_1.png)

* **Budowanie bez pamięci podręcznej (No-Cache):**
  Zaktualizowano komendy budujące obrazy Dockera o flagę `--no-cache`. Gwarantuje to spełnienie kryterium "Definition of Done", wymuszając budowę kontenera całkowicie od zera.
  ![Omijanie cache przy budowaniu](screeny/lab7_2.png)

  ## 2. Przygotowanie infrastruktury pod Ansible
W drugiej części laboratorium przygotowano środowisko do automatyzacji, stawiając nową, lekką maszynę wirtualną (`ansible-target`) oraz konfigurując bezpieczne połączenie sieciowe.

* **Weryfikacja adresu IP nowej maszyny:**
  Po instalacji systemu Ubuntu Server (wersja zminimalizowana) zweryfikowano przydzielony z przełącznika adres IP.
  ![Adres IP maszyny docelowej](screeny/lab7_3.png)

* **Generowanie kluczy SSH:**
  Na głównej maszynie sterującej wygenerowano parę kluczy RSA (4096 bitów) do autoryzacji.
  ![Generowanie kluczy RSA](screeny/lab7_4.png)

* **Przesłanie klucza na serwer docelowy:**
  Klucz publiczny został autoryzowany i skopiowany na nową maszynę za pomocą polecenia `ssh-copy-id`.
  ![Kopiowanie klucza SSH](screeny/lab7_5.png)

* **Weryfikacja logowania bez hasła:**
  Potwierdzono poprawność konfiguracji poprzez bezproblemowe logowanie na użytkownika `ansible` bez konieczności podawania hasła.
  ![Logowanie SSH bez hasła](screeny/lab7_6.png)

* **Instalacja narzędzia Ansible:**
  Na maszynie głównej (sterującej) zainstalowano oprogramowanie Ansible. Zostało to zweryfikowane poleceniem sprawdzającym wersję.
  ![Wersja Ansible](screeny/lab7_7.png)