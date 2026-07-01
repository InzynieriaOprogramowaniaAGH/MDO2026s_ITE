# Sprawozdanie 3

## Lab 8: Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

**Środowisko: Maszyna wirtualna Ubuntu Server (główna) w Hyper-V na systemie operacyjnym Windows 11 oraz maszyna wirtualna ubuntu server (ansible-target) również w Hyper-v**

Przeprowadziłam taki sam proces instalacji jak w laboratrium 7. Teraz mam dwie maszyny wirtualne: ansible-target1 i ansible-target2.  

![ansible-target2](<Lab8/Zrzut ekranu 2026-06-30 222753.png>)  

Następnie nadałam nazwę hostowi na głównej maszynie i dodałam oba hosty ansible-target do pliku /etc/hosts.  

![etc/hosts](<Lab8/Zrzut ekranu 2026-06-30 222950.png>)  

Wymieniłam klucz SSH z ansible-target2 i sprawdziłam łączność przez ssh.  

![ssh ansible-target2](<Lab8/Zrzut ekranu 2026-06-30 223352.png>)  

Sprawdziłam również ponownie łączność z ansible-target1.  

![ssh ansible-target1](<Lab8/Zrzut ekranu 2026-06-30 223402.png>)  

Utowrzyłam plik inwentaryzacji.  

```yaml
[Orchestrators]
ansible-orchestrator ansible_connection=local

[Endpoints]
ansible-target1 ansible_user=ansible
ansible-target2 ansible_user=ansible

[Endpoints:vars]
```

Wysłałam ping do wszystkich maszyn - zakończył się sukcesem.  

![ping-pong](<Lab8/Zrzut ekranu 2026-06-30 225555.png>)  

Następnie utowrzyłam playbooka. Pierwsze uruchomienie zakończyło się niepowodzeniem. By naprawić wszelkie błędy, utworzyłam użytkownika ansible na głównej maszynie (ansible-orchestrator), który nie wymaga podania hasła przez ssh. Włączyłam również zbieranie faktów (gather_facts: true), gdyż wtedy mogłam pobrać zmienną ansible_os_family. Wyłączyłam sudo dla pingu (become: false). Zrestartowałam również usługi sshd i rngd wyłącznie na Endpointach.  

![pierwsze uruchomienie](<Lab8/Zrzut ekranu 2026-07-01 001545.png>)  

Treść poprawnego playbooka:  

```yaml
- name: Ping do wszystkich maszyn
  hosts: all
  become: true  
  gather_facts: true 

  tasks:
    - name: Wysyłanie ping
      ansible.builtin.ping:
      become: false

    - name: Kopiowanie pliku inwentaryzacji na endpointy
      ansible.builtin.copy:
        src: ./inventory
        dest: /home/ansible/inventory_backup
        owner: ansible
        group: ansible
        mode: '0644'
      when: "'Endpoints' in group_names"

    - name: Aktualizacja pakietów
      ansible.builtin.apt:
        update_cache: yes
        upgrade: safe
        cache_valid_time: 3600
      when: ansible_os_family == "Debian" or "Endpoints" in group_names

    - name: Restart usługi sshd
      ansible.builtin.systemd:
        name: sshd
        state: restarted
      when: "'Endpoints' in group_names"

    - name: Restart usługi rngd
      ansible.builtin.systemd:
        name: rngd
        state: restarted
      when: "'Endpoints' in group_names"
      ignore_errors: true
```  

Przy ponownie uruchomionym playbooku (już poprawnym) można zauważyć, że wcześniej zadania oznaczone jako changed zmieniły się na ok. Wynika to z idempotentności Ansible'a. Narzędzie sprawdza stan (czy pliki są identyczne, pakiety najnowsze) i nie wykonuje ponownie zadań, jeśli są już wykonane. Usługa rngd ma ustawioną flagę ignore_errors na true, gdyż może się zdarzyć, że nie wszystkie urządzenia potrzebują konkretnej usługi i może jej na nich nie być. W tym wypadku nie ma potrzeby ich restartować/aktualizować i wtedy taka flaga jest niezbędna by dobrze skonfigurować playhooka.  

