# Sprawozdanie z laboratoriów 8–11

## Lab 8

**Przygotowanie środowiska i inwentaryzacja**

Na maszynie głównej (`agh-serwer-testowy`) zainstalowano Ansible. Utworzono maszynę `ansible-target` z Ubuntu i użytkownikiem `ansible`, skonfigurowano `/etc/hosts` oraz wymieniono klucze SSH:

```bash
ssh-keygen -t ed25519
ssh-copy-id ansible@ansible-target
```

Plik `inventory.ini`:

```ini
[Orchestrators]
localhost ansible_connection=local

[Endpoints]
ansible-target
```

Test połączenia ping:

![image](Sprawozdanie3/6.png)

**Playbook – podstawowe zadania**

Plik `setup.yml`:

```yaml
- name: Zadania Lab 8
  hosts: Endpoints
  become: true
  tasks:
    - name: Test połączenia ping
      ansible.builtin.ping:

    - name: Aktualizacja pakietów
      ansible.builtin.package:
        name: "*"
        state: latest

    - name: Restart usług
      ansible.builtin.service:
        name: "{{ item }}"
        state: restarted
      loop:
        - sshd
        - rngd
```

Uruchomienie:

```bash
ansible-playbook -i inventory.ini setup.yml
```

Wynik wykonania playbooka:

![image](Sprawozdanie3/9.png)

**Zarządzanie artefaktem – kontener**

Playbook pobiera artefakt z Jenkinsa, kopiuje plik `.deb` do maszyny docelowej, instaluje Dockera, uruchamia kontener i weryfikuje działanie:

```yaml
- name: Pobierz artefakt z kontenera Jenkins
  delegate_to: localhost
  become: false
  ansible.builtin.command:
    cmd: docker cp jenkins-blueocean:/var/jenkins_home/workspace/Lab7/211b-98b.deb /tmp/app.deb

- name: Upewnij się, że Docker jest na targetcie
  ansible.builtin.apt:
    name: docker
    state: present
    update_cache: yes

- name: Wyślij wyciągnięty plik na target
  ansible.builtin.copy:
    src: /tmp/app.deb
    dest: /tmp/app.deb
    mode: '0644'

- name: Uruchom kontener i zainstaluj .deb
  community.docker.docker_container:
    name: moja_aplikacja_kontener
    image: ubuntu:22.04
    state: started
    volumes:
      - "/tmp/app.deb:/tmp/app.deb"
    command: bash -c "apt-get update && apt-get install -y /tmp/app.deb && zlib-tool"

- name: Sanity check – weryfikacja czy kontener działa
  ansible.builtin.assert:
    that:
      - "container_info.container.State.Running"
    fail_msg: "Kontener nie wystartował"
```

Wynik uruchomienia powyższych zadań:

![image](Sprawozdanie3/14.png)

**Stworzenie roli Ansible**

```bash
ansible-galaxy role init moja_aplikacja
```

![image](Sprawozdanie3/12.png)

Wypełniono strukturę roli zadaniami i meta/main.yml.

---

## Lab 9

**Przygotowanie pliku Kickstart**

Plik `fedora-ks.cfg`:

```cfg
text
eula --agreed

url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64
repo --name=update --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64

clearpart --all --initlabel
autopart --type=lvm

network --bootproto=dhcp --device=link --activate
network --hostname=agh-serwer-testowy

rootpw --plaintext admin123
user --name=oskar --password=devops --groups=wheel

timezone Europe/Warsaw
keyboard --vckeymap=pl --xlayouts='pl'
lang pl_PL.UTF-8

reboot

%packages
@core
docker
curl
wget
%end

%post
# Pobranie artefaktu z serwera Pythona
wget http://172.23.08.1:8000/app.deb -O /tmp/app.deb

# Uruchomienie kontenera Ubuntu, instalacja paczki i odpalenie zlib-tool
docker run -v /tmp/app.deb:/tmp/app.deb ubuntu:22.04 bash -c "apt-get update && apt-get install -y /tmp/app.deb && zlib-tool"

# Dodanie usługi systemd do automatycznego uruchamiania po restarcie
cat > /etc/systemd/system/uruchom-aplikacje.service << EOF
[Unit]
Description=Uruchomienie aplikacji po starcie systemu

[Service]
Type=oneshot
ExecStart=/usr/bin/docker run -v /tmp/app.deb:/tmp/app.deb ubuntu:22.04 bash -c "apt-get update && apt-get install -y /tmp/app.deb && zlib-tool"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable uruchom-aplikacje.service
echo "Konfiguracja post zakończona."
chvt 1
%end
```

