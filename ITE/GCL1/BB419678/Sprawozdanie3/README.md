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

### Wnioski
Narzędzia takie jak Ansible pozwalają na bezagentowe i deklaratywne zarządzanie konfiguracją wielu maszyn jednocześnie. Wykorzystanie plików inwentaryzacji (Inventory) oraz playbooków znacząco automatyzuje powtarzalne procesy operacyjne, takie jak aktualizacje pakietów czy wdrażanie aplikacji (np. paczek DEB w kontenerach). Z kolei mechanizm ról (Ansible Galaxy) pozwala na modularną organizację kodu, ułatwiając jego wielokrotne użycie.


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


### Wnioski

Użycie plików odpowiedzi (takich jak ks.cfg) umożliwia całkowicie zautomatyzowaną, nienadzorowaną instalację systemu operacyjnego, co drastycznie skraca czas wdrażania nowych węzłów. Kluczowym wyzwaniem jest fakt, że podczas fazy instalacyjnej (w sekcji %post) usługi takie jak Docker nie są jeszcze uruchomione. Wymusza to stosowanie mechanizmów opóźnionych, takich jak skrypty "First Boot" wdrażane jako usługi systemd.  

## Temat 10

#### Cel zajęć - Wdrażanie oprogramowania na zarządzalne kontenery za pomocą oprogramowania Kubernetes


W ramach ćwiczenia wykorzystałem obraz `nginx:alpine` zamiast wcześniej zbudowanego oprogramowania, gdyż pozwoli to na lepsze zobrazowanie różnych scenariuszy zmiany konfiguracji wdrożeń nowszych wersji.

Na początku instaluje minikube oraz kubectl zgodnie z dokumentacją:

```sh
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```
```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
Włączam klaster na 2 CPU i 2GB RAM:
```sh
minikube start --cpus=2 --memory=2048 --driver=docker
```
Sprawdzam dashboard (narazie jest pusty):
```sh
minikube dashboard &
```
Dodatkowo tworze prosty dockerfile dla mojej aplikacji, który zostaje później użyty do deploymentu jej różnych wersji:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```
Na podstawie tych faktów przystępuje do czynów. Na początku ładuje wcześniej utworzony obraz do minikube, "modyfikuje" wersję programu, buduje wersje nr. 2, ładuje ją do minikube, dodaktowo tworzę trzecią "zepsutą" wersje aplikacji i ponownie ładuję ją do klastra.
![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20090134.png)
Na początku sprawdzam działanie pojedyńczego poda, gdzie przekierowuje nginx na port 8081 i sprawdzam działanie narzędziem curl:

```bash
kubectl run moj-pod --image=moj-app:v1 --port=80 --image-pull-policy=Never --labels app=moj-pod

kubectl port-forward pod/moj-pod 8081:80 &
```
![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20090517.png)

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20090507.png)



![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20090544.png)
Jak widać, pokazuje się wersja 1 aplikacji narazie, co jest zgodne z poleceniem.

Pod można usunąć poleceniem:

```bash
kubectl delete pod moj-pod
```
Następnie tworze plik deployment.yaml, dzięki któremu moge zautomatyzować wdrożenie wersji aplikacji na klaster:

```yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: kontener-aplikacji
        image: moj-app:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: lab-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

```

Tworzymy tutaj deployment, który utworzy 4 pody zawierają wersję v1 nginx. 
Dodatkowo dodaję jeszcze serwis, który bedzie przekazywał port jednego z podów na local, dzięki czemu bedzie można sprawdzić działanie deploymentu.

Włączam deployment poniższą komendą:

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091137.png)

Sprawdzam status deploymentu - czy nie ma żadnych błędów (nie ma):


![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091159.png)

Dodatkowo na dashboardzie widać nasze 4 pody z deploymentu, każdy z nich używa obrazu moj-app:v1, co jest zgodne z plikiem wdrożenia.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091219.png)

Przekazuje porty i sprawdzam działanie deploymentu - jak widać działa poprawnie na porcie 8082.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091511.png)

