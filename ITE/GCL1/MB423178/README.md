# Sprawozdanie - MB423178

## 1. Mój Git Hook
Oto skrypt, który napisałem, aby wymusić poprawne nazewnictwo commitów:

```bash
#!/bin/bash
PREFIX="MB423178"
commit_msg=$(head -n1 "$1")
if [[ ! $commit_msg == $PREFIX* ]]; then
    echo "BŁĄD: Twój commit message musi zaczynać się od: $PREFIX"
    exit 1
fi
```
<img width="1072" height="668" alt="Zrzut ekranu 2026-03-06 093141" src="https://github.com/user-attachments/assets/dafbeb0d-83d5-4cee-aeef-8ade44e40c82" />
<img width="1034" height="684" alt="Zrzut ekranu 2026-03-06 093354" src="https://github.com/user-attachments/assets/2dbd0ad5-4d76-4afc-9406-0d0369e63182" />
<img width="1262" height="485" alt="Zrzut ekranu 2026-03-06 095359" src="https://github.com/user-attachments/assets/1a876885-c948-4c3f-802a-eb54fcf9ffbe" />
<img width="1473" height="143" alt="Zrzut ekranu 2026-03-06 095533" src="https://github.com/user-attachments/assets/fd45cab0-1df4-4483-9058-c6ccdd98afe6" />




# LAB 2 Docker


## Zadanie 2 i 3: Docker - Instalacja, obrazy i kody wyjścia

Zgodnie z instrukcją zainstalowałem Dockera, pobrałem wymagane obrazy (w tym te z repozytorium Microsoftu) oraz sprawdziłem ich rozmiary i kod wyjścia (dla hello-world). Poniżej pełna dokumentacja z tych kroków:

![Krok 1](docker1screen.png)

![Krok 2](docker2screen.png)

![Krok 3](docker2-2screen.png)

![Krok 4](docker3screen.png)

# Lab 03: Dockerfiles 

## 1. Wybór oprogramowania i budowa lokalna
Wybrałem aplikację **Spring PetClinic**. Jest to otwartoźródłowy projekt (licencja Apache 2.0) służący do demonstracji możliwości frameworka Spring Boot. Wykorzystuje on narzędzie **Maven** do zarządzania cyklem życia aplikacji.

### Proces przygotowania środowiska i budowy na hoście:
* **Instalacja JDK 17 oraz Git:**
    ![Instalacja środowiska](Zrzut%20ekranu%202026-03-20%20094651.png)
* **Klonowanie repozytorium:**
    ![Klonowanie PetClinic](Zrzut%20ekranu%202026-03-20%20094812.png)
* **Budowanie aplikacji (mvnw package):**
    ![Build lokalny](Zrzut%20ekranu%202026-03-20%20095058.png)
* **Uruchomienie testów lokalnie:**
    ![Testy lokalne](Zrzut%20ekranu%202026-03-20%20095209.png)

## 2. Izolacja: build w kontenerze interaktywnie
Kolejnym etapem było powtórzenie procesu wewnątrz odizolowanego kontenera, aby zapewnić powtarzalność środowiska.

* **Pobieranie obrazu bazowego Javy:**
    ![Docker pull](Zrzut%20ekranu%202026-03-20%20095511.png)
* **Klonowanie repozytorium wewnątrz kontenera:**
    ![Klonowanie w kontenerze](Zrzut%20ekranu%202026-03-20%20095630.png)
* **Instalacja narzędzi pomocniczych (Git):**
    ![Instalacja Git w kontenerze](Zrzut%20ekranu%202026-03-20%20095723.png)
* **Finalny Build i testy w kontenerze:**
    ![Sukces testów w kontenerze](Zrzut%20ekranu%202026-03-20%20100222.png)

## 3. Automatyzacja: Dockerfiles i Docker Compose
Aby zautomatyzować powyższe kroki, stworzyłem dwa pliki Dockerfile:
1.  **Dockerfile.petClinic.build** – odpowiedzialny za kompilację kodu.
    ![Budowanie obrazu bazowego](Zrzut%20ekranu%202026-03-20%20102659.png)
2.  **Dockerfile.petClinic.test** – bazujący na pierwszym, dedykowany do uruchamiania testów.
    ![Budowanie obrazu testowego](Zrzut%20ekranu%202026-03-20%20102735.png)

### Wykazanie pracy kontenera i różnica obraz vs kontener
Uruchomiłem kontener testowy ręcznie:
![Praca kontenera](Zrzut%20ekranu%202026-03-20%20102915.png)

**Różnica:** Obraz to statyczna definicja środowiska i aplikacji, natomiast kontener to działająca instancja. W moim przypadku w kontenerze pracuje proces **Java (JVM)**, który wykonuje testy jednostkowe przy pomocy biblioteki JUnit.

### Ujęcie w kompozycję (Docker Compose)
Finalnie proces został ujęty w `docker-compose.yml`, co pozwala na uruchomienie całego etapu CI jedną komendą:
![Docker Compose Start](Zrzut%20ekranu%202026-03-20%20103527.png)
![Docker Compose Success](Zrzut%20ekranu%202026-03-20%20103553.png)

## 4. Dyskusja: Przygotowanie do wdrożenia (Deploy)
* **Czy program nadaje się do wdrażania jako kontener?** Tak, aplikacje Spring Boot są natywnie przystosowane do pracy w kontenerach (microservices).
* **Artefakt końcowy:** Aplikacja powinna być dystrybuowana jako plik **JAR**.
* **Oczyszczanie:** Obraz budujący zawiera kod źródłowy i narzędzia deweloperskie, co zwiększa jego rozmiar i zmniejsza bezpieczeństwo. Do celów produkcyjnych należy zastosować technikę **Multi-stage build**, kopiując wyłącznie skompilowany plik `.jar` do lekkiego obrazu JRE (np. Alpine).