![drugie uruchomienie](<Lab8/Zrzut ekranu 2026-07-01 001633.png>)  

Na koniec wyłączyłam ssh na ansible-target1 i uruchomiłam ponownie playbooka. 

![ssh stop ansible-target1](<Lab8/Zrzut ekranu 2026-07-01 004330.png>)  

Można zauważyć, że ansible pominął hosta, który jest "unreachable" i wykonał konfigurację na reszcie hostów.  

![unreachable](<Lab8/Zrzut ekranu 2026-07-01 004341.png>)  

Aby wdrożyć aplikację napisaną przy okazji pipeline'a wygenerowałam strukturę roli docker_deploy.  

![init role](<Lab8/Zrzut ekranu 2026-07-01 013209.png>)  

Następnie wypełniłam plik meta/main.yml zawierający podstawowe metadane.  

```yaml
galaxy_info:
  author: Magdalena Biskup
  description: Wdrożenie aplikacji Java za pomocą Dockera
  company: AGH
  license: MIT
  min_ansible_version: "2.14"
  platfroms:
    - name: Ubuntu
      versions:
        - all
  categories:
    - deployment
dependencies: []
```

Utworzyłam główny plik yamlowy, który zrealizuje sanity check, zainstaluje Dockera, sprawdzi czy Docker działa, oczyści środowisko (jeśli stary kontener produkcyjny istnieje), pobierze obraz JRE, uruchomi kontener produkcyjny i uruchomi w nim przesłany plik JAR, zweryfikuje czy kontener się poprawnie uruchomił i na koniec usunie kontener produkcyjny.  

```yaml
# 1. Sanity check środowiska przed wdrożeniem
- name: Sanity check - sprawdzenie dostępnego miejsca na dysku (min. 1GB)
  ansible.builtin.assert:
    that:
      - (ansible_mounts | selectattr('mount', 'equalto', '/') | first).size_available > 1073741824
    fail_msg: "Brak wystarczającej ilości miejsca na dysku!"
  ignore_errors: true

- name: Instalacja wymaganych pakietów systemowych
  ansible.builtin.apt:
    name:
      - apt-transport-https
      - ca-certificates
      - curl
      - software-properties-common
      - python3-pip
    state: present
    update_cache: yes

- name: Dodanie klucza GPG Dockera
  ansible.builtin.apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present

- name: Dodanie oficjalnego repozytorium Dockera
  ansible.builtin.apt_repository:
    repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
    state: present

- name: Instalacja Docker Engine
  ansible.builtin.apt:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    state: present
    update_cache: yes

- name: Upewnienie się, że usługa Docker jest uruchomiona
  ansible.builtin.systemd:
    name: docker
    state: started
    enabled: yes

- name: Przygotowanie folderu na aplikację na maszynie docelowej
  ansible.builtin.file:
    path: /opt/my-app
    state: directory
    mode: '0755'

- name: Wysłanie pliku binarnie (aplikacja.jar) ze struktury roli na maszynę docelową
  ansible.builtin.copy:
    src: aplikacja.jar
    dest: /opt/my-app/app.jar
    mode: '0755'

- name: Oczyszczenie starego kontenera jeśli istniał
  community.docker.docker_container:
    name: app-production-container
    state: absent

- name: Uruchomienie kontenera Java i zamontowanie w nim przesłanego pliku JAR
  community.docker.docker_container:
    name: app-production-container
    image: eclipse-temurin:17-jre
    state: started
    restart_policy: always
    volumes:
      - /opt/my-app:/app
    working_dir: /app
    command: 'sh -c "java -jar app.jar; tail -f /dev/null"'

- name: Odczekanie 5 sekund na rozruch aplikacji
  ansible.builtin.pause:
    seconds: 5

- name: Pobranie statusu działającego kontenera
  community.docker.docker_container_info:
    name: app-production-container
  register: container_info

- name: Weryfikacja czy kontener nie napotkał awarii i działa
  ansible.builtin.assert:
    that:
      - container_info.container.State.Running == true
    fail_msg: "Aplikacja z pliku JAR nie uruchomiła się poprawnie wewnątrz kontenera!"

- name: Sprzątanie - usunięcie kontenera wdrożeniowego po udanym teście
  community.docker.docker_container:
    name: app-production-container
    state: absent
```

