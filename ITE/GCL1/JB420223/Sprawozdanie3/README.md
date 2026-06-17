# Sprawozdanie Metodyki DevOps
Jakub Bednarczyk

## Lab 8 Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

### Instalacja zarządcy Ansible

Utworzono maszynę wirtualną w hyper-v która posiada:
* System [Ubuntu](https://ubuntu.com/download/server)
* 2 GB RAM
* 16 GB miejsca na dysku
* Program tar
* Serwer OpenSSH

Zapisano checkpoint

![Zdj](lab8/8_1.png)

Zainstalowano program Ansible na głównej maszynie

![Zdj](lab8/8_2.png)

Ustawiono dostęp poprzez ssh do maszyny ansible poprzez komendy z poziomu głównej maszyny (użyto już istniejącego klucza na maszynie głównej)

```
ssh-copy-id ansible@172.30.174.56
```
```
ssh ansible@172.30.174.56
```

![Zdj](lab8/8_3.png)


### Inwentaryzacja

Zmieniono nazwy hostnamectl

Główna maszyna
```
sudo hostnamectl set-hostname ansible-orchestrator
```

Maszyna ansible
```
sudo hostnamectl set-hostname ansible-target
```

Aby ustawić nazwę DNS maszyny ansible w głównej maszynie trzeba do pliku `/etc/hosts` dopisać `ip_maszyny nazwa_w_dns`

```
172.30.170.110 ansible-orchestrator // Główna
172.30.174.56 ansible-target // Ansible
```

Połączenie istnieje i jest stabilne
![Zdj](lab8/8_4.png)

Stworzono plik inwentaryzacji

```
// Plik: inventory.ini

[Orchestrators]
ansible-orchestrator ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible
```

Połączenie ansible'a z maszynami jest poprawne

![Zdj](lab8/8_5.png)


### Zdalne wywoływanie procedur

Utworzenie pliku `tasks.yml`

```
---
- name: Laboratorium - Zdalne wywoływanie procedur
  hosts: all
  become: no

  tasks:
    - name: 1. Pingowanie maszyn przez moduł Ansible
      ansible.builtin.ping:

    - name: 2. Kopiowanie pliku inwentaryzacji na Endpoints
      ansible.builtin.copy:
        src: inventory.ini
        dest: /home/ansible/inventory_backup.ini
        mode: '0644'
      when: "'Endpoints' in group_names"

    - name: 3. Aktualizacja listy pakietów (apt update)
      ansible.builtin.apt:
        update_cache: yes
      become: yes
      ignore_errors: yes

    - name: 4. Restart usługi SSH (Ubuntu)
      ansible.builtin.systemd:
        name: ssh
        state: restarted
      become: yes
      ignore_errors: yes

    - name: 4b. Restart usługi RNGD
      ansible.builtin.systemd:
        name: rngd
        state: restarted
      become: yes
      ignore_errors: yes
```

Użycie pliku `tasks.yml` w ansible

![Zdj](lab8/8_6.png)

Pierwszy test wykazał że plik wykonuje to co miał robić dopóki nie dochodzi do wykorzystania sudo na ansible-target. Jednak co ważne nic się nie wysypało bo błędy są ignorowane. Sudo potrzebuje hasła, aby zatwierdzić komendę, dlatego musimy ustawić użytkownikowi drugiej maszyny uprawnienia tak, aby nie musiał wpisywać hasła przy sudo, aby to zrobić musimy dopisać `ansible ALL=(ALL) NOPASSWD:ALL` po wywołaniu komendy `sudo visudo`. Oprócz tego nie było usługi rngd, dlatego musimy ją zainstalować na obu maszynach za pomocą komendy `sudo apt install rng-tools`

Po tych zmianach

![Zdj](lab8/8_7.png)

Wszystko działa tak jak powinno

Następnie wyłączono ssh na maszynie ansible

![Zdj](lab8/8_8.png)

I ponownie spróbowano się połączyć

![Zdj](lab8/8_9.png)

Maszyna od razu jest nieosiągalna

Potem odłączono kartę sieciową w hyper - v ustawiając `Virtual switch` na `Not connected`

![Zdj](lab8/8_10.png)

![Zdj](lab8/8_11.png)

Tym razem trzeba chwilę poczekać (kilka sekund), aby pojawił się komunikat `Unreachable`


### Zarządzanie stworzonym artefaktem

Na głównej maszynie wygenerowano rolę

```
ansible-galaxy role init redis_deploy
```

Następnie edytujemy plik `main.yml` w folderze `meta` naszej roli

```
galaxy_info:
  author: Jakub Bednarczyk
  description: desc
  license: MIT
  min_ansible_version: 2.1
  platforms:
    - name: Ubuntu
      versions:
        - plucky

dependencies: []
```

Następnie do folderu `files` wrzucamy plik artefaktu

Potem w folderze `tasks` edytujemy plik `main.yml` tak aby:

* Przeprowadzał sanity check maszyny docelowej przed rozpoczęciem wdrożenia (np. * sprawdzenie dostępnej pamięci RAM), upewniając się, że skrypt nie ulegnie awarii w przypadku niepowodzenia tego kroku

* Zapewniał obecność środowiska Docker, instalując go za pomocą modułów Ansible (w tym zależności, klucze GPG oraz repozytoria) bezpośrednio na maszynie docelowej

* Przesyłał i rozpakowywał artefakt (plik aplikacji tar.gz) na zdalną maszynę do wyznaczonego katalogu wdrożeniowego

* Uruchamiał aplikację wewnątrz kontenera Docker, mapując odpowiednie porty oraz montując wolumen z przesłanym plikiem binarnym i wymaganymi zależnościami

* Weryfikował poprawne uruchomienie aplikacji, sprawdzając rzeczywisty stan kontenera (czy jego status to running), a nie tylko sam fakt pomyślnego zakończenia wcześniejszych zadań w playbooku

* Oczyszczał środowisko docelowe poprzez zatrzymanie, usunięcie kontenera oraz skasowanie wdrożonych plików aplikacji po zakończeniu testów

```
---
- name: Sanity check - Sprawdzenie wolnej pamięci RAM przed wdrożeniem
  ansible.builtin.shell: free -m | awk '/^Mem:/{print $4}'
  register: free_memory
  ignore_errors: yes

- name: Wyświetl ostrzeżenie, jeśli pamięć jest na wyczerpaniu
  ansible.builtin.debug:
    msg: "UWAGA: Wykryto mało pamięci RAM, ale kontynuuję wdrożenie!"
  when: free_memory.stdout | int < 200
  ignore_errors: yes

- name: Instalacja wymaganych zależności systemowych
  ansible.builtin.apt:
    name:
      - apt-transport-https
      - ca-certificates
      - curl
      - software-properties-common
      - python3-pip
    state: present
    update_cache: yes
  become: yes

- name: Upewnij się, że katalog na klucze repozytoriów istnieje
  ansible.builtin.file:
    path: /etc/apt/keyrings
    state: directory
    mode: '0755'
  become: yes

- name: Dodanie oficjalnego klucza GPG Dockera
  ansible.builtin.get_url:
    url: https://download.docker.com/linux/ubuntu/gpg
    dest: /etc/apt/keyrings/docker.asc
    mode: '0644'
  become: yes

- name: Rejestracja repozytorium Docker w systemie
  ansible.builtin.apt_repository:
    repo: "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
    state: present
  become: yes

- name: Instalacja silnika Docker (docker-ce)
  ansible.builtin.apt:
    name: docker-ce
    state: present
    update_cache: yes
  become: yes

- name: Upewnij się, że usługa Docker jest uruchomiona i włączona
  ansible.builtin.systemd:
    name: docker
    state: started
    enabled: yes
  become: yes

- name: Utworzenie dedykowanego katalogu pod aplikację
  ansible.builtin.file:
    path: /opt/redis_app
    state: directory
    mode: '0755'
  become: yes

- name: Przesłanie i automatyczne wypakowanie archiwum binarnego
  ansible.builtin.unarchive:
    src: redis-JB420223-bin.tar.gz
    dest: /opt/redis_app/
  become: yes

- name: Uruchomienie aplikacji w kontenerze
  ansible.builtin.shell: |
    docker stop redis_runtime_container || true
    docker rm redis_runtime_container || true
    docker run -d \
      --name redis_runtime_container \
      --restart always \
      -v /opt/redis_app:/app \
      -p 6379:6379 \
      ubuntu:latest /app/redis-server
  become: yes

- name: Oczekiwanie na inicjalizację Redis
  ansible.builtin.pause:
    seconds: 5

- name: Sprawdzenie statusu kontenera przez docker ps
  ansible.builtin.shell: docker ps --filter "name=redis_runtime_container" --format "{{"{{.Status}}"}}"
  register: container_status
  become: yes

- name: Walidacja czy status kontenera zawiera 'Up'
  ansible.builtin.assert:
    that:
      - "'Up' in container_status.stdout"
    fail_msg: "Błąd: Aplikacja wewnątrz kontenera nie działa poprawnie!"
    success_msg: "Sukces: Kontener wdrożony i działa w tle."

- name: Czyszczenie - Zatrzymanie i usunięcie kontenera testowego
  ansible.builtin.shell: |
    docker stop redis_runtime_container || true
    docker rm redis_runtime_container || true
  become: yes

- name: Czyszczenie - Skasowanie katalogu aplikacyjnego wraz z artefaktami
  ansible.builtin.file:
    path: /opt/redis_app
    state: absent
  become: yes
```

Następnie tworzymy nowy plik `tasks2.yml` który wywoła naszą rolę

```
---
- name: Zarządzanie artefaktem z Pipeline
  hosts: all
  vars:
    ansible_python_interpreter: /usr/bin/python3

  roles:
    - redis_deploy
```

Oraz należy wykomentować główną maszynę z pliku `inventory.ini`

```
#[Orchestrators]
#ansible-orchestrator ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible
```

Wtedy cały proces przejdzie prawidłowo bez żadnych przeszkód

![Zdj](lab8/8_12.png)

![Zdj](lab8/8_13.png)
