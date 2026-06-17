# Sprawozdanie 1 - Konfiguracja środowiska

## Lab 1: Wprowadzenie, Git, Gałęzie, SSH

**Środowisko: Maszyna wirtualna Ubuntu Server w Hyper-V na systemie operacyjnym Windows 11**  

W celu przygotowania stanowiska pracy odpowiednio skonfigurowałam token PAT w ustawieniach GitHuba. (mogłam pominąć instalację Git oraz SSH ze względu na poprzednie projekty)<br>
![PAT](<Lab1/Zrzut ekranu 2026-06-15 153207.png>)<br>
Po pobraniu Hyper-V oraz uruchomieniu maszyny wirtualnej, próbowałam połączyć się poprzez SSH w Visual Studio Code. Problem pojawił się przy połączeniu - pomimo każdorazowego podmieniania adresu IP na aktualny adres maszyny wirtualnej, wyświetlał się poniższy błąd. Wykonałam więc odpowiednie kroki by naprawić problem.<br>
![problem](<Lab1/Zrzut ekranu 2026-03-10 081533.png>)<br>
Włączyłam agenta SSH w PowerShellu na Windowsie.<br>
![Agent SSH](<Lab1/image.png>)<br>
Następnie odpowiednio skonfigurowałam plik *config* tak, aby połączenie nie było uzależnione od adresu IP maszyny wirtualnej - wykorzystuje ono połączenie po nazwie (mDNS).<br>
![config](<Lab1/Zrzut ekranu 2026-06-15 161753.png>)<br>
Na maszynie wirtualnej zainstalowałam Avahi daemon, czyli proces działający w tle w systemach Linux, który umożliwia połączenie za pomocą nazwy hosta, zezwalając na automatyczne wykrywanie urządzeń w sieci.<br>
![avahi](<Lab1/Zrzut ekranu 2026-06-15 162215.png>)<br>
Tym razem połączenie zakończyło się sukcesem. Dodatkowo przy sklonowaniu repo nie musiałam podawać hasła do GitHuba, co wskazuje na to, że poprawnie skonfigurowałam PAT.<br>
![SSH w VS Code](<Lab1/Zrzut ekranu 2026-06-15 162953.png>)<br>
Utworzyłam dwa klucze SSH - z hasłem i bez.<br>
![klucze SSH](<Lab1/Zrzut ekranu 2026-06-17 193135.png>)<br>
Dodałam obydwa do konta na GitHubie.<br>  
![klucze SSH na githubie](<Lab1/Zrzut ekranu 2026-06-17 193553.png>)<br>
Następnie nawiązałam połączenie z GitHubem za pomocą obydwu kluczy i skonfigurowałam klucz SSH jako metodę połączenia z GitHubem.<br>
![klucz SSH](<Lab1/Zrzut ekranu 2026-06-17 193117.png>)<br>
![klucz SSH z hasłem](<Lab1/Zrzut ekranu 2026-06-17 192839.png>)<br>
Skonfigurowałam uwierzytelnianie dwuskładnikowe poprzez aplikację autoryzującą oraz aplikację mobilną github.<br>
![Dwuskładnikowe logowanie](<Lab1/Zrzut ekranu 2026-06-17 200650.png>)<br>
Z sukcesem przesłałam screenshota z folderu *Screeny* na Windowsie do wirtualnej maszyny za pomocą programu FileZilla.<br>
![FileZilla](<Lab1/Zrzut ekranu 2026-06-17 215245.png>)  
Utworzyłam własny branch *MB421332* i skonfigurowałam odpowiednio strukturę folderów na githubie, a następnie napisałam Git hooka, który nie pozwala na wysłanie *commita* niezaczynającego się od *MB421332*. Zorientowałam się również, że w ukrytym folderze *.git/hooks* commit-msg miał rozszerzenie *.sample* - należało przenieść treść *Git hooka* do pliku o tej samej nazwie bez rozszerzenia.  
![commit-msg](<Lab1/Zrzut ekranu 2026-06-17 222421.png>)
Treść Git hooka:

#!/bin/bash  
MSG=$(cat "$1")  
if [[ ! $MSG =~ ^MB421332 ]]; then  
    echo "BŁĄD: Commit musi zaczynać się od MB421332!"  
    exit 1  
fi  

Poprawny komunikat *Git hooka* przy błędnie dodanym *commicie*.  
![Treść ostrzeżenia](<Lab1/Zrzut ekranu 2026-06-17 222511.png>)  


## Lab 2: Git, Docker



## Lab 3: Dockerfiles, kontener jako definicja etapu

