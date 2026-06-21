## Sprawozdanie numer 4
Bartosz Bodulski, grupa 1, tematy 12 i 13.

### Temat 12
Cel zajeć: Zapoznanie się z github Actions oraz dyrektywą "shift-left".

Na początku zgodnie z poleceniem, forkuję i klonuję repozytorium mojego wcześniej wybranego oprogramowania - jest to neovim, tworzę nową gałąź lokalną ino_dev, usuwam wszystkie workflowy dla github actions ustawione przez autorów oprogramowania.

![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20084632.png)

Następnie dodaję swój plik dla Github Actions, w którym sprawdzam jakość kodu, gdyż neovim lubi się długo budować, szczególnie na 1 rdzeniu, który przydzielony jest w ramach planu darmowego.

![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20085129.png)

Plik konfiguracyjny reaguje na pushe na gałęzi `ino_dev` dla systemu ubuntu 24.04. Tutaj mamy podobny workflow do naszego wcześniejszego Jenkinsfile, ale tutaj jest mamy uproszczenie całego pipeline'u. Najpierw pobieramy narzędzie shellcheck do sprawdzania skryptów powłoki bash w projekcie, po czym sprawdzamy je i na koniec tworzymy prosty raport w postaci artefaktu, pakując go w tarball'a o nazwie `neovim-raport-artefakt`.


```yml
name: Shift-left Neovim Pipeline

# Akcja reaguje tylko na kod wrzucony do gałęzi ino_dev
on:
  push:
    branches:
      - ino_dev

jobs:
  code-quality-and-artifact:
    runs-on: ubuntu-24.04

    steps:
      # Pobranie kodu repozytorium
      - name: Checkout repository
        uses: actions/checkout@v4

      #  Analiza jakości kodu (Code Quality) - Zamiast długiego buildu
      - name: Sprawdzenie jakości kodu (Shellcheck)
        run: |
          echo "Zgodnie z poleceniem: Ponieważ pełny build/test Neovima zajmuje >30 min,"
          echo "wykonujemy czynnosc zastepcza: Code Quality."
          
          sudo apt-get update && sudo apt-get install -y shellcheck
          
          # Szukamy wszystkich skryptów .sh w repozytorium i sprawdzamy ich poprawność
          find . -type f -name "*.sh" -exec shellcheck {} + || true
          
          echo "Jakość kodu powłoki sprawdzona pomyślnie!"

      # Wygenerowanie pliku do artefaktu
      - name: Generowanie przykladowego artefaktu
        run: |
          mkdir -p build_output
          echo "Raport Code Quality wygenerowany pomyślnie dla gałęzi ino_dev" > build_output/raport_cq.txt
          # Pakujemy folder do archiwum .tar.gz
          tar -czvf neovim-raport.tar.gz build_output/

      # Zapisanie zbudowanego artefaktu za pomocą dedykowanej akcji
      - name: Udostepnienie artefaktu (Upload Artifact)
        uses: actions/upload-artifact@v4
        with:
          name: neovim-raport-artefakt
          path: neovim-raport.tar.gz
          retention-days: 5

```
 
Przed spushowaniem commita z plikem konfiguracyjnym panel github actions wyglada tak:

![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20085939.png)

Po spushowaniu commita pipeline jest uruchamiany i wszystko przedchodzi bez błędów:

![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20090342.png)


![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20090647.png)


![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20090703.png)
 
Wynikiem pipeline'u jest właśnie raport w postaci pliku tekstowego, który można normalnie sciągnąć i sprawdzić na własnej maszynie:


![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20090917.png)

Następnie dodaje kolejny plik konfiguracyjny, którego zadaniem jest przybliżenie końcowej wersji jenkinsfile. Pipeline pobiera zależności, kompiluje neovima, buduje paczkę debiana za pomocą Cpack, wykonuje mój smoke test z argumentem --headless oraz zwraca naszą paczkę .deb w tarball'u.