Następnie zmieniam liczbę podów w wdrożeniu z 4 na 8 za pomocą polecenienia `kubectl scale` i ponownie sprawdzam ich liczbę. Analogicznie można skalować w dół oraz do 0, daje to podobne wynki do tego:


![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091626.png)

Aktualizuję obraz do wersji moj-app:v2 za pomocą polecenia `kubectl set image` oraz sprawdzam stan klastra poleceniem `kubectl rollout status` 

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091700.png)

Ponownie przekierowuje porty i sprawdzam działanie za pomocą narzędzia curl - wynikiem jest komunikat "Wersja V2 - po aktualizacji" - pody poprawnie zmieniły obraz w ramach modyfikacji deploymentu.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20092234.png)

Dodatkowo na dashboardzie wszystkie pody początkowego deploymentu teraz mają obraz V2, natomiast widzimy dwa deploymenty w ReplicaSet, jeden V1, drugi V2.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20092308.png)

Następnie zmieniam wersje obrazu na V3 w celu sprawdzenia czy klaster przyjmie wadliwy obraz - wynikiem jest zepsucie połowy kontenerów, w związku z czym  trzeba zrobić `kubectl rollout undo` aby powrócić do poprzedniego stanu.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20092743.png)

Następnie tworzę prosty skrypt, który sprawdza staus deploymentu i zwraca odpowiedni komunikat:

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20224727.png)

Prechodzę do kwestii rodzajów wdrożeń - zacznę od recreate. Ten typ wdrożenia zabije wszystkie pody ze starą wersją, po czym podnosi je z nowszą wersją oprogramowania:

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-deployment
spec:
  replicas: 4
  strategy:
      type: Recreate
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: kontener-aplikacji
        image: moj-app:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: lab-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20225434.png)

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20225521.png)

Kolejny jest rolling update, gdzie określona część kontenerów zostanie podmnieniona w płynny sposób, a reszta pozostanie w tym czasie w wersji poprzedniej, aby uniknąć przerwy w dostarczanku usług.

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-deployment
spec:
  replicas: 4
  strategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1
        maxSurge: 25%  # 1 kontener przy 4 replikach
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: kontener-aplikacji
        image: moj-app:v2
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: lab-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```
Wynikiem tego jest 3 kontenery w wersji v2 oraz 1 w wersji v1, który pod koniec zmienia się w kontener wersji v2.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20230424.png)

Na koniec mamy deployment typu canary, gdzie najpierw musimy wyłączyć wszystkie pody podchodzący pod nasz pierwotny deployment. Ten typ wdrożeń polega na tagach, gdzie tylko ustalona część klientów ma dostęp do podów z nowszą wersją oprogramowania, w porównaniu do Rolling Update to przejście na nowszą wersję jest prawie natychmiastowe, oczywiscie po poprawnie zaliczonym zbiorze testów.

Do zrobienia wdrożenia ponownie modfyikujemy nasz plik wdrożenia:

```yml

---
# (Wspólny punkt wejścia)
apiVersion: v1
kind: Service
metadata:
  name: canary-service
spec:
  selector:
    app: aplikacja-lab  # Złapie wszystkie pody z tą etykietą
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

---
# wdrozenie stabilne v1 - 75% ruchu
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-stable
spec:
  replicas: 3
  selector:
    matchLabels:
      app: aplikacja-lab
      track: stable       # Unikalna etykieta stabilna
  template:
    metadata:
      labels:
        app: aplikacja-lab
        track: stable
    spec:
      containers:
      - name: kontener
        image: moj-app:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80

---
# wdrozenie "canary" - 25% ruchu
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aplikacja-lab
      track: canary       # Unikalna etykieta kanarka
  template:
    metadata:
      labels:
        app: aplikacja-lab
        track: canary
    spec:
      containers:
      - name: kontener
        image: moj-app:v2
        imagePullPolicy: Never
        ports:
        - containerPort: 80

