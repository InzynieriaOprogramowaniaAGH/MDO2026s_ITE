# Sprawozdanie 3 - Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

## Zajęcia 08

Celem zajęć było przygotowanie środowiska zarządzanego przez Ansible, wykonanie inwentaryzacji maszyn, sprawdzenie zdalnego wykonywania poleceń oraz wdrożenie przygotowanego artefaktu na maszynie docelowej. W ramach zadania wykorzystano dwie maszyny wirtualne:

```text
devops-vm        - maszyna główna, pełniąca rolę orchestratora
ansible-target   - maszyna docelowa, pełniąca rolę endpointa
```

Maszyna `ansible-target` została przygotowana wcześniej jako lekka instalacja Ubuntu Server w wersji minimalnej. Zapewniono obecność programu `tar`, serwera `OpenSSH` oraz użytkownika `ansible`. Na głównej maszynie zainstalowano Ansible, skonfigurowano połączenie SSH bez hasła oraz przygotowano pliki inventory, playbooki i rolę Ansible.

---

## 1. Przygotowanie struktury sprawozdania

Na początku utworzono osobny katalog dla trzeciego sprawozdania oraz katalogi potrzebne do pracy z Ansible:

```bash
cd ~/MDO2026s_ITE/ITE/GCL1/LC417617

mkdir -p Sprawozdanie3/Zajecia8/playbooks
mkdir -p Sprawozdanie3/Zajecia8/roles
mkdir -p Sprawozdanie3/Zajecia8/artifact_source
mkdir -p Sprawozdanie3/Zajecia8/artifacts
mkdir -p Sprawozdanie3/img
```

Do katalogu `artifact_source` skopiowano również plik `Dockerfile.build` przygotowany przy poprzednich zajęciach. Plik ten posłużył później do ponownego przygotowania artefaktu `cJSON`.

![Struktura Sprawozdanie3](./img/S08_01_struktura_sprawozdanie3.png)

*Rys. 1. Przygotowana struktura katalogów dla zajęć 08.*

---

## 2. Ustalenie nazw maszyn

W zadaniu ważne było unikanie `localhost` i korzystanie z przewidywalnych nazw maszyn. Maszyna główna pełni rolę orchestratora, a maszyna `ansible-target` rolę endpointa.

Sprawdzono nazwy maszyn poleceniami:

```bash
hostnamectl
hostname
ssh ansible@ansible-target "hostnamectl && hostname && whoami"
```

![Hostname maszyn](./img/S08_02_hostname_maszyn.png)

*Rys. 2. Sprawdzenie nazw maszyn `devops-vm` oraz `ansible-target`.*

---

## 3. Konfiguracja nazw w `/etc/hosts` i weryfikacja łączności

Aby możliwe było odwoływanie się do maszyn po nazwach, skonfigurowano wpisy w pliku `/etc/hosts`. Dzięki temu maszyna docelowa mogła być wywoływana jako `ansible-target`, a nie wyłącznie przez adres IP.

Przykładowy wpis:

```text
IP_MASZYNY_GLOWNEJ devops-vm
IP_MASZYNY_DOCELOWEJ ansible-target
```

Po zapisaniu konfiguracji wykonano testy:

```bash
ping -c 3 devops-vm
ping -c 3 ansible-target
```

![Hosts i ping](./img/S08_03_hosts_i_ping.png)

*Rys. 3. Sprawdzenie wpisów w `/etc/hosts` oraz test połączenia po nazwach maszyn.*

---

## 4. Plik konfiguracyjny Ansible i inventory

W katalogu `Sprawozdanie3/Zajecia8` utworzono plik `ansible.cfg`, aby Ansible korzystał z lokalnego pliku inventory oraz lokalnego katalogu ról:

```ini
[defaults]
inventory = inventory.ini
roles_path = ./roles
host_key_checking = False
retry_files_enabled = False
stdout_callback = default

[privilege_escalation]
become_ask_pass = True
```

Następnie przygotowano plik `inventory.ini` z sekcjami wymaganymi w zadaniu:

```ini
[Orchestrators]
devops-vm ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

Sekcja `Orchestrators` zawiera maszynę zarządzającą, a sekcja `Endpoints` zawiera maszynę docelową.

![Inventory](./img/S08_04_inventory.png)

*Rys. 4. Plik inventory z sekcjami `Orchestrators` oraz `Endpoints`.*

---

## 5. Ping Ansible do wszystkich maszyn

Po przygotowaniu inventory wykonano test połączenia z użyciem modułu `ping` Ansible:

```bash
ansible all -m ping
```

Test potwierdził, że Ansible widzi zarówno maszynę główną, jak i endpoint.

![Ansible ping CLI](./img/S08_05_ansible_ping_cli.png)

*Rys. 5. Wynik polecenia `ansible all -m ping`.*

---

## 6. Playbook sprawdzający łączność

Utworzono playbook `01_ping_all.yml`, który wysyła żądanie ping do wszystkich maszyn z inventory:

```yaml
---
- name: Ping wszystkich maszyn z inventory
  hosts: all
  gather_facts: false

  tasks:
    - name: Sprawdzenie odpowiedzi ping Ansible
      ansible.builtin.ping:
```

Uruchomienie playbooka:

```bash
ansible-playbook playbooks/01_ping_all.yml
```

![Playbook ping](./img/S08_06_playbook_ping.png)

*Rys. 6. Uruchomienie playbooka sprawdzającego łączność ze wszystkimi maszynami.*

---

## 7. Kopiowanie pliku inventory na endpoint

Kolejny playbook wykonywał operacje administracyjne na maszynie `ansible-target`. Jednym z pierwszych zadań było skopiowanie pliku inventory na endpoint:

```yaml
- name: Skopiowanie pliku inventory na endpoint
  ansible.builtin.copy:
    src: ../inventory.ini
    dest: /tmp/inventory.ini
    owner: ansible
    group: ansible
    mode: "0644"
```

Playbook uruchomiono dwukrotnie, aby porównać różnice w wyjściu. Przy pierwszym uruchomieniu plik został skopiowany i zadanie otrzymało status `changed`.

![Kopiowanie inventory pierwszy raz](./img/S08_07_kopiowanie_inventory_pierwszy_raz.png)

*Rys. 7. Pierwsze skopiowanie pliku inventory na endpoint.*

Przy drugim uruchomieniu Ansible wykazał mniejszą liczbę zmian, ponieważ część stanu była już zgodna z oczekiwanym. Pokazuje to idempotentny charakter zadań Ansible.

![Kopiowanie inventory drugi raz](./img/S08_08_kopiowanie_inventory_drugi_raz.png)

*Rys. 8. Ponowne uruchomienie operacji i porównanie różnic w wyjściu.*

---

## 8. Aktualizacja pakietów i restart usług

W playbooku wykonano również aktualizację cache pakietów APT, bezpieczną aktualizację pakietów oraz instalację wymaganych pakietów:

```yaml
- name: Aktualizacja cache
  ansible.builtin.apt:
    update_cache: true
    cache_valid_time: 3600

- name: Bezpieczna aktualizacja
  ansible.builtin.apt:
    upgrade: safe

- name: Instalacja pakietów
  ansible.builtin.apt:
    name:
      - tar
      - openssh-server
      - rng-tools5
    state: present
```

![Aktualizacja pakietów](./img/S08_09_aktualizacja_pakietow.png)

*Rys. 9. Aktualizacja cache APT, bezpieczna aktualizacja systemu oraz instalacja wymaganych pakietów.*

Następnie pobrano informacje o usługach i wykonano restart usług `ssh` oraz `rngd`:

```yaml
- name: Restart SSH Ubuntu
  ansible.builtin.service:
    name: ssh
    state: restarted

- name: Restart usługi rngd, jeśli istnieje
  ansible.builtin.service:
    name: rngd
    state: restarted
  register: rngd_restart
  failed_when: false
```

![Restart usług](./img/S08_10_restart_uslug.png)

*Rys. 10. Restart usług `ssh` oraz `rngd` na maszynie docelowej.*

---

## 9. Test maszyny z wyłączonym SSH

W ramach testu awarii zatrzymano usługę SSH na maszynie `ansible-target`. Ponieważ w Ubuntu SSH może być aktywowane przez socket, zatrzymano zarówno usługę, jak i socket:

```bash
sudo systemctl stop ssh.socket
sudo systemctl stop ssh.service
```

Następnie uruchomiono playbook testujący zachowanie Ansible przy niedostępnym endpoincie:

```bash
ansible-playbook playbooks/03_unreachable_test.yml
```

Playbook został przygotowany tak, aby nie kończył całej pracy awarią w przypadku niedostępności maszyny:

```yaml
---
- name: Test zachowania Ansible przy niedostępnym endpoincie
  hosts: Endpoints
  gather_facts: false
  ignore_unreachable: true

  tasks:
    - name: Próba ping Ansible do endpointa
      ansible.builtin.ping:
      register: ping_result
      failed_when: false

    - name: Pokazanie wyniku próby połączenia
      ansible.builtin.debug:
        var: ping_result
