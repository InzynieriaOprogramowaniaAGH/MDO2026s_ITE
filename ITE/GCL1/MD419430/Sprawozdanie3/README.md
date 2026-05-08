# Laboratorium 8

## 1. Automatyzacja i zdalne wykonywanie polecen (Ansible)

### Cel
Celem zadania bylo przygotowanie srodowiska Ansible (VM1 jako orchestrator, VM2 jako endpoint), wykonanie inwentaryzacji hostow, uruchomienie playbookow operacyjnych oraz zarzadzanie artefaktem kontenerowym z pipeline'u.

------------------------------------------------------------------------

### Krok 1. Przygotowanie VM2 (ansible-target)
Na maszynie docelowej przygotowano minimalny system, zainstalowano `tar` i `openssh-server`, ustawiono hostname oraz utworzono uzytkownika `ansible`.

```bash
sudo apt update
sudo apt install -y openssh-server tar rng-tools
sudo systemctl enable --now ssh

sudo hostnamectl set-hostname ansible-target
sudo adduser ansible
sudo usermod -aG sudo ansible
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
sudo chmod 440 /etc/sudoers.d/ansible
```

------------------------------------------------------------------------

### Krok 2. Instalacja Ansible i wymiana kluczy (VM1)
Na maszynie orchestratora (VM1) zainstalowano Ansible i skonfigurowano logowanie bezhaslowe do VM2.

```bash
sudo apt update
sudo apt install -y ansible

ssh-keygen -t ed25519 -C "ansible@vm1"
ssh-copy-id ansible@ansible-target
```

------------------------------------------------------------------------

### Krok 3. Inwentaryzacja i weryfikacja lacznosci
Ustalono nazwy hostow i wpisy DNS w `/etc/hosts`, a nastepnie utworzono plik inwentaryzacji z sekcjami `Orchestrators` i `Endpoints`.

```ini
[Orchestrators]
ansible-control ansible_connection=local

[Endpoints]
ansible-target ansible_host=192.168.1.50 ansible_user=ansible
```

Test lacznosci:

```bash
ansible -i inventory.ini all -m ping
```

![alt text](../img/L8/L8-01.png)

------------------------------------------------------------------------

### Krok 4. Playbook operacyjny (ping, kopiowanie, aktualizacja, restart)
Przygotowano playbook `lab08.yml`, ktory:
1. Wysyla `ping` do wszystkich maszyn.
2. Kopiuje plik inwentaryzacji na endpoint.
3. Ponawia `ping`.
4. Aktualizuje pakiety i restartuje `ssh` oraz `rngd`/`rng-tools`.

```bash
ansible-playbook -i inventory.ini lab08.yml -v
```

![alt text](../img/L8/L8-02.png)
![alt text](../img/L8/L8-03.png)

------------------------------------------------------------------------

### Krok 5. Test hosta niedostepnego
Wylaczono SSH na VM2 i uruchomiono test odpornosci (playbook nie przerywa pracy dla hosta niedostepnego):

```bash
sudo systemctl stop ssh
```

```bash
ansible -i inventory.ini Endpoints -m ping -T 3
```

Nastepnie przywrocono SSH:

```bash
sudo systemctl start ssh
```

![alt text](../img/L8/L8-04.png)

------------------------------------------------------------------------

### Krok 6. Zarzadzanie artefaktem (kontener)
Poniewaz artefaktem z pipeline'u jest kontener, przygotowano role `deploy_artifact` zbudowana przez `ansible-galaxy`. Rola:
- wykonuje sanity check (dysk, pamiec, docker),
- instaluje Dockera,
- klonuje repo z branchu `MD419430`,
- buduje obraz runtime z `Dockerfile`,
- uruchamia i weryfikuje kontener lokalny,
- pobiera obraz z Docker Hub i testuje jego uruchomienie,
- sprzata kontenery po weryfikacji.

Uruchomienie roli:

```bash
ansible-playbook -i inventory.ini deploy_artifact.yml
```

Domyslne parametry (ustawione w `defaults/main.yml`):

```yaml
repo_url: "https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git"
repo_version: "MD419430"
published_image: "mateuszdoktor1/nest-app:3"
```

![alt text](../img/L8/L8-05.png)

------------------------------------------------------------------------

### Krok 7. Struktura roli
W repozytorium umieszczono role w nastepujacej strukturze:

```
roles/deploy_artifact/
	defaults/main.yml
	tasks/main.yml
	meta/main.yml
```