```

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20230845.png)

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20231151.png)

Dla wersji "stable" przekazujemy 75% ruchu użytkowników, natomiast reszta idzie na nasze pody z tagiem "canary". Dodatkowo sprawdzam za pomocą testowego poda czy rozkład zapytań i odpowiedzi zgadza się z plikiem konfiguracyjnym:

```sh
kubectl run test-pod --rm -i --tty --image=curlimages/curl -- sh
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.

$ for i in $(seq 1 10); do curl -s http://canary-service; echo ""; sleep 0.5; done

<h1>To jest wersja V1 aplikacji na laboratoria kubernetes!</h1>
<h1>Wersja V2 - po aktualizacji</h1>

<h1>To jest wersja V1 aplikacji na laboratoria kubernetes!</h1>
<h1>To jest wersja V1 aplikacji na laboratoria kubernetes!</h1>
<h1>To jest wersja V1 aplikacji na laboratoria kubernetes!</h1>
<h1>Wersja V2 - po aktualizacji</h1>

<h1>To jest wersja V1 aplikacji na laboratoria kubernetes!</h1>
<h1>To jest wersja V1 aplikacji na laboratoria kubernetes!</h1>
<h1>Wersja V2 - po aktualizacji</h1>

<h1>To jest wersja V1 aplikacji na laboratoria kubernetes!</h1>
 
$
```
Widać, że mamy tutaj właśnie interakcje z podami "stable" oraz "canary".
Stosunek poszczególnych odpowiedzi zależy pewnie od load balancera i może być niederministyczny.

### Wnioski

Obiekty typu Deployment abstrakcyjnie zarządzają podami, dbając o utrzymanie pożądanego stanu klastra (np. zdefiniowanej liczby replik). Kubernetes natywnie wspiera bezpieczne aktualizacje wersji aplikacji, a wbudowany mechanizm historii (rollout history i undo) pozwala na błyskawiczne wycofanie zmian w przypadku wdrożenia wadliwego obrazu. Różne strategie (Recreate, Rolling Update, Canary) pozwalają dostosować proces wdrożenia do wymagań biznesowych, balansując między brakiem dostępności a płynnym przenoszeniem ruchu.


## Temat 11

#### Kubernetes - ciąg dalszy 

Na podstawie wcześniej utworzonego klastra z aplikacją nginx próbuje wyeksponować na różne sposoby. Na początku mam ustawioną liczbę podów na 12, aby nie zapchać całego RAM'u maszyny wirtualnej. Dodatkowo modyfikuje plik deployment'u - dodaje wyświetlanie identyfikatora każdego poda przy zapytaniu http:

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 12  # Ogromna liczba podów!
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
      - name: nginx-container
        image: nginx:alpine
        # Pod wpisuje swoją nazwę na stronę WWW
        command: ["/bin/sh", "-c"]
        args: ["echo \"<h1>Odpowiada Pod: $HOSTNAME</h1>\" > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
        ports:
        - containerPort: 80
```

![img](../screenshots/lab11/Zrzut%20ekranu%202026-06-03%20091419.png)

Najpierw przekierowuje porty z jednego poda:

![img](../screenshots/lab11/Zrzut%20ekranu%202026-06-03%20091855.png)

Widać, że pod poprawnie odpowiada identyfikatorem nadanym poprzez deployment:

![img](../screenshots/lab11/Zrzut%20ekranu%202026-06-03%20091904.png)

Tak samo robie następnie dla całego deploymentu - to przypisze mi dokładnie jeden pod należący do klastra:

![img](../screenshots/lab11/Zrzut%20ekranu%202026-06-03%20092236.png)

Wynkiem jest ponownie odpowiedź z identyfikatorem poda:

![img](../screenshots/lab11/Zrzut%20ekranu%202026-06-03%20092246.png)


Dodatkowo jeszcze można to zrobić na 2 sposoby:

- poleceniem:
``` kubectl expose deployment web-deployment --name=web-service-cmd --port=80 --target-port=80```

- oddzielnym plikiem yaml:

