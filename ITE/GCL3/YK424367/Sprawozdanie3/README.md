# Sprawozdanie 3 (zajęcia 8-11)

Celem zajęć 8-11 było zaznajomienie się z Ansible, kickstartem systemu na maszynie wirtualnej, orkiestracją kontenerów w Kubernetes. Artefaktem jest **readme-aura** (paczka NPM `.tgz`) - wdrożyłem ją przez Ansible i kickstart Fedory. Do laboratorium kubernetes wybrałem **nginx**, bo readme-aura to narzędzie CLI bez serwera HTTP i nie nadaje się na sensowny Deployment.

---

## Zajęcia 08 - Ansible

### Środowisko

Na głównej maszynie (`myserver`) zainstalowałem Ansible z repozytorium Ubuntu. Druga maszyna wirtualna dostała hostname `ansible-target`, użytkownika `ansible` i OpenSSH. Wymieniłem klucze SSH tak, że logowanie `ssh ansible@ansible-target` nie wymaga hasła.

Nazwy ustawiłem przez `hostnamectl`, wpisy w `/etc/hosts` i `systemd-resolved`, żeby maszyny były dostępne po nazwie a nie tylko po IP:

```bash
hostname
# myserver

ssh ansible@ansible-target hostname
# ansible-target

getent hosts ansible-target
# 192.168.2.3     ansible-target

ping -c 3 ansible-target
# 0% packet loss
```

Plik inwentaryzacji `~/ansible/inventory.ini`:

```ini
[Orchestrators]
myserver

[Endpoints]
ansible-target
```

Weryfikacja `ping`:

```bash
ansible -i ~/ansible/inventory.ini all -m ping
```

```text
myserver | SUCCESS => { "ping": "pong" }
ansible-target | SUCCESS => { "ping": "pong" }
```

Scenariusz z trzecią maszyną i operacjami przy wyłączonym SSH nie był u mnie wykonywany.

### Playbook `site.yml`

Playbook w katalogu `Sprawozdanie3/` obejmuje kilka playów:

1. `ping` na wszystkich hostach
2. kopiowanie `inventory.ini` na `Endpoints`
3. `apt upgrade` na `Endpoints`
4. restart `sshd` i `rngd` (rngd z `ignore_errors: yes`)
5. rola `readme_aura_deploy` - wdrożenie artefaktu z pipelineu

Fragment z kopiowaniem inventory i aktualizacją pakietów:

```yaml
- name: Skopiuj inventory na Endpoints
  hosts: Endpoints
  tasks:
    - name: Kopiuj inventory.ini
      ansible.builtin.copy:
        src: "{{ lookup('env', 'HOME') }}/ansible/inventory.ini"
        dest: /home/ansible/inventory.ini

- name: Zaktualizuj pakiety na Endpoints
  hosts: Endpoints
  tasks:
    - name: apt update i upgrade
      ansible.builtin.apt:
        upgrade: dist
        update_cache: yes
      become: yes
```

Uruchomienie całości (w tym roli deploy):

```bash
ansible-playbook -i ~/ansible/inventory.ini \
  ITE/GCL3/YK424367/Sprawozdanie3/site.yml \
  -e "local_artifact_path=ITE/GCL3/YK424367/Sprawozdanie3/readme-aura.tgz"
```

### Rola `readme_aura_deploy`

Rolę utworzyłem przez `ansible-galaxy role init readme_aura_deploy` i umieściłem w repozytorium.

Rola robi mniej więcej tyle:

1. **Sanity check** - `ping` i sprawdzenie wolnego miejsca na `/` (błędy ignorowane, playbook idzie dalej)
2. **Instalacja Dockera** na maszynie docelowej przez Docker CE
3. **Kopiowanie** pliku `.tgz` na endpoint do `/tmp/readme-aura-deploy/`
4. **Uruchomienie** kontenera `node:20`, który instaluje paczkę lokalnie i odpala `npx readme-aura init` + `npx readme-aura build`
5. **Assert** na `rc == 0` - sprawdzam exit code kontenera
6. **Cleanup** - usunięcie katalogu z artefaktem i obrazu `node:20`

