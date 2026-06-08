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


## Temat 9

#### Cel zajęć - Przygotowanie źrodła instalacyjnego dla maszyny wirtualnej Fedora

W ramach zajęć musiałem utworzyć źródło instalacji nienadzorowanej dla systemu operacyjnego hostującego oraz przeprowadzić instalację systemu, który po uruchomieniu rozpocznie hostowanie naszego programu.

Na początku pobrałem obraz fedora 44 server z wbudowanymi pakietami, który przyjmuje pliki odpowiedzi w menu grub zgodnie z instrukcją, następnie utworzyłem prostą maszynę wirtualną z tym obrazem:
 

![img](../screenshots/lab9/Zrzut%20ekranu%202026-06-05%20211813.png)

Następnie znalazłem plik `/root/anaconda-ks.cfg`, który wygląda następująco:

```ini
# Generated by Anaconda 44.30
# Keyboard layouts
keyboard --vckeymap=pl --xlayouts='pl'
# System language
lang pl_PL.UTF-8

%packages
@^custom-environment

%end

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.13.2
ignoredisk --only-use=sda
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
autopart
# Partition clearing information
clearpart --none --initlabel

# System timezone
timezone Europe/Warsaw --utc

# Root password
rootpw --iscrypted --allow-ssh $y$j9T$6CsVoonZjNdD2MGrm4x4W2sC$UqWmSiLEoK3lJCsE6ijHQ/Lv8B7D4eWQGfKXv5sEA78

```

Mamy tutaj podstawowe parametry do konfiguracji systemu, takie jak kodowanie, język, paczki, rodzaj partycjowania pamięci, hash hasła użytkownika root itp.


Na podstawie tego pliku tworzę własny plik konfiguracyjny, który wystawiam na maszynie w postaci servera http za pomocą polecenia `python3 http.server`:

``` 
# === glowna konfiguracja ===
text
lang pl_PL.UTF-8
keyboard pl
timezone Europe/Warsaw

# Źródło instalacji 
url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64
repo --name=update --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64

# Formatowanie w kółko i automatyczne partycje
clearpart --all --initlabel
autopart

# Nazwa hosta i użytkownicy (inne niż domyślne)
network --bootproto=dhcp --hostname=fedora-devops-host
rootpw --plaintext haslo123
user --name=fedora --password=haslo123 --groups=wheel

# restart po stworzeniu użytkownika
reboot

# Wybór pakietów do instalacji
%packages
@core
docker
wget
%end

# === (%post) ===
%post
# %post wypisze nam wszystkie informacje na ekran
exec < /dev/tty3 > /dev/tty3 2>&1
chvt 3
echo "=== konfiguracja po instalacji danych ==="

# docker po reboocie
systemctl enable docker

# Rozwiązanie problemu: Docker nie działa w instalatorze.
# Tworzymy skrypt "First Boot", który wykona się przy pierwszym uruchomieniu
cat << 'EOF' > /usr/local/bin/deploy-neovim.sh
#!/bin/bash
sleep 15 # Czekamy na sieć i Dockera

# pobieramy artefakt z naszej maszyny ubuntu po adresie ip!
wget http://172.25.32.137:8000/neovim-final.deb -O /tmp/neovim-final.deb

# Tworzymy obraz Dockera
cat << 'DOCKER' > /tmp/Dockerfile
FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
COPY neovim-final.deb /tmp/
RUN apt-get update && apt-get install -y /tmp/neovim-final.deb && rm -rf /var/lib/apt/lists/*
CMD ["nvim", "--headless", "-v"]
DOCKER

cd /tmp
docker build -t neovim-app .
# test czy dziala
docker run --rm neovim-app > /root/neovim-dziala.txt
EOF

chmod +x /usr/local/bin/deploy-neovim.sh

# Rejestrujemy skrypt jako jednorazową usługę startową
cat << 'EOF' > /etc/systemd/system/neovim-deploy.service
[Unit]
Description=Deploy Neovim Container on First Boot
After=network-online.target docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/deploy-neovim.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable neovim-deploy.service
echo "=== koniec konfiguracji ==="
chvt 1
%end
```

