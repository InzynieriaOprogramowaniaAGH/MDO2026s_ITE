# Sprawozdanie 3

Bartosz Bodulski  
gr. 1, Tematy 8-11

## Temat 8

#### Cel zajęć - Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

W ramach zajęć musiałem stworzyć drugą maszynę wirtualną, na której automatyzowałbym polecenia za pomocą oprogramowania Ansible - maszyna musi mieć conajmniej 2048 MB RAM oraz 2 logiczne rdzenie:

![img](../screenshots/lab8/Zrzut%20ekranu%202026-06-05%20142402.png)

Potem modyfikuje nazwę mojej początkowej maszyny za pomocą polecenia `hostnamectl set-hostname ansible-master`, aby nadać jej odpowiednią nazwę do poprawnej procedury inwentaryzacji w pliku `inventory.ini`:

```ini
[Orchestrators]
ansible-master ansible_connection=local

[Endpoints]
ansible-target ansible_host=ansible-target.local ansible_user=ansible
```
Naszym "konduktorem" bedzię maszyna ansible-master, natomiast odbiorcą rozkazów bedzie ansible-target! Do komunikacji między maszynami za pomocą dns użyłem  Avahi - programu, który pozwala na komunikacje między maszynami za pomocą multicast dns: https://pl.wikipedia.org/wiki/Avahi_(program)

Testuje połączenie za pomocą wbudowanego polecenia ping:

![img](../screenshots/lab8/Zrzut%20ekranu%202026-06-05%20155017.png)

Na podstawie inwentaryzacji piszę pierwszego playbooka - jest to plik z listą kroków, które mają być wykonane przez maszynę docelową. Kopiuje odpowiednie pliki, włacząm usługę sshd/rngd i aktualizuje pakiety systemowe:

``` yml
 name: Podstawowa konfiguracja i testy systemu
  hosts: Endpoints
  become: yes # (wymagane do apt i systemd)

  tasks:
    - name: ping (wbudowany modul)
      ansible.builtin.ping:

    - name: Skopiuj plik inwentaryzacji na maszyny Endpoints
      ansible.builtin.copy:
        src: ./inventory.ini
        dest: /tmp/inventory.ini

    - name: Zaktualizuj pakiety w systemie (troche czasu zajmie)
      ansible.builtin.apt:
        upgrade: yes
        update_cache: yes

    - name: Zrestartuj usluge sshd
      ansible.builtin.service:
        name: ssh
        state: restarted

    # rngd (RNG tools), jezeli nie ma to dodajemy ignore_errors
    - name: Zrestartuj usługę rngd (jeśli istnieje)
      ansible.builtin.service:
        name: rng-tools
        state: restarted
      ignore_errors: yes
```
Sprawdzamy działanie playbooka - jak widać, krok z rngd zwraca błąd, gdyż nie jest zainstalowany na systemie, ale przerywa działa playbooka. Na koniec dostajemy statystki, którę liczą statusy poszczególnych kroków operacji.

![img](../screenshots/lab8/Zrzut%20ekranu%202026-05-08%20085552.png)

Jeżeli wykonamy to polecenie jeszcze raz - kopiowanie  pliku inwentaryzacji do maszyny docelowej będzie mieć status "unchanged", co ma sens, gdyż ten plik o niezmienionej zawartości już znajdował się na ansible-target po pierwszym wykonaniu polecenia.

![img](../screenshots/lab8/Zrzut%20ekranu%202026-05-08%20085603.png)

jeżeli natomiast wyłączymy kartę sieciową - dostaniemy komunikat błędu z statusem "unreachable". Tutaj żadnych zadań nieudało się wykonać.

![img](../screenshots/lab8/Zrzut%20ekranu%202026-05-08%20085628.png)

Następnie tworzę oddzielny playbook do sprawdzenia działania wcześniej utworzonego artekfaktu neovima od Jenkinsa. Sprawdzamy najpierw czy nasza maszyna spełnia wymagania, instalujemy dockera, sprawdzamy działanie w tle, następnie tworzymy kontener, odpalamy oprogramowanie w celu sprawdzenia działa i na koniec wszystko sprzątamy:

