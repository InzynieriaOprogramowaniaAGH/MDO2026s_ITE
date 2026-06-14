# SPRAWOZDANIE Z LABORATORIÓW 8-11
**Przedmiot:** DevOps
**Grupa:** 3

---

## Laboratorium 08: Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

### 1. Instalacja zarządcy i przygotowanie węzła docelowego
W celu realizacji środowiska automatyzacji uruchomiono drugą, minimalistyczną maszynę wirtualną o nazwie sieciowej `ansible-target`. Zainstalowano na niej czysty system operacyjny zgodny z maszyną główną, 
ograniczając pakiety do niezbędnego minimum (serwer OpenSSH oraz pakiet `tar`). Utworzono dedykowanego użytkownika systemowego `ansible`.

Na maszynie głównej zainstalowano pakiet `ansible` z oficjalnego repozytorium dystrybucji. Przeprowadzono bezhasłową wymianę kluczy kryptograficznych SSH za pomocą polecenia `ssh-copy-id ansible@ansible-target`,
co pozwoliło na autoryzację kluczem publicznym i zabezpieczyło sesję przed monitem o hasło.

<img width="1121" height="752" alt="image" src="https://github.com/user-attachments/assets/8ae43e1a-6188-44f0-a5d8-7b11434d31b8" />
<img width="659" height="352" alt="image" src="https://github.com/user-attachments/assets/7fba6284-8a9f-459e-a6d7-cb3ce89e4e9b" />


### 2. Inwentaryzacja systemów
W pliku `/etc/hosts` na maszynie kontrolera przypisano adres IP maszyny docelowej do nazwy DNS `ansible-target`, unikając stosowania podatnych na błędy adresów pętli zwrotnej (`localhost`). W katalogu projektu utworzono plik inwentaryzacji `inventory.ini` o następującej strukturze logicznej:

```ini
[Orchestrators]
ansible-manager ansible_connection=local

[Endpoints]
ansible-target ansible_host=ansible-target ansible_user=ansible
```

Łączność ze wszystkimi zdefiniowanymi węzłami zweryfikowano za pomocą polecenia systemu Ansible:

<img width="821" height="279" alt="image" src="https://github.com/user-attachments/assets/9a77fd3a-3462-4183-b7f5-a6aa14f4af05" />

### 2. Zdalne wywoływanie procedur
Napisano automatyzację instalacji silnika Docker na maszynie docelowej bezpośrednio z poziomu playbooka Ansible. Po upewnieniu się, że demon Dockera działa,
zaimplementowano kroki pobierające zbudowany wcześniej obraz kontenera z aplikacji Fastify (będący artefaktem z potoku CI/CD) i uruchomiono go na maszynie docelowej z mapowaniem portów.
`site.yml`:
```
---
- name: Uruchomienie pełnego wdrożenia za pomocą roli
  hosts: Endpoints
  become: yes
  roles:
    - app_deploy
```

<img width="1618" height="938" alt="image" src="https://github.com/user-attachments/assets/723f8629-cf02-4a64-a6dc-4f85dd3f6fb5" />

Całość logiki wdrożeniowej ustrukturyzowano w reużywalną rolę Ansible przy użyciu narzędzia szkieletowania:
```ansible-galaxy role init deploy_app```

---
## Laboratorium 09: Pliki odpowiedzi dla wdrożeń nienadzorowanych

### 1. Konfiguracja automatycznej instalacji UEFI

Celem zadania było pełne zautomatyzowanie procesu instalacji systemu operacyjnego Fedora Server (architektura UEFI), tak aby system był gotowy do hostowania aplikacji natychmiast po starcie,
bez interwencji człowieka. Wykorzystano bazowy plik odpowiedzi `anaconda-ks.cfg` wygenerowany z instalacji wzorcowej.

<img width="1278" height="861" alt="image" src="https://github.com/user-attachments/assets/d377fa2e-57c9-47bc-b51e-3df8f69e479e" />


Modyfikacja pliku Kickstart objęła kluczowe dyrektywy:

* Zdefiniowanie zewnętrznych repozytoriów sieciowych;