```

![Test braku SSH](./img/S08_11_test_braku_ssh.png)

*Rys. 11. Test zachowania playbooka przy niedostępnej usłudze SSH.*

Po zakończeniu testu SSH zostało ponownie uruchomione:

```bash
sudo systemctl start ssh.socket
sudo systemctl start ssh.service
```

Następnie sprawdzono, że połączenie z maszyną docelową znowu działa.

![Po włączeniu SSH](./img/S08_12_po_wlaczeniu_ssh.png)

*Rys. 12. Przywrócenie działania SSH po teście awarii.*

---

## 10. Przygotowanie artefaktu cJSON

Artefaktem z poprzednich zajęć był zestaw plików zbudowanych dla projektu `cJSON`. Na potrzeby zajęć 08 artefakt został ponownie przygotowany lokalnie, a następnie spakowany do pliku `cjson-artifact.tar.gz`.

Wykonano między innymi:

```bash
docker build --no-cache \
  -f artifact_source/Dockerfile.build \
  -t lc417617-cjson-bldr:s08 \
  artifact_source

mkdir -p artifacts

docker create --name cjson_artifact_s08 lc417617-cjson-bldr:s08 /bin/true
docker cp cjson_artifact_s08:/artifact artifacts/cjson-artifact
docker rm cjson_artifact_s08

tar -czf artifacts/cjson-artifact.tar.gz -C artifacts cjson-artifact
```

![Przygotowanie artefaktu cJSON](./img/S08_13_przygotowanie_artefaktu_cjson.png)

*Rys. 13. Przygotowanie artefaktu `cJSON` do wdrożenia przez Ansible.*

---

## 11. Utworzenie roli Ansible

Zgodnie z wymaganiem zadania kroki wdrożeniowe zostały ujęte w rolę Ansible. Strukturę roli utworzono komendą:

```bash
cd Sprawozdanie3/Zajecia8/roles
ansible-galaxy role init cjson_deploy
```

Następnie sprawdzono wygenerowaną strukturę katalogów.

![Rola ansible-galaxy](./img/S08_14_ansible_galaxy_role.png)

*Rys. 14. Utworzenie szkieletu roli `cjson_deploy` za pomocą `ansible-galaxy`.*

---

## 12. Plik `meta/main.yml`

W roli uzupełniono plik `meta/main.yml`, opisujący autora, przeznaczenie roli, wspierany system oraz tagi.

Przykładowa zawartość:

```yaml
galaxy_info:
  author: LC417617
  description: Deploy artefaktu cJSON w Docker na endpoint
  company: AGH
  license: MIT
  min_ansible_version: "2.14"

  platforms:
    - name: Ubuntu
      versions:
        - noble

  galaxy_tags:
    - devops
    - docker
    - cjson
    - deployment

dependencies: []
```

![Meta roli](./img/S08_15_meta_roli.png)

*Rys. 15. Uzupełniony plik `meta/main.yml` roli `cjson_deploy`.*

---

## 13. Sanity check i instalacja Dockera przez Ansible

Rola `cjson_deploy` rozpoczyna się od sanity checka maszyny docelowej. Sprawdzono między innymi informacje o systemie, obecność programu `tar` oraz ilość miejsca na dysku.

Następnie Docker został zainstalowany na maszynie docelowej przez Ansible:

```yaml
- name: Instalacja Dockera na maszynie docelowej
  ansible.builtin.apt:
    name:
      - docker.io
      - tar
    state: present

- name: Uruchomienie i włączenie usługi Docker
  ansible.builtin.service:
    name: docker
    state: started
    enabled: true
```

![Sanity check i Docker](./img/S08_16_sanity_check_i_docker.png)

*Rys. 16. Sanity check maszyny docelowej oraz instalacja Dockera przez Ansible.*

---

## 14. Wdrożenie artefaktu na endpoint

Rola kopiuje artefakt `cjson-artifact.tar.gz` na maszynę `ansible-target`, rozpakowuje go w katalogu `/opt/cjson-demo`, kopiuje `Dockerfile.runtime`, a następnie buduje obraz runtime.

Najważniejsze zadania:

```yaml
- name: Skopiowanie artefaktu cJSON na endpoint
  ansible.builtin.copy:
    src: cjson-artifact.tar.gz
    dest: /opt/cjson-demo/cjson-artifact.tar.gz
    owner: root
    group: root
    mode: "0644"

- name: Rozpakowanie artefaktu na endpoint
  ansible.builtin.unarchive:
    src: /opt/cjson-demo/cjson-artifact.tar.gz
    dest: /opt/cjson-demo
    remote_src: true

- name: Zbudowanie obrazu runtime dla artefaktu cJSON
  ansible.builtin.command: docker build -t lc417617-cjson-deploy:s08 /opt/cjson-demo