```yml
  name: Wdrożenie artefaktu binarnego (Neovim DEB)
  hosts: Endpoints
  become: yes # Uruchamiaj zadania jako root (docker)
  vars:
    artifact_name: "neovim-final.deb"
    deploy_dir: "/opt/neovim_deploy"

  tasks:
    # ---------------------------------------------------------
    # Sanity check (z ignore_errors)
    # ---------------------------------------------------------
    - name: Przeprowadź sanity check (czy to Ubuntu i czy ma minimum 512MB RAM)
      ansible.builtin.assert:
        that:
          - ansible_facts['distribution'] == "Ubuntu"
          - ansible_facts['memtotal_mb'] >= 512
        fail_msg: "Maszyna nie spełnia wymagań sprzętowych lub systemowych!"
        success_msg: "Sanity check zakończony sukcesem."
      ignore_errors: yes # "nie ulegaj awarii w przypadku niepowodzenia"

    # ---------------------------------------------------------
    # Sprawdzenie dockera
    # ---------------------------------------------------------
    - name: Zainstaluj Dockera (upewnij się wprost, że istnieje)
      ansible.builtin.apt:
        name: docker.io
        state: present
        update_cache: yes

    - name: Upewnij się, że usługa Docker jest uruchomiona
      ansible.builtin.service:
        name: docker
        state: started
        enabled: yes

    # ---------------------------------------------------------
    # Przesył paczki .deb na ansible-target
    # ---------------------------------------------------------
    - name: Utwórz katalog wdrożeniowy na maszynie docelowej
      ansible.builtin.file:
        path: "{{ deploy_dir }}"
        state: directory
        mode: '0755'

    - name: Skopiuj paczkę DEB z Orchestratora na maszynę docelową
      ansible.builtin.copy:
        src: "./{{ artifact_name }}"
        dest: "{{ deploy_dir }}/{{ artifact_name }}"

    # ---------------------------------------------------------
    # Uruchamiamy paczke na kontenerze
    # ---------------------------------------------------------
    - name: Utwórz Dockerfile, by umieścić/udostępnić plik w kontenerze
      ansible.builtin.copy:
        dest: "{{ deploy_dir }}/Dockerfile"
        content: |
          FROM ubuntu:24.04
          ARG DEBIAN_FRONTEND=noninteractive
          # Kopiujemy nasz artefakt z maszyny docelowej do wnętrza kontenera
          COPY {{ artifact_name }} /tmp/
          # Instalujemy Neovima rozwiązując jego zależności (apt-get)
          RUN apt-get update && apt-get install -y /tmp/{{ artifact_name }} && rm -rf /var/lib/apt/lists/*
          WORKDIR /workspace

    - name: Zbuduj obraz kontenera z wdrożoną aplikacją
      ansible.builtin.command:
        cmd: docker build -t neovim-deployed-app .
        chdir: "{{ deploy_dir }}"

    # ---------------------------------------------------------
    # Smoke test paczki z opcja --headless
    # ---------------------------------------------------------
    - name: Uruchom aplikację w kontenerze (Zwrócenie wersji Neovima)
      ansible.builtin.command:
        cmd: docker run --rm neovim-deployed-app nvim --headless -v
      register: app_verification_output

    - name: Wyświetl dowód działania (Weryfikacja)
      ansible.builtin.debug:
        msg: "Aplikacja działa poprawnie! Zwrócona wersja: {{ app_verification_output.stdout_lines[0] }}"

    # ---------------------------------------------------------
    # Czyszczenie środowiska docelowego
    # ---------------------------------------------------------
    - name: Usuń obraz Dockera (sprzątanie)
      ansible.builtin.command:
        cmd: docker rmi neovim-deployed-app
      ignore_errors: yes

    - name: Usuń katalog wdrożeniowy i pliki binarne z maszyny docelowej
      ansible.builtin.file:
        path: "{{ deploy_dir }}"
        state: absent
```
![img](../screenshots/lab8/Zrzut%20ekranu%202026-05-08%20095404.png)


Następnie owijam tego playbooka w tzw. role za pomocą polecenia `ansible-galaxy init role <rola>`. Tworzy się struktura plików, w której musze uzupełnić odpowiednie pliki. Playbook przeniesiony zostaje do `neovim_deploy/tasks/main.yml`, dodatkowo podajemy potrzebne metadane w pliku `neovim_deploy/main.yml`, takie jak nazwa autora, organizacji, wymagania systemowe, licencje, tagi itp. :


```yml
galaxy_info:
  author: BB419678
  description: your role description
  company: your company (optional)

  # If the issue tracker for your role is not on github, uncomment the
  # next line and provide a value
  # issue_tracker_url: http://example.com/issue/tracker

  # Choose a valid license ID from https://spdx.org - some suggested licenses:
  # - BSD-3-Clause (default)
  # - MIT
  # - GPL-2.0-or-later
  # - GPL-3.0-only
  # - Apache-2.0
  # - CC-BY-4.0
  license: MIT

  min_ansible_version: 2.1

  platforms:
  - name: Ubuntu
    versions:
      - "24.04"

  

  # If this a Container Enabled role, provide the minimum Ansible Container version.
  # min_ansible_container_version:

  #
  # Provide a list of supported platforms, and for each platform a list of versions.
  # If you don't wish to enumerate all versions for a particular platform, use 'all'.
  # To view available platforms and versions (or releases), visit:
  # https://galaxy.ansible.com/api/v1/platforms/
  #
  # platforms:
  # - name: Fedora
  #   versions:
  #   - all
  #   - 25
  # - name: SomePlatform
  #   versions:
  #   - all
  #   - 1.0
  #   - 7
  #   - 99.99

    galaxy_tags:
    - neovim
    - docker
    - deploy
    - testing
    
    # List tags for your role here, one per line. A tag is a keyword that describes
    # and categorizes the role. Users find roles by searching for tags. Be sure to
    # remove the '[]' above, if you add tags to this list.
    #
    # NOTE: A tag is limited to a single word comprised of alphanumeric characters.
    #       Maximum 20 tags per role.

dependencies: []
  # List your role dependencies here, one per line. Be sure to remove the '[]' above,
  # if you add dependencies to this list.

```




