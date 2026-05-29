# Sprawozdanie z Laboratorium 10
## Temat: Wdrażanie na zarządzalne kontenery – Kubernetes (Minikube)

---

### 1. Instalacja i uruchomienie klastra Kubernetes

Czynności rozpoczęto od uruchomienia lokalnego klastra Kubernetes za pomocą narzędzia Minikube z wykorzystaniem sterownika Dockera (--driver=docker). Krok ten pozwala na emulację pełnoprawnego węzła Kubernetes wewnątrz izolowanego środowiska kontenerowego, co mityguje wysokie wymagania sprzętowe klasycznej instalacji produkcyjnej.

Po zainicjowaniu klastra zweryfikowano status węzłów roboczych poleceniem:
```bash
kubectl get nodes
```
Węzeł sterujący (control-plane) osiągnął status Ready, co potwierdza pełną gotowość środowiska do przyjmowania zadań.

![Status węzła Minikube](k8s_nodes_ready.png)

Następnie uruchomiono systemowy panel graficzny Kubernetes Dashboard, służący do wizualizacji stanu aplikacji i zasobów klastra za pomocą komendy:
```bash
minikube dashboard --url
```
Polecenie to wystawiło dedykowany proxy serwer API klastra, umożliwiając bezpieczną łączność z poziomu przeglądarki internetowej hosta.

![Uruchomienie Dashboard](minikube_dashboard--url.png)

---

### 2. Manualne uruchomienie i analiza kontenera

W celu zapoznania się z podstawową jednostką obliczeniową klastra, jaką jest Pod, przeprowadzono wdrożenie imperatywne (manualne). Wykorzystano stabilny, lekki obraz nginx:1.25-alpine.

```bash
kubectl run moj-nginx-pod --image=nginx:1.25-alpine --port=80 --labels app=moj-nginx-pod
```
Służący do testów Pod został pomyślnie powołany do życia w przestrzeni klastra.

![Status manualnego Poda](pod_manualny.png)

Ponieważ Pod domyślnie posiada adres IP dostępny tylko wewnątrz sieci klastra, zastosowano mechanizm przekierowania portów (port-forward), aby uzyskać dostęp do aplikacji z poziomu systemu operacyjnego hosta:
```bash
kubectl port-forward pod/moj-nginx-pod 8080:80 --address 0.0.0.0
```
Weryfikacja działania serwera WWW została wykonana za pomocą narzędzia curl skierowanego na lokalny punkt końcowy. Wynik polecenia zwrócił poprawny nagłówek kodu HTML (Welcome to nginx!), co udowodniło komunikację sieciową.

![Weryfikacja działania aplikacji via curl](nginx_curl.png)

---

### 3. Deklaratywne wdrażanie za pomocą plików YAML (Wersja I)

Podejście manualne zastąpiono profesjonalnym podejściem deklaratywnym typu Infrastruktura jako Kod (IaC). W tym celu stworzono plik konfiguracyjny deployment.yaml realizujący cel postawienia kontrolera Deployment zarządzającego automatycznie 4 replikami aplikacji.

#### Plik: deployment.yaml (Wersja z 4 replikami)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
```
Wdrożenie konfiguracji z pliku zrealizowano kluczową komendą:

```bash
kubectl apply -f deployment.yaml
```

Kontroler replikacji Kubernetesa wykrył różnicę stanu i natychmiastowo utworzył dokładnie 4 niezależne Pody, dbając o ich wysoką dostępność.

![Wdrożenie 4 replik z pliku YAML](wdrozenie_yaml_4.png)

---

### 4. Dynamiczne skalowanie i zarządzanie zasobami

Przetestowano elastyczność i skalowalność klastra „w locie” (bez przerywania ciągłości działania aplikacji). Wykonano sekwencyjną zmianę liczby replik za pomocą instrukcji kubectl scale:

1. Skalowanie w górę do 8 replik (zwiększenie wydajności pod ruch masowy).
2. Redukcja do 1 repliki (minimalizacja kosztów infrastruktury).
3. Całkowite wygaszenie zasobów do 0 replik (zawieszenie działania aplikacji).
4. Powrót do stabilnego stanu docelowego 4 replik.

```bash
kubectl scale deployment/nginx-deployment --replicas=8
kubectl scale deployment/nginx-deployment --replicas=1
kubectl scale deployment/nginx-deployment --replicas=0
kubectl scale deployment/nginx-deployment --replicas=4
```bash

![Logi operacji dynamicznego skalowania](multiple_deployments.png)

---

### 5. Aktualizacja wdrożenia i obsługa awarii (Rollback)

Jedną z najważniejszych cech klastra Kubernetes jest automatyczna ochrona przed błędami ludzkimi podczas aktualizacji aplikacji. W celu prezentacji tej funkcji zasymulowano awarię poprzez próbę wdrożenia nieistniejącego w repozytorium, wadliwego obrazu kontenera:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:wersja-z-bledem-999
```