```

![Deploy artefaktu](./img/S08_17_deploy_artefaktu.png)

*Rys. 17. Skopiowanie artefaktu, rozpakowanie go i zbudowanie obrazu runtime na maszynie docelowej.*

---

## 15. Weryfikacja działania kontenera

Po zbudowaniu obrazu uruchomiono kontener z artefaktem `cJSON`. Następnie pobrano jego logi i sprawdzono, czy zawierają komunikat potwierdzający poprawne uruchomienie:

```yaml
- name: Uruchomienie kontenera z artefaktem cJSON
  ansible.builtin.command: docker run --name cjson-demo lc417617-cjson-deploy:s08
  register: docker_run

- name: Pobranie logów kontenera
  ansible.builtin.command: docker logs cjson-demo
  register: container_logs
  changed_when: false

- name: Weryfikacja poprawnego uruchomienia artefaktu
  ansible.builtin.assert:
    that:
      - "'cJSON deploy smoke test passed' in container_logs.stdout"
    success_msg: "Artefakt cJSON uruchomił się poprawnie w kontenerze."
    fail_msg: "Artefakt cJSON nie uruchomił się poprawnie."
```

![Weryfikacja kontenera](./img/S08_18_weryfikacja_kontenera.png)

*Rys. 18. Weryfikacja poprawnego uruchomienia artefaktu `cJSON` w kontenerze.*

---

## 16. Czyszczenie środowiska docelowego

Po zakończonym wdrożeniu wykonano czyszczenie środowiska docelowego. Usunięto kontener, obraz runtime oraz katalog wdrożeniowy `/opt/cjson-demo`.

Wykorzystano playbook `05_cleanup_cjson.yml`:

```yaml
---
- name: Czyszczenie środowiska po wdrożeniu cJSON
  hosts: Endpoints
  become: true
  gather_facts: false

  tasks:
    - name: Usunięcie kontenera cjson-demo
      ansible.builtin.command: docker rm -f cjson-demo
      register: cleanup_container
      failed_when: false
      changed_when: cleanup_container.rc == 0

    - name: Usunięcie obrazu runtime
      ansible.builtin.command: docker rmi lc417617-cjson-deploy:s08
      register: cleanup_image
      failed_when: false
      changed_when: cleanup_image.rc == 0

    - name: Usunięcie katalogu wdrożeniowego
      ansible.builtin.file:
        path: /opt/cjson-demo
        state: absent
```

![Czyszczenie środowiska docelowego](./img/S08_19_czyszczenie_srodowiska_docelowego.png)

*Rys. 19. Czyszczenie środowiska docelowego po zakończeniu wdrożenia.*

---

## 17. Zapisanie zmian w repozytorium

Po wykonaniu zadania dodano do repozytorium pliki konfiguracyjne Ansible, playbooki, strukturę roli, pliki artefaktu oraz zrzuty ekranu.

Wykonano:

```bash
git add Sprawozdanie3/Zajecia8
git add Sprawozdanie3/img/S08_*.png
git commit -m "LC417617 wykonanie Zajec 08 Ansible"
git push origin LC417617
```

![Commit i push](./img/S08_20_commit_push.png)

*Rys. 20. Przed dodaniem plików zajęć 08 do repozytorium.*

---

## 18. Listing najważniejszych poleceń

Poniżej przedstawiono najważniejsze polecenia użyte podczas wykonywania zadania. Listing nie zawiera haseł, tokenów ani innych danych wrażliwych.

```bash
cd ~/MDO2026s_ITE/ITE/GCL1/LC417617

mkdir -p Sprawozdanie3/Zajecia8/playbooks
mkdir -p Sprawozdanie3/Zajecia8/roles
mkdir -p Sprawozdanie3/Zajecia8/artifact_source
mkdir -p Sprawozdanie3/Zajecia8/artifacts
mkdir -p Sprawozdanie3/img

cp Sprawozdanie2/Zajecia7/Dockerfile.build Sprawozdanie3/Zajecia8/artifact_source/Dockerfile.build

hostnamectl
hostname
ssh ansible@ansible-target "hostnamectl && hostname && whoami"

sudo nano /etc/hosts
ping -c 3 devops-vm
ping -c 3 ansible-target

cd Sprawozdanie3/Zajecia8

nano ansible.cfg
nano inventory.ini
ansible-inventory --list
ansible all -m ping

nano playbooks/01_ping_all.yml
ansible-playbook playbooks/01_ping_all.yml

nano playbooks/02_system_ops.yml
ansible-playbook playbooks/02_system_ops.yml -K
ansible-playbook playbooks/02_system_ops.yml -K