* Wymuszenie automatycznego czyszczenia tabeli partycji i formatowania dysków;

* Automatyczną konfigurację sieci, nazwy hosta oraz utworzenie konta użytkownika;

* Dodanie flagi reboot na końcu pliku, zapobiegającej zawieszeniu instalatora;

### 2. Automatyzacja post-instalacyjna (%post)

W sekcji %post --log=/root/ks-post.log zaimplementowano skrypt powłoki uruchamiany w końcowej fazie instalacji systemu. Ponieważ polecenia sieciowe Dockera nie mogą zostać w pełni wykonane wewnątrz
środowiska chroot instalatora, zastosowano podejście dwuetapowe:

* W sekcji %packages nakazano instalację zależności oraz pakietu moby-engine (Docker).

* W sekcji %post aktywowano usługę komendą systemctl enable docker.

Zaimplementowano mechanizm, który przy pierwszym uruchomieniu fizycznego systemu pobiera stabilny obraz kontenera z aplikacji Fastify, wystawia port 3000 i uruchamia usługę.

<img width="1048" height="819" alt="image" src="https://github.com/user-attachments/assets/79259842-c314-4b5a-b636-acae61117c1d" />

<img width="1072" height="619" alt="image" src="https://github.com/user-attachments/assets/3fadbe7c-0f09-4dcb-a909-5db6461973f9" />

Podczas testu maszyna wirtualna uruchomiona z obrazu ISO przeszła cały proces bezdotykowo,
automatycznie czyszcząc nośnik i podnosząc aplikację Fastify po restarcie.

## Laboratorium 10: Wdrażanie na zarządzalne kontenery: Kubernetes

### 1. Instalacja klastra Minikube i analiza manualna
Środowisko lokalnego klastra Kubernetes zrealizowano za pomocą narzędzia minikube. Skonfigurowano alias minikubctl mapujący komendy do wbudowanego binaru kubectl. 
W celu optymalizacji i mitygacji ograniczeń sprzętowych maszyny gospodarza (brak pamięci RAM), dostosowano parametry startowe klastra, ograniczając alokację zasobów, 
a zbędne pakiety Dockera zostały uprzednio wyczyszczone.

```minikube start --cpus=2 --memory=2048mb --driver=docker```
<img width="1044" height="338" alt="image" src="https://github.com/user-attachments/assets/144b1346-a7fc-4a57-9c1d-1776037c6105" />
<img width="1859" height="889" alt="image" src="https://github.com/user-attachments/assets/6e709489-5bd6-4b48-9e7c-9bb4bff1f04f" />

W celach testowych uruchomiono pojedynczy pod z aplikacją komendą imperatywną, a komunikację zewnętrzną zweryfikowano poprzez tunelowanie portów komendą kubectl port-forward.
<img width="650" height="300" alt="image" src="https://github.com/user-attachments/assets/9e5c210a-f26c-4d9c-b842-9f64760a9693" />
<img width="1414" height="972" alt="image" src="https://github.com/user-attachments/assets/8e2dfb1e-fc4e-44d6-9b67-bee057bbd533" />


### 2. Przekucie wdrożenia w plik YAML i skalowanie

Utworzono plik konfiguracyjny deployment.yaml. Zadeklarowano w nim architekturę opartą na 4 replikach kontenera aplikacyjnego Fastify z polityką pobierania
obrazu ustawioną na Never (korzystanie z lokalnego cache minikube).
<img width="1366" height="950" alt="image" src="https://github.com/user-attachments/assets/00458cbf-9240-4ae7-adef-ecb03b5b68f7" />
<img width="1816" height="751" alt="image" src="https://github.com/user-attachments/assets/31449d3c-015a-4d34-a4fe-b4eb16102e13" />
Przetestowano elastyczność klastra, manipulując liczbą replik w locie poprzez komendy aktualizacji pliku YAML (sekwencyjnie: zwiększenie do 8 podów, 
redukcja do 1, całkowite wygaszenie do 0, ponowne podniesienie do 4).
<img width="1128" height="915" alt="image" src="https://github.com/user-attachments/assets/06a28d3e-7770-42a1-bdf0-ca731c81dcd2" />

