# Sprawozdanie 1 - Konfiguracja środowiska

**Konfiguracja klienta Git**
Na początku odpowiednio skonfigurowałam token PAT w ustawieniach githuba.
![PAT](<img/Lab1/Zrzut ekranu 2026-06-15 153207.png>)
Największy problem pojawił się przy połączeniu SSH Hyper-V z Windowsem. Pomimo każdorazowego podmieniania adresu IP, za każdym razem wyświetlał się poniższy błąd. Wykonałam więc odpowiednie kroki by naprawić problem. 
![problem](<img/Lab1/Zrzut ekranu 2026-03-10 081533.png>)
Włączyłam agenta SSH w PowerShellu.
![Agent SSH](img/Lab1/image.png)
Następnie odpowiednio skonfigurowałam plik *config* tak, aby połączenie nie było uzależnione od adresu IP maszyny wirtualnej - wykorzystuje ono połączenie po nazwie (mDNS).
![config](<img/Lab1/Zrzut ekranu 2026-06-15 161753.png>)
Na maszynie wirtualnej zainstalowałam Avahi daemon, czyli proces działający w tle w systemach Linux, który umożliwia połączenie za pomocą nazwy hosta, zezwalając na automatyczne wykrywanie urządzeń w sieci.
![avahi](<img/Lab1/Zrzut ekranu 2026-06-15 162215.png>)
Tym razem połączenie zakończyło się sukcesem. Dodatkowo przy sklonowaniu repo nie musiałam podawać hasła do githuba, co wskazuje na to, że poprawnie skonfigurowałam PAT.
![SSH w VS Code](<img/Lab1/Zrzut ekranu 2026-06-15 162953.png>)
Utworzyłam dwa klucze SSH - z hasłem i bez.
![klucze SSH](<img/Lab1/Zrzut ekranu 2026-06-17 193135.png>)
Dodałam obydwa do konta na githubie.
![klucze SSH na githubie](<img/Lab1/Zrzut ekranu 2026-06-17 193553.png>)
Następnie nawiązałam połączenie z githubem za pomocą obydwu kluczy.
![klucz SSH](<img/Lab1/Zrzut ekranu 2026-06-17 193117.png>)
![klucz SSH z hasłem](<img/Lab1/Zrzut ekranu 2026-06-17 192839.png>)
