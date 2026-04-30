Pobrałem obraz `Fedora-Server-dvd-x86_64-43-1.6.iso` i zainstalowałem go w VirtualBoxie według poleceń, ustawiając odpowiednie nazwy.

Upewniłem się o obecności sshd i tar.

```bash
which tar
systemctl status sshd
```

Utworzyłem migawkę.

![alt text](image.png)

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

Ustawiłem nazwy dns w `/etc/hosts`:

![alt text](image-1.png)

Zwykły ping fedora:

![alt text](image-2.png)

Zwykły ping ubuntu:

![alt text](image-3.png)

ping
`ansible all -i ~/ansible-lab/inventory.ini -m ping`

inventory.ini:

```yaml
[Orchestrators]
ubuntu ansible_connection=local

[Endpoints]
fedora ansible_user=ansible
```

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

## Zdalne wywoływanie procedur
