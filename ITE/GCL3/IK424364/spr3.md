Na maszynie docelowej utworzono usera ansible z prawami sudo

![scr1](./cw8/Screenshot_2.png)

![scr1](./cw8/Screenshot_3.png)

![scr1](./cw8/Screenshot_4.png)

Na maszynie głownej zainstalowano ansible

![scr1](./cw8/Screenshot_1.png)

Także zgenerowano i wymieniono klucze ssh

![scr1](./cw8/Screenshot_5.png)

Ustawione odpowiednie nazwy hostów

![scr1](./cw8/Screenshot_6.png)

Zmieniony plik /etc/hosts

![scr1](./cw8/Screenshot_7.png)

Na maszynie gownej utowrzony ansible.cfg (ustawiona opcja do omijania Host Key Checking)

```
[defaults]
host_key_checking = False
inventory = inventory.ini
```

I inventory.ini

```
[orchestrators]
control-node ansible_connection=local

[endpoints]
ansible-target ansible_user=ansible
```

Po tym 

![scr1](./cw8/Screenshot_8.png)

```
---
- name: Przygotowanie systemów
  hosts: endpoints
  become: yes
  tasks:
    - name: Testowanie łączności
      ping:

    - name: Plik inventory.ini
      copy:
        src: ./inventory.ini
        dest: /home/ansible/inventory_backup.ini
        owner: ansible
        mode: '0644'

    - name: Aktualizacja pakietów (Ubuntu)
      apt:
        update_cache: yes
        upgrade: dist
      when: ansible_os_family == "Debian"

    - name: Aktualizacja pakietów (Fedora)
      shell: "dnf upgrade -y"
      when: ansible_os_family == "RedHat"
      become: yes

    - name: Restart serwisów
      service:
        name: "{{ item }}"
        state: restarted
      loop:
        - sshd
      ignore_errors: yes
```

![scr1](./cw8/Screenshot_9.png)

Do deployu stworzona odpowidnia rola w ansible-galaxy

![scr1](./cw8/Screenshot_10.png)

Został stworzony plik z instrukcjami do buildu oraz deployu aplikacji z poprzednich zajęć

```
---
- name: Sanity Check
  shell: df -h / | tail -1 | awk '{print $4}'
  register: disk_space
  ignore_errors: yes

- name: Instalacja Docker
  shell: "dnf install -y docker python3-docker"
  become: yes

- name: Włączenie Dockera
  service:
    name: docker
    state: started
    enabled: yes
  become: yes

- name: Kopia pliku binarnego
  copy:
    src: files/realworld-app.jar
    dest: /opt/realworld-app.jar
    mode: '0755'

- name: Dockerfile dla JAR
  copy:
    dest: /opt/Dockerfile
    content: |
      FROM eclipse-temurin:25-jre-noble
      COPY realworld-app.jar /app.jar
      ENTRYPOINT ["java", "-jar", "/app.jar"]

- name: Build image z JAR
  shell: "docker build -t realworld-from-jar /opt"
  become: yes

- name: Kontener docker
  shell: |
    docker stop realworld-final || true
    docker rm realworld-final || true
    docker run -d --name realworld-final -p 8081:8080 realworld-from-jar
  become: yes

- name: Health Check
  uri:
    url: "http://localhost:8081/api/tags"
    status_code: 200
  register: result
  until: result.status == 200
  retries: 5
  delay: 10
  ```

![scr1](./cw8/Screenshot_11.png)

Używaliśmy modułów shell zamiast natywnych modułów dnf i docker poprzez niekompatybilnością bieżących bibliotek Ansible z eksperymentalną wersją Python 3.14 na maszynie docelowej z systemem Fedora 43. Pozwoliło to na pomyślne zakończenie deploymentu poprzez wyeliminowanie błędów segmentacji oraz niezgodności interfejsów API