### 3. Detekcja awarii obrazu i Rollback

Do celów testowych przygotowano uszkodzony obraz aplikacji oznaczony tagiem v2 (zdefiniowany w pliku Dockerfile.bad), którego proces główny 
natychmiast kończył się kodem błędu (process.exit(1)). Podmieniono obraz w działającym wdrożeniu. Wskutek zaaplikowania wadliwego obrazu, Kubernetes
zarejestrował pętlę awarii, a pody przyjęły status Error. Dokonano inspekcji historii wdrożenia, po czym przywrócono stabilną infrastrukturę przy użyciu mechanizmu cofania zmian:
```
kubectl rollout history deployment/fastify-deployment
kubectl rollout undo deployment/fastify-deployment
```
System automatycznie przywrócił działanie podów z wersją obrazu v1.
<img width="1164" height="690" alt="image" src="https://github.com/user-attachments/assets/12868090-1026-4799-b2e8-5c929f2eebe1" />
### 4. Skrypt automatycznej kontroli wdrożenia
Napisano skrypt w Bashu weryfikuj.sh z limitem czasu, sprawdzający poprawność wdrożenia aplikacji:
```
#!/bin/bash
echo "Rozpoczynam weryfikację wdrożenia fastify-deployment..."

kubectl rollout status deployment/fastify-deployment --timeout=60s

if [ $? -eq 0 ]; then
    echo "[SUKCES] Wdrożenie zakończyło się pomyślnie w czasie poniżej 60 sekund!"
    exit 0
else
    echo "[BŁĄD] Wdrożenie przekroczyło limit 60 sekund lub zakończyło się awarią!"
    exit 1
fi
```
### 5. Strategie wdrożeń 
Przygotowano trzy niezależne manifesty konfigurujące odmienne podejścia do aktualizacji oprogramowania:

* Recreate (deployment-recreate.yaml);

* Rolling Update (deployment-rolling.yaml);

* Canary Deployment (deployment-canary.yaml + canary-service.yaml);


#### Strategia Recreate:
<img width="1136" height="661" alt="image" src="https://github.com/user-attachments/assets/fbff746f-8175-4fc6-a289-1ae576ddc928" />
Wszystkie 4 dotychczasowe pody natychmiast otrzymały status Terminating (zamykanie). Przez kilka sekund liczba działających podów wynosiła dokładnie 0. Dopiero po całkowitym usunięciu starych kontenerów,
Kubernetes zaczął uruchamiać 4 nowe pody. 
**Wniosek:** Strategia drastyczna, powodująca przerwę w dostępności usługi, ale gwarantująca, że dwie różne wersje aplikacji nigdy nie działają w tym samym momencie.

#### Strategia Rolling Update:
<img width="1157" height="433" alt="image" src="https://github.com/user-attachments/assets/0e6d2713-a7f1-4bea-b678-be6f6d5989fe" />
Klaster nie wyłączył aplikacji. Widoczne było uruchamianie nowej partii podów przy jednoczesnym utrzymaniu części starych. W szczytowym momencie na liście znajdowało się więcej podów niż 
zadeklarowane 4 repliki. Pody były wymieniane płynnie.
**Wniosek:** Strategia zapewnia brak przestoju. Użytkownik końcowy cały czas ma dostęp do aplikacji podczas wdrożenia nowej wersji.

#### Canary Deployment
<img width="1148" height="481" alt="image" src="https://github.com/user-attachments/assets/100f5e61-84b7-4b51-9746-0cd26ee165f5" />
Ruch przychodzący na serwis fastify-canary-service jest automatycznie rozdzielany pomiędzy pody z etykietą role: frontend. Ponieważ kanarek stanowi małą część puli, nowa wersja testowana
jest bezpiecznie na małej grupie zapytań. W razie błędu kanarka, usuwa się tylko jedno małe wdrożenie, nie niszcząc głównej produkcji.
**Wniosek:** Strategia idealna do testowania ryzykownych aktualizacji bezpośrednio na użytkownikach bez przerywania stabilnej usługi.