nano playbooks/03_unreachable_test.yml
ansible-playbook playbooks/03_unreachable_test.yml

docker build --no-cache -f artifact_source/Dockerfile.build -t lc417617-cjson-bldr:s08 artifact_source
mkdir -p artifacts
docker create --name cjson_artifact_s08 lc417617-cjson-bldr:s08 /bin/true
docker cp cjson_artifact_s08:/artifact artifacts/cjson-artifact
docker rm cjson_artifact_s08
tar -czf artifacts/cjson-artifact.tar.gz -C artifacts cjson-artifact

cd roles
ansible-galaxy role init cjson_deploy
cd ..

cp artifacts/cjson-artifact.tar.gz roles/cjson_deploy/files/
nano roles/cjson_deploy/files/Dockerfile.runtime
nano roles/cjson_deploy/meta/main.yml
nano roles/cjson_deploy/tasks/main.yml

nano playbooks/04_deploy_cjson_role.yml
ansible-playbook playbooks/04_deploy_cjson_role.yml -K

nano playbooks/05_cleanup_cjson.yml
ansible-playbook playbooks/05_cleanup_cjson.yml -K

cd ~/MDO2026s_ITE/ITE/GCL1/LC417617
git add Sprawozdanie3/Zajecia8
git add Sprawozdanie3/img/S08_*.png
git commit -m "LC417617 wykonanie Zajec 08 Ansible"
git push origin LC417617
```

---

## 19. Użycie narzędzi generatywnej AI

Podczas realizacji zadania wykorzystano model LLM jako pomoc przy uporządkowaniu kolejności działań, przygotowaniu playbooków Ansible, analizie problemów z łącznością SSH oraz opisaniu wyników w sprawozdaniu.

### Treść głównego zapytania

> Pomóż mi wykonać zadanie z Ansible dotyczące automatyzacji i zdalnego wykonywania poleceń. Mam maszynę główną `devops-vm` oraz maszynę docelową `ansible-target`. Chcę przygotować inventory z sekcjami Orchestrators i Endpoints, wykonać ping Ansible, skopiować inventory, zaktualizować pakiety, zrestartować usługi sshd i rngd, obsłużyć przypadek niedostępnego SSH oraz wdrożyć artefakt cJSON przy pomocy roli utworzonej przez ansible-galaxy.

### Metoda weryfikacji odpowiedzi

Odpowiedzi modelu zostały zweryfikowane praktycznie podczas wykonywania zadania:

* poprawność inventory sprawdzono poleceniami `ansible-inventory --list` oraz `ansible all -m ping`,
* poprawność łączności SSH sprawdzono przez logowanie `ssh ansible@ansible-target`,
* działanie playbooka ping potwierdzono przez `ansible-playbook playbooks/01_ping_all.yml`,
* kopiowanie inventory sprawdzono przez dwukrotne uruchomienie playbooka i porównanie wyniku,
* aktualizację pakietów oraz restart usług zweryfikowano przez wyniki zadań Ansible,
* przypadek niedostępnego SSH sprawdzono przez zatrzymanie `ssh.socket` i `ssh.service`,
* wdrożenie artefaktu sprawdzono przez uruchomienie kontenera i odczyt logów,
* poprawne działanie artefaktu potwierdzono komunikatem `cJSON deploy smoke test passed`,
* czyszczenie środowiska potwierdzono przez playbook usuwający kontener, obraz oraz katalog wdrożeniowy.




## Zajęcia 09 - Pliki odpowiedzi dla wdrożeń nienadzorowanych

Celem zajęć było przygotowanie pliku odpowiedzi dla instalacji nienadzorowanej systemu Fedora. Instalacja miała zostać wykonana z użyciem pliku Kickstart znajdującego się w repozytorium, a po pierwszym uruchomieniu system miał automatycznie przygotować środowisko do uruchomienia artefaktu `cJSON`.

W ramach zadania wykorzystano maszynę główną `devops-vm`, która udostępniała plik Kickstart i artefakt przez prosty serwer HTTP, oraz nową maszynę wirtualną `fedora-cjson-auto`, na której przeprowadzono instalację Fedory.

---

### 1. Przygotowanie maszyny wirtualnej Fedora

Utworzono nową maszynę wirtualną w Hyper-V przeznaczoną do instalacji Fedory. Maszyna została utworzona jako maszyna drugiej generacji, czyli z obsługą UEFI.

Przyjęte ustawienia:

```text
Nazwa maszyny: fedora-cjson-auto
Generacja: Generation 2 / UEFI
Pamięć RAM: 2048 MB
Dysk: 20 GB
Sieć: ten sam przełącznik Hyper-V co maszyna devops-vm
Obraz ISO: Fedora Server 44
```

![Maszyna Fedora UEFI](./img/S09_02_fedora_vm_uefi.png)

*Rys. 21. Konfiguracja maszyny wirtualnej Fedora w Hyper-V.*

---

### 2. Pierwsza ręczna instalacja Fedory

Najpierw wykonano ręczną instalację Fedory. Było to potrzebne do uzyskania bazowego pliku odpowiedzi wygenerowanego przez instalator Anaconda.

Podczas instalacji ustawiono między innymi:

```text
hostname: fedora-cjson-auto
użytkownik: deploy
typ instalacji: Fedora Server Edition
partycjonowanie: automatyczne
```

![Ręczna instalacja Fedory](./img/S09_03_instalacja_fedora_reczna.png)

*Rys. 22. Pierwsza ręczna instalacja Fedory.*

Po zakończeniu instalacji zalogowano się do systemu i skopiowano wygenerowany plik Kickstart z katalogu `/root`:

```bash
sudo cp /root/anaconda-ks.cfg /home/deploy/anaconda-ks-source.cfg
sudo chown deploy:deploy /home/deploy/anaconda-ks-source.cfg
ls -l /home/deploy/anaconda-ks-source.cfg
head -40 /home/deploy/anaconda-ks-source.cfg
```

![Plik anaconda-ks.cfg](./img/S09_04_anaconda_ks_cfg.png)

*Rys. 23. Bazowy plik odpowiedzi `anaconda-ks.cfg` wygenerowany przez instalator.*

Plik został następnie skopiowany na maszynę `devops-vm` do katalogu:

```text
Sprawozdanie3/Zajecia9/kickstart/anaconda-ks-source.cfg
```

---

### 3. Przygotowanie właściwego pliku Kickstart

Na podstawie pliku `anaconda-ks.cfg` przygotowano docelowy plik odpowiedzi:

```text
Sprawozdanie3/Zajecia9/kickstart/ks-fedora-cjson.cfg
```

Ten sam plik został również skopiowany do katalogu udostępnianego przez HTTP:

```text
Sprawozdanie3/Zajecia9/http/ks-fedora-cjson.cfg
```

Plik Kickstart zawierał między innymi:

```kickstart
text
reboot