Napisałam playbook java-json.yml, który wywołuje utworzoną przeze mnie rolę.  

```yaml
- name: Wdrożenie aplikacji java-json za pomocą roli Docker
  hosts: Endpoints
  become: true
  gather_facts: true

  roles:
    - docker_deploy
```

Następnie uruchomiłam utworzoną rolę i wdrażanie zakończyło się sukcesem.  

![success](<Lab8/Zrzut ekranu 2026-07-01 015515.png>)  

Połączyłam się z ansible-target1 przez ssh i sprawdziłam manualnie czy na pewno wszystko dobrze zadziałało. Można zauważyć, że Docker został pobrany, żaden kontener nie jest postawiony, plik app.jar skopiowany, a uruchomienie aplikacji w kontenerze zakończyło się sukcesem.  

![ssh check](<Lab8/Zrzut ekranu 2026-07-01 015537.png>)  


## Lab 9: Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

**Środowisko: Maszyna wirtualna Ubuntu Server (główna) w Hyper-V na systemie operacyjnym Windows 11 oraz maszyna wirtualna fedora server również w Hyper-v**

Zainstalowałam serwer Fedory, aby otrzymać plik anaconda-ks.cfg.  

```bash
# Generated by Anaconda 44.30
# Keyboard layouts
keyboard --vckeymap=pl --xlayouts='pl'
# System language
lang pl_PL.UTF-8

%packages
@^server-product-environment
@container-management
@domain-client
@guest-agents
@server-hardware-support

%end

# System authorization information
authselect enable-feature with-fingerprint

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.13.2
ignoredisk --only-use=sda
autopart
# Partition clearing information
clearpart --none --initlabel

# System timezone
timezone Europe/Warsaw --utc

#Root password
rootpw --lock
user --groups=wheel --name=mbiskup --password=$y$j9T$i6g7N2sF76Y09v9B5K.tD1$nL5.6LshmE0X6R8U5G5Gz.C.Kz9Jt.7tK2mXN8W4p2D --iscrypted --gecos="Magdalena Biskup"
```

Utworzyłam serwer http, aby przesłać zmodyfikowany plik anaconda-ks.cfg.  

![serwer python3](<Lab9/Zrzut ekranu 2026-07-01 205959.png>)  

Po parametrze quiet w komendzie linux przypisałam dyrektywą uruchomieniową *inst.ks* plik umieszczony na serwerze:

Nowy plik anaconda-ks.cfg
```bash
# Generated by Anaconda 44.30
# Keyboard layouts
keyboard --vckeymap=pl --xlayouts='pl'
# System language
lang pl_PL.UTF-8

url --mirrorlist="http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64"
repo --name=updates --mirrorlist="http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64"

%packages
@^server-product-environment
@container-management
@domain-client
@guest-agents
@server-hardware-support
%end

# System authorization information
authselect enable-feature with-fingerprint

# Run the Setup Agent on first boot
firstboot --enable

clearpart --all --initlabel
autopart

network --bootproto=dhcp --device=link --activate --hostname=fedora-server-mbism

# System timezone
timezone Europe/Warsaw --utc

# Root password
rootpw --lock
user --groups=wheel --name=mbism --password=12345 --gecos="Magdalena Biskup"
```

Instalacja rozpoczęła się bez wyświetlenia opcji instalacji.  

![instalacja fedora](<Lab9/Zrzut ekranu 2026-07-01 210951.png>)  

