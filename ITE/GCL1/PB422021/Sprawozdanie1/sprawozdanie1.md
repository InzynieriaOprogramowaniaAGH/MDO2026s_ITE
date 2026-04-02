# Sprawozdanie nr 1

#### Wszystkie zadania wykonałam na Ubuntu Server 24.04 LTS w Hyper-V, poprzez połączenie zdalne przez protokół SSH z poziomu Visual Studio Code.

# Lab 1

### Moim pierwszym zadaniem było przygotowanie klienta Git. Po upewnieniu się, że pakiet jest zainstalowany, sklonowałam repozytorium przedmiotu. Z racji, że GitHub nie wspiera uwierzytelniania zwykłym hasłem, wykorzystałam protoków HTTPS i Personal Acces Token, który wygenerowałam wcześniej w ustawieniach deweloperskich mojego konta na GitHubie.

### Następnie w celu zwiększenia bezpieczeństwa, skonfigurowałąm dostęp przez SSH. Zgodnie z instrukcją utworzyłam dwa różne klucze - klucz standardowy i klucz zabezpieczony hasłem, wymagający podania hasła przy każdej próbie użycia.


![Błąd wyświetlania](lab1_ss/ss3.png)


### Następnie dodałam klucz publiczny do mojego profilu na GitHubie i sprawdziłam połączenie. Z racji, że miałam już skondfigurowane uwierzytelnianie dwuskładnikowe to pominęłam ten etap. 

### Następnie sprawdziłam adres ip mojej maszyny wirtualnej, aby móc się z nią połączyć przez Visual Studio Code za pomocą wtyczki Remote SSH.


![Błąd wyświetlania](lab1_ss/ss4.png)


### Następnie przetestowałam natychmiastowe przesyłanie plikó programem FileZilla przenosząc plik hej.txt.


 ![Błąd wyświetlania](lab1_ss/ss5.png)

 ![Błąd wyświetlania](lab1_ss/ss6.png)


### W kolejnym kroku w odpowiedniej gałęzi grupy utworzyłam swoją gałąź o nazwie PB422021 i zaczęłam na niej prace. Napisałam Git hooka, weryfikującego każdego commita, aby zaczynał się od nazwy mojej gałęzi.


![Utworzenie własnego folderu](lab1_ss/ss1.png)


### treść hooka:
```bash
#!/bin/bash
INPUT_FILE=$1
START_LINE=$(head -n 1 "$INPUT_FILE")
if [[ ! $START_LINE =~ ^PB422021 ]]; then
  echo "BŁĄD: Commit message musi zaczynać się od PB422021"
  exit 1
fi
```
### Jako ostatni krok nadałam odpowiednie uprawnienia dla hooka.


 ![Błąd wyświetlania](lab1_ss/ss2.png)





# Lab2

### W pierwszej kolejności zainstalowałam dockera w moim środowisku.

![Błąd wyświetlania](lab2_ss/ss_1.png)
![Błąd wyświetlania](lab2_ss/ss_2.png)

### Następnie zpaoznałam się z wypisanymi w instrukcji obrazami i kolejno każdy z nich uruchomiłam, sprawdziłam rozmiary oraz kody wyjścia komendą `echo $?`.

![Lista obrazów](lab2_ss/docker_images.png)

![Docker run echo](lab2_ss/docker_run_echo.png)

![Docker run echo 2](lab2_ss/docker_run_echo2.png)

### Uruchomiłam kontener Busybox w trybie interaktywnym i sprawdziłam nr wersji. Tryb interaktywny pozwolił na bezpośrednią pracę w powłoką wewnątrz kontenera.

![Busybox interaktywnie](lab2_ss/busybox_uruchmienie_interaktywne.png)

### Następnie uruchomiłam kontener z obrazem ubuntu, aby zweryfikować izolację procesów.  

### W kontenerze polecenie `ps -ef` wykazało, że procesem o PID 1 jest mojapowłoka /bin/bash, co oznacza, że dla kontenera nie istnieje świat zewnętrzny.

![PID1 w kontenerze](lab2_ss/PID1.png)

### W tym samym czasie, w drugim terminalu SSH, sprawdziłam procesy dockera. Proces bash miał tam zupełnie inny numer PID. 

![Procesy na hoście](lab2_ss/procesy_dockera_na_hoście.png)

### Zaktualizowałam pakiety wewnątrz kontenera.

![Aktualizacja pakietów](lab2_ss/aktualizacja_pakietów.png)