```yml
apiVersion: v1
kind: Service
metadata:
  name: web-service-yaml
spec:
  selector:
    app: web-server
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Ponownie tworze tymczasowy pod żeby przetestować działanie tej zmiany:

```
bartosz123@ansible-master:~/MDO2026s_ITE$ kubectl run test-pod --rm -i --tty --image=curlimages/curl -- sh
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
~ $ for i in $(seq 1 10); do curl -s http://web-service-yaml; done
<h1>Odpowiada Pod: web-deployment-787c5b74bc-hvt8g</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-59tdf</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-59tdf</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-sjl7x</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-59tdf</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-qwdtx</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-hvt8g</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-kx44x</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-sw6fv</h1>
<h1>Odpowiada Pod: web-deployment-787c5b74bc-5jtn7</h1>
```
Jak widać, zwracane są pody o różnych identyfikatorach należących do deploymentu.


Na koniec ponownie przeskalowuje klaster:


- za pomocą polecenia scale:

```sh
bartosz123@ansible-master:~/MDO2026s_ITE/ITE/GCL1/BB419678/lab11$ kubectl scale deployment web-deployment --replicas=10
deployment.apps/web-deployment scaled
bartosz123@ansible-master:~/MDO2026s_ITE/ITE/GCL1/BB419678/lab11$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
test-pod                          1/1     Running   0          6m42s
web-deployment-787c5b74bc-59tdf   1/1     Running   0          111m
web-deployment-787c5b74bc-5jtn7   1/1     Running   0          111m
web-deployment-787c5b74bc-hvt8g   1/1     Running   0          111m
web-deployment-787c5b74bc-hww2v   1/1     Running   0          111m
web-deployment-787c5b74bc-j9k2w   1/1     Running   0          111m
web-deployment-787c5b74bc-kx44x   1/1     Running   0          111m
web-deployment-787c5b74bc-qwdtx   1/1     Running   0          111m
web-deployment-787c5b74bc-sw6fv   1/1     Running   0          111m
web-deployment-787c5b74bc-thnkb   1/1     Running   0          111m
web-deployment-787c5b74bc-zn4v5   1/1     Running   0          111m
```

- za pomocą ponownie zmodyfikowanego pliku yaml:

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 8  # liczba podow zmieniona na 8
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
      - name: nginx-container
        image: nginx:alpine
        # Pod wpisuje swoją nazwę na stronę WWW
        command: ["/bin/sh", "-c"]
        args: ["echo \"<h1>Odpowiada Pod: $HOSTNAME</h1>\" > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
        ports:
        - containerPort: 80
```

```sh
bartosz123@ansible-master:~/MDO2026s_ITE/ITE/GCL1/BB419678/lab11$ kubectl apply -f web-deployment.yaml 
deployment.apps/web-deployment configured
bartosz123@ansible-master:~/MDO2026s_ITE/ITE/GCL1/BB419678/lab11$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
test-pod                          1/1     Running   0          8m15s
web-deployment-787c5b74bc-59tdf   1/1     Running   0          113m
web-deployment-787c5b74bc-hvt8g   1/1     Running   0          113m
web-deployment-787c5b74bc-hww2v   1/1     Running   0          113m
web-deployment-787c5b74bc-j9k2w   1/1     Running   0          113m
web-deployment-787c5b74bc-qwdtx   1/1     Running   0          113m
web-deployment-787c5b74bc-sw6fv   1/1     Running   0          113m
web-deployment-787c5b74bc-thnkb   1/1     Running   0          113m
web-deployment-787c5b74bc-zn4v5   1/1     Running   0          113m
```

### Wnioski

Kubernetes udostępnia elastyczne metody eksponowania usług na zewnątrz – od bezpośredniego przekierowania portów (port-forwarding) dla pojedynczego poda, aż po abstrakcyjne serwisy (Service) rozkładające ruch na całe wdrożenie. Skalowanie zasobów w klastrze można realizować zarówno imperatywnie (polecenie scale), jak i deklaratywnie (aktualizacja pliku YAML), przy czym podejście deklaratywne jest preferowane ze względu na możliwość trzymania infrastruktury w kodzie (Infrastructure as Code).