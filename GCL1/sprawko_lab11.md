# Sprawozdanie: Wdrażanie na kontenery - Kubernetes (Lab 11)

## 1. Wstęp
Celem laboratorium było praktyczne zapoznanie się z mechanizmami orkiestracji kontenerów w środowisku Kubernetes. Zadanie obejmowało wdrożenie aplikacji w formie Deploymentu, ekspozycję usług za pomocą obiektów Service (zarówno za pomocą CLI, jak i plików deklaratywnych) oraz przeprowadzenie operacji skalowania.

## 2. Przebieg prac i wdrożenie
Ze względu na izolację środowiska laboratoryjnego (brak dostępu do zewnętrznych rejestrów obrazów, takich jak Docker Hub), wdrożenie przeprowadzono z wykorzystaniem lokalnie dostępnego obrazu `nginx` (ID: 501d84f5d064). W celu uniknięcia błędów `ImagePullBackOff`, w pliku konfiguracyjnym Deploymentu ustawiono `imagePullPolicy: Never`.

### Plik konfiguracyjny (web-deployment.yaml)
![Wdrożenie deploymentu](web-deployment.png)

### Status wdrożonych podów
Po zastosowaniu konfiguracji, pody zostały poprawnie uruchomione:
![Działające pody](running_pods.png)

## 3. Ekspozycja serwisu
W ramach zadania wyeksponowano dostęp do web-serwera na dwa sposoby:

1. **Polecenie CLI:** `kubectl expose deployment web-server-deployment --type=NodePort --name=web-service`
2. **Plik YAML:** Zastosowano dodatkową deklarację typu Service.

![Ekspozycja serwisów - CLI](expose_i_get_svc.png)
![Oba serwisy w klastrze](oba_serwisy_svc.png)

Weryfikacja dostępu do serwera została przeprowadzona za pomocą mechanizmu `port-forward`:
![Przekierowanie portów](port_forward.png)
![Test połączenia curl](curl.png)

## 4. Skalowanie klastra
Przetestowano elastyczność klastra poprzez zmianę liczby replik:

* **Skalowanie za pomocą komendy `scale`:**
![Skalowanie przez konsolę](scale_konsola.png)
* **Skalowanie przez edycję pliku YAML:**
![Zmiana replik w YAML](8_replik_yaml.png)
![Efekt skalowania YAML](drugi_scale.png)

## 5. Wnioski
1. **Zarządzanie stanem:** Deployment pozwala na deklaratywne zarządzanie stanem aplikacji, automatycznie utrzymując zadaną liczbę replik podów.
2. **Izolacja sieciowa:** W środowiskach typu *air-gapped* kluczowe jest korzystanie z lokalnego cache'u obrazów (`minikube image load`) oraz odpowiednie definiowanie `imagePullPolicy`.
3. **Ekspozycja usług:** Kubernetes oferuje elastyczne metody udostępniania usług – od doraźnych poleceń CLI, po uporządkowane pliki konfiguracyjne YAML, które są zalecaną praktyką w środowiskach produkcyjnych.