## Laboratorium 11: Wdrażanie na zarządzalne kontenery: Kubernetes - Eksponowanie i Skalowanie
### 1. Masowe wdrożenie
Napisano deklaratywny manifest mass-deployment.yaml generujący w klastrze masową strukturę 36 replik aplikacji Fastify. Wszystkie kontenery zostały pomyślnie zaplanowane i uruchomione
w przestrzeni nazw klastra Minikube.
<img width="1411" height="1038" alt="image" src="https://github.com/user-attachments/assets/623eb362-5008-4ff2-b3fd-ca4340b7fec4" />
### 2. Trzy metody eksponowania usług sieciowych
Zrealizowano i przetestowano trzy metody uzyskania dostępu do uruchomionego serwera:

* Metoda A (Do jednego poda): Wykorzystano bezpośrednie przekierowanie warstwy aplikacyjnej komendą kubectl port-forward pod/<nazwa_poda> 8082:3000. Ruch trafiał bez pośredników do pojedynczego kontenera.

* Metoda B (Do deploymentu poleceniem imperatywnym): Wykonano komendę kubectl expose deployment fastify-mass-deployment --type=NodePort --name=service-via-cmd --port=3000. Kubernetes automatycznie
wygenerował obiekt Service z losowo przydzielonym portem zewnętrznym z puli wysokich portów.

* Metoda C (Do serwisu dodatkowym plikiem YAML): Stworzono dedykowany plik manifestu sieciowego mass-service.yaml mapujący selektorem ruch do podów. Podejście deklaratywne pozwoliło na sztywno
wymusić stały port zewnętrzny 32000 (NodePort).

Dostęp do jednego poda:
<img width="1231" height="433" alt="image" src="https://github.com/user-attachments/assets/c419d0d4-5978-4dcf-934a-638b6eb6e5d9" />

Dostęp do deploymentu:
<img width="752" height="582" alt="image" src="https://github.com/user-attachments/assets/b6e3f3f1-e338-442a-9508-988b87a8fd3d" />

Dostęp do serwisu:

<img width="750" height="591" alt="image" src="https://github.com/user-attachments/assets/5f53378c-2554-4f4e-89d7-8f474a155e1d" />

### 3. Przeskalowanie wdrożenia i analiza różnic w plikach konfiguracyjnych
Dokonano redukcji skali wdrożenia z 36 podów do mniejszej wartości dwoma sposobami:

* Imperatywnie: Poleceniem kubectl scale deployment fastify-mass-deployment --replicas=10.

* Deklaratywnie: Poprzez przygotowanie pliku mass-deployment-scaled.yaml z wartością replicas: 5 i zaaplikowanie go za pomocą kubectl apply.

<img width="856" height="730" alt="image" src="https://github.com/user-attachments/assets/833f3f57-c15f-48c2-baa0-0092e51ea5c5" />

<img width="1062" height="345" alt="image" src="https://github.com/user-attachments/assets/fea9f8fc-47ab-4407-9f62-5a3d7b84028e" />

W celu jednoznacznego wykazania różnic w podejściach konfiguracyjnych wykorzystano systemowe narzędzie porównywania plików:

<img width="1075" height="142" alt="image" src="https://github.com/user-attachments/assets/ba09fc3d-f5ab-460d-869c-d99fd17deac2" />

### 4. Zadanie Bonusowe: Weryfikacja Load Balancingu przez logi Fastify
W celu sprawdzenia, do których podów trafia ruch sieciowy po przeskalowaniu do 5 replik, uruchomiono ciągły nasłuch logów ze wszystkich instancji jednocześnie.
Z poziomu drugiego okna konsoli wygenerowano serię zapytań testowych przy użyciu narzędzia curl uderzających w adres serwisu na porcie 32000.
<img width="1221" height="421" alt="image" src="https://github.com/user-attachments/assets/bd502ac1-6b13-442a-89e0-b86831f30178" />
W tym wypadku curla obsłużył pod `fastify-mass-deployment-6d55757df8-mxxxl`.
