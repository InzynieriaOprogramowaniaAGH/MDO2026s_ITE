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
Utworzyłam własny branch *MB421332* i skonfigurowałam odpowiednio strukturę folderów na githubie, a następnie napisałam Git hooka, który nie pozwala na wysłanie *commita* niezaczynającego się od *MB421332*. Zorientowałam się również, że w ukrytym folderze *.git/hooks commit-msg* miał rozszerzenie *.sample* - należało przenieść treść *Git hooka* do pliku o tej samej nazwie bez rozszerzenia.  
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

**Środowisko: Maszyna wirtualna Ubuntu Server w Hyper-V na systemie operacyjnym Windows 11**

Zainstalowałam Docker oraz Docker-compose w terminalu, a następnie dodałam użytkownika do grupy Docker, aby nie pisać za każdym razem *sudo*.  
![Instalacja Docker](<Lab2/Zrzut ekranu 2026-06-24 181250.png>)  
Wyczyściłam wszystkie kontenery Docker, aby zapoznać się z podanymi w sprawozdaniu kontenerami.  
![Docker prune](<Lab2/Zrzut ekranu 2026-06-24 182643.png>)  

Następnie przetestowałam wszystkie z wypisanych w sprawozdaniu obrazów:  
- Obraz hello-world:linux zajął 10.1kB dysku wirtualnego i otrzymał kod wyjścia 0 (sukces).   
![alt text](<Lab2/Zrzut ekranu 2026-06-24 183844.png>)
![hello-world miejsce i kod wyjścia](<Lab2/Zrzut ekranu 2026-06-24 183908.png>)  
- Obraz busybox zajął 1.26 MB i otrzymał również kod wyjścia 0.  
![buysbox](<Lab2/Zrzut ekranu 2026-06-24 184348.png>)  
- Obraz ubuntu zajął 100 MB i otrzymał kod wyjścia 0.  
![ubuntu](<Lab2/Zrzut ekranu 2026-06-24 185209.png>)  
- Obraz mariadb zajął 362 MB i otrzymał kod wyjścia 1. Oznacza on ogólny błąd aplikacji. Z logów po uruchomieniu obrazu można wywnioskować, że błąd wystąpił, ponieważ nie określiłam bazy danych i nie podałam hasła roota.  
![mariadb](<Lab2/Zrzut ekranu 2026-06-24 185209.png>)  
- Obraz node zajął 1.24 GB i otrzymał kod wyjścia 0.  
![node](<Lab2/Zrzut ekranu 2026-06-24 190129.png>)  
- Obraz runtime (jetbrains) zajął 2.21 GB i otrzymał kod wyjścia 0.  
![runtime](<Lab2/Zrzut ekranu 2026-06-24 190545.png>)  
- Obraz aspnet (eclipse) zajął 1.1 GB i otrzymał kod wyjścia 0. Aby go uruchomić, musiałam wymusić zatrzymanie kontenera i dodać flagi pozwalające zużyć do 2GB RAMu i 2 rdzeni procesora. Do wyświetlenia kodu wyjścia użyłam polecenia *inspect* - kod nie był widoczy, dlatego że kontener pozostał uruchomiony.  
![eclipse](<Lab2/Zrzut ekranu 2026-06-24 191718.png>)  
![eclipse z flagami](<Lab2/Zrzut ekranu 2026-06-24 191745.png>)  
![eclipse kod wyjścia](<Lab2/Zrzut ekranu 2026-06-24 191754.png>)  
- Obraz sdk (ory corp) zajął 5.53 GB i otrzymał kod wyjścia 0.  
![sdk](<Lab2/Zrzut ekranu 2026-06-24 193636.png>)  
![sdk run](<Lab2/Zrzut ekranu 2026-06-24 193644.png>)  
![sdk rozmiar i kod wyjścia](<Lab2/Zrzut ekranu 2026-06-24 193718.png>)  

Na koniec przerwałam działanie kontenerów eclipse, których postawiłam trzy przez problem z długim uruchamianiem. Przez moduł bezpieczeństwa w Linuxie o nazwie AppArmor nie mogłam tak po prostu zatrzymać ich poleceniem *docker stop*. Sprawdziłam więc PID procesów i w sposób siłowy je przerwałam (*kill*).  
![apparmor](<Lab2/Zrzut ekranu 2026-06-24 201035.png>)  
![pid kill](<Lab2/Zrzut ekranu 2026-06-24 201048.png>)  
Uruchomiłam busybox w trybie interaktywnym i sprawdziłam jego wersję.  
![busybox -it](<Lab2/Zrzut ekranu 2026-06-24 201841.png>)  
Uruchomiłam system w kontenerze (ubuntu) i wyświetliłam PID1, a następnie w drugim terminalu wyświetliłam procesy dockera na hoście. Zaktualizowałam pakiety i opuściłam kontener ubuntu.  
![ubuntu -it](<Lab2/Zrzut ekranu 2026-06-24 202643.png>)  
![procesy docker](<Lab2/Zrzut ekranu 2026-06-24 202734.png>)  
Utworzyłam plik *Dockerfile*, który precyzuje system, pobiera gita, tworzy katalog roboczy *app* i klonuje repo *MDO2026S_ITE*. Następnie zbudowałam kontener na podstawie tego pliku i sprawdziłam czy git rzeczywiście został pobrany a repo sklonowane.  
![moj-kontener build](<Lab2/Zrzut ekranu 2026-06-24 204623.png>)  
![moj-kontener -it](<Lab2/Zrzut ekranu 2026-06-24 204801.png>)  
Sprawdziłam wszystkie postawione kontenery (z nadal działającym *moj-kontener* z *Dockerfile*'a), a następnie zamknęłam wszytskie i usunęłam komendą *prune*.  
![docker ps -a](<Zrzut ekranu 2026-06-24 205314.png>)  
![prune](<Zrzut ekranu 2026-06-24 205408.png>)  



## Lab 3: Dockerfiles, kontener jako definicja etapu


## Promty AI
AI używałam do rozwiązywania błędów oraz doprecyzowywania zagadnień, gdy nie rozumiałam w jaki sposób dane narzędzie działa:
- Spróbuj wciągnąć swoją gałąź do gałęzi grupowej - co to znaczy
- jak sprawdzić czy jestem w grupie docker
- Do czego służą obrazy w dockerze
- no matching manifest for linux/amd64 in the manifest list entries - co to za błąd przy pull w docker
- kod wyjścia 1 co oznacza
- co mam zrobić jak mi się eclipse obraz w dockerze bardzo długo uruchamia?
- jak sprawdzić exit code jak obraz jest UP
- Error response from daemon: cannot stop container: d54c52d3a4f9: permission denied - jak sprawdzić ten error
