# Dokumentacja Procesu CI - Express.js

Zgodnie z wymaganiami, poniższy dokument zawiera opisy i diagramy UML dla procesu Continuous Integration.

## 1. Wymagania wstępne środowiska

Środowisko uruchomieniowe dla pipeline'u musi spełniać następujące założenia:
* **Serwer Jenkins:** Skonfigurowana instancja Jenkins z zainstalowanymi wtyczkami do obsługi Pipeline, Git oraz Docker.
* **Środowisko Docker:** Jenkins musi posiadać dostęp do środowiska uruchomieniowego kontenerów. Wymagane jest środowisko zagnieżdżone (uruchomienie obrazu Dockera eksponującego środowisko zagnieżdżone, np. DIND) lub dostęp do gniazda Dockera hosta.
* **Dostęp sieciowy:** Możliwość pobierania kodu z publicznego repozytorium Git (aby sklonować Express.js) oraz obrazów bazowych z rejestru Docker Hub.

## 2. Diagram aktywności (Proces CI)

Diagram przedstawia kolejne etapy realizowane w ramach pipeline'u: `collect`, `build`, `test` oraz `report`.

```mermaid
stateDiagram-v2
    direction LR
    [*] --> Collect

    state Collect {
        [*] --> Pobranie_Kodu
        Pobranie_Kodu --> checkout_git
    }
    
    Collect --> Build
    
    state Build {
        [*] --> Uruchomienie_Kontenera_Node
        Uruchomienie_Kontenera_Node --> Instalacja_Zależności : npm install
    }
    
    Build --> Test
    
    state Test {
        [*] --> Uruchomienie_Testów : npm test
    }
    
    Test --> Report
    
    state Report {
        [*] --> Analiza_Logów
        Analiza_Logów --> Publikacja_Wyników : Zapisanie artefaktów
    }
    
    Report --> [*]