Ustawiamy strefę czasową systemu na Warszawę, konfigurujemy patrycjonowanie, sciągamy wszystkie potrzebne zależności z zdefiniowanych źródeł instalacji, dodatkowo przekierowujemy wszystkie do stdout, żeby widzieć wyniki wszystkich poleceń. Następnie pobieramy nasz artefakt z pipeline'u, tworzymy oddzielny obraz dockera, na którym włączamy oprogramowanie w celu sprawdzenia jego działania. Na koniec zapisujemy wyniki w pliku tekstowym, usuwamy obraz i pliki wykonawcze i sprzątamy system.

Podczas instalacji ISO na kolejnej maszynie fedora trzeba ustawić parametr ints.ks na adres naszego serwera w pythonie, tak aby system pobrał ten plik i skonfigurował się zgodnie z naszymi oczekiwaniami:


![img](../screenshots/lab9/Zrzut%20ekranu%202026-05-22%20090549.png)

Po ekranie GRUB system przystępuje do instalacji z podanym wcześniej plikiem konfiguracji.

![img](../screenshots/lab9/Zrzut%20ekranu%202026-05-22%20091030.png)

Jeżeli natomiast stracimy połączenie z serwem pliku konfiguracyjnego, dostaniemy taki komunikat, który informuje nas że plik kickstart nie został znaleziony! 

![img](../screenshots/lab9/Zrzut%20ekranu%202026-05-22%20090711.png)

Po zakończeniu poprawnej instalacji logujemy się na użytkownika fedora z hasłem haslo123 (tylko dla celi edukacyjnych, nie jest to bezpieczne! )

![img](../screenshots/lab9/Zrzut%20ekranu%202026-05-22%20091601.png)

Sprawdzamy, czy obraz sprawdził wersje naszego oprogramowania - należy pamiętać, żeby używać sudo w scieżce /root na fedorze.


![img](../screenshots/lab9/Zrzut%20ekranu%202026-05-22%20092406.png)



Dodatkowo można jeszcze zautomatyzować cały proces tworzenia takiej maszyny. Dla hyperV możemy użyć skryptu, który bierze z predefiniowanych folderów obrazy, tworzy maszynę z zadaną ilością pamięci ram, miejsca na dysku itp. oraz konfiguruje zabezpieczenia. Przykładowy skrypt może wyglądać tak:

```powershell
# Ustawienia
$VMName = "Fedora-Kickstart"
$ISOPath = "E:\_Install\Inne\linux_iso\Fedora-Server-netinst-x86_64-44-1.7.iso"  # <--- zmienna sciezka
$SwitchName = "Default Switch" # <--- mozemy także zmieniać switche do sieci

# Utworzenie nowej maszyny Generacji 2 z 2GB RAM i dyskiem 20GB
New-VM -Name $VMName -MemoryStartupBytes 2048MB -Generation 2 -NewVHDPath "C:\ProgramData\Microsoft\Windows\Hyper-V\Virtual Hard Disks\$VMName.vhdx" -NewVHDSizeBytes 20GB -SwitchName $SwitchName

# Skonfigurowanie Secure Boot pod Linuksa 
Set-VMFirmware -VMName $VMName -SecureBootTemplate "MicrosoftUEFICertificateAuthority"

# ISO fedory do instalacji
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

# Kolejność bootowania systemu
$DVDDrive = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive

# Uruchomienie maszny
Start-VM -VMName $VMName
```


Skrypt ten można włączyć w środowisku Powershell jako adminstator - wynikiem jest maszyna wirtuala o takiej samej specyfikacji jak w skryptcie:

![img](../screenshots/lab9/Zrzut%20ekranu%202026-06-06%20132435.png)

![img](../screenshots/lab9/Zrzut%20ekranu%202026-06-06%20132418.png)





