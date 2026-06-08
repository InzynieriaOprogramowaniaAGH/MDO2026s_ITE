# Sprawozdanie z zajęć 8-11

## *Lab 8:* Automatyzacja i zdalne wykonanie poleceń za pomocą Ansible

### 1. Instalacja zarządcy i przygotowanie węzła docelowego.

W celu automatyzacji uruchomiono drugą maszynę wirtualną o nazwie `ansible-target`. Zainstalowano na niej system operacyjny zgodny z maszyną główną.

Na głównej maszynie zainstalowano pakiet `anisble` z oficjalnego repozytorium oraz przeprowadzoną bezhasłową wymianę kluczy kryptograficznych.

W /etc/hosts dopisano nazwy hostów, tak aby mieć komunikację po nazwach hostów.

![alt text](<lab8/ansible-project/Zrzut ekranu 2026-05-31 184218.png>)

![alt text](<lab8/ansible-project/Zrzut ekranu 2026-05-31 190845.png>)

### 2. Uruchomienie procedur

W katalogu utworzono plik `inventory.ini`, o strukturze:

```ini
[Orchestrators]
olek ansible_connection=local

[Endpoints]
ansible-target ansible_user=olek2
```

Pingowanie poleceniem ansible:

![alt text](<lab8/ansible-project/Zrzut ekranu 2026-05-31 191345.png>)


Napisano plik automatyzujący instalację silnika Docker na maszynie docelowej, tak aby pobierał on wcześniej utworzony obraz kontenera aplikacj Flask.

`site.yml`:
```
---
- name: Uruchomienie pełnego wdrożenia za pomocą roli
  hosts: Endpoints
  become: yes
  roles:
    - app_deploy

```

Wywołanie procedur ansible
![alt text](<lab8/ansible-project/Zrzut ekranu 2026-05-31 194939.png>)

## *Lab 9:* Pliki odpowiedzi dla wdrożeń nienadzorowanych

### 1. Pobranie pliku anaconda-ks.cfg

Celem było pełne zautomatyzowanie procesu instalacji systemu operacyjnego, tak aby serwer był gotowy do hostowania zaraz po starcie. Wykorzystano bazowy plik odpowiedzi anaconda-ks.cfg wygenerowany z instalacji wzorcowej.

![alt text](<lab9/Zrzut ekranu 2026-05-31 203928.png>)

### 2. Automatyzacja poinstalacyjna (%post)

W sekcji %post --log=/root/kickstart-post.log zaimplementowano skrypt, który uruchmia się w końcowej fazie instalacji systemu.
W sekscji %packages dodano instalację pakietu DOcker
W sekcji %post  uruchomiono usługe Docker.

Zaimplementowano mechanizm który przy uruchomieniu systemu maszyna pobiera stabilny obraz aplikacji Flask, wystawia port i uruchamia aplikację.

![alt text](<lab9/Zrzut ekranu 2026-05-31 212758.png>)

![alt text](<lab9/Zrzut ekranu 2026-05-31 221217.png>)

## *Lab 10:* Wdrażanie na zarządzalne kontenery: Kubernetes

### 1. Instalacja klastra Minikube i analiza manualna

Środowisko lokalnego klastra Kubernetes zrealizowano za pomocą narzędzia minikube.

![alt text](<lab10i11/Zrzut ekranu 2026-05-31 222805.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-05-31 224113.png>)

W celach testowych uruchomiono pojedynczy pod z aplikacją.

![alt text](<lab10i11/Zrzut ekranu 2026-05-31 224649.png>)

### 2. Przekucie wdrożenia w plik yaml oraz skalowanie.

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 194013.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 194107.png>)

### 3.Detekcja awarii obrazu i Rollback.

W celach testowych utworzono obraz uszkodzony
![alt text](<lab10i11/Zrzut ekranu 2026-06-02 194302.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 194439.png>)

Weryfikuj.sh:

```
#!/bin/bash
echo "Rozpoczynam weryfikację wdrożenia fastify-deployment..."

# Sprawdzamy stan rolloutu z limitem 60 sekund
minikubctl rollout status deployment/fastify-deployment --timeout=60s

# Sprawdzamy kod wyjścia (exit code) poprzedniego polecenia
if [ $? -eq 0 ]; then
    echo "[SUKCES] Wdrożenie zakończyło się pomyślnie w czasie poniżej 60 sekund!"
    exit 0
else
    echo "[BŁĄD] Wdrożenie przekroczyło limit 60 sekund lub zakończyło się awarią!"
    exit 1
fi
```

### 4. Strategie wdrożeń:

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 195751.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 200002.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 200748.png>)


## *Lab 11:* Skalowanie

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 203635.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 204027.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 204415.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 204631.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 204829.png>)

![alt text](<lab10i11/Zrzut ekranu 2026-06-02 204955.png>)