Na maszynie utworzony został user mbism oraz zmieniona została nazwa hosta.  

![fedora v1](<Lab9/Zrzut ekranu 2026-07-01 213310.png>)  

Napisałam plik anaconda-ks.cfg, który realizuje paradygmat IaC. Plik czyści dysk, instaluje system Fedory, konfiguruje sieć, wdraża środowisko uruchomieniowe i aplikację z pipeline'a z poprzednich zajęć w sposób automatyczny.  

```bash
# Generated by Anaconda 44.30
keyboard --vckeymap=pl --xlayouts='pl'
lang pl_PL.UTF-8

reboot

url --mirrorlist="http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64"
repo --name=updates --mirrorlist="http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64"

%packages
@^server-product-environment
@container-management
@domain-client
@guest-agents
@server-hardware-support

docker
jq
wget
%end

# System authorization information
authselect enable-feature with-fingerprint

# Run the Setup Agent on first boot
firstboot --enable

clearpart --all --initlabel
autopart

network --bootproto=dhcp --device=link --activate --hostname=fedora44-server

# System timezone
timezone Europe/Warsaw --utc

rootpw --iscrypted $y$j9T$i6g7N2sF76Y09v9B5K.tD1$nL5.6LshmE0X6R8U5G5Gz.C.Kz9Jt.7tK2mXN8W4p2D
user --groups=wheel --name=mbiskup --password=12345 --gecos="Magdalena Biskup"

%post --log=/root/ks-post.log

systemctl enable docker

mkdir -p /usr/local/bin/json-app

wget http://172.26.10.35:8000/aplikacja.jar -O /usr/local/bin/json-app/aplikacja.jar

cat <<EOF > /etc/systemd/system/json-app.service
[Unit]
Description=Zadanie Projektowe - Aplikacja JSON-java w Dockerze
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
WorkingDirectory=/usr/local/bin/json-app
ExecStartPre=-/usr/bin/docker rm -f json-java-container
ExecStart=/usr/bin/docker run --name json-java-container -v /usr/local/bin/json-app:/app -w /app eclipse-temurin:17-jre java -jar aplikacja.jar

[Install]
WantedBy=multi-user.target
EOF

systemctl enable json-app.service

%end
```  

Plik ten pobiera arfitekt z serwera python, ponieważ, gdy podawałam token z Jenkinsa i tak nie pozwałał on pobrać pliku. Może to być związane z polityką Jenkinsa.  

Error 403 (token)

![token](<Lab9/Zrzut ekranu 2026-07-01 225154.png>)  

Bez tokena  

![no token](<Lab9/Zrzut ekranu 2026-07-01 231408.png>)


## Lab 10: Wdrażanie na zarządzalne kontenery: Kubernetes

**Środowisko: Maszyna wirtualna Ubuntu Server (główna) w Hyper-V na systemie operacyjnym Windows 11 oraz maszyna wirtualna ubuntu server (ansible-target) również w Hyper-v**  


Zainstalowałam minikube i utowrzyłam alias.  

![install minikube](<Lab10/Zrzut ekranu 2026-07-01 232726.png>)  

Instalacja minikube w środowisku lokalnym jest bardzo bezpieczna. Można to sprawdzić patrząc na konfigurację: komunikacja między kubectl a klastrem jest szyfrowana za pomocą certyfikatów TLS.

![config view](<Lab10/Zrzut ekranu 2026-07-01 233819.png>)  

Uruchomiłam klaster.  

![minikube start](<Lab10/Zrzut ekranu 2026-07-01 232740.png>)  

Sprawdziłam stan węzła, a następnie uruchomiłam kontener serwera Nginx. Na koniec uruchomiłam dashboard.  

![run dashboard](<Lab10/Zrzut ekranu 2026-07-01 232751.png>)  

Po kliknięciu w link wygenerowany w terminalu, dashboard otwiera się w przeglądarce.  

![dashboard](<Lab10/Zrzut ekranu 2026-07-01 232808.png>)  