**Przeprowadzenie instalacji**

Maszynę wirtualną UEFI uruchomiono z Fedora Everything Netinst ISO. W boot menu dodano parametr:

```
inst.ks=http://172.23.08.1:8000/fedora-ks.cfg
```

![image](Sprawozdanie3/15%20lab9.png)
![image](Sprawozdanie3/17.png)
![image](Sprawozdanie3/18.png)
![image](Sprawozdanie3/19.png)



Instalacja przebiegła w pełni automatycznie. Po zakończeniu system uruchomił się ponownie, a na ekranie widoczne były logi z działania skryptu.
![image](Sprawozdanie3/20.png)
![image](Sprawozdanie3/21.png)



---

## Sprawozdanie z laboratorium 10

#### Krok 1: Weryfikacja konfiguracji sieciowej i SSH 


![image](Sprawozdanie3/22%20lab10.png)

#### Krok 2: Uruchomienie Minikube

Na zdjęciu widać wykonanie polecenia:

```bash
minikube start --cpus=2 --memory=2048 --driver=docker
```

Minikube uruchamia klaster Kubernetes z określonymi zasobami (2 CPU, 2048 MB RAM) przy użyciu sterownika Docker. Widoczne są komunikaty systemowe, w tym ostrzeżenie o alokacji pamięci pozostawiającej niewielki margines dla systemu.

![image](Sprawozdanie3/23.png)

#### Krok 3: Sprawdzenie stanu węzłów klastra

Po uruchomieniu klastra wykonano:

```bash
kubectl get nodes
```

Wynik pokazuje jeden węzeł `minikube` w stanie `Ready`, z rolą `control-plane` i wersją Kubernetesa `v1.35.1`. Oznacza to, że klaster jest gotowy do pracy.

![image](Sprawozdanie3/24.png)

#### Krok 4: Uruchomienie Dashboardu

```bash
minikube dashboard
```

Polecenie otwiera panel zarządzania klastrem w przeglądarce. Widok Dashboardu jest pusty (brak zasobów), co jest prawidłowe po czystej instalacji.

![image](Sprawozdanie3/25.png)

#### Krok 5: Budowa obrazu Docker wersji v1 

```bash
sudo docker build -t oskar-nginx:v1 .
```

Proces budowy obrazu bazującego na `nginx:alpine`. 
![image](Sprawozdanie3/26.png)

#### Krok 6: Test lokalny obrazu v1

```bash
sudo docker run -d --name lab10-web -p 8888:8888 oskar-nginx:v1
```

Kontener uruchomiony w tle. Widoczny identyfikator kontenera.

![image](Sprawozdanie3/27.png)

#### Krok 7: Weryfikacja działania kontenera

![image](Sprawozdanie3/28.png)
#### Krok 8: Strona dostępna w przeglądarce

W przeglądarce wyświetla się strona z napisem `[ KONTENER AKTYWNY ]`. Potwierdza to poprawne działanie kontenera z własną konfiguracją Nginx na porcie 8888.

![image](Sprawozdanie3/29.png)

#### Krok 9: Eksport obrazu i wczytanie do Minikube

```bash
sudo docker save oskar-nginx:v1 -o oskar-nginx.tar
minikube image load oskar-nginx.tar
```

Obraz zostaje zapisany do pliku `.tar`, a następnie wczytany do środowiska Minikube, aby był dostępny dla klastra.

![image](Sprawozdanie3/30.png)

#### Krok 10: Sprawdzenie obrazów w Minikube

```bash
docker images | grep oskar
```

Przełączenie się na terminal wewnątrz minikube i zbudowanie tam obrazu v1

![image](Sprawozdanie3/31.png)

#### Krok 11: Ręczne uruchomienie Poda