lang en_US.UTF-8
keyboard --xlayouts='pl'
timezone Europe/Warsaw --utc

network --bootproto=dhcp --device=link --activate --hostname=fedora-cjson-auto

url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64

rootpw --lock
user --name=deploy --groups=wheel --password=HASLO_W_POSTACI_HASH --iscrypted --gecos="Deploy User"

zerombr
clearpart --all --initlabel
autopart --type=lvm

services --enabled=sshd,docker
```

Zastosowano `clearpart --all --initlabel`, aby instalacja mogła być wykonywana wielokrotnie na tej samej maszynie i za każdym razem czyściła dysk przed ponowną instalacją.

W sekcji `%packages` dodano pakiety potrzebne do działania systemu oraz kontenera:

```kickstart
%packages
@core
openssh-server
moby-engine
curl
tar
ca-certificates
%end
```

W sekcji `%post` dodano mechanizm pobierania artefaktu `cJSON` oraz pliku `Dockerfile.runtime` z serwera HTTP uruchomionego na maszynie `devops-vm`. Dodatkowo utworzono usługę systemd `cjson-firstboot.service`, której zadaniem było zbudowanie obrazu kontenera i uruchomienie aplikacji po pierwszym starcie systemu.

---

### 4. Udostępnienie pliku odpowiedzi i artefaktu przez HTTP

Na maszynie `devops-vm` uruchomiono prosty serwer HTTP w katalogu:

```text
Sprawozdanie3/Zajecia9/http
```

W katalogu znajdowały się pliki:

```text
ks-fedora-cjson.cfg
cjson-artifact.tar.gz
Dockerfile.runtime
```

Serwer uruchomiono poleceniem:

```bash
cd ~/MDO2026s_ITE/ITE/GCL1/LC417617/Sprawozdanie3/Zajecia9/http
python3 -m http.server 8000 --bind 0.0.0.0
```

Dostępność plików sprawdzono poleceniami `curl`:

```bash
curl http://ADRES_IP_DEVOPS:8000/ks-fedora-cjson.cfg | head
curl -I http://ADRES_IP_DEVOPS:8000/cjson-artifact.tar.gz
curl -I http://ADRES_IP_DEVOPS:8000/Dockerfile.runtime
```

![Serwer HTTP](./img/S09_06_http_server.png)

*Rys. 24. Udostępnienie pliku Kickstart oraz artefaktu przez prosty serwer HTTP.*

---

### 5. Uruchomienie instalacji nienadzorowanej

Następnie uruchomiono maszynę `fedora-cjson-auto` z obrazu ISO Fedory. Na ekranie bootowania Fedory wybrano opcję instalacji i przejście do edycji parametrów startowych GRUB.

Do linii startowej dopisano parametr `inst.ks`, wskazujący na plik Kickstart udostępniany przez maszynę `devops-vm`:

```text
inst.ks=http://ADRES_IP_DEVOPS:8000/ks-fedora-cjson.cfg ip=dhcp
```

W praktyce użyto adresu IP maszyny `devops-vm`, odczytanego z pola `src` polecenia:

```bash
ip route get 1.1.1.1
```

![Parametr inst.ks](./img/S09_07_boot_inst_ks.png)

*Rys. 25. Dopisanie parametru `inst.ks` w ekranie bootowania Fedory.*

Po uruchomieniu instalatora plik odpowiedzi został pobrany z serwera HTTP. Instalator nie wymagał ręcznego wybierania użytkownika, partycjonowania, hostname ani pakietów.

![Instalacja bez pytań](./img/S09_08_instalacja_bez_pytan.png)

*Rys. 26. Instalacja nienadzorowana Fedory z użyciem pliku Kickstart.*

Na końcu instalacji system został automatycznie zrestartowany dzięki dyrektywie:

```kickstart
reboot
```

![Restart po instalacji](./img/S09_09_reboot_po_instalacji.png)

*Rys. 27. Automatyczny restart maszyny po zakończeniu instalacji.*

---

### 6. Pierwsze uruchomienie systemu po instalacji

Po restarcie maszyna uruchomiła już zainstalowany system Fedora. Sprawdzono nazwę hosta oraz wersję systemu:

```bash
hostname
whoami
cat /etc/fedora-release
```

![Pierwsze uruchomienie Fedory](./img/S09_10_pierwsze_uruchomienie.png)

*Rys. 28. Pierwsze uruchomienie systemu po instalacji nienadzorowanej.*

---

### 7. Sprawdzenie usługi Docker

Plik Kickstart instalował pakiet `moby-engine`, który zapewnia działanie silnika kontenerowego zgodnego z Dockerem. Po pierwszym uruchomieniu sprawdzono usługę Docker:

```bash
sudo systemctl status docker --no-pager
sudo docker version
```

![Usługa Docker](./img/S09_11_docker_service.png)

*Rys. 29. Sprawdzenie działania usługi Docker po instalacji systemu.*

---

### 8. Automatyczne uruchomienie artefaktu cJSON

W sekcji `%post` pliku Kickstart utworzono usługę systemd `cjson-firstboot.service`. Jej zadaniem było wykonanie działań po pierwszym uruchomieniu systemu, ponieważ polecenia `docker run` nie powinny być wykonywane bezpośrednio z poziomu instalatora.

Usługa wykonywała skrypt:

```text
/usr/local/sbin/cjson-firstboot.sh
```

Skrypt po pierwszym starcie systemu:

```text
1. rozpakowywał artefakt cJSON,
2. czekał na dostępność Dockera,
3. budował obraz kontenera,
4. uruchamiał kontener cjson-demo,
5. zapisywał logi do /var/log/cjson-demo.log.
```

Sprawdzono status kontenera:

```bash
sudo docker ps -a
sudo docker logs cjson-demo
```

![Kontener cJSON](./img/S09_12_cjson_container_running.png)

*Rys. 30. Kontener `cjson-demo` uruchomiony po pierwszym starcie systemu.*

---

### 9. Weryfikacja działania programu

Poprawność działania programu zweryfikowano przez odczyt logów kontenera oraz pliku `/var/log/cjson-demo.log`:

```bash
sudo docker logs cjson-demo
cat /var/log/cjson-demo.log
```

W logach znajdował się komunikat:

```text
cJSON deploy smoke test passed
```

Oznacza to, że artefakt przygotowany w poprzednich zadaniach został poprawnie pobrany, umieszczony w kontenerze i uruchomiony po pierwszym starcie systemu.

![Logi cJSON](./img/S09_13_cjson_logs.png)

*Rys. 31. Logi kontenera potwierdzające poprawne uruchomienie programu.*

---

### 10. Log sekcji `%post`

Dodatkowo sprawdzono log sekcji `%post`, zapisany w pliku:

```text
/root/ks-post.log
```

Wykonano:

```bash
sudo cat /root/ks-post.log
```

![Log ks-post](./img/S09_14_ks_post_log.png)

*Rys. 32. Log działań wykonanych w sekcji `%post` pliku Kickstart.*

---

### 11. Pliki przygotowane w repozytorium

W repozytorium umieszczono pliki potrzebne do odtworzenia instalacji nienadzorowanej:

```text
Sprawozdanie3/Zajecia9/http/cjson-artifact.tar.gz
Sprawozdanie3/Zajecia9/http/Dockerfile.runtime
Sprawozdanie3/Zajecia9/http/ks-fedora-cjson.cfg
Sprawozdanie3/Zajecia9/kickstart/anaconda-ks-source.cfg
Sprawozdanie3/Zajecia9/kickstart/ks-fedora-cjson.cfg
```

Plik `anaconda-ks-source.cfg` jest bazowym plikiem odpowiedzi wygenerowanym przez ręczną instalację Fedory. Plik `ks-fedora-cjson.cfg` jest zmodyfikowaną wersją używaną do instalacji nienadzorowanej.

---

### 12. Listing najważniejszych poleceń

Poniżej przedstawiono najważniejsze polecenia użyte podczas wykonywania zadania. Listing nie zawiera haseł ani tokenów.

```bash
cd ~/MDO2026s_ITE/ITE/GCL1/LC417617

