# --- PLIK ODPOWIEDZI KICKSTART (Fedora Lab 09) ---

text
noninteractive
reboot

keyboard --vckeymap=pl --xlayouts='pl'
lang pl_PL.UTF-8

# Konfiguracja sieci i Hostname (wymóg z instrukcji)
network --bootproto=dhcp --device=link --activate
network --hostname=fedora-markedjs-host

# Dodajemy repozytoria Fedory (przydatne przy Netinst)
url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-40&arch=x86_64
repo --name=update --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f40&arch=x86_64

# Użytkownicy
rootpw --plaintext admin
user --groups=wheel --name=student --password=student --plaintext

# Czyszczenie i partycjonowanie (Wymóg: instalacja w kółko)
ignoredisk --only-use=sda,vda,nvme0n1
clearpart --all --initlabel --drives=sda,vda,nvme0n1
autopart --type=lvm --fstype=ext4

# Pakiety podstawowe (doinstalujemy dockera, żeby był gotowy do kolejnego kroku)
%packages
@^server-product-environment
wget
curl
tar
nano
docker
%end

# sekcja %post