### Następnie stworzyłam własny plik Dockerfile, który automatyzuje przygotowanie środowiska z Gitem.

![Plik Dockerfile](lab2_ss/dockerfile.png)

### Zbudowałam obraz:

![Budowanie obrazu](lab2_ss/budowanie_obrazy(dockerfile).png)

### Uruchomiłam i zweryfikowałam (ls -la) zawartości sklonowanego repozytorium:

![Weryfikacja Dockerfile](lab2_ss/uruchomieni_i_weryfikacja_dockerfile.png)

### Na koniec wyświetliłam wszytskie kontenery.

![Historia kontenerów](lab2_ss/historia_kontenerów.png)

### Usunęłam zakończone kontenery:

![Błąd wyświetlania](lab2_ss/ss_3.png)





# LAB3 

### Do realizacji laboratorium wybrałam repozytorium NestJS TypeScript Starter: [NestJS TypeScript Starter](https://github.com/nestjs/typescript-starter.git). Spełnia on wymagania instrukcji - posiada skrypty budowania (npm run build) oraz testy jednostkowe (npm run test). Ma też licencję MIT.

 ### Po sklonowaniu repo na systemie Ubuntu Server próba zbudowania zakończyła się niepowodzeniem. Wybrane repozytorium wymaga środowiska Node.js w wersji >= 20, podczas gdy system operacyjny oferuje wersję 18.19.1.

 ![Błąd wyświetlania](lab3_ss/lab3ss1.png)

 ### Z tego powodu przechodzę do wykonania kolejnej części instrukcji, aby wykonać to bez potrzeby instalacji nowej wersji node na ubuntu.

 ### Uruchomiałam i pobrałam nowy obraz node:20 
 
 ![Błąd wyświetlania](lab3_ss/lab3ss2.png)

 ### Zainstalowałam gita 

  ![Błąd wyświetlania](lab3_ss/lab3ss3.png)

 ### Sklonowałam repozytorium do folderu app.

  ![Błąd wyświetlania](lab3_ss/lab3ss4.png)

### Repozytorium zostało pobrane poprawnie.

 ![Błąd wyświetlania](lab3_ss/lab3ss5.png)

### Następnie zainstalowałam zależności. 
 ![Błąd wyświetlania](lab3_ss/lab3ss6.png)

### Uruchomiłam build, po tej komendzie pojawił się nowy folder dist, co wskazuje na poprawne zbudowanie programu. 

 ![Błąd wyświetlania](lab3_ss/lab3ss7.png)

### Następnie uruchomiłam testy, które przeszły poprawnie.

 ![Błąd wyświetlania](lab3_ss/lab3ss8.png)


### W kolejnym kroku przeszłam do utworzenia plików Dockerfile, które zautomatyzują to co było wykonane wcześniej. 

### Dockerfile.build przygotowuje środowisko, klonuje kod i kompiluje aplikację.

Dockerfile.build:
```bash
FROM node:20

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/nestjs/typescript-starter.git .

RUN npm install
RUN npm run build

CMD ["npm", "run", "start:prod"]
```

 
 ### Dockerfile.test natomiast nie buduje aplikacji od nowa a dziedziczy wszystko po wcześniej napisanycm Dockerfile i tylko uruchamia testy.

Dockerfile.test:
```bash
FROM app-build

CMD ["npm", "run", "test"]
```

### Następnie zbudowałam program i przetestowałam przy użyciu napisanych Dockerfile'ów.

 ![Błąd wyświetlania](lab3_ss/lab3ss11.png)
 ![Błąd wyświetlania](lab3_ss/lab3ss12.png)

 ### W kolejnym kroku uruchomiłam kontener testowy:

 ![Błąd wyświetlania](lab3_ss/lab3ss13.png)

### To, że i w tym przypadku testy przeszły poprawnie potwierdza poprawność wdrożenia.

 ![Błąd wyświetlania](lab3_ss/lab3ss14.png)





 # LAB 4

### Pracę z woluminami rozpoczęłam w wersji bez zainstalowanego gita. Utworzyłąm zatem dwa woluminy - wejściowy i wyjściowy. Woluminy zostały utworzone niejawnie podczas uruchamiania kontenera przy użyciu flagi -v. Docker automatycznie zainicjalizował nazwane woluminy lab4_wejscie i lab4_wyjscie. 

