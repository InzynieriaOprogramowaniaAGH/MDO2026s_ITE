# Sprawozdanie: Laboratorium 5, 6 i 7 

## 1. Wybrana Aplikacja i Repozytorium
Do wdrożenia wybrano prostą aplikację backendową napisaną w środowisku **Node.js** z wykorzystaniem frameworka **Express**. 
* **Licencja:** Kod ma charakter dydaktyczny, co pozwala na swobodny obrót nim na potrzeby zadania (licencja otwarta).
* **Repozytorium:** Zdecydowano się pracować na osobistej gałęzi (`SB422052`) wewnątrz istniejącego repozytorium przedmiotowego (`MDO2026s_ITE`), zamiast tworzyć pełnego forka.

## 2. Zadania Wstępne (Weryfikacja Środowiska)
W ramach rozgrzewki przygotowano projekty typu *Freestyle*, weryfikujące poprawność konfiguracji Jenkinsa:
1. `Zadanie_1_Uname` - Pomyślne wywołanie powłoki systemowej.
2. `Zadanie_2_Godzina` - Poprawne zachowanie przy błędzie (celowe przerwanie `exit 1` przy nieparzystej godzinie).
3. `Zadanie_3_Docker` - Pomyślne pobranie obrazu Ubuntu.

> **Dowód realizacji zadań wstępnych:**
> ![widok projektów wstępnych](Screeny2/1.1.png)
> ![logi błędu - zadanie z godziną](Screeny2/2.2.png)

## 3. Diagram Aktywności (Proces CI/CD)
Poniższy diagram UML obrazuje zaplanowany przepływ pracy w Jenkinsie:

```mermaid
graph TD
    classDef success fill:#d4edda,stroke:#28a745,stroke-width:2px,color:#000;
    classDef fail fill:#f8d7da,stroke:#dc3545,stroke-width:2px,color:#000;
    classDef info fill:#d1ecf1,stroke:#17a2b8,stroke-width:2px,color:#000;
    classDef action fill:#fff3cd,stroke:#ffc107,stroke-width:2px,color:#000;

    A([Start: Trigger Pipeline]):::info --> B[Czyszczenie Workspace <br> cleanWs]:::action
    B --> C[Checkout SCM <br> Pobranie gałęzi SB422052]:::action

    subgraph Krok_1 [Etap 2 i 3: Build & Test]
        C --> D[Budowa obrazu kontenera <br> moj-express-bldr z node:18-slim]
        D --> E[Uruchomienie środowiska testowego <br> docker run --rm]
        E --> F{Wykonanie: npm test }
    end

    F -- Błąd testów --> ERR1[Sprzątanie środowiska i FAILURE]:::fail
    F -- Sukces testów --> G[Testy zaliczone ]:::success

    subgraph Krok_2 [Etap 4: Publish]
        G --> H1[Docker Login i Tagowanie]:::action
        H1 --> H2[Docker Push do rejestru z tagiem latest]:::action
        H2 --> I1[Generowanie paczki tar.gz <br> bez .git i node_modules]:::action
        I1 --> I2[(Archiwizacja Jenkins <br> archiveArtifacts)]
    end

    subgraph Krok_3 [Etap 5: Deploy & Weryfikacja]
        I2 --> J[Usunięcie starego kontenera <br> docker rm -f]:::action
        J --> K[Wdrożenie na serwer <br> docker run -d port 3000]:::action
        K --> L{Smoke Test <br> curl /health}
    end

    L -- Błąd (Status != 200) --> ERR2[Zatrzymanie procesu]:::fail
    L -- Sukces (200 OK) --> M[Logi: Aplikacja działa]:::success
    
    M --> N[Post Action: Czyszczenie <br> cleanWs]:::action
    ERR1 --> N
    ERR2 --> N
    
    N --> O([Koniec: Definition of Done <br> Status SUCCESS]):::success
```

## 4. Realizacja etapów Pipeline (Ścieżka Krytyczna)
Zgodnie z zaplanowanym diagramem, zrealizowano potok CI/CD. Proces jest w pełni zautomatyzowany i powtarzalny dzięki czyszczeniu środowiska przed i po każdym uruchomieniu.

Krok 1: Build i Testowanie
Zbudowano obraz aplikacji na bazie obrazu node:18-slim. Wybór tej wersji pozwolił na zachowanie niskiej wagi obrazu przy jednoczesnym zapewnieniu stabilności środowiska. Po budowie obrazu, Jenkins automatycznie uruchomił kontener testowy i wykonał testy jednostkowe przy użyciu biblioteki Mocha.

Wynik: Testy zakończone sukcesem.
> ![testy](Screeny2/testy.png)

Krok 2: Publikacja Artefaktów (Publish)
Po pomyślnym przejściu testów, potok przeszedł do etapu publikacji:

Docker Hub: Obraz został otagowany i wypchnięty do zewnętrznego rejestru pod nazwą sebboze3/moj-express-bldr:latest. Dzięki temu aplikacja jest dostępna do pobrania na dowolnej maszynie.
> ![widok repozytorium dockerhuba](Screeny2/dockerhub.png)
> ![push obrazu](Screeny2/push-dockerhub.png)

Archiwum lokalne: Kod produkcyjny został spakowany do archiwum .tar.gz (z wykluczeniem katalogu .git i node_modules) i zarchiwizowany bezpośrednio w Jenkinsie jako artefakt do pobrania.
> ![archiwum lokalne](Screeny2/archiwum.png)

Krok 3: Wdrożenie i Weryfikacja (Deploy & Smoke Test)
Ostatnim etapem było wdrożenie produkcyjne na lokalnym środowisku Docker.


Jenkins usunął poprzednią instancję aplikacji, aby uniknąć konfliktów portów.

Uruchomiono nową wersję na porcie 3000.
> ![push obrazu](Screeny2/3000.png)

Smoke Test: Wykonano weryfikację "na żywo" za pomocą narzędzia curl. Odpytano endpoint /health, który zwrócił status 200 OK, co potwierdza, że aplikacja nie tylko się uruchomiła, ale poprawnie obsługuje żądania sieciowe.

> ![push obrazu](Screeny2/smoketest.png)

## 5. Odpowiedzi na pytania i wnioski
Format artefaktu: Wybrano obraz Docker (jako główny format redystrybucyjny) oraz archiwum .tar.gz. Obraz Docker zapewnia pełną przenośność (Portable Artifact), eliminując różnice w środowiskach między deweloperem a produkcją.

node vs node-slim: Pełny obraz node zawiera dodatkowe narzędzia kompilacji (np. python, kompilatory C++), które są potrzebne przy budowaniu niektórych bibliotek, ale zbędne do samego uruchomienia aplikacji. Obraz node-slim jest ich pozbawiony, co czyni go znacznie lżejszym i bezpieczniejszym na produkcji, ponieważ ogranicza liczbę zainstalowanych pakietów (mniejsza powierzchnia ataku).

Kontener Deploy: W moim projekcie kontenerem wdrożeniowym jest ten sam obraz, który został zbudowany w kroku Build. Dzięki zastosowaniu pliku .dockerignore, obraz ten jest "czysty" – nie zawiera logów ani historii Gita, co czyni go optymalnym do roli produkcyjnej (tzw. Runtime Image).

Definition of Done: Zadanie uznaję za zakończone, ponieważ proces kończy się wystawieniem gotowego do wdrożenia artefaktu na Docker Hubie, a automatyczna weryfikacja (Smoke Test) potwierdza jego pełną sprawność po starcie.