```bash
kubectl run oskar-web-pod --image=oskar-nginx:v1 --port=8888 --labels app=oskar-web-pod
```

Polecenie tworzy pojedynczy Pod z obrazem `v1`, eksponując port 8888 i dodając etykietę.

![image](Sprawozdanie3/32.png)

#### Krok 12: Sprawdzenie statusu Poda

```bash
kubectl get pods
```

Pod `oskar-web-pod` jest w stanie `Running` od 47 sekund. Weryfikacja poprawności uruchomienia.

![image](Sprawozdanie3/33.png)

#### Krok 13: Dashboard Kubernetesa

Widok Dashboardu pokazuje pojedynczy Pod uruchomiony w domyślnym namespace. Potwierdza to, że Pod jest widoczny w interfejsie graficznym.

![image](Sprawozdanie3/34.png)

#### Krok 14: Wdrożenie Deploymentu z 4 replikami

```bash
kubectl apply -f deployment.yaml
```

Deployment `oskar-web-deployment` został utworzony. Wcześniej przygotowany plik YAML definiował 4 repliki.

![image](Sprawozdanie3/35.png)

#### Krok 15: Sprawdzenie Deploymentu

```bash
kubectl get deployments
```

Wdrożenie `oskar-web-deployment` ma 4/4 replik gotowych, co oznacza poprawne uruchomienie wszystkich podów.

![image](Sprawozdanie3/36.png)

#### Krok 16: Port-forward do Poda

```bash
kubectl port-forward pod/oskar-web-pod 8888:8888 --address 0.0.0.0
```

Przekierowanie ruchu z portu 8888 na hoście na port 8888 w Podzie. Widać komunikaty o nawiązywaniu połączeń.

![image](Sprawozdanie3/37.png)

#### Krok 17: Sprawdzenie statusu rollout

```bash
kubectl rollout status deployment/oskar-web-deployment
```

Komenda potwierdza, że wdrożenie "successfully rolled out". Wszystkie repliki są aktualne.

![image](Sprawozdanie3/38.png)

#### Krok 18: Lista podów po wdrożeniu

```bash
kubectl get pods
```

Widoczne są 4 pody z deploymentu (`oskar-web-deployment-...`) oraz osobny pod `oskar-web-pod`. Wszystkie w stanie `Running`.

![image](Sprawozdanie3/39.png)

#### Krok 19: Eksponowanie Deploymentu jako Service

```bash
kubectl expose deployment oskar-web-deployment --type=ClusterIP --port=8888 --name=oskar-web-service
```

Tworzy Service typu `ClusterIP` dla deploymentu, udostępniając go wewnątrz klastra na porcie 8888.

![image](Sprawozdanie3/40.png)

#### Krok 20: Sprawdzenie Service


Service `oskar-web-service` został utworzony.

![image](Sprawozdanie3/41.png)

#### Krok 21: Budowa obrazu wersji v2

```bash
docker build -t oskar-nginx:v2 .
```

Budowa zaktualizowanej wersji obrazu.

![image](Sprawozdanie3/42.png)

#### Krok 22: Budowa obrazu "broken"

```bash
docker build -t oskar-nginx:broken -f Dockerfile.broken .
```

Obraz, który po uruchomieniu kończy pracę z błędem. Komenda `CMD` wypisująca "KRYTYCZNY BŁĄD: Aplikacja zepsuta!" i kończąca się `exit 1`.
```bash
Dockerfile.broken:

FROM oskar-nginx:v1

CMD ["/bin/sh", "-c", "echo 'KRYTYCZNY BLAD: Aplikacja zepsuta!' && exit 1"]
```
![image](Sprawozdanie3/43.png)

#### Krok 23: Lista obrazów Docker na hoście

```bash
docker images | grep oskar
```

Widoczne obrazy: `oskar-nginx:v1`, `oskar-nginx:v2`, `oskar-nginx:broken`.

![image](Sprawozdanie3/44.png)

#### Krok 24: Wczytanie obrazu v2 do Minikube

```bash
minikube image load oskar-nginx:v2
```

Obraz `v2` zostaje załadowany do środowiska Minikube.

![image](Sprawozdanie3/45.png)

#### Krok 25: Skalowanie do 8 replik