```yml
name: Full Neovim Build Pipeline

on:
  push:
    branches:
      - ino_dev

jobs:
  build-and-test:
    runs-on: ubuntu-24.04

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      # ---------------------------------------------------------
      # Zbudowanie Neovima i paczki DEB (Natywnie)
      # ---------------------------------------------------------
      - name: Instalacja zaleznosci systemowych
        run: |
          sudo apt-get update
          sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential

      - name: Kompilacja Neovima ze zrodel
        run: |
          echo "Rozpoczynamy kompilacje Neovima. Moze to potrwac 10-15 minut..."
          make CMAKE_BUILD_TYPE=Release

      - name: Pakowanie do pliku DEB (Wykorzystanie CPack)
        run: |
          cd build
          cpack -G DEB
          
          # Zmiana nazwy wygenerowanego pliku na ta, ktora byla w Jenkinsie
          mv nvim-*.deb ../neovim-final.deb
          cd ..
          
          echo "--- zaleznosci zbudowanej paczki .deb ---"
          dpkg -I ./neovim-final.deb | grep 'Depends' || true

      # ---------------------------------------------------------
      #  Deploy i Smoke Test w izolowanym kontenerze Dockera
      # ---------------------------------------------------------
      - name: Deploy i Smoke Test (CD)
        run: |
          echo "--- Tworzymy przykładowe pliki tekstowe do smoke test'u ---"
          echo "To jest NIEZMODYFIKOWANY tekst testowy." > test_file.txt

          echo "--- Budowanie kontenera CD (Deploy) ---"
          cat << 'EOF' > Dockerfile.deploy
          FROM ubuntu:24.04
          COPY neovim-final.deb /tmp/
          COPY test_file.txt /workspace/
          WORKDIR /workspace
          ARG DEBIAN_FRONTEND=noninteractive
          RUN apt-get update && apt-get install -y /tmp/neovim-final.deb && rm -rf /var/lib/apt/lists/*
          EOF

          docker build -t neovim-cd-container -f Dockerfile.deploy .
          docker rm -f smoke-test-run || true

          echo "--- Wykonanie testu w kontenerze (Run & Check OUT) ---"
          docker run --name smoke-test-run neovim-cd-container nvim --headless -c '%s/NIEZMODYFIKOWANY/ZMODYFIKOWANY/g' -c 'wq' test_file.txt

          echo "--- Weryfikacja wyniku (OUT -> OK?) ---"
          docker cp smoke-test-run:/workspace/test_file.txt ./test_file_out.txt
          
          if grep -q "ZMODYFIKOWANY" ./test_file_out.txt; then
              echo "Neovim poprawnie zedytował plik."
          else
              echo "Plik nie został poprawnie przetworzony!"
              exit 1
          fi

      - name: Sprzatanie po Smoke Tescie
        if: always() # klauzula post { always { ... } } w Jenkinsie
        run: docker rm -f smoke-test-run || true

      # ---------------------------------------------------------
      # Archiwizacja artefaktu
      # ---------------------------------------------------------
      - name: Archiwizacja Artefaktow (Paczka DEB)
        uses: actions/upload-artifact@v4
        with:
          name: neovim-final-deb
          path: ./neovim-final.deb
          retention-days: 5

```
Po spushowaniu commita dostaje takie wyniki:

![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20092111.png)


![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20092143.png)


![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20092357.png)


![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20092802.png)


![img](../screenshots/lab12/Zrzut%20ekranu%202026-06-12%20092910.png)

Jak widać, wszytkie kroki przeszły poprawnie i bezbłędnie. Jeżeli dodałbym do tego pipeline'u testy jednostkowe dla całego oprogramowania, zajełoby to niestety ponad 30 min, dlatego proces ten został o ten etap "uszczuplony".

#### Wnioski

GitHub Actions to wydajne i natywnie wbudowane w repozytorium rozwiązanie, które pozwala na łatwe zarządzanie artefaktami i szybki feedback dla programistów przy każdym nowym commit'cie.

