# Sprawozdanie 3

## Class 08

### Wstęp

Ansible jest otwartym oprogramowaniem służącym do automatyzacji wdrażania, konfiguracji i zarządzania. Umożliwia centralne zarządzanie wieloma systemami jednocześnie, co znacząco usprawnia administrację środowiskiem oraz ogranicza ryzyko błędów wynikających z ręcznej konfiguracji.

### Instalacja zarządcy Ansible

W celu przygotowania środowiska testowego utworzono drugą maszynę wirtualną z systemem `Ubuntu Server 24.04`. Maszynie przydzielono minimalne zasoby sprzętowe: 1,5 GB pamięci RAM, 2 rdzenie procesora oraz 15 GB przestrzeni dyskowej.

Podczas instalacji systemu wybrano najmniejszy dostępny wariant instalacji, obejmujący jedynie podstawowy zestaw pakietów niezbędnych do działania systemu. Na etapie konfiguracji nadano maszynie hostname `ansible-target` oraz utworzono użytkownika `ansible`.

Na głównej maszynie, używanej przez wszystkie poprzednie zajęcia zainstalowano program `Ansible` w konsoli.

```bash
sudo apt update
sudo apt install ansible -y
```

### Wymiana kluczy między użytkownikami maszyn

Na obu maszynach w ustawieniach zmieniono połączenie z NAT na Mostkowana karta sieciowa (bridged). Po tej zmianie, maszyny pobrały adresy z domowej sieci, co pozwoliło na wzajemną wymianę adresów ip i umożliwiło komunikację między nimi. 

W celu uproszczenia komunikacji oraz identyfikacji hostów skonfigurowano plik `/etc/hosts` na obu maszynach, przypisując odpowiednie adresy ip do nazw hostów.

```bash
192.168.x.x ubuntu-server
192.168.x.x ansible-target
```

Konfigurację zweryfikowano pingując obie maszyny:

```bash
ping ansible-target
```

Natępnie, na głównej maszynie wirtualnej wygenerowano klucz SSH z komentarzem `ansible` oraz skopiowano klucz do maszyny docelowej `ansible-target`.

```bash
ssh-keygen -t ed25519 -C "ansible"
ssh-copy-id ansible@ansible-target
```

Na koniec przetestowano połączenie z maszyny `ubustu-server` na `ansible-taget` poprzez ssh bez podawnia hasła

```bash
ssh ansible@ansible-target
```

![Zdjęcie 1](img/s1.png)

### Inwentaryzacja

### Wysłanie żądania ping do wszystkich maszyn

![Zdjęcie 2](img/s2.png)

# Wysłanie żądania ping do wszystkich maszyn

Playbook `ping-all.yml`:

```yaml
---
- name: My first play
  hosts: all

  tasks:
   - name: Ping my hosts
     ansible.builtin.ping:
```

Rezultat:

![Zdjęcie 5](img/s5.png)

# Skopiowanie pliku inwentaryzacji na maszynę `Endpoints`, ponowienie operacji i porównanie wyjścia

Playbook `copy-inventory.yml`:

```yaml
---
- name: Copy inventory
  hosts: Endpoints

  tasks:
   - name: Copy inventory.ini file to ansible-target
     ansible.builtin.copy:
       src: inventory.ini
       dest: /tmp/inventory.ini
       mode: '0644' 
```

Rezultat:

![Zdjęcie 6](img/s6.png)

Ponowne uruchomienie:

![Zdjęcie 7](img/s7.png)

# Zaaktualizowanie pakietów w systemie

Playbook `copy-inventory.yml`:

```yaml
---
- name: Update packages
  hosts: all
  become: true

  tasks:
    - name: Apply patches
      ansible.builtin.command:
        cmd: apt --fix-broken install -y

    - name: Update packages - apt update + upgrade
      ansible.builtin.apt:
        update_cache: true
        upgrade: dist
      when: ansible_os_family == "Debian"
```

Prośba o podanie hasła (bez tego błąd braku dsotępu poprzez sudo). Opcja `become: true` oznacza wykonanie polecenia z sudo na początku. 

```bash
ansible-playbook -i inventory.ini update-packages.yml --ask-become-pass
```

Rezultat:

![Zdjęcie 8](img/s8.png)

# Rester usług `SSH` oraz `RNGD`

---
- name: Restart sshd and rngd
  hosts: all
  become: true

  tasks:
    - name: Restart sshd
      ansible.builtin.service:
        name: sshd
        state: restarted

    - name: Restart rngd
      ansible.builtin.service:
        name: rng-tools-debian
        state: restarted

Rezultat:

![Zdjęcie 9](img/s9.png)

## Class 09

## Class 10

```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```