### W pierwszej wersji przygotowałam kontener bazowy, który nie posiada gita, więc zrobiłam to na obrazie node:20-slim. 

  ![Błąd wyświetlania](lab4_ss/lab4ss1.png)

  ### Ponieważ kontener nie mógł sam pobrać kodu skożystałam z kontenera pomocniczego. Uruchomilam tymczasowy kontener oparty na obrazie alpine/git. Podczas jego startu podmontowałam wolumin lab4_wejscie do katalogu /target wewnątzr kontenera. Następnie sklonowałam repo na ten wolumin.

  ![Błąd wyświetlania](lab4_ss/lab4ss2.png)

  ### Jest to rozwiązanie, który pozwala zachować obraz budujący czysty, bez zbędnych zależności. Kontener pomocniczy wypełnia swoje zadanie i jest od razu usuwany, zostawiając dane na wspólnym woluminie. Dla porównania Bind Mount wymagałby posiadania Gita na hoście i ręcznego zarządzania uprawnieniami do plików między hostem a kontenerem. Natomiast kopiowanie do /var/lib/docker ingeruje w wewnętrzne pliki systemowe Dockera, co może prowadzić do uszkodzenia danych.

  ![Błąd wyświetlania](lab4_ss/lab4ss3.png)

  ![Błąd wyświetlania](lab4_ss/lab4ss4.png)

  ### Następnie uruchomiłam build w kontenerze.

  ![Błąd wyświetlania](lab4_ss/lab4ss5.png)

  ![Błąd wyświetlania](lab4_ss/lab4ss6.png)

  ### Skopiowałam zbudowany folder dist na wolumin wyjściowy:

  ![Błąd wyświetlania](lab4_ss/lab4ss7.png)

  ### Następnie, aby sprawdzić czy dane przetrwały, całkowicie usunęłam kontener lab4-base i podpięłam wolumin wyjściowy do zupełnie nowego kontenera busybox.

  ![Błąd wyświetlania](lab4_ss/lab4ss8.png)

  ### Na ekranie pojawiła się pełna struktura skompilowanych plików JavaScript, co potwierdza to, że proces budowania zakończył się sukcesem.


  ### Następnie zrobiłam to samo, ale klonawanie na wolumin wejściowy przeprowadziłam wewnątrz kontenera już z wykorzystaniem Gita w kontenerze.

 ![Błąd wyświetlania](lab4_ss/lab4ss9.png)

 ### Po uruchomieniu nowego kontenera w folderze input nadal były stare pliki, więc musiałam je usunąć przed zaciągnięciem repo do tego folderu. Po usunięciu pierwszej instancji kontenera i uruchomieniu nowej z tym samym montowaniem, pliki z poprzedniej sesji były nadal dostępne. Ponieważ narzędzie Git wymaga pustego katalogu docelowego do wykonania operacji clone, konieczne było wyczyszczenie zawartości woluminu przed ponownym pobraniem kodu.

  ![Błąd wyświetlania](lab4_ss/lab4ss10.png)

  ![Błąd wyświetlania](lab4_ss/lab4ss11.png)
  ![Błąd wyświetlania](lab4_ss/lab4ss12.png)
  ![Błąd wyświetlania](lab4_ss/lab4ss13.png)

 ### Ta metoda jest szybsza w konfiguracji, ale powoduje że finalny obraz kontenera jest znacznie cięższy.

  ### Prezanalizowałam również możliwość automatyzacji opisanych kroków za pomocą pliku Dockerfile i instrukcji RUN --mount, kóra pozwala na tymczasowe podpięcie zasobów wyłącznie na czas budowania obrazu. Umożliwiłoby to dostarczenie kodu źródłowego do kompilacji bez koniecnzości jego trwałego kopiowania do warstw obrazu czy instalacji Gita wewnątrz kontenera bazowego. Takie podejście pozwala na stworzenie minimalistycznego obrazu zawierającego folder dist jednocześnie eliminując konieczność zarządzania. woluminami wejściowymi i wyjściowymi. 


  ### Następnie rozpoczęłam kolejną część laboratoriów dotyczącą łączności między kontenerami.

  ### Do uruchomienia serweru iperf wykorzystałam gotowy obraz. 

 ![Błąd wyświetlania](lab4_ss/lab4_ss14.png)

 ### Następnie sprawdziłam adres IP serwera:

 ![Błąd wyświetlania](lab4_ss/lab4_ss15.png)

 ### Uruchomiłam drugi kontener, który posłuży jako klient i połączyłam się z drugim kontenerem. W ten sposób zabadałam ruch sieciowy. 

  ![Błąd wyświetlania](lab4_ss/lab4_ss16.png)

  ### Sprawdziłam adres ip drugiego kontenera.

   ![Błąd wyświetlania](lab4_ss/lab4_ss17.png)

   ### Jednocześnie został wykonany test przepustowości. Wyniki są na poziomie 66,8 Gbits/sec, co jest bardzo dobrym wynikiem.

   ### W celu potwierdzenia połączenia między dwoma kontenerami wyświetliłam logi:

   ![Błąd wyświetlania](lab4_ss/lab4_ss18.png)

   ### Następnie przeszłam do utworzenia dedykowanej sieci mostkowej.

   ![Błąd wyświetlania](lab4_ss/lab4_ss19.png)

   ### Aby móc skorzystać z tej samej nazwy serwera usunęlam stary serwer, a następnie uruchomiłam nowy serwer w sieci lab4_network.

   ![Błąd wyświetlania](lab4_ss/lab4_ss20.png)

   ### Tym razem połączyłam się z wykorzystaniem nazw zamiast adresów IP. Test zakończył się sukcesem, co udowodniło poprawność działania wewnętrznego mechanizmu DNS Dockera w sieciach użytkownika.

   ![Błąd wyświetlania](lab4_ss/lab4_ss21.png)

   ### W kolejnym kroku, aby połączyć się spoza kontenera ponownie usunęłam poprzedni serwer i uruchomiłam nowy z mapowaniem portów.

   ![Błąd wyświetlania](lab4_ss/lab4_ss22.png)


### Najpierw połączyłam się z poziomu hosta z mojego ubuntu. W tym celu najpierw zainstalowałam Ierf3 na moim ubuntu. 

### Następnie uruchomiłam test łacząc się z adresem localhost.

![Błąd wyświetlania](lab4_ss/lab4_ss23.png)

### Test zakończył się powodzeniem, zatem przeszłam do testu łączności spoza hosta - z mojego windowsa. W konsoli powershell wykonałam test i również zakończył się powodzeniem.

![Błąd wyświetlania](lab4_ss/lab4_ss24.png)

![Błąd wyświetlania](lab4_ss/lab4_ss25.png)

![Błąd wyświetlania](lab4_ss/lab4_ss26.png)


### Następnie przystąpiłam do kolejnej części laboratorium. Przygotowałam kontener z SSHD.

![Błąd wyświetlania](lab4_ss/lab4_ss27.png)

![Błąd wyświetlania](lab4_ss/lab4_ss28.png)

### Teraz otwierając nowy terminal w sprawdziłam połączenie.

![Błąd wyświetlania](lab4_ss/lab4_ss29.png)

   
### Główną zaletą SSH jest wygoda i możliwość korzystania z różnych narzędzi. Dodatkowo można w prosty sposób kopiować pliki z mojego komputera bezpośrednio do wnętrza kontenera. To rozwiązanie ma jednak też wady. Kontener ma większy rozmiar - konieczne było zainstalowanie dodatkowych pakietó takich jak openssh-server. 


### Przeszłam do ostatniego etapu instrukcji, czyli uruchomienie Jenkinsa wewnątrz Dockera. 

### Zastosowałam obraz docker:dind w trybie --privileged. Pozwoliło to na stworzenie dedykowanego środowiska, w którym Jenkins może samodzielnie zarządzać kontenerami. Natomiast użycie woluminów zapewniło trwałość certyfikatów TLS oraz danych konfiguracyjnych.
  
![Błąd wyświetlania](lab4_ss/lab4_ss30.png)



### Uruchomiłam główny kontener serwera Jenkins, wykorzystując obraz jenkinsci/blueocean. luczowym elementem konfiguracji było zdefiniowanie zmiennych środowiskowych DOCKER_HOST, DOCKER_CERT_PATH, które wskazały Jenkinsowi drogę do zewnętrznego silnika Docker-in-Docker.

![Błąd wyświetlania](lab4_ss/lab4_ss31.png)

![Błąd wyświetlania](lab4_ss/lab4_ss32.png)

### Następnie wyświetliłam logi, aby uzyskać hasło. Wpisałam w przeglądarkę windowsa adres [..... ](http://172.25.100.132:8080/) i się zalogowałam.


![Błąd wyświetlania](lab4_ss/lab4_ss33.png)

![Błąd wyświetlania](lab4_ss/lab4_ss34.png)