```bash
sed -i 's/replicas:./replicas: 8/' deployment.yaml
kubectl apply -f deployment.yaml
```

Plik YAML jest edytowany, a następnie zastosowany. Liczba replik zmienia się z 4 na 8.

![image](Sprawozdanie3/46.png)

#### Krok 26: Sprawdzenie podów po skalowaniu

```bash
kubectl get pods
```

Widać 8 podów z nowego deploymentu (te z nazwą zawierającą `7b779b9b74`), a także stary pod `oskar-web-pod`.

![image](Sprawozdanie3/47.png)

#### Krok 27: Skalowanie do 0 replik

```bash
sed -i 's/replicas:./replicas: 0/' deployment.yaml
kubectl apply -f deployment.yaml
```

Liczba replik zostaje zredukowana do 0. Wszystkie pody z deploymentu przechodzą w stan `Terminating`.

![image](Sprawozdanie3/48.png)

#### Krok 28: Skalowanie do 4 replik

```bash
sed -i 's/replicas:./replicas: 4/' deployment.yaml
kubectl apply -f deployment.yaml
```

Przywrócenie 4 replik. Pody są tworzone na nowo.

![image](Sprawozdanie3/49.png)

#### Krok 29: Zmiana wersji obrazu na v2

```bash
sed -i 's/image: oskar-nginx:.*/image: oskar-nginx:v2/' deployment.yaml
kubectl apply -f deployment.yaml
```

Aktualizacja obrazu z `v1` na `v2`. Wdrożenie jest ponownie konfigurowane.

![image](Sprawozdanie3/50.png)

#### Krok 30: Status podów po aktualizacji

```bash
kubectl get pods
```

Widoczne pody z obrazem `v2` (nazwy zawierają `bcc648489`). Wszystkie w stanie `Running`.

![image](Sprawozdanie3/51.png)

#### Krok 31: Test wadliwego obrazu

```bash
sed -i 's/image: oskar-nginx:v2/image: oskar-nginx:broken/' deployment.yaml
kubectl apply -f deployment.yaml
```

Obraz `broken` zostaje zastosowany. Widoczne są komunikaty o błędach.

![image](Sprawozdanie3/52.png)

#### Krok 32: Status podów po wdrożeniu wadliwego obrazu

```bash
kubectl get pods
```

Pody z obrazem `broken` (nazwy `bcc648489-...`) są w stanie `ContainerCreating`, ale wkrótce przejdą w `Error`.

![image](Sprawozdanie3/53.png)

#### Krok 33: Pody w stanie błędu

```bash
kubectl get pods
```

Pody z obrazem `broken` (nazwy `6ddb64574-...`) są w stanie `Error`. Pojawiają się restarty (2 restarty w ciągu 28 sekund). To typowe zachowanie dla kontenera, który kończy pracę z błędem – Kubernetes próbuje go ponownie uruchomić.

![image](Sprawozdanie3/54.png)

#### Krok 34: Historia wdrożeń

```bash
kubectl rollout history deployment/oskar-web-deployment
```

Wyświetla historię zmian. Widoczne rewizje od 2 do 4. Brak adnotacji `CHANGE-CAUSE` (domyślnie `<none>`).

![image](Sprawozdanie3/55.png)

#### Krok 35: Rollback do wersji 2

```bash
kubectl rollout undo deployment/oskar-web-deployment --to-revision=2
```

Przywracamy wdrożenie do rewizji nr 2. Komenda potwierdza pomyślny rollback.

![image](Sprawozdanie3/56.png)

#### Krok 36: Status podów po rollbacku

```bash
kubectl get pods
```

Pody wróciły do stanu `Running`. Widać 4 pody z nazwami zawierającymi `7b779b9b74`. Rollback przywrócił stabilną wersję.

![image](Sprawozdanie3/57.png)

#### Krok 37: Wdrożenie strategii Recreate

```bash
kubectl apply -f deploy-recreate.yaml
```

Plik `deploy-recreate.yaml` definiuje strategię `Recreate`. Wdrożenie zostało skonfigurowane. Widoczne pody w stanie `Running`.

![image](Sprawozdanie3/58.png)

