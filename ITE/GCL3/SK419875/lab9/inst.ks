# --- PLIK ODPOWIEDZI KICKSTART (Fedora 44 - Lab 09) ---

# Instalacja w trybie tekstowym i automatyczny restart (Wymóg instrukcji)
text
reboot

# Konfiguracja klawiatury i języka
keyboard --vckeymap=pl --xlayouts='pl'
lang pl_PL.UTF-8

# Konfiguracja sieci i Hostname (Wymóg: hostname inny niż localhost)
network --bootproto=dhcp --device=link --activate
network --hostname=fedora-markedjs-host

# Źródło instalacji - zaktualizowane do Fedory 44
url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64
repo --name=update --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64

# Użytkownicy (Wymóg: użytkownik inny niż 'user')
rootpw --plaintext admin
user --groups=wheel --name=student --password=student --plaintext

# Czyszczenie i partycjonowanie (Wymóg: instalacja "w kółko" i formatowanie nośników)
clearpart --all --initlabel
autopart --type=lvm --fstype=ext4

# Wybór pakietów do instalacji
%packages
@^server-product-environment
wget
curl
tar
nano
docker
%end

# --- SEKCJA POST-INSTALL ---
# Wymóg: Rozszerz plik o repozytoria i oprogramowanie.
# Zapewnij uruchomienie po pierwszym uruchomieniu systemu.

%post --log=/root/ks-post-install.log
# 1. Włączamy usługę Dockera, aby startowała razem z systemem
systemctl enable docker

# 2. Tworzymy nową usługę systemową (Service)
# Ponieważ Docker nie działa wewnątrz instalatora, usługa ta uruchomi się 
# dopiero PO zrestartowaniu maszyny i odpaleniu gotowego systemu.
cat << 'EOF' > /etc/systemd/system/markedjs-app.service
[Unit]
Description=Automatyczne wdrozenie aplikacji MarkedJS (Lab 09)
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
# Tutaj definiujemy, co ma sie uruchomic. 
ExecStart=/usr/bin/docker run -d --name markedjs-app --restart always -p 80:80 nginx:alpine

[Install]
WantedBy=multi-user.target
EOF

# 3. Włączamy naszą usługę, aby system wiedział, że ma ją uruchomić
systemctl enable markedjs-app.service

%end