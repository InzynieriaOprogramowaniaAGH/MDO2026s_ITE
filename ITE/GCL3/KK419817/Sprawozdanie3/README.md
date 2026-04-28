
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

Ustawiłem nazwy dns:

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
