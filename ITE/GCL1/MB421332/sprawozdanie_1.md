# Sprawozdanie 1 - Konfiguracja środowiska

## Lab 1: Wprowadzenie, Git, Gałęzie, SSH

Na początku odpowiednio skonfigurowałam token PAT w ustawieniach githuba.<br>
![PAT](<img/Lab1/Zrzut ekranu 2026-06-15 153207.png>)<br>
Największy problem pojawił się przy połączeniu SSH Hyper-V z Windowsem. Pomimo każdorazowego podmieniania adresu IP, za każdym razem wyświetlał się poniższy błąd. Wykonałam więc odpowiednie kroki by naprawić problem.<br>
![problem](<img/Lab1/Zrzut ekranu 2026-03-10 081533.png>)<br>
Włączyłam agenta SSH w PowerShellu.<br>
![Agent SSH](img/Lab1/image.png)<br>
Następnie odpowiednio skonfigurowałam plik *config* tak, aby połączenie nie było uzależnione od adresu IP maszyny wirtualnej - wykorzystuje ono połączenie po nazwie (mDNS).<br>
![config](<img/Lab1/Zrzut ekranu 2026-06-15 161753.png>)<br>
Na maszynie wirtualnej zainstalowałam Avahi daemon, czyli proces działający w tle w systemach Linux, który umożliwia połączenie za pomocą nazwy hosta, zezwalając na automatyczne wykrywanie urządzeń w sieci.<br>
![avahi](<img/Lab1/Zrzut ekranu 2026-06-15 162215.png>)<br>
Tym razem połączenie zakończyło się sukcesem. Dodatkowo przy sklonowaniu repo nie musiałam podawać hasła do githuba, co wskazuje na to, że poprawnie skonfigurowałam PAT.<br>
![SSH w VS Code](<img/Lab1/Zrzut ekranu 2026-06-15 162953.png>)<br>
Utworzyłam dwa klucze SSH - z hasłem i bez.<br>
![klucze SSH](<img/Lab1/Zrzut ekranu 2026-06-17 193135.png>)<br>
Dodałam obydwa do konta na githubie.<br>  
![klucze SSH na githubie](<img/Lab1/Zrzut ekranu 2026-06-17 193553.png>)<br>
Następnie nawiązałam połączenie z githubem za pomocą obydwu kluczy.<br>
![klucz SSH](<img/Lab1/Zrzut ekranu 2026-06-17 193117.png>)<br>
![klucz SSH z hasłem](<img/Lab1/Zrzut ekranu 2026-06-17 192839.png>)<br>
Skonfigurowałam uwierzytelnianie dwuskładnikowe poprzez aplikację autoryzującą oraz aplikację mobilną github.<br>
![Dwuskładnikowe logowanie](<img/Lab1/Zrzut ekranu 2026-06-17 200650.png>)<br>
Z sukcesem przesłałam screenshota z folderu *Screeny* do wirtualnej maszyny.<br>
![FileZilla](<img/Lab1/Zrzut ekranu 2026-06-17 215245.png>)  
Utworzyłam własny branch *MB421332* i skonfigurowałam odpowiednio strukturę folderów na githubie, a następnie napisałam Git hooka.  
![Git hook](<img/Lab1/Zrzut ekranu 2026-03-24 101346.png>)<br>
Treść Git hooka:

#!/bin/bash  
MSG=$(cat "$1")  
if [[ ! $MSG =~ ^MB421332 ]]; then  
    echo "BŁĄD: Commit musi zaczynać się od MB421332!"  
    exit 1  
fi  



## Lab 2: Git, Docker



## Lab 3: Dockerfiles, kontener jako definicja etapu