mkdir -p Sprawozdanie3/Zajecia9/kickstart
mkdir -p Sprawozdanie3/Zajecia9/http
mkdir -p Sprawozdanie3/img

cp Sprawozdanie3/Zajecia8/artifacts/cjson-artifact.tar.gz Sprawozdanie3/Zajecia9/http/

scp deploy@IP_FEDORY:/home/deploy/anaconda-ks-source.cfg Sprawozdanie3/Zajecia9/kickstart/anaconda-ks-source.cfg

nano Sprawozdanie3/Zajecia9/http/Dockerfile.runtime
nano Sprawozdanie3/Zajecia9/kickstart/ks-fedora-cjson.cfg

DEVOPS_IP=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')
echo "$DEVOPS_IP"

sed -i "s#__DEVOPS_IP__#${DEVOPS_IP}#g" Sprawozdanie3/Zajecia9/kickstart/ks-fedora-cjson.cfg

cp Sprawozdanie3/Zajecia9/kickstart/ks-fedora-cjson.cfg Sprawozdanie3/Zajecia9/http/

cd Sprawozdanie3/Zajecia9/http
python3 -m http.server 8000 --bind 0.0.0.0

curl http://${DEVOPS_IP}:8000/ks-fedora-cjson.cfg | head
curl -I http://${DEVOPS_IP}:8000/cjson-artifact.tar.gz
curl -I http://${DEVOPS_IP}:8000/Dockerfile.runtime

