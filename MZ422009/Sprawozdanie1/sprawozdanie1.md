# Sprawozdanie 1 #


# Lab 1 #
Wykonane kroki:
## 1.1. Dodanie klucza SSH do GitHub.
## 1.2. Branch.
Utworzenie nowej własnej gałęzi (branch) oraz sprawdzenie poprawności wybrania odpowiedniego brancha.

  ![Branch](SS-1.png)

## 1.3. Skrypt Git hook
Napisanie skryptu Git hooka - commit-msg, który werfikuje czy każdy commit zaczyna się poprawnym kodem (inicjały&nrindeksu).Skrypt należy umieścić w odpowiednim miejscu (.git/hooks), aby uruchamiał się przy każdym commicie.
### Kod skryptu: ###

  ![Hook](SS-2.png)

### Testowanie: ###
Wykonanie commitu z celowym bledem, aby sprawdzic poprawnosc skryptu.

  ![Wrong commit](SS-3.png)

Wykonanie prawidlowego commita.

  ![Right commit](SS-4.png)

## 1.4. Polecenie git push -> wysłanie zrobionych rzeczy do githuba.

  ![git push](SS-5.png)


# Lab 2 #
Wykonane kroki:
## 2.1. Docker
Zainstalowanie dockera (pakiet docker.io) w systemie Ubuntu 24.04.1 . Weryfikacja wersji:

  ![Docker-version](SS-6.png)

## 2.2. Obrazy
Pobranie obrazów: `hello-world`, `busybox`, `ubuntu`, `mariadb`, `node` za pomocą polecenia *sudo docker pull nazwa_obrazu*. Lista pobranych obrazów z ich rozmiarami:

  ![Downloaded images](SS-7.png)

## 2.3. hello-world
Testowe uruchomienie obrazu hello-world.

  ![hello-world image](SS-8.png)

## 2.4. busybox
Podlaczenie sie interaktywnie do kontenera z obrazu busybox. Poprzez wywołanie "echo $?" sprawdzamy kod zakończenia ostatnio wykonanego polecenia, czyli w tym przypadku poprawność wykonania busybox.

  ![busybox image](SS-9.png)

## 2.5. ubuntu
Uruchomienie "systemu w kontenerze"(ubuntu) + zaprezentowanie PID1 dla "bash", co potwierdza izolację od procesów hosta.

  ![ubuntu image](SS-10.png)

## 2.6. Dockerfile
Stworzenie pliku Dockerfile, który bazuje na obrazie ubuntu, instaluje "git", określa katalog roboczy oraz klonuje nasze repozytorium.
### Kod Dockerfile: ###

  ![Dockerfile](SS-11.png)

Budowa obrazu za pomocą utworzonego pliku Dockerfile oraz weryfikacja poprawności klonowania:

  ![Build](SS-12.png)
  ![Run](SS-13.png)

## 2.7. Wyświetlenie listy uruchomionych kontenerów:

  ![Running containers](SS-14.png)

## 2.8. Usuniecie kontenerow i obrazow z lokalnego magazynu:
  ![Containers remove](SS-15.png)
  ![Images remove](SS-16.png)


# Lab 3 #
Wykonane kroki:

## 3.1. Wybór repozytorium z kodem oprogramowania.
Do realizacji zadania wybrano projekt **Express.js**, czyli framework *Node.js* przeznaczony do budowy aplikacji webowych. Repozytorium zawiera kod źródłowy, zależności instalowane przez `npm` oraz testy uruchamiane poleceniem `npm test`, dzięki czemu nadaje się do demonstracji procesu *build* i *test* w kontenerach Dockera.

## 3.2. Etap build - Dockerfile.bld
Utworzono plik Dockerfile odpowiedzialny za przygotowanie środowiska oraz budowę aplikacji.
### Kod Dockerfile.bld: ###

  ![Dockerfile.bld](SS-17.png)

Za pomocą polecenia *sudo docker build -t express-build -f Dockerfile.bld .* zbudowano ten obraz. Oto tego wynik:

  ![Build](SS-18.png)

## 3.3. Etap testów - Dockerfile.test
Utworzono drugi Dockerfile bazujący na obrazie build. Ten Dockerfile ustawia katalog roboczy oraz uruchamia testy poleceniem *npm test*.
### Kod Dockerfile.test: ###

  ![Dockerfile.test](SS-19.png)