#### Krok 38: Wdrożenie strategii Rolling Update

```bash
kubectl apply -f deploy-rolling.yaml
```

Plik `deploy-rolling.yaml` definiuje strategię `RollingUpdate` z parametrami `maxUnavailable: 2` i `maxSurge: 25%`. Wdrożenie zakończone pomyślnie.

![image](Sprawozdanie3/59.png)

#### Krok 39: Usunięcie deploymentu oraz zastosowanie metody kanarkowej

```bash
kubectl delete deployment oskar-web-deployment
```

Usunięcie wdrożenia i wszystkich podów. Komenda potwierdza, że deployment został skasowany oraz zastosowana zostałą metoda kanarkowa.

![image](Sprawozdanie3/60.png)

#### Krok 40: Sprawdzanie działania kanarkowej metody.

Aby zaimplementować strategię Canary, przygotowano dwa pliki YAML: `deploy-canary-test.yaml` (1 replika z etykietą `track: canary`) oraz `deploy-canary-stable.yaml` (3 repliki z etykietą `track: stable`).

**Plik `deploy-canary-test.yaml` (wersja testowa/canary):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oskar-web-canary
  labels:
    app: oskar-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: oskar-web
      track: canary
  template:
    metadata:
      labels:
        app: oskar-web
        track: canary
    spec:
      containers:
      - name: nginx-container
        image: oskar-nginx:v2
        imagePullPolicy: Never
        ports:
        - containerPort: 8888
```

**Plik `deploy-canary-stable.yaml` (wersja stabilna):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oskar-web-stable
  labels:
    app: oskar-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: oskar-web
      track: stable
  template:
    metadata:
      labels:
        app: oskar-web
        track: stable
    spec:
      containers:
      - name: nginx-container
        image: oskar-nginx:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 8888
```

Obydwa wdrożenia zastosowano poleceniem:

```bash
kubectl apply -f deploy-canary-stable.yaml
kubectl apply -f deploy-canary-test.yaml
```

Po ich wdrożeniu uruchomiono polecenie `kubectl get pods --show-labels`, aby potwierdzić, że pody mają przypisane odpowiednie etykiety `track=canary` oraz `track=stable`.


- **Recreate** – pody są usuwane i tworzone od nowa.
- **Rolling Update** – pody są wymieniane stopniowo.
- **Canary** – umożliwia testowanie nowej wersji na małej liczbie podów obok stabilnej wersji. Etykiety `track: canary` i `track: stable` pozwalają na selektywne kierowanie ruchu.


![image](Sprawozdanie3/61.png)
Zauważamy załadowane czściowe wersji v2. Jest to dowód działania kanarkowej metody.

## Lab 11

#### Krok 1: Wdrożenie masywnego deploymentu (36 replik)

Pierwszym zadaniem było wdrożenie serwera web z dużą liczbą podów. W tym celu przygotowano plik `lab11-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oskar-massive-web
  labels:
    app: oskar-web
spec:
  replicas: 36
  selector:
    matchLabels:
      app: oskar-web
  template:
    metadata:
      labels:
        app: oskar-web
    spec:
      containers:
      - name: nginx-container
        image: oskar-nginx:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 8888
```

Wdrożenie wykonano poleceniem:

```bash
kubectl apply -f lab11-deployment.yaml
```

![image](Sprawozdanie3/62%20lab11.png)

#### Krok 2: Status podów po wdrożeniu

Po chwili sprawdzono stan podów – wszystkie 36 podów znajdowało się w stanie `ContainerCreating`. Był to efekt pobierania obrazów i uruchamiania kontenerów na klastrze.

```bash
kubectl get pods -w
```

#### Krok 3: Port-forward do masywnego deploymentu

Aby przetestować dostęp do aplikacji, wykonano port-forward z deploymentu na port 8882 na hoście:

```bash
kubectl port-forward deployment/oskar-massive-web 8882:8888 --address 0.0.0.0
```

![image](Sprawozdanie3/65.png)

#### Krok 4: Weryfikacja działania strony

Po przekierowaniu portu otworzono w przeglądarce adres `http://localhost:8882`. Strona wyświetlała treść `[ KONTENER AKTYWNY ]`. Potwierdziło to poprawne działanie serwera Nginx z własną konfiguracją na porcie 8888.

