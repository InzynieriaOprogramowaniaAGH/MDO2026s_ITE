Srawozdanie 1 Kamil Lewandowski 03.03.2026

utworzono maszyne wirtualną Fedora Linux 43 Server Edition oraz połączono się z nią po ssh
![](1-vm.png)

skonfigurowano remote ssh w vs code
![](2-vscode.png)

wygenerowano klucze 

sklonowano repozytorium po https i ssh

![](3-repo-https.png)
![](4-repo-ssh.png)

utworzono brancha

![](5-branch.png)

stworzono hooka (commit-msg)

![](6-hook.png)

przetestowano hooka

![](7-hook-test.png)

===ZAJ2===

zainstalowano dockera

![](8-instalacja-dockera.png)

zalogowano się do dockerhub

![](9-zalogowanie-docker-hub.png)

uruchomiono kontenery 

![](10-docker-run-1.png)
![](11-docker-run-2.png)

sprawdzono rozmiar kontenerów

![](12-kontenery-rozmiar.png)

uruchomiono interaktywnie busybox 
![](13-busy-box.png)

uruchomiono kontener z ubuntu
![](14-ubuntu.png)

stworzono obraz za pomocą dockerfile i uruchomiono kontener
![](15-dockerfile.png)

usunięto kontenery
![](16-kontenery.png)

usunięto obrazy
![](17-obrazy.png)

===ZAJ3===

sklonowano ripgrep na fedore
![](18-clone-ripgrep.png)


zbudowano ripgrep z użyciem cargo
![](19-build.png)


uruchomiono testy ripgrep
![](20-test.png)

zrobiono te kroki w dockerze
![](21-docker.png)

===ZAJ4===

uruchomiono kotener z iperf3
![](22-iperf-server.png)

znaleziono adress kontenera używając komendy 
docker inspect iperf-1
![](23-adres-kontener-1.png)

uruchomiono drugi kontener z iperfem łącząc się z 1 po adresie IP
![](24-iperf-client.png)

stworzono nową sieć iperf-network i uruchomiono w niej kontener z iperfem
![](25-network.png)

uruchomiono drugi kontener w tej sieci i połączono się z 1 po nazwie
![](26-network-client.png)

połączono się z 1 kontenerem z servera fedora
![](27-vm-connect.png)

uruchomiono kontener z iperfem w sieci host
![](28-run-in-host.png)

sprawdzono adress maszyny wirtualnej
![](29-fedora-check-adres.png)

próba połaczenie się z systemu windows(poza host) nieudana (zły adres)
![](30-windows-connect-fail.png)

druga nie udana próba
![](31-windows-connect-fail-2.png)


dodanie przekierowania portów w maszynie wirtualnej
![](32-port-forwarding.png)

dodanie portu 5201 do firewalla
![](33-fire-wall.png)

uruchomiono kontener z iperfem w sieci host
![](34-run-server.png)

udane połączenie się z systemu windows(poza host)
![](35-windows-connect-working.png)

Stworzono woluminy wejściowy i wyjściowy
![](36-volume-in-out.png)

stworzono kontener w którym sklonowano kod do woluminu wejściowego
![](37-clone.png)

w głównym kontenerze zbudowano kod a wynik zapisano w woluminie wyjściowym
![](38-ripgrep-build.png)

sprawdzono zawartość woluminu wyjściowego z użyciem pomocniczego kontenera
![](39-sprawdzenie-woluminu.png)

stworzono kolejne 2 woluminy poczym
używając głównego kontenera i woluminów sklonowano kod i zbowano aplikacje
![](40-one-container-1.png)
![](41-one-container-2.png)


zadanie to można wykonać z w dockerfile kluczem jest użycie --mount, można też użyć specialnych katalogów do cachowania 

RUN git clone https://github.com/BurntSushi/ripgrep.git . && \
    --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/src/ripgrep/target \
    cargo build --release && \
    cp target/release/rg /usr/local/bin/r


za pomocą Dockerfile.fedora-sshd

stworzono fedore z ssh

![](42-fedora-ssh.png)

zalety:
niektóre narzędzia muszą korzystać z ssh

wady:
poziom skomplikowania trzeba zarządzać hasłami/kluczami wewnątrz kontenerów

co do zasady powinien być jeden proces na kontener, takie podejście łamię tą zasadę

![](42-fedora-ssh.png)


odczytano hasło używając
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword

stworzono sieci i woluminy dla jenkinsa
![](43-jenkins-network-volume.png)

utworzono dind
![](44-dind.png)

zbudowano obraz jenkindsa
![](45-jenkins-build.png)

uruchomiono jenkinsa
![](46-jenkins-run.png)

dodano przekierowanie portów do maszyny wirtualnej
![](47-port-forwarding.png)

po wejściu na adres http://127.0.0.1:8080/ na windowsie 
zainstalowano sugerowane wtycznki
![](48-install-plugins.png)

po zalogowaniu otrzymano panel jenkinsa
![](49-fin.png)