Implementacja narzędzia `shellcheck` na wczesnym etapie potoku (pipeline'u) udowadnia skuteczność podejścia Shift-Left. Pozwala to na wychwycenie błędów składniowych w skryptach powłoki w czasie poniżej kilkunastu sekund, co pozwala zaoszczędzić czas (i minuty obliczeniowe runnerów), unikając długotrwałej kompilacji kodu zawierającego błędy.

Wykorzystanie tymczasowych kontenerów Docker do wdrożenia i przeprowadzenia smoke testów skompilowanej paczki .deb gwarantuje, że aplikacja będzie działać prawidłowo w czystym systemie docelowym (Ubuntu), niezależnie od konfiguracji maszyny budującej.


### Temat 13


Cel zajęć: Wdrażanie na zarządzalne kontenery w chmurze.

Przed zajęciami miałem już zajerestrowane konto uczelniane na platformie Azure, dlatego nie muszę teraz zajmować się procesem rejestracji. 

Na początku łącze się z azure cloud shell,aby utworzyć grupę zasobów potrzebnych w tym ćwiczeniu. Wynikiem tego polecenia jest obiekt JSON, który zwraca konfigurację naszej grupy ( region, tagi, nazwa itd. ).

![img](../screenshots/lab13/Zrzut%20ekranu%202026-06-15%20084305.png)

Następnie publikuje kontener mojej aplikacji nginx w wersji v3 na dockerHub w celu użycia jego w konterzene Azure:

![img](../screenshots/lab13/Zrzut%20ekranu%202026-06-15%20084955.png)

Podczas pierwszej próby utworzenia kontenera na nowej subskrypcji, Azure musi zarejestrować dostawcę zasobów (Resource Provider) dla usługi Container Instances (Microsoft.ContainerInstance). Proces ten jest jednorazowy i zajmuje kilka-kilkanaście minut.


![img](../screenshots/lab13/Zrzut%20ekranu%202026-06-15%20085549.png)
Po około 20 minutach mogę już stworzyć mój kontener, który działa na porcie 80 z obrazem pobranym z mojego DockerHuba o nazwie `moj-app-bartbod123`, który używa 1 vCPU i 1 GB RAM w systemie Linux (Domyślam się, że jest to Apline Linux).


![img](../screenshots/lab13/Zrzut%20ekranu%202026-06-21%20193239.png)

Po utworzeniu kontenera dostaje odpowiedź w postacji obiektu JSON, który daje mi dużą ilość informacji na temat stworzonego kontenera:

```json
{
  "confidentialComputeProperties": null,
  "containerGroupProfile": null,
  "containers": [
    {
      "command": null,
      "configMap": {
        "keyValuePairs": {}
      },
      "environmentVariables": [],
      "image": "bartbod/moj-app:v3",
      "instanceView": {
        "currentState": {
          "detailStatus": "",
          "exitCode": null,
          "finishTime": null,
          "startTime": "2026-06-21T17:31:45.935000+00:00",
          "state": "Running"
        },
        "events": [
          {
            "count": 1,
            "firstTimestamp": "2026-06-21T17:31:45+00:00",
            "lastTimestamp": "2026-06-21T17:31:45+00:00",
            "message": "Started container",
            "name": "Started",
            "type": "Normal"
          },
          {
            "count": 1,
            "firstTimestamp": "2026-06-21T17:31:35+00:00",
            "lastTimestamp": "2026-06-21T17:31:35+00:00",
            "message": "Successfully pulled image \"bartbod/moj-app@sha256:558a8e4aa39a646a0d6716c1767d972a14f067e62e007272f9f62242c1da3ab3\"",
            "name": "Pulled",
            "type": "Normal"
          },
          {
            "count": 1,
            "firstTimestamp": "2026-06-21T17:31:25+00:00",
            "lastTimestamp": "2026-06-21T17:31:25+00:00",
            "message": "pulling image \"bartbod/moj-app@sha256:558a8e4aa39a646a0d6716c1767d972a14f067e62e007272f9f62242c1da3ab3\"",
            "name": "Pulling",
            "type": "Normal"
          }
        ],
        "previousState": null,
        "restartCount": 0
      },
      "livenessProbe": null,
      "name": "moja-aplikacja",
      "ports": [
        {
          "port": 80,
          "protocol": "TCP"
        }
      ],
      "readinessProbe": null,
      "resources": {
        "limits": null,
        "requests": {
          "cpu": 1.0,
          "gpu": null,
          "memoryInGb": 1.0
        }
      },
      "securityContext": null,
      "volumeMounts": null
    }
  ],
  "diagnostics": null,
  "dnsConfig": null,
  "encryptionProperties": null,
  "extensions": null,
  "id": "/subscriptions/cb842ff3-17a8-404b-8439-6a9d8336f6da/resourceGroups/Lab13-ResourceGroup/providers/Microsoft.ContainerInstance/containerGroups/moja-aplikacja",
  "identity": null,
  "imageRegistryCredentials": null,
  "initContainers": [],
  "instanceView": {
    "events": [],
    "state": "Running"
  },
  "ipAddress": {
    "autoGeneratedDomainNameLabelScope": "Unsecure",
    "dnsNameLabel": "moj-app-bartbod-123",
    "fqdn": "moj-app-bartbod-123.westeurope.azurecontainer.io",
    "ip": "20.54.201.53",
    "ports": [
      {
        "port": 80,
        "protocol": "TCP"
      }
    ],
    "type": "Public"
  },
  "isCreatedFromStandbyPool": false,
  "location": "westeurope",
  "name": "moja-aplikacja",
  "osType": "Linux",
  "priority": null,
  "provisioningState": "Succeeded",
  "resourceGroup": "Lab13-ResourceGroup",
  "restartPolicy": null,
  "sku": "Standard",
  "standbyPoolProfile": null,
  "subnetIds": null,
  "tags": {},
    "type": "Microsoft.ContainerInstance/containerGroups",
  "volumes": null,
  "zones": null
}

```
Dodatkowo sprawdzam istnieje kontenera za pomocą powłoki - wynikiem jest adres, który mogę wpisać do przeglądarki i sprawdzić działanie mojej aplikacji statycznej.

![img](../screenshots/lab13/Zrzut%20ekranu%202026-06-21%20193601.png)

Jak widać, wszystko działa zgodnie z naszą konfiguracją. Przez to, że nasze połączenie nie jest skonfigurowane pod HTTPS, dostajemy informacje "Not Secure" od firefoxa'a. Na potrzeby tego laboratorium taka konfiguracja jest wystarczająca.

![img](../screenshots/lab13/Zrzut%20ekranu%202026-06-21%20193357.png)

Następnie sprawdzam logi maszyny, w której widzimy logi naszej aplikacji oraz żądania HTTP, jak i błędy not found 404 na niezdefiniowanych scieżkach api - jest to prawdopodobnie bot wykonujący web-scraping.

![img](../screenshots/lab13/Zrzut%20ekranu%202026-06-21%20193642.png)

Na koniec usuwam poleceniem `az group delete --name --yes --no-wait` moją grupe zasobów, aby nie marnować niepotrzebnie moich przydzielonych kredytów.

![img](../screenshots/lab13/Zrzut%20ekranu%202026-06-21%20193859.png)

#### Wnioski

Usługa Azure Container Instances to najszybsza metoda na uruchomienie skonteneryzowanej aplikacji w chmurze Azure. Nie wymaga ona konfigurowania, zarządzania, ani utrzymywania maszyn wirtualnych czy skomplikowanych klastrów Kubernetes.

 Platforma Azure integruje się płynnie z publicznymi rejestrami. Do uruchomienia prostej aplikacji nie było wymagane tworzenie własnego rejestru w Azure (Azure Container Registry - ACR), co zaoszczędziło czas i koszty, pozwalając na bezpośrednie pobranie lekkiego obrazu z Docker Hub. 
 
 Zgodnie z zagadnieniami z instrukcji funkcja Container Registry Cache okazała się niepotrzebna dla tak małego obrazu wdrażanego jednorazowo. Cache stosuje się komercyjnie, by ominąć limity zapytań (rate limits) do Docker Hub oraz skrócić czas pobierania ciężkich obrazów. 
 
 Zamykanie środowiska testowego poprzez całkowite usunięcie grupy zasobów `az group delete` jest kluczową dobrą praktyką. Ponieważ w modelu chmurowym płaci się za zasoby na sekundę/minutę ich działania, takie podejście gwarantuje, że z budżetu nie zostaną pobrane niepożądane środki za działające w tle, nieużywane instancje.