Weryfikacja stanu podów natychmiast wykazała błąd krytyczny ImagePullBackOff oraz ErrImagePull. Cluster zidentyfikował brak możliwości pobrania oprogramowania i wstrzymał proces aktualizacji, chroniąc stare, działające pody przed usunięciem.

![Błąd pobierania obrazu w klastrze](image_error.png)

W celu natychmiastowego przywrócenia pełnej sprawności operacyjnej systemu, wykonano wycofanie ostatniej nieudanej transakcji (operacja Rollback):

```bash
kubectl rollout undo deployment/nginx-deployment
```

System automatycznie powrócił do ostatniej zapamiętanej w historii, stabilnej konfiguracji, co przywróciło status wszystkich podów do flagi Running.

![Stan systemu po wykonaniu operacji Rollback](image_error_fixed.png)

---

### 6. Kontrola wdrożenia – Skrypt Weryfikacyjny

Zgodnie z wymaganiami technicznymi przygotowano skrypt powłoki Bash o nazwie verify.sh. Jego zadaniem jest automatyczna kontrola stanu wdrożenia i weryfikacja, czy pody uruchomiły się poprawnie w zadanym oknie czasowym wynoszącym maksymalnie 60 sekund.

#### Plik: verify.sh

```bash
#!/bin/bash
echo "Rozpoczynam automatyczną weryfikację statusu wdrożenia..."
kubectl rollout status deployment/nginx-deployment --timeout=60s
```

Skrypt nadano uprawnienia wykonywalne (chmod +x verify.sh) i uruchomiono. Wynik działania skryptu jednoznacznie potwierdził sukces operacji wdrożeniowej (komunikat successfully rolled out).

![Wynik wykonania skryptu weryfikacyjnego](script_output.png)

---

### 7. Zaawansowane strategie wdrożeń (Wersja II pliku YAML)

W ostatniej fazie laboratorium zmodyfikowano strategię aktualizacji aplikacji. Domyślną konfigurację rozszerzono o strategię RollingUpdate (aktualizacja krocząca). Pozwala ona na bezprzerwowe (Zero-Downtime) podmienianie kontenerów na nowsze wersje przy zachowaniu rygorystycznych limitów bezpieczeństwa zasobów.

#### Plik: deployment.yaml (Wersja II ze strategią RollingUpdate)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 2
      maxSurge: 25%
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
```

Wyjaśnienie parametrów strategii:
* maxUnavailable: 2 – informuje klastry, że podczas aktualizacji maksymalnie 2 pody z 4 mogą być jednocześnie niedostępne. Gwarantuje to zachowanie minimum 50% wydajności aplikacji w trakcie rolloutu.
* maxSurge: 25% – określa, że Kubernetes może stworzyć tymczasowo maksymalnie 25% (czyli 1 dodatkowy pod ponad stan 4 replik) nowych kontenerów w trakcie trwania procesu wymiany.

Plik został pomyślnie zaaplikowany do systemu (deployment.apps/nginx-deployment configured), co stanowi końcowe, pełne wykonanie założeń projektowych laboratorium.

![Zatwierdzenie zaawansowanej strategii wdrożenia](final_confirmation.png)

---
### Wnioski
Laboratorium pozwoliło na pełne opanowanie orkiestracji kontenerów z poziomu platformy Kubernetes. Podejście deklaratywne za pomocą plików konfiguracyjnych YAML zapewnia powtarzalność środowisk, automatyczne skalowanie eliminuje problemy z przeciążeniem infrastruktury, a wbudowane mechanizmy monitorowania stanu (Rollback, RollingUpdate) gwarantują bezpieczeństwo aplikacji na poziomie produkcyjnym.