## Laboratorium 8

### Instalacja zarządcy Ansible

#### 1: Utworzono drugą maszynę wirtualną
Ze względu na obawę że mój laptop na którym do tej pory działałem może nie poradzić sobie z uruchomieniem dwóch maszyn wirtualnych, zdecydowalem przenieść się na komputer stacjonarny, tam od nowa utworzylem 2 maszyny wirtualne


Maszyny hostowane są na vmware_workstation:
- Zarządca - Ubuntu 24.04 server 4GB RAM, 2 vCPU, 32GB HDD (skonfigurowano wszystkie narzędzia z którymi do tej pory dzialaliśmy)
- Target - Fedora 43 server 2GB RAM, 1 vCPU, 20GB HDD

Target:
![](zdj/l8-z5.png)

Zarządca:
![](zdj/l8-z6.png)

Na targecie sprawdzono obecność tar i odblokowano ssh
```bash
sudo systemctl enable --now sshd
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload

tar --version
```

#### 2: Snapshot
Po upewnieniu się że wszystko działa poprawnie, utworzono snapshot targetu

![](zdj/l8-z1.png)

#### 3: Instalacja Ansible i wymiana kluczy SSH
Zainstalowano Ansible na zarządcy
```bash
sudo apt update
sudo apt install ansible -y
```

Wyegenerowano i przesłano klucze SSH z zarządcy do targetu
```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id ansible@192.168.219.131
```

Przetestowano połączenie
![](zdj/l8-z2.png)

### Inwentaryzacja
#### 1: Wprowadzono nazwy DNS na Zarządcy w /etc/hosts
Wprowadzono nazwy
![](zdj/l8-z3.png)

Zweryfikowano działanie
![](zdj/l8-z4.png)

#### 2: Plik inwentaryzacyjny Ansible

Utworzono plik inwentaryzacyjny Ansible 
![](zdj/l8-z7.png)

Zweryfikowano działanie wysyłając ping do wszystkich maszyn
![](zdj/l8-z8.png)

### Zdalne wywoływanie procedur

#### 1. Utworzono playbook Ansible

```yml
---
- name: Zadania Ansible Lab
  hosts: all
  become: yes
  tasks:
    - name: Ping
      ping:

    - name: Kopiowanie inwentarza
      copy:
        src: ./inventory.ini
        dest: /home/ansible/inventory_backup.ini

    - name: Aktualizacja i restart sshd
      shell: |
        dnf update -y
        systemctl restart sshd
      when: inventory_hostname != 'localhost'
```

#### 2. Uruchomiono playbook pierwszy raz

```bash
ansible-playbook -i inventory.ini tasks.yml --ask-become-pass
```

Po wpisaniu hasła
![](zdj/l8-z9.png)

Przy pierwszym wywołaniu Ansible wykrywa, że systemy docelowe znajdują się w stanie odbiegającym od definicji w playbooku.
Status changed: Widoczny przy zadaniu kopiowania oraz aktualizacji, oznacza, że Ansible faktycznie wykonał pracę (przesłał plik, wywołał menedżer pakietów).

#### 3. Drugie uruchomienie

![](zdj/l8-z10.png)

Ansible używa dedykowanego modułu copy, po ponownym uruchomieniu playbooka ansible przed przesłaniem pliku sprawdza jego sumę kontrolną na obu maszynach. Ponieważ plik na Fedorze był identyczny z lokalnym, ansible pominął kopiowanie i zwrócił status ok. Aktualizacja systemu wykonała się ponownie, ponieważ użyłem modułu shell. W przeciwieństwie do modułów dedykowanych, moduł shell nie potrafi sam ocenić, czy stan pożądany został już osiągnięty dlatego licznik changed nadal wzrasta przy każdym odpaleniu.


#### 4. Trzecie uruchomienie bez ssh na targecie

```bash
sudo systemctl stop sshd
```
![](zdj/l8-z11.png)

Po wyłączeniu serwera SSH na maszynie ansible-target, Ansible raportuje błąd UNREACHABLE. Ansible nie wymaga zainstalowanego agenta na maszynie docelowej, ale jest całkowicie zależny od protokołu SSH. Brak łączności natychmiast przerywa proces dla danego hosta, nie wpływając jednak na wykonanie zadań na pozostałych dostępnych maszynach.

## Wnioski laboratorium 8

- Dla pełnej automatyzacji w środowiskach produkcyjnych zaleca się stosowanie natywnych modułów, które raportują changed: false, jeśli system jest już w pełni zaktualizowany. Użycie modułu shell jest prostsze w zapisie, ale oszukuje statystyki.

- Ansible pozwala na zarządzanie wieloma maszynami o różnych systemach (Ubuntu, Fedora) za pomocą jednego, czytelnego pliku YAML. Eliminuje to konieczność ręcznego logowania się na każdy serwer z osobna.

- Ansible jest agentless, ale całkowicie zależny od SSH. Brak łączności z maszyną docelową skutkuje błędem UNREACHABLE, co podkreśla znaczenie stabilnej infrastruktury sieciowej dla skutecznego zarządzania konfiguracją.