git add Sprawozdanie3/Zajecia9
git add Sprawozdanie3/img/S09_*.png
git commit -m "LC417617 Zajecia 09 - Kickstart"
git push origin LC417617
```

---

### 13. Użycie narzędzi generatywnej AI

Podczas realizacji zadania wykorzystano model LLM jako pomoc przy uporządkowaniu kolejności działań, przygotowaniu pliku Kickstart, analizie błędów z pobieraniem pliku odpowiedzi oraz opracowaniu opisu do sprawozdania.

#### Treść głównego zapytania

> Chcę przygotować instalację Fedory z użyciem pliku Kickstart z repozytorium. System po instalacji ma pobrać artefakt cJSON z repozytorium Gita lub ode mnie, zainstalować Dockera i po pierwszym uruchomieniu automatycznie uruchomić kontener z programem. Jak ogarnąć Fedorę z instalacją ręczną oraz z nienadzarowaną?

#### Metoda weryfikacji odpowiedzi

Odpowiedzi modelu zostały zweryfikowane praktycznie podczas wykonywania zadania:

* bazowy plik odpowiedzi potwierdzono przez obecność `/root/anaconda-ks.cfg`,
* poprawność udostępnienia pliku Kickstart sprawdzono przez `curl`,
* instalację nienadzorowaną potwierdzono przez uruchomienie instalatora z parametrem `inst.ks`,
* brak ręcznego uzupełniania danych potwierdził poprawność pliku odpowiedzi,
* automatyczny restart potwierdził działanie dyrektywy `reboot`,
* instalację Dockera sprawdzono przez `systemctl status docker` oraz `docker version`,
* uruchomienie artefaktu potwierdzono przez `docker ps -a`,
* poprawność działania programu potwierdzono komunikatem `cJSON deploy smoke test passed`,
* działania sekcji `%post` sprawdzono w pliku `/root/ks-post.log`.