Fragment z uruchomienia aplikacji:

```yaml
- name: Uruchom readme-aura w kontenerze node:20
  ansible.builtin.shell: |
    docker run --rm \
      --name {{ container_name }} \
      -v {{ artifact_dir }}:/artifacts:ro \
      {{ node_image }} \
      sh -c "
        set -e
        mkdir /app && cd /app
        npm init -y
        npm install /artifacts/{{ artifact_filename }}
        npx readme-aura init --template PurpleGlow
        npx readme-aura build
      "
  register: run_result

- name: Zweryfikuj poprawne uruchomienie aplikacji
  ansible.builtin.assert:
    that:
      - run_result.rc == 0
```

Artefakt `readme-aura.tgz` to paczka wyprodukowana wcześniej w pipelinie Jenkinsa.

---

## Zajęcia 09 - Kickstart Fedora

Po pierwszej instalacji Fedory 44 pobrałem szablon `/root/anaconda-ks.cfg` i zmodyfikowałem go pod wymagania zajęć. Plik leży w repozytorium jako [`anaconda-ks.cfg`](./anaconda-ks.cfg).

Kluczowe elementy:

- źródło instalacji Fedora 44 **aarch64** (moja maszyna to ARM64)
- `clearpart --all` + `autopart` - reinstalacja „w kółko" na pustym dysku
- hostname `yehor-fedora`, użytkownik `yehor`
- sekcja `%packages`: `docker`, `docker-compose`, `curl`, `wget`, `git`
- `reboot` na końcu - instalator nie zostaje na ostatnim ekranie

W `%post` włączam Docker przy starcie i tworzę usługę systemd, która po pierwszym bootcie uruchamia readme-aura w kontenerze:

```bash
systemctl enable docker

cat > /etc/systemd/system/readme-aura.service << 'EOF'
[Unit]
Description=readme-aura container
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker run --rm --name readme-aura-app node:20 npx readme-aura@canary --help

[Install]
WantedBy=multi-user.target
EOF

systemctl enable readme-aura.service
```

### Instalacja nienadzorowana

Nową maszynę UEFI uruchomiłem z ISO Fedory 44. W GRUB dodałem parametr wskazujący plik kickstart hostowany w sieci:

![GRUB - instalacja z plikiem kickstart](./assets/Screenshot%202026-05-19%20at%2009.24.31.png)

```text
linux ... ro inst.ks=https://tinyurl.com/35jr8d9r
```

Formatowanie dysku, pakiety i `%post` poszły automatycznie.

### Weryfikacja po pierwszym uruchomieniu

Po restarcie sprawdziłem czy Docker i usługa readme-aura wstały:

```bash
systemctl status docker
systemctl status readme-aura
journalctl -u readme-aura --no-pager
cat /root/ks-post.log
```

W logu post-install jest linia `>>> Post-install complete`. Usługa `readme-aura` odpala kontener z `npx readme-aura@canary --help` - to smoke test tego samego artefaktu co w Jenkinsie, tylko pobranego z NPM z tagiem `canary`.

---

## Zajęcia 10 - Kubernetes (minikube, deployment, strategie)

Do deploymentu użyłem nginx.


Uruchomiłem klaster:

```bash
minikube start
```

```text
😄  minikube v1.38.1 on Ubuntu 22.04 (arm64)
✨  Automatically selected the docker driver
🏄  Done! kubectl is now configured to use "minikube" cluster
```

Dashboard uruchomiłem przez `minikube dashboard`.

### Pierwszy pod (manualnie)

```bash
minikube kubectl -- run nginx-app --image=nginx --port=80 --labels app=nginx-app
minikube kubectl -- get pods
```

![Pod nginx-app w Dashboard](./assets/Screenshot%202026-05-26%20at%2008.57.52.png)

