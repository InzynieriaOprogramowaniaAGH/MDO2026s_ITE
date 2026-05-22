# Sprawozdanie z laboratorium: Automatyzacja instalacji systemu Fedora i wdrożenie aplikacji

## 1. Cel laboratorium
Celem zadania była automatyzacja procesu instalacji systemu operacyjnego Fedora z wykorzystaniem plików Kickstart (ks.cfg) oraz zdalna konfiguracja środowiska wykonawczego dla aplikacji w języku C, integrującej się z bazą Redis.

## 2. Konfiguracja środowiska
* Serwer dystrybucyjny: Host z systemem Windows, udostępniający pliki konfiguracyjne (ks.cfg) oraz źródła aplikacji przez protokół HTTP (Python http.server na porcie 8000).
* Klient: Maszyna wirtualna VirtualBox (Fedora Linux 40) z uruchomionym instalatorem w trybie tekstowym z automatycznym pobieraniem konfiguracji przez sieć.

## 3. Plik konfiguracyjny Kickstart (ks.cfg)

lang pl_PL.UTF-8
keyboard pl
timezone Europe/Warsaw --utc
rootpw --plaintext haslo123
text

network --bootproto=dhcp --device=link --activate --hostname=fedora-lab9

clearpart --all --initlabel
part /boot/efi --fstype="efi" --size=200
part / --fstype="ext4" --size=15000
part swap --fstype="swap" --size=2048

reboot

%packages
@^minimal-environment
gcc
make
hiredis-devel
wget
tar
%end

%post --log=/root/ks-post.log
WINDOWS_IP="192.168.1.1"
PORT="8000"
BASE_URL="http://$WINDOWS_IP:$PORT"

wget --no-check-certificate $BASE_URL/sample.c -O /root/sample.c
wget --no-check-certificate $BASE_URL/hiredis-v1.0-b7-PD420765.tar.gz -O /root/hiredis.tar.gz

gcc /root/sample.c -o /usr/local/bin/my_app -lhiredis
chmod +x /usr/local/bin/my_app

cat <<EOF > /etc/systemd/system/moj-program.service
[Unit]
Description=Moj program z lab9
After=network.target

[Service]
ExecStart=/usr/local/bin/my_app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable moj-program.service
%end

## 4. Przebieg realizacji
1. Przygotowanie serwera: Uruchomiono serwer HTTP na maszynie hosta w folderze D:\LAB9.
2. Automatyzacja instalacji: Uruchomiono maszynę wirtualną z przekazaniem parametru inst.ks=http://192.168.1.1:8000/ks.cfg. Proces partycjonowania oraz instalacji przebiegł automatycznie.
3. Wdrożenie aplikacji: Po zakończeniu instalacji system automatycznie pobrał pliki źródłowe, przeprowadził kompilację oraz zarejestrował usługę moj-program.service w systemie systemd.
4. Weryfikacja: Po zalogowaniu do systemu zweryfikowano poprawność komunikacji aplikacji z usługą Redis.

## 5. Dokumentacja wizualna

W folderze lab9/screenshots/ znajdują się następujące zrzuty ekranu:

![Serwer HTTP](lab9/screenshots/serving_http.png)
*Rys. 1: Uruchomiony serwer plików na hoście.*

![Rozpoczęcie instalacji](lab9/screenshots/boot_fedory.png)
*Rys. 2: Uruchomienie instalatora Fedory.*

![Logi pobierania](lab9/screenshots/logi_python.png)
*Rys. 3: Potwierdzenie pobrania plików przez maszynę wirtualną.*

![Logowanie](lab9/screenshots/successfull_login.png)
*Rys. 4: Pomyślne zalogowanie do zainstalowanego systemu.*

![Status aplikacji](lab9/screenshots/ostateczne_log_running.png)
*Rys. 5: Potwierdzenie poprawnego działania aplikacji (wynik: PONG).*

## 6. Wnioski
Zastosowanie mechanizmu Kickstart znacząco przyspiesza proces wdrażania nowych instancji systemu. Dzięki automatyzacji zadań poinstalacyjnych (sekcja %post) możliwe jest dostarczenie gotowego do pracy środowiska bez konieczności ręcznej konfiguracji, co gwarantuje wysoką powtarzalność i eliminację błędów konfiguracyjnych.