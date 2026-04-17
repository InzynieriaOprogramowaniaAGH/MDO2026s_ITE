# Sprawozdanie z Laboratorium 5,6, i 7
**Autor:** Piotr Drożyński

---

## 1. Instalacja i Konfiguracja Środowiska Jenkins

Celem etapu było uruchomienie skonteneryzowanego Jenkinsa z dostępem do gniazda Dockera hosta, co umożliwia budowanie obrazów wewnątrz potoków CI/CD.

**Definicja obrazu Jenkinsa**
Przygotowano Dockerfile instalujący klienta Docker oraz wtyczkę Blue Ocean.
![dockerfile_jenkins.png](lab5/screenshots/dockerfile_jenkins.png)

**Orkiestracja kontenera**
Konfiguracja Docker Compose z podmontowaniem gniazda `/var/run/docker.sock`.
![jenkins_docker_compose.png](lab5/screenshots/jenkins_docker_compose.png)

**Inicjalizacja i hasło administratora**
Odczytanie hasła startowego z logów kontenera w celu odblokowania panelu.
![jenkins_haslo.png](lab5/screenshots/jenkins_haslo.png)
![tu_wprowadzam_haslo.png](lab5/screenshots/tu_wprowadzam_haslo.png)

**Konfiguracja użytkownika i URL**
Proces tworzenia konta administratora oraz finalne zatwierdzenie adresu instancji.
![create_first_admin.png](lab5/screenshots/create_first_admin.png)
![jenkins_url_config.png](lab5/screenshots/jenkins_url_config.png)

---

## 2. Zadania Wstępne

Przed budową potoków Pipeline, przetestowano podstawowe możliwości Jenkinsa na prostych zadaniach.

**Zadanie 2.1: Identyfikacja systemu (uname)**
Konfiguracja prostego kroku shell, który wywołuje polecenie `uname -a`.
![build_step_uname.png](lab5/screenshots/build_step_uname.png)

**Wynik uname**
Podgląd konsoli Jenkinsa, wykazujący poprawną identyfikację jądra systemu Linux, na którym pracuje serwer.
![uname_console_output.png](lab5/screenshots/uname_console_output.png)

**Zadanie 2.2: Test logiki (Godzina nieparzysta)**
Skrypt Bash weryfikujący aktualną godzinę. Jeśli jest nieparzysta, skrypt zwraca `exit 1`, co Jenkins interpretuje jako błąd zadania.
![odd_hour_script.png](lab5/screenshots/odd_hour_script.png)

**Wynik testu godziny**
Przykładowy wynik, gdzie build zakończył się niepowodzeniem (status FAILURE), ponieważ godzina była nieparzysta (07:00).
![odd_hour_result.png](lab5/screenshots/odd_hour_result.png)

**Zadanie 2.3: Komunikacja z Dockerem**
Projekt wykonujący polecenie `docker pull`. Ma na celu udowodnienie, że Jenkins ma uprawnienia do pobierania obrazów z Docker Hub.
![docker_build_script.png](lab5/screenshots/docker_build_script.png)

**Pobieranie obrazu Ubuntu**
Logi konsoli potwierdzające pomyślne pobranie warstw obrazu Ubuntu na maszynę wirtualną.
![docker_pull_result.png](lab5/screenshots/docker_pull_result.png)

---

## 3. Implementacja Obiektu typu Pipeline

Głównym zadaniem było stworzenie zautomatyzowanego potoku dla projektu **hiredis**, który przeprowadzi proces od pobrania kodu po publikację artefaktu.

**Konfiguracja obiektu Pipeline**
Utworzenie nowego projektu i wybór typu Pipeline w interfejsie Jenkins.
![pipeline_config.png](lab5/screenshots/pipeline_config.png)

**Definicja Jenkinsfile (Skrypt potoku)**
Zaimplementowano skrypt pipeline'u, dzielący pracę na etapy: Checkout, Build, Test oraz Publish.
![pipeline_1.png](lab5/screenshots/pipeline_1.png)
![pipeline_2.png](lab5/screenshots/pipeline_2.png)

**Wizualizacja sukcesu w Blue Ocean**
Pomyślne przejście wszystkich etapów potoku.
![pipeline_success.png](lab5/screenshots/pipeline_success.png)

---

## 4. Analiza i Modelowanie Procesu

**Zadanie 4.1: Sekwencja CI/CD**
Proces przebiega według następującej logiki:
1. **Collect**: Jenkins pobiera kod z GitHuba (gałąź `PD420765`).
2. **Build**: Wywołanie `docker build`, kompilacja źródeł C przez GCC wewnątrz kontenera.
3. **Test**: Uruchomienie kontenera z bazą Redis i wykonanie `make check`.
4. **Report/Publish**: Jeśli testy przejdą pomyślnie, Jenkins wyodrębnia plik `libhiredis.so`, pakuje go do `.tar.gz` i archiwizuje jako gotowy artefakt.