![image](Sprawozdanie3/64.png)

#### Krok 5: Eksponowanie deploymentu jako Service

Aby udostępnić wdrożenie wewnątrz klastra, utworzono Service typu `ClusterIP`:

```bash
kubectl expose deployment oskar-massive-web --type=ClusterIP --port=8888 --name=oskar-service-c11
```

![image](Sprawozdanie3/67.png)

#### Krok 6: Port-forward do serwisu (część 1)

Przekierowano ruch z serwisu na port 8883 na hoście:

```bash
kubectl port-forward svc/oskar-service-c11 8883:8888 --address 0.0.0.0
```

#### Krok 7: Weryfikacja działania przez serwis

Ponownie otworzono przeglądarkę – strona `[ KONTENER AKTYWNY ]` była dostępna pod adresem `http://localhost:8883`. Oznacza to, że Service poprawnie kieruje ruch do jednego z podów deploymentu.

![image](Sprawozdanie3/68.png)

#### Krok 8: Alternatywny port-forward do serwisu

Wykonano także przekierowanie na port 8884 (przykład dla różnych portów):

```bash
kubectl port-forward svc/oskar-service-c11 8884:8888 --address 0.0.0.0
```

![image](Sprawozdanie3/70.png)
![image](Sprawozdanie3/71.png)


#### Krok 9: Skalowanie przez `scale`

Zwiększono liczbę replik z 36 na 10 (operacja skalowania w dół, aby zmniejszyć obciążenie klastra):

```bash
kubectl scale deployment oskar-massive-web --replicas=10
```

![image](Sprawozdanie3/72.png)

#### Krok 10: Porównanie plików YAML

Aby zobaczyć różnicę między oryginalnym plikiem `lab11-deployment.yaml` a nowym `lab11-deployment-scaled.yaml` (z 5 replikami), wykonano polecenie `diff`:

```bash
diff lab11-deployment.yaml lab11-deployment-scaled.yaml
```

![image](Sprawozdanie3/73.png)

Różnica widoczna w linii `replicas: 5` wobec `replicas: 36` w oryginalnym pliku.

#### Krok 11: Sprawdzenie podów po skalowaniu

Po wykonaniu `scale` sprawdzono listę podów – część z nich znalazła się w stanie `Terminating` (usuwane), a część pozostała `Running`.

```bash
kubectl get pods
```

![image](Sprawozdanie3/74.png)

Po wykonaniu skalowania ruch z serwisu `oskar-service-c11` jest kierowany przez Kubernetes do różnych podów. Aby sprawdzić, który konkretny Pod obsłużył dane żądanie HTTP, wykonano następujące czynności:

1. **Wysłanie testowego żądania** – na porcie `8084` wykonano zapytanie do ścieżki `/oskar-test` (celowo nieistniejącej), aby wywołać błąd 404 i zarejestrować żądanie w logach:
   
   ```
   http://localhost:8084/oskar-test
   ```

   W rezultacie w przeglądarce pojawił się błąd **404 Not Found**:

   ![image](Sprawozdanie3/76.png)

2. **Analiza logów** – sprawdzono logi wszystkich podów z etykietą `app=oskar-web`, filtrując pod kątem zapytania `oskar-test`:

   ```bash
   kubectl logs -l app=oskar-web --prefix | grep "oskar-test"
   ```

   Wynik wskazał konkretnego Poda, który obsłużył to żądanie:

   ![image](Sprawozdanie3/75.png)

   W logach widoczne jest:

   ```
   [pod/oskar-massive-web-7b779b9b74-r69bx/nginx-container] 2026/06/09 19:32:42 [error] 20#20: *11 open() "/usr/share/nginx/html/oskar-test" failed (2: No such file or directory), client: 127.0.0.1, server: localhost, request: "GET /oskar-test HTTP/1.1", host: "localhost:8084"
   ```

   Oznacza to, że żądanie `/oskar-test` trafiło do Poda **`oskar-massive-web-7b779b9b74-r69bx`**. Dzięki temu możliwe jest jednoznaczne określenie, który Pod przetworzył zapytanie po przeskalowaniu.