Port-forward i test HTTP:

```bash
minikube kubectl -- port-forward pod/nginx-app 9090:80 --address 0.0.0.0 
```

### Deployment z pliku YAML

Zapisałem wdrożenie w [`nginx-deployment.yaml`](./nginx-deployment.yaml) i zaaplikowałem:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

```bash
minikube kubectl -- apply -f nginx-deployment.yaml
minikube kubectl -- rollout status deployment/nginx-deployment
```

![4 repliki nginx-deployment](./assets/Screenshot%202026-05-26%20at%2009.04.56.png)

### Skalowanie i zmiany obrazu

Po kolei zmieniałem `replicas` i tag obrazu w YAML, za każdym razem `kubectl apply` + `rollout status`:

| Zmiana | Efekt |
|--------|-------|
| replicas: 8 | 8/8 podów Running |
| replicas: 1 | zostaje jeden pod |
| replicas: 0 | deployment istnieje, `No resources found` |
| replicas: 4 | z powrotem 4 repliki |
| image: nginx:1.26 | Rolling Update, 4/4 na nowej wersji |
| image: nginx:1.25 | rollback ręczny przez YAML |
| image: nginx:99.99 | część podów w `ErrImagePull` |

![Deployment 8/8 replik](./assets/Screenshot%202026-05-26%20at%2009.08.21.png)

![Deployment 4/4 na nginx:1.26](./assets/Screenshot%202026-05-26%20at%2009.09.49.png)

Przy wadliwym obrazie Kubernetes nie usuwa starych podów dopóki nowe nie wstaną - stare 3 pody na `nginx:1.25` zostawały `Running`, a nowe szły w `ImagePullBackOff`:

![Deployment 3/4 - wadliwy obraz nginx:99.99](./assets/Screenshot%202026-05-26%20at%2009.10.23.png)

![Pody z ErrImagePull obok Running](./assets/Screenshot%202026-05-26%20at%2009.10.43.png)

```bash
minikube kubectl -- rollout history deployment/nginx-deployment
minikube kubectl -- rollout undo deployment/nginx-deployment
minikube kubectl -- rollout status deployment/nginx-deployment
```

### Serwis i skrypt weryfikacji

```bash
minikube kubectl -- expose deployment nginx-deployment --port=80 --type=ClusterIP
minikube kubectl -- port-forward service/nginx-deployment 9091:80 --address 0.0.0.0 &
```

Serwis YAML: [`nginx-service.yaml`](./nginx-service.yaml)

Skrypt [`check-deployment.sh`](./check-deployment.sh) czeka max 60 sekund na rollout:

```bash
chmod +x check-deployment.sh
./check-deployment.sh nginx-deployment
```

```text
Checking deployment: nginx-deployment (timeout: 60s)
deployment "nginx-deployment" successfully rolled out
SUCCESS: Deployment nginx-deployment rolled out within 60s
```

### Strategie wdrożeń

#### Recreate ([`nginx-recreate.yaml`](./nginx-recreate.yaml))

```yaml
strategy:
  type: Recreate
```

Przy zmianie obrazu (`set image ... nginx=nginx:1.26`) wszystkie stare pody znikają naraz, dopiero potem powstają nowe.

#### Rolling Update ([`nginx-rolling.yaml`](./nginx-rolling.yaml))

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 2
    maxSurge: 25%