**Zadanie 4.2. Diagram Wdrożeniowy (Deployment Diagram)**
1. **Node: Host Machine (Ubuntu VM)**:
   - a) **Docker Engine**: Zarządza cyklem życia wszystkich kontenerów.
   - b) **Container: Jenkins Blue Ocean**: Serwer CI/CD sterujący procesem przez `/var/run/docker.sock`.
2. **Dynamic Containers**:
   - a) **hiredis-builder**: Kontener z narzędziami `build-essential`.
   - b) **hiredis-tester**: Kontener z `redis-server` i skompilowaną biblioteką.
3. **Artifact Storage**: System plików Jenkinsa przechowujący paczki `.tar.gz`.


### Laboratorium 6

## 1. Weryfikacja Ścieżki Krytycznej

Zaimplementowany potok Pipeline w Jenkinsie realizuje pełną automatyzację procesu dostarczania oprogramowania. Ścieżka krytyczna obejmuje:
- **Clone**: Pobranie kodu źródłowego z GitHuba.
- **Build**: Kompilacja biblioteki w kontenerze `builder`.
- **Test**: Przeprowadzenie testu integracyjnego między dwoma kontenerami (C1 i C2).
- **Publish**: Przygotowanie wersjonowanego artefaktu i jego archiwizacja.

---

## 2. Implementacja i Konfiguracja Potoku

Proces został zdefiniowany jako "Pipeline as Code". Poniżej przedstawiono konfigurację oraz strukturę skryptu.

**Kod źródłowy Pipeline (Jenkinsfile)**
Zaimplementowany skrypt wykorzystuje mechanizm `docker exec` oraz `docker cp`, aby umożliwić przesyłanie kodu przykładowego do kontenera budującego bez konieczności instalowania w nim Gita.
![pipeline_1.png](lab5/screenshots/pipeline_1.png)
![pipeline_2.png](lab5/screenshots/pipeline_2.png)

---

## 2,5. Implementacja Obiektu typu Pipeline

Głównym zadaniem było stworzenie potoku CI/CD, który realizuje pełny test integracyjny biblioteki przy użyciu dwóch kontenerów: serwera bazy danych (C1) oraz aplikacji testowej (C2).

**3.1. Kod aplikacji testowej (sample.c)**
Zgodnie ze schematem, przygotowano plik `sample.c`, który pełni rolę "konsumenta" biblioteki. Kod łączy się z serwerem o nazwie `redis-server`, wysyła komendę `PING` i oczekuje odpowiedzi `PONG`.

```c
#include <stdio.h>
#include <hiredis/hiredis.h>

int main() {
    redisContext *c = redisConnect("redis-server", 6379);
    if (c == NULL || c->err) {
        printf("Błąd połączenia: %s\n", c ? c->errstr : "Błąd alokacji");
        return 1;
    }
    redisReply *reply = redisCommand(c, "PING");
    printf("Wynik testu: %s\n", reply->str); 
    freeReplyObject(reply);
    redisFree(c);
    return 0;
}

## 3. Realizacja Testu Integracyjnego

Zgodnie z wytycznymi, przeprowadzono test weryfikujący poprawność działania biblioteki w interakcji z zewnętrzną usługą.

**Przebieg testu:**
1. **Kontener C1 (Redis Server)**: Uruchomiony w tle w dedykowanej sieci `hiredis-network`.
2. **Kontener C2 (Integration Client)**: Kontener bazujący na obrazie budującym, do którego "wstrzyknięto" plik `sample.c`.
3. **Kompilacja i Linkowanie**: Wewnątrz C2 wykonano `make install`, aby zarejestrować bibliotekę w systemie, a następnie skompilowano kod przykładowy z flagą `-lhiredis`.
4. **Weryfikacja**: Program połączył się z C1 i wykonał komendę `PING`.

**Dowód pomyślnej komunikacji (Logi):**
W logach konsoli odnotowano odpowiedź serwera: **`Wynik testu: PONG`**. Potwierdza to, że biblioteka została poprawnie zbudowana, zainstalowana i jest zdolna do komunikacji sieciowej.
![pipeline_success.png](lab5/screenshots/pipeline_success.png)

---

## 4. Etap Publish i Archiwizacja Artefaktów

Po pomyślnych testach, Jenkins wyodrębnił plik binarny `libhiredis.so` z kontenera i przygotował paczkę redystrybucyjną.

**Tworzenie Artefaktu**
Biblioteka została spakowana do formatu `.deb` przy użyciu narzędzia `tar`.
```bash
tar -czvf hiredis-package.deb libhiredis.so
