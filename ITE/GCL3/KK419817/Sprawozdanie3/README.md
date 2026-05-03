# Sprawozdanie 3 - Ansible

## Przygotowanie środowiska wirtualnego

### Instalacja systemu Fedora Server

Pobrałem obraz `Fedora-Server-dvd-x86_64-43-1.6.iso` i zainstalowałem go w VirtualBoxie według poleceń, ustawiając odpowiednie nazwy.

Upewniłem się o obecności sshd i tar.

```bash
which tar
systemctl status sshd
```

Utworzyłem migawkę.

![alt text](image.png)

### Konfiguracja Ansible i uwierzytelniania SSH

Na głównej maszynie zainstalowałem ansible:

```bash
sudo apt install ansible -y
```

- przelaczylem vmki na 'karta sieci izolowanej (host-only)'
- sprawdzilem ip `ip a`
- wykonałem poniższe komendy aby nie musiec sie lacyzc hasle

```
ssh-keygen -t ed25519
ssh-copy-id ansible@192.168.56.102
```

Klucze SSH umożliwiają bezpieczne połączenie bez konieczności wielokrotnego wpisywania hasła.

## Konfiguracja inwentarza

### Mapowanie nazw hostów

Ustawiłem nazwy dns w `/etc/hosts`:

![alt text](image-1.png)

Zwykły ping fedora:

![alt text](image-2.png)

Zwykły ping ubuntu:

![alt text](image-3.png)

### Plik inwentaryzacyjny

ping
`ansible all -i inventory.ini -m ping`

inventory.ini:

```yaml
[Orchestrators]
ubuntu ansible_connection=local

[Endpoints]
fedora ansible_user=ansible
```

Plik inwentaryzacyjny definiuje grupy hostów i parametry połączenia dla każdej maszyny.

![alt text](image-4.png)

Następnie jakimś cudem zepsułem połączenie między VMkami, potem połączenie z siecią, potem repozytorium się zepsuło a 'git pull' pobierał się z prędkością 10kB/s a potem i tak nie działał i - choć teoretycznie powinienem opisać proces naprawy tych wszystkich rzeczy - to jednak ze względu na dobro moje i osób w moim otoczeniu, postanowiłem mimo wszystko zaniechać tej praktyki akurat w tym przypadku.

Na koniec wykonałem `git push --force`.

Wracając, końcowo:

Z tych wszystkich powodów używam dwóch VMek z NATem.
Port forwarduje 2222 dla ubuntu i 2223 dla fedory.
Łączę się z ip lokalnego hosta, obecna zawartość `/etc/hosts`:

```bash
192.168.56.101 ubuntu
10.0.2.2 fedora
```

![alt text](image-6.png)

![alt text](image-5.png)

Dodatkowo zmodyfikowałem inventory.ini aby zawierało informację o porcie:

`fedora ansible_port=2223 ansible_user=ansible`

```bash
[Orchestrators]
ubuntu ansible_connection=local

[Endpoints]
fedora ansible_port=2223 ansible_user=ansible
```

Połączenie z maszynami przez ansible zostało zweryfikowane.

Przekierowanie portów przez NAT zapewnia stabilne połączenie między maszynami wirtualnymi.

## Zdalne wywoływanie procedur

### Utworzenie playbooka

Utworzyłem playbook:

```yaml
---
- name: Ansible Lab
  hosts: all
  tasks:
    - name: Ping
      ping:

    - name: Kopiuj inventory
      copy:
        src: ./inventory.ini
        dest: /tmp/inventory.ini
      when: inventory_hostname != 'ubuntu'

    - name: Zaktualizuj pakiety w systemie
      command: dnf upgrade -y
      when: inventory_hostname != 'ubuntu'
      become: yes

    - name: Zrestartuj usługę sshd
      service:
        name: sshd
        state: restarted
      when: inventory_hostname != 'ubuntu'
      become: yes
```

### Pierwsze wykonanie playbooka

`ansible-playbook -i inventory.ini playbook1.yaml --ask-become-pass`

(dodałem --ask-become-pass aby móc podać hasło potrzebne do niektórych operacji z wyższmi uprawnieniami)

![alt text](image-11.png)

Status `changed` wskazuje, że Ansible wykrył różnice i wprowadził zmiany w systemie docelowym.

### Ponowne uruchomienie

![alt text](image-12.png)

Widać że ansible coś zmieniło - najpierw mamy status `changed` a po drugim wykonaniu `OK` - czyli wprowadzono odpowiednie modyfikacje i te modyfikacje faktycznie zostały zapisane.

### Test bez dostępu SSH

Po wyłączeniu sshd na targecie, target jest unreachable:

`sudo systemctl stop sshd`

![alt text](image-7.png)

Brak działającego SSH uniemożliwia Ansible komunikację z hostem, co skutkuje statusem UNREACHABLE.

Ansible wymaga stabilnego połączenia SSH do wszystkich zarządzanych hostów. Bez działającego serwera SSH na maszynie docelowej, zarządzanie konfiguracją jest niemożliwe.

Moduły dedykowane Ansible (jak `copy` czy `service`) potrafią wykryć, czy zmiana jest potrzebna. Dzięki temu ponowne uruchomienie playbooka nie wprowadza niepotrzebnych modyfikacji. W przypadku `command` niestety takiego mechanizmu nie posiadamy.

---

Uruchomiłem nowy playbook `deploy.yaml`:

![alt text](image-8.png)