```

Przy 4 replikach i `maxSurge: 25%` Kubernetes może na chwilę postawić 5 podów. 
Stary deployment nadal obsługuje ruch podczas aktualizacji.

#### Canary ([`nginx-canary-stable.yaml`](./nginx-canary-stable.yaml) + [`nginx-canary-new.yaml`](./nginx-canary-new.yaml))

Dwa osobne deploymenty i wspólny serwis z selektorem `app: nginx-canary`:

- **stable**: 3 repliki, `nginx:1.25`, etykieta `track: stable`
- **canary**: 1 replika, `nginx:1.26`, etykieta `track: canary`

Serwis kieruje ruch do obu, 75% na stable, 25% na canary. Jak canary działa, można stopniowo przesuwać repliki.

---

## Zajęcia 11 - Kubernetes (eksponowanie, skalowanie)

### Deployment z 36 replikami

```bash
minikube start --force
cd ITE/GCL3/YK424367/Sprawozdanie3
minikube kubectl -- apply -f nginx-deployment-36.yaml
minikube kubectl -- rollout status deployment/nginx-deployment
minikube kubectl -- get deployment nginx-deployment
```

`--force` dałem dlatego, że minikube bez tego odmawiał startu - moja virtualna maszyna ma tylko jeden rdzeń CPU, a domyślnie minikube chce więcej i proponuje przebudowę klastra. Nie chciałem tego robić, więc wymusiłem start na istniejącej konfiguracji.

```text
nginx-deployment   36/36   36           36
```

Plik [`nginx-deployment-36.yaml`](./nginx-deployment-36.yaml) ma `replicas: 36` i obraz `nginx:1.26`.

### Eksponowanie - pod, deployment, serwis

**Do jednego poda:**

```bash
minikube kubectl -- get pods -l app=nginx
minikube kubectl -- port-forward pod/nginx-deployment-8574879789-28zfz 9090:80
```

![Port-forward do poda - localhost:9090](./assets/Screenshot%202026-06-02%20at%2008.44.27.png)

**Do deploymentu** (Kubernetes wybiera jeden z podów):

```bash
minikube kubectl -- port-forward deployment/nginx-deployment 9092:80
```

**Do serwisu** - poleceniem `expose` serwis już istniał (`AlreadyExists`), więc zaaplikowałem YAML:

```bash
minikube kubectl -- expose deployment nginx-deployment --port=80
# Error from server (AlreadyExists): services "nginx-deployment" already exists

minikube kubectl -- apply -f nginx-service.yaml
minikube kubectl -- port-forward service/nginx-deployment 9093:80
```

Wszystkie trzy warianty pokazują działającą stronę Welcome to nginx.

### Skalowanie

**Przez dyrektywę `scale`:**

```bash
minikube kubectl -- scale deployment/nginx-deployment --replicas=12
minikube kubectl -- scale deployment/nginx-deployment --replicas=20
```

![Deployment 12/12 replik](./assets/Screenshot%202026-06-02%20at%2008.54.02.png)

![Deployment 20/20 replik](./assets/Screenshot%202026-06-02%20at%2008.54.24.png)

**Przez YAML** - wystarczy zmienić `replicas` w pliku i `kubectl apply`. Różnica względem `scale`: YAML trafia do repozytorium i jest powtarzalny, `scale` to szybka zmiana z terminala bez edycji pliku.

---

## Podsumowanie

Na zajęciach 8-11 zapoznałem się z:

- **Ansible** - inventory, playbook, rola instalująca Docker i uruchamiająca artefakt readme-aura z `.tgz`
- **Kickstart** - powtarzalna instalacja Fedory z automatycznym startem readme-aura po bootcie
- **Kubernetes** - minikube, deployment YAML, skalowanie, aktualizacje obrazów, rollback, strategie Recreate / Rolling / Canary
- **Eksponowanie** - port-forward do poda, deploymentu i serwisu; skalowanie do 36, potem 12 i 20 replik

Ten sam projekt readme-aura pojawia się w Jenkinsie, Ansible i kickstart. W minikube użyłem nginx, bo to serwer HTTP, a readme-aura to narzędzie CLI.

---

## Pytania do LLM

1. Jak napisać rolę Ansible, która instaluje Docker na zdalnej maszynie i uruchamia w nim aplikację z pliku `.tgz`?
2. Co robi `kubectl rollout undo`?
3. Zformatuj mi sprawozdanie w README.md, ustrukturyzuj je i dodaj formatowanie markdown
