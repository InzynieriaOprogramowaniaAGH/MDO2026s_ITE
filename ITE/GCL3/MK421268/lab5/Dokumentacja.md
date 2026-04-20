## 1. Wymagania wstępne środowiska

Aby zaprezentowany proces ciągłej integracji i wdrażania (CI/CD) mógł zostać pomyślnie wykonany, wymagane są następujące elementy:

* Działająca instancja serwera ciągłej integracji (Jenkins) uruchomiona jako kontener Docker.
* Skonfigurowane i połączone środowisko zagnieżdżone Docker-in-Docker (DinD), pozwalające Jenkinsowi na bezpieczne budowanie obrazów, tworzenie wyizolowanych sieci oraz uruchamianie testów w locie.
* Sforkowane repozytorium z kodem źródłowym aplikacji (np. z modyfikacją frameworka Express.js pod kątem walidacji) wraz z odpowiednio zdefiniowanymi plikami konfiguracyjnymi: `Dockerfile.build`, `Dockerfile.test` oraz głównym `Jenkinsfile`.
* Dostęp do zewnętrznego rejestru obrazów lub wewnętrznego mechanizmu archiwizacji artefaktów (dla plików `.tgz`).

---

## 2. Diagram aktywności (Proces CI)

Diagram przedstawia przepływ zadań w pipeline, ze szczególnym uwzględnieniem izolacji środowiska testowego.

```mermaid
stateDiagram-v2
    direction TB

    [*] --> Stage_Build
    
    state Stage_Build {
        [*] --> Docker_Build_NoCache
        Docker_Build_NoCache --> express_build_image
    }

    Stage_Build --> Stage_Test

    state Stage_Test {
        [*] --> Build_Test_Image
        Build_Test_Image --> Run_npm_test : docker run --rm
    }

    Stage_Test --> Stage_Validation_Deploy

    state Stage_Validation_Deploy {
        [*] --> Create_Docker_Network
        Create_Docker_Network --> Start_c_deploy : (Uruchomienie aplikacji)
        Start_c_deploy --> Start_c_curl : (Uruchomienie testera)
        
        state Start_c_curl {
            [*] --> Fetch_JSON : GET /advanced
            Fetch_JSON --> Validate_Status : Check HTTP 200 & status:pass
        }
        
        Start_c_curl --> Cleanup : docker stop & network rm
    }

    Stage_Validation_Deploy --> Stage_Publish

    state Stage_Publish {
        [*] --> Artifact_Packaging : npm pack
        Artifact_Packaging --> Docker_Hub_Push : docker push
    }

    Stage_Publish --> Post_Processing
    Post_Processing --> [*]
```

## 3. Diagram wdrożeniowy (Validation & Deploy Stage)
```mermaid
graph TB
    subgraph Jenkins_Host [Serwer Jenkins]
        subgraph Docker_Engine [Docker Engine]
            
            subgraph Isolated_Network [Docker Network: pipeline-net-ID]
                C_DEPLOY[<b>c_deploy</b><br/>Port: 3000<br/>Image: express-build-image]
                C_CURL[<b>c_curl</b><br/>Tool: curl + jq<br/>Image: alpine]
            end

            C_CURL -- "HTTP GET /advanced" --> C_DEPLOY
            
            VOL[(Workspace Volume)]
            C_CURL -- "Write test_report.txt" --> VOL
        end
    end

    subgraph External_Registry [Docker Hub]
        REG[Repository: express-app]
    end

    Docker_Engine -- "docker push" --> REG
    
    subgraph Artifact_Storage [Jenkins Artifacts]
        TGZ[package.tgz]
        REP[test_report.txt]
    end

    VOL -- "archiveArtifacts" --> Artifact_Storage

    style C_DEPLOY fill:#f9f,stroke:#333,stroke-width:2px
    style C_CURL fill:#ccf,stroke:#333,stroke-width:2px
    style Isolated_Network stroke-dasharray: 5 5