Następnie zbudowano tym razem ten obraz.

  ![Test](SS-20.png)

## 3.4. Weryfikacja obrazów
Sprawdzono dostępne obrazy:

  ![Obrazy](SS-21.png)


# Lab 4 #
Wykonane kroki:

## 4.1. Woluminy Dockera i zachowanie stanu
Na początku utworzono dwa woluminy: wejściowy i wyjściowy. Wolumin wejściowy został przeznaczony na kod źródłowy projektu, a wyjściowy na zapis wyników pracy kontenera.

![Volume create](SS-22.png)

Następnie uruchomiony został kontener bazowy `express-build` z podpiętymi właśnie stworzonymi woluminami pod katalogi `/input` oraz `/output`.

![Run+Volume](SS-23.png)

**Jak to zostało wykonane i dlaczego ta metoda?**
W celu sklonowania repozytorium do woluminu wejściowego wykorzystano uruchomienie kontenera pomocniczego z podpiętym woluminem (`input-data`) i wykonanie operacji `git clone` wewnątrz kontenera.
Takie rozwiązanie pozwala na zapisanie danych bezpośrednio w woluminie Dockera, który jest niezależny od cyklu życia kontenera.
	Nie zastosowano *bind mount* z lokalnym katalogiem, ponieważ dane miały być przechowywane w zarządzanym przez Dockera woluminie, co zapewnia większą przenośność i izolację od systemu hosta.
	Nie wykorzystano również bezpośredniego kopiowania do katalogu Dockera (`/var/lib/docker`), ponieważ nie jest to zalecana praktyka — katalog ten jest zarządzany przez silnik Dockera i nie powinien być modyfikowany ręcznie.

![Volume clone](SS-24.png)

Po udanym sklonowaniu, wykonano instalację zależności poleceniem `npm install` (będąc dalej wewnątrz kontenera). Teraz można już skopiować gotowy katalog projektu do wolumina wyjściowego.

![volume output](SS-26.png)

### Sprawdzenie wyników ###
W celu weryfikacji zapisania wyników na woluminie wyjsciowym po wyłączeniu kontenera, uruchomiono nowy kontener i sprawdzono zawartość woluminu `output-data`, potwierdzając zachowanie danych po zakończeniu pracy poprzedniego kontenera.

![output check](SS-27.png)

### Wniosek ###
Woluminy Dockera umożliwiają zachowanie stanu między kolejnymi kontenerami. Dzięki temu dane wejściowe i wyniki pracy nie zostały utracone po zakończeniu działania pojedynczej instancji kontenera.

## 4.2. Łączność między kontenerami
** a) Połączenie w domyślnej sieci Dockera (adres IP)**
W celu zbadania komunikacji sieciowej uruchomiono kontener z serwerem *iperf3*.

![iperf server](SS-28.png)
![iperf server](SS-29.png)

Następnie uruchomiono drugi kontener i wykonano w nim połączenie z użyciem adresu IP servera:

![iperf server](SS-30.png)
![iperf server](SS-31.png)


**Opis:** W tym przypadku komunikacja odbywa się w domyślnej sieci Dockera, gdzie kontenery identyfikowane są przez adresy IP.

** b) Połączenie w dedykowanej sieci (po nazwie kontenera)**
Utworzono własną sieć mostkową oraz uruchomiono kontener serwera w tej sieci:

![iperf server](SS-32.png)
![iperf server](SS-33.png)

Nastepnie uruchomiono drugi kontener clienta i wykonano w nim połączenie po nazwie kontenera:

![iperf server](SS-34.png)
![iperf server](SS-35.png)

**Opis:** W dedykowanej sieci Dockera możliwe jest używanie nazw kontenerów zamiast adresów IP dzięki wbudowanemu mechanizmowi DNS.

** c) Połączenie z hosta**
Uruchomiono kontener z mapowaniem portu, a w nim uruchomiono server iperf3:

![iperf server](SS-36.png)
![iperf server](SS-37.png)

Następnie z poziomu hosta wykonano połączenie do `localhost`:

![iperf server](SS-38.png)

**Opis:** Mapowanie portów (`-p`) umożliwia dostęp do usług działających w kontenerze z poziomu systemu hosta.
