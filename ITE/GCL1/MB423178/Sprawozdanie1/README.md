# Sprawozdanie - MB423178

## Środowisko uruchomieniowe
Wszystkie opisane poniżej kroki zostały wykonane w wyizolowanym środowisku.
* **System operacyjny:** Maszyna wirtualna z systemem Linux.
* **Metoda dostępu:** Połączenie zdalne za pośrednictwem protokołu SSH (Secure Shell). Zgodnie z wytycznymi, cała praca odbywała się na koncie standardowego użytkownika (bez stałej sesji root ani logowania przez su). Polecenia demona Docker uruchamiałem jednak z użyciem przedrostka sudo. Wynika to z faktu, że nie przypisywałem na stałe swojego konta do grupy docker w systemie operacyjnym maszyny wirtualnej. Praca odbywała się bez użycia konsoli KVM.
* **Narzędzia pracy:** Edytor Visual Studio Code z wtyczką *Remote - SSH*, zapewniający dostęp do terminala oraz zarządzanie plikami.

## Lab 1 Wprowadzenie, Git, Gałęzie, SSH

Celem zajęć było przygotowanie stanowiska pracy, w tym konfiguracja narzędzi, uwierzytelniania SSH oraz struktury repozytorium.

### 1. Git
 Na początku sprawdziłem, czy w systemie jest zainstalowany klient Git. Następnie wykonałem pierwsze, testowe klonowanie repozytorium przedmiotowego z użyciem protokołu HTTPS. Do uwierzytelnienia wykorzystałem wygenerowany w panelu GitHub *Personal Access Token* (PAT).

![Klonowanie HTTPS i autoryzacja](lab1_9.png)

### 2. SSH

Aby zabezpieczyć komunikację z serwerem, skonfigurowałem klucze SSH.

* **Tworzenie kluczy:** Wygenerowałem dwa klucze oparte o nowoczesne algorytmy inne niż RSA:
  1. Główny klucz `ED25519` zabezpieczony silnym hasłem (`ssh-keygen -t ed25519 -C "bednarczyk1mikolaj@gmail.com"`).
  2. Zapasowy klucz `ECDSA` 521-bit (`ssh-keygen -t ecdsa -b 521`).
  
  ![Generowanie głównego klucza ED25519](lab1_6.png)
  
  ![Odczyt klucza publicznego ECDSA](lab1_18.png)

* **Konfiguracja GitHub:** Klucze publiczne dodałem do ustawień konta GitHub, a konto dodatkowo zabezpieczyłem uwierzytelnianiem dwuskładnikowym (2FA).

  ![Zarządzanie kluczami w GitHub](lab1_17.png)

* **Klonowanie repozytorium po SSH:** Przetestowałem połączenie poleceniem (`ssh -T git@github.com`) i sklonowałem repozytorium wykorzystując protokół SSH.

  ![Klonowanie po SSH](lab1_8.png)

### 3. Narzędzia

Jako środowisko pracy wybrałem **Visual Studio Code** z rozszerzeniem *Remote - SSH*. Dzięki temu mogłem edytować pliki i korzystać z terminala bezpośrednio na maszynie wirtualnej, co znacznie ułatwiło i przyspieszyło pracę, zapewniło natychmiastową wymianę plików.

![Podgląd plików i terminala w VS Code](lab1_15.png)


### 4. Gałąź i struktura katalogów

Pracę z repozytorium zacząłem od przejścia na gałąź `main`, a potem na gałąź mojej grupy `GCL1`.
* Stworzyłem nową gałąź roboczą (branch) o nazwie `MB423178` (inicjały i numer indeksu) od gałęzi grupowej.
* Wewnątrz powiązanego katalogu utworzyłem dedykowany katalog roboczy `MB423178`.

  ![Tworzenie gałęzi i struktury](lab1_10.png)

**Napisanie i wdrożenie Git Hooka**
Aby wymusić poprawną konwencję nazewnictwa, przygotowałem skrypt `commit-msg` weryfikujący, czy wiadomość commita zaczyna się od zadanego prefiksu. Dodałem go do folderu roboczego, a następnie skopiowałem do katalogu `.git/hooks`, nadając mu prawa do wykonywania (`chmod +x`).

### Mój Git Hook
Skrypt utworzyłem lokalnie, użyłem do tego wbudowanego edytora tekstu `nano`. W terminalu wpisałem polecenie `nano hook_skrypt.sh`, napisałem poniższy kod, a następnie zapisałem plik (skrót `Ctrl+O`, `Enter`) i zamknąłem edytor (`Ctrl+X`).

Oto dokładna treść, która znalazła się wewnątrz pliku:

```bash
#!/bin/bash
PREFIX="MB423178"
commit_msg=$(head -n1 "$1")
if [[ ! $commit_msg == $PREFIX* ]]; then
    echo "BŁĄD: Twój commit message musi zaczynać się od: $PREFIX"
    exit 1
fi
```

### 5. Praca z serwerem i rozwiązywanie konfliktów
Po dodaniu plików i zrzutów ekranu spróbowałem zrobić `git push`. Wystąpił konflikt, co pozwoliło zweryfikować poprawne działanie przygotowanego Git Hooka.

1. **Problem z `git push`:** Serwer odrzucił wysłanie zmian, ponieważ na zdalnym repozytorium znajdowały się commity, których nie miałem pobranych lokalnie.

   ![Odrzucenie pusha](lab1_11.png)

   ![Zalecenie użycia git pull](lab1_12.png)

2. **Aktywacja Git Hooka podczas `git pull`:** Przy próbie integracji zmian z serwera (`git pull`), Git usiłował stworzyć automatyczny "Merge commit". Operacja ta została **zablokowana przez mój autorski skrypt**, ponieważ domyślna wiadomość scalająca nie posiadała wymaganego prefiksu `MB423178`.

   ![Hook blokuje automatyczny merge commit](lab1_13.png)

3. **Rozwiązanie:** Aby prawidłowo połączyć pliki z pominięciem blokady, wykonałem commita ręcznie, nadając mu tytuł spełniający wymogi skryptu (`MB423178: Złączenie plików z serwerem`). Dzięki temu mogłem poprawnie wysłać zmiany na serwer (`git push`).

   ![Ręczny commit i poprawny push](lab1_14.png)

---

# LAB 2 Docker Git, Docker - Zestawienie środowiska skonteneryzowanego

Celem zajęć była konfiguracja Dockera, zapoznanie się z cyklem życia kontenerów oraz budową własnych obrazów.

### 1. Instalacja Dockera
Dockera zainstalowałem bezpośrednio z natywnego repozytorium dystrybucji Ubuntu, unikając ciężkich pakietów typu Snap czy Flatpak, które często wprowadzają niepotrzebny narzut wirtualizacji i problemy z uprawnieniami do plików systemowych. Poprawność instalacji potwierdziłem sprawdzając wersję narzędzia:

```bash
docker --version
```

![Wersja zainstalowanego Dockera](docker1screen.png)

### 2. oraz 3. Pobieranie obrazów, sprawdzanie rozmiarów i kodów wyjścia
Zarejestrowałem konto na platformie Docker Hub. Następnie pobrałem wyznaczone obrazy testowe i systemowe: `hello-world`, `busybox`, `ubuntu`, bazę danych `mariadb`, serwer `node` oraz środowiska .NET.
Do weryfikacji zajmowanego przez nie miejsca na dysku użyłem polecenia:
```bash
sudo docker images
```

![Zestawienie rozmiarów pobranych obrazów](docker2-2screen.png)

Aby przetestować uruchamianie kontenerów i zweryfikować kody wyjścia (exit codes), uruchomiłem obraz `hello-world`. Ponieważ program ten wykonuje zadanie i natychmiast się kończy, po jego wykonaniu odczytałem status ostatniego polecenia systemowego:

```bash
sudo docker run hello-world
echo $?
```

Kod wyjścia wyniósł `0`, co potwierdza bezbłędne wykonanie procesu.

![Uruchomienie hello-world i kod wyjścia](docker3screen.png)

### 4. Praca interaktywna z kontenerem BusyBox
Uruchomiłem lekki kontener narzędziowy oparty na obrazie `busybox` w trybie interaktywnym z podłączonym terminalem TTY (flagi `-it`), aby móc wydawać w nim polecenia. Wewnątrz środowiska sprawdziłem numer wersji narzędzia:

```bash
sudo docker run -it busybox sh
/ # busybox | head -n 1
```

![Praca interaktywna w busybox](docker4screen.png)

### 5. System w kontenerze i demonstracja PID 1
Aby sprawdzić procesy wewnątrz kontenera, uruchomiłem obraz ubuntu w kontenerze:

```bash
sudo docker run -it ubuntu bash
```

Wewnątrz kontenera odświeżyłem repozytoria oraz zainstalowałem pakiet `procps`, aby móc wywołać menedżer zadań `ps`:

```bash
apt update
apt install procps -y
ps -p 1
```

Wynik polecenia potwierdza, że głównym procesem (PID 1) wewnątrz kontenera jest powłoka `bash`. Świadczy to o pełnej izolacji środowiska od procesów pracujących na maszynie hosta.

![Uruchomienie Ubuntu i aktualizacja apt](docker5screen.png)

![Dowód na działanie bash jako PID 1](docker6screen.png)

Potwierdziłem, że proces działa w tle, wykonując z drugiego terminala na hoście listowanie uruchomionych kontenerów:

```bash
sudo docker ps
```

![Działający kontener Ubuntu (ps)](dockerScreen(9).png)

### 7. Budowa własnego obrazu (Dockerfile)
Stworzyłem własny plik `Dockerfile` definiujący nowe środowisko oparte na `ubuntu:24.04`, wyposażone w narzędzie `git` oraz pobrany kod repozytorium zajęciowego. 
Zanim zbudowałem obraz, musiałem fizycznie utworzyć plik z instrukcjami. W terminalu wpisałem polecenie `nano Dockerfile` (wielkość liter ma znaczenie), napisałem w nim poniższą zawartość, zapisałem plik (`Ctrl+O`, `Enter`) i wyszedłem z edytora (`Ctrl+X`).

**Treść `Dockerfile`:**
```dockerfile
# FROM - Określa obraz bazowy (nowoczesne wydanie LTS Ubuntu)
FROM ubuntu:24.04

# RUN - Wykonuje polecenia podczas budowania warstwy. 
# Zgrupowanie poleceń update i install w jednej linijce to dobra praktyka oszczędzająca ilość warstw obrazu.
RUN apt-get update && apt-get install -y git

# WORKDIR - Ustawia katalog roboczy dla kolejnych instrukcji w kontenerze
WORKDIR /app

# RUN - Sklonowanie repozytorium przedmiotowego do katalogu roboczego
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

# CMD - Definiuje domyślny proces (powłokę), który zostanie uruchomiony po starcie kontenera
CMD ["bash"]
```

Zbudowałem obraz nadając mu własny tag `my-image-git`:

```bash
sudo docker build -t my-image-git .
```

Następnie uruchomiłem wygenerowany kontener interaktywnie, aby sprawdzić, czy repozytorium faktycznie zostało do niego sklonowane.

```bash
sudo docker run -it my-image-git
ls -la MDO2026s_ITE/
```

Repozytorium było na swoim miejscu.

![Tworzenie pliku Dockerfile](dockerScreen(8).png)

![Proces budowania - docker build](dockerScreen(7).png)

![Weryfikacja sklonowanego repozytorium wewnątrz kontenera](dockerScreen(6).png)

### 8. Zarządzanie kontenerami i czyszczenie (Prune)
Wyświetliłem pełną listę kontenerów (działających oraz zatrzymanych) komendą `ps -a`. Następnie użyłem komendy czyszczącej, aby hurtem usunąć z systemu wszystkie kontenery, które zakończyły swoje działanie:

```bash
sudo docker ps -a
sudo docker container prune -f
```

![Lista wszystkich kontenerów](dockerScreen(5).png)

![Czyszczenie zatrzymanych kontenerów](dockerScreen(4).png)

### 9. Oczyszczanie lokalnego magazynu obrazów
Po wyczyszczeniu kontenerów wykonałem polecenie usuwające nieużywane obrazy pobrane do lokalnego cache demona, aby odzyskać przestrzeń dyskową na maszynie wirtualnej:

```bash
sudo docker image prune -a -f
```

Wykonanie tej komendy zwolniło miejsce na dysku, zachowując jednocześnie plik `Dockerfile`.

![Komenda image ls](dockerScreen(1).png)

![Odzyskanie miejsca przez usunięcie obrazów](dockerScreen(2).png)

---

## Lab 03: Dockerfiles - kontener jako definicja etapu

Celem zajęć było zbudowanie oprogramowania w powtarzalnym środowisku CI, gwarantującym przenośność procesu pomiędzy różnymi systemami.

### 1. Wybór oprogramowania i budowa lokalna na hoście
Na obiekt testowy wybrałem projekt **Spring PetClinic**. Projekt idealnie pasuje do polecenia: ma licencję Apache 2.0, używa Mavena (./mvnw) i ma już napisane testy jednostkowe z raportem końcowym.

W pierwszej kolejności przygotowałem środowisko na maszynie hosta, doinstalowując niezbędne pakiety (Java JDK 17 i Git), a następnie zbudowałem i przetestowałem projekt lokalnie:

```bash
sudo apt update && sudo apt install -y openjdk-17-jdk git
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
./mvnw package -DskipTests
./mvnw test
```

**Dokumentacja procesu na hoście:**
![Instalacja środowiska na hoście](lab3_1.png)
![Klonowanie repozytorium na hoście](lab3_2.png)
![Sukces budowania aplikacji lokalnie](lab3_3.png)
![Sukces wykonania testów lokalnie](lab3_4.png)

### 2. Izolacja i powtarzalność: build w kontenerze interaktywnie
Aby zagwarantować powtarzalność środowiska, odtworzyłem cały proces kompilacji i testowania wewnątrz czystego kontenera bazowego z preinstalowanym środowiskiem Java. Uruchomiłem interaktywną powłokę (TTY) w obrazie `eclipse-temurin:17-jdk`:

```bash
sudo docker run -it eclipse-temurin:17-jdk bash
```

Wewnątrz kontenera zainstalowałem narzędzie `git`, sklonowałem projekt i ponownie wykonałem fazy *build* oraz *test*:

```bash
apt-get update && apt-get install -y git
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
./mvnw package -DskipTests
./mvnw test
```

**Dokumentacja pracy interaktywnej:**
![Pobranie i uruchomienie kontenera Java](lab3_5.png)
![Instalacja Git w kontenerze](lab3_7.png)
![Klonowanie repozytorium w kontenerze](lab3_6.png)
![Sukces fazy test w kontenerze](lab3_8.png)

### 3. Automatyzacja procesu (Dockerfiles)
Zautomatyzowałem powyższy proces tworząc pliki Dockerfile.:

**Plik 1: `Dockerfile.petClinic.build`** (odpowiada wyłącznie za pobranie i zbudowanie kodu). Utworzyłem go wpisując w terminalu `nano Dockerfile.petClinic.build`i piosząc w nim  taki kod:

```dockerfile
FROM eclipse-temurin:17-jdk
WORKDIR /app
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/spring-projects/spring-petclinic.git .
RUN ./mvnw package -DskipTests
```

**Wyjaśnienie użytych dyrektyw:**
* **`FROM`**: Określa obraz bazowy, na którym będzie opierał się nasz kontener. W tym przypadku jest to gotowe środowisko Java (JDK 17), niezbędne do skompilowania projektu.
* **`WORKDIR`**: Tworzy i ustawia domyślny katalog roboczy (`/app`) wewnątrz kontenera. Wszystkie kolejne instrukcje będą wykonywane w tym folderze.
* **`RUN`**: Służy do uruchamiania poleceń powłoki w trakcie budowania (tworzenia warstw) obrazu. Najpierw użyłem go do instalacji narzędzia Git, następnie do pobrania kodu źródłowego aplikacji z GitHuba, a na końcu do uruchomienia Mavena (`./mvnw package`), który skompilował projekt do pliku wykonywalnego z pominięciem testów.

**Plik 2: `Dockerfile.petClinic.test`** (bazuje na obrazie budującym i definiuje proces testowania). Utworzyłem go wpisując w terminalu `nano Dockerfile.petClinic.build`i piosząc w nim  taki kod:

```dockerfile
FROM petclinic-build:latest
CMD ["./mvnw", "test"]
```

**Wyjaśnienie użytych dyrektyw:**
* **`FROM`**: Jako bazy nie używa czystego systemu, lecz naszego lokalnego obrazu `petclinic-build:latest`, który zbudowaliśmy w poprzednim kroku. Dzięki temu kontener testowy dziedziczy całe środowisko wraz z już pobranym i skompilowanym kodem.
* **`CMD`**: Definiuje polecenie, które ma zostać uruchomione jako główny proces w momencie startu gotowego kontenera (w przeciwieństwie do `RUN`, które działa tylko podczas budowania obrazu). Tutaj wymusza wykonanie zestawu testów jednostkowych za pomocą narzędzia Maven.
Zbudowałem oba obrazy:

```bash
sudo docker build -t petclinic-build -f Dockerfile.petClinic.build .
sudo docker build -t petclinic-test -f Dockerfile.petClinic.test .
```

![Budowanie warstwy Build](lab3_9.png)

![Budowanie warstwy Test z wykorzystaniem gotowej bazy](lab3_10.png)

Następnie wdrożyłem i uruchomiłem finalny kontener testowy:

```bash
sudo docker run --name tester-petclinic petclinic-test
```

![Działanie testów w kontenerze](lab3_11.png)

**Różnica między obrazem a kontenerem:** Obraz (`petclinic-test`) to statyczna paczka, niezmienna warstwa plików zawierająca system operacyjny, kod źródłowy i skompilowaną aplikację. Kontener (`tester-petclinic`) to uruchomiony na jej podstawie proces – w tym konkretnym wypadku jest to działająca maszyna Javy (JVM) odpalająca testy w Mavenie.

### 4. Zadania dodatkowe: Docker Compose
Aby zautomatyzować proces budowania i testowania, przygotowałem plik `docker-compose.yml`, napisałem w nim poniższą konfigurację i zapisałem:

```yaml
version: '3.8'
services:
  app-test:
    build:
      context: .
      dockerfile: Dockerfile.petClinic.test
```

Uruchomiłem całość zautomatyzowaną komendą `sudo docker-compose up`. Proces podniósł usługi, wykonał testy i wyłączył kontener z kodem `0` (sukces).

![Inicjalizacja Docker Compose](lab3_12.png)

![Poprawne zakończenie działania kompozycji](lab3_13.png)

### 5. Przygotowanie do wdrożenia (Deploy) - Dyskusja
Odpowiedzi na pytania z instrukcji:

* **Czy program nadaje się jako kontener?** PetClinic to aplikacja webowa komunikująca się przez port 8080, co czyni ją bardzo dobrym kandydatem do konteneryzacji i potencjalnej orkiestracji np. w Kubernetesie.
* **Oczyszczanie po buildzie:** Obecny obraz deweloperski zawiera pełne środowisko JDK i kod źródłowy, co niepotrzebnie zwiększa jego rozmiar oraz powierzchnię ataku. Przed wdrożeniem na produkcję należy zastosować mechanizm *Multi-stage build* – kompilacja kodu następuje w pierwszej warstwie, a do drugiego, lekkiego obrazu (zawierającego tylko środowisko uruchomieniowe JRE) kopiowany jest wyłącznie gotowy artefakt.
* **Format dystrybucji:** Docelowym artefaktem dla frameworka Spring Boot jest plik `.jar` z wbudowanym serwerem aplikacyjnym np. Tomcat, więc do uruchomienia całości wystarczy samo polecenie `java -jar`.

---

## Lab 04: Woluminy, Sieci, Usługi i Jenkins

### 1. Zachowywanie stanu (Woluminy Dockera)
Zadanie polegało na zachowaniu wygenerowanego pliku `.jar` nawet po usunięciu kontenera budującego.
Utworzyłem woluminy wirtualne:

```bash
docker volume create wejscie
docker volume create wyjscie
```

![Tworzenie woluminów](lab4_1.png)

Zgodnie z wymogami "czystego obrazu" (bez preinstalowanego narzędzia Git), repozytorium sklonowałem na wolumin `wejscie` przy pomocy tymczasowego kontenera pomocniczego:

```bash
docker run --rm -v wejscie:/data alpine/git clone [https://github.com/spring-projects/spring-petclinic.git](https://github.com/spring-projects/spring-petclinic.git) /data/spring-petclinic
```

![Klonowanie kontenerem pomocniczym](lab4_2.png)

**Dlaczego użyłem kontenera pomocniczego, a nie innych metod?**
**Uzasadnienie użycia kontenera pomocniczego:** Wykorzystanie tymczasowego kontenera pozwoliło sklonować repozytorium bezpośrednio na wolumin Dockera, z pominięciem lokalnego systemu plików hosta. Gwarantuje to wyższą przenośność (brak zależności od lokalnych ścieżek, jak w przypadku *bind mount*) i omija problemy z uprawnieniami, które mogłyby wystąpić przy ręcznym kopiowaniu plików do systemowego katalogu `/var/lib/docker`.
* **Bind mount z lokalnym folderem:** Gdybym po prostu zmapował lokalny katalog z kodem do kontenera, mój setup działałby tylko na tej konkretnej maszynie i tylko w tej konkretnej ścieżce. To psuje główną zaletę Dockera, czyli przenośność.
* **Ręczne kopiowanie do `/var/lib/docker`:** Grzebanie bezpośrednio w plikach systemowych Dockera na hoście to najgorsze, co można zrobić. Trzeba by to robić z konta root, co na 99% zepsułoby uprawnienia do plików i wywaliło błędy w samym demonie.
* **Kontener pomocniczy:** To najczystsze wyjście. Tworzymały, jednorazowy kontener, który po prostu pobiera repozytorium z sieci prosto na dockerowy wolumin, a potem sam się usuwa (dzięki fladze `--rm`).

Następnie uruchomiłem kontener budujący, podpinając oba woluminy, i skopiowałem wynik na wolumin wyjściowy:

```bash
docker run --rm -v wejscie:/app -v wyjscie:/out eclipse-temurin:17-jdk bash -c "cd /app/spring-petclinic && ./mvnw package -DskipTests && cp target/*.jar /out/"
```

![Sukces budowania](lab4_3.png)

![Gotowy plik jar na woluminie](lab4_4.png)

Ponowiłem test interaktywnie z instalacją Gita wewnątrz kontenera i zapisaniem drugiego pliku:
![Instalacja Gita interaktywnie](lab4_5.png)
![Klonowanie interaktywnie](lab4_6.png)
![Sukces ponowienia](lab4_7.png)
![Dwa pliki na woluminie po ponowieniu interaktywnym](lab4_8.png)

**Alternatywa z wykorzystaniem dyrektywy `RUN --mount`:** Operacje na zewnętrznych woluminach podczas budowy można zoptymalizować, stosując dyrektywę `RUN --mount=type=bind` w pliku `Dockerfile`. Pozwala to na dostęp do lokalnego kodu na czas kompilacji bez trwałego kopiowania go do warstw obrazu, co upraszcza proces i eliminuje konieczność ręcznego tworzenia woluminów w CLI. Pozwala to zaoszczędzić trochę wpisywania komend w terminalu.

### 2. Eksponowanie portów i łączność (Sieci)
Do testów łączności użyłem narzędzia `iperf3`.

W **sieci domyślnej (default bridge)** uruchomiłem serwer i odpytałem go z klienta za pomocą statycznego adresu IP wyciągniętego narzędziem `docker inspect`:

```bash
docker run -d --name serwer-iperf networkstatic/iperf3 -s
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' serwer-iperf
docker run -it --rm networkstatic/iperf3 -c <ZWRÓCONE_IP>
```

![Uruchomienie serwera iperf](lab4_9.png)

![Wynik testu po adresie IP](lab4_11.png)

Następnie utworzyłem własną sieć mostkową (custom bridge). Taka konfiguracja uaktywnia wbudowany w Dockera serwer DNS, co pozwoliło mi na nawiązanie połączenia przy użyciu samej nazwy hosta (`serwer-dns`), bez konieczności sprawdzania jego IP:

```bash
docker network create moja-siec
docker run -d --name serwer-dns --network moja-siec networkstatic/iperf3 -s
docker run -it --rm --network moja-siec networkstatic/iperf3 -c serwer-dns
```

![Wynik testu po nazwie DNS we własnej sieci](lab4_12.png)

**Wnioski z testów przepustowości (iperf3):**
Jak widać na powyższych zrzutach ekranu, przepustowość komunikacji w domyślnej sieci mostkowej wyniosła średnio **23.0 Gbits/sec**, a w dedykowanej sieci z rozwiązywaniem nazw DNS osiągnęła **21.4 Gbits/sec**. Oba wyniki są do siebie bardzo zbliżone. Wynika z tego, że narzut z wirtualizacji sieci Dockera jest znikomy. 
Warto również zauważyć, dlaczego te wartości są tak ogromne – ponieważ oba kontenery działają na tej samej fizycznej maszynie, cały ruch sieciowy odbywa się przez wirtualny interfejs loopback. Program w rzeczywistości nie testuje tu przepustowości fizycznej karty sieciowej, lecz wydajność procesora i pamięci RAM przy przerzucaniu buforów danych.

### 3. Usługi w systemie i klastrze (SSHD)
Uruchomiłem kontener realizujący usługę SSH i zalogowałem się do niego z poziomu mojej maszyny:

```bash
docker run -d --name serwer-ssh -p 2222:22 rastasheep/ubuntu-sshd:18.04
ssh root@localhost -p 2222
```

![Logowanie SSH do kontenera](lab4_13.png)

**Po co SSH w kontenerze?**
**Wnioski dotyczące usługi SSH w kontenerze:**
Uruchamianie serwera SSH w kontenerze jest uznawane za antywzorzec. Łamie to zasadę jednego procesu na kontener, utrudnia centralizację logów i stwarza niepotrzebne ryzyko bezpieczeństwa. Do standardowej interakcji ze środowiskiem należy używać polecenia `docker exec -it <nazwa> bash`. Wyjątkami uzasadniającymi implementację SSH w kontenerze są bardzo specyficzne scenariusze, takie jak tworzenie środowisk typu *Honeypot* do analizy ataków sieciowych lub konieczność konteneryzacji przestarzałych aplikacji (legacy), które wymuszają taki typ komunikacji.

### 4. Serwer Jenkins (Docker-in-Docker)
Przejrzałem oficjalną dokumentację Jenkinsa i na jej podstawie uruchomiłem środowisko Jenkins w konfiguracji DIND (Docker-in-Docker). Utworzyłem dedykowaną sieć i uruchomiłem kontener za pomocą oficjalnie rekomendowanej komendy:

```bash
docker network create jenkins

# Uruchomienie głównego kontenera Jenkinsa w stworzonej sieci z odpowiednimi portami i woluminem
sudo docker run --name jenkins-blueocean --rm --detach --network jenkins --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 --publish 8080:8080 --publish 50000:50000 --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro jenkins/jenkins:lts

# Weryfikacja działania
docker ps
```
**Kluczowe parametry użytej komendy:**
* `--network jenkins`: Podłącza kontener do dedykowanej sieci.
* Zmienne środowiskowe (`--env DOCKER_...`): Odpowiadają za autoryzację i bezpieczne połączenie TLS z demonem Dockera.
* Przekierowanie portów (`-p 8080:8080` i `-p 50000:50000`): Udostępnia interfejs graficzny oraz port do komunikacji z agentami.
* Mapowanie woluminów (`-v jenkins-data...`): Pozwala na zachowanie wtyczek, konfiguracji oraz hasła administratora po restarcie kontenera (co normalnie zostałoby utracone przez użycie flagi `--rm`).

Ponieważ główny kontener uruchomiłem z flagą `--rm`, po jego restarcie przepadły logi z początkowym hasłem administratora. Udało mi się je jednak bez problemu odzyskać z podpiętego woluminu `jenkins-data`:

```bash
sudo docker run --rm -v jenkins-data:/var/jenkins_home alpine cat /var/jenkins_home/secrets/initialAdminPassword
```

![Odzyskanie hasła z woluminu](lab4_17.png)

Przekierowałem port 8080 do środowiska lokalnego za pomocą VS Code i odblokowałem interfejs graficzny zdekodowanym hasłem, po czym zainstalowałem niezbędne wtyczki.

![Ekran Odblokuj Jenkinsa](lab4_15.png)

![Instalacja wtyczek Jenkins](lab4_16.png)

---

## Historia poleceń (Command History)
Poniżej znajduje się listing historii poleceń obrazujący sekwencję mojej pracy w terminalu maszyny wirtualnej (SSH):

```bash
# ==========================================
# LAB 1: Konfiguracja, Git, SSH i Git Hook
# ==========================================
git clone [https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git](https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git)
cd MDO2026s_ITE/ITE/GCL1/
git checkout -b MB423178
mkdir MB423178 && cd MB423178/
cp hook_skrypt.sh ../../../.git/hooks/commit-msg
chmod +x ../../../.git/hooks/commit-msg
ssh-keygen -t ed25519 -C "bednarczyk1mikolaj@gmail.com"
ssh-keygen -t ecdsa -b 521 -C "bednarczyk1mikolaj@gmail.com"
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
git config pull.rebase false

# ==========================================
# LAB 2: Docker - Podstawy, Obrazy, PID 1
# ==========================================
sudo apt update && sudo apt install docker.io -y
docker --version
sudo docker pull hello-world
sudo docker pull busybox
sudo docker pull ubuntu
sudo docker images
sudo docker run hello-world
echo $?
sudo docker run -it busybox sh
sudo docker run -it ubuntu bash
cat <<EOF > Dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y git
WORKDIR /app
RUN git clone [https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git](https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git)
CMD ["bash"]
EOF
sudo docker build -t my-image-git .
sudo docker run -it my-image-git
sudo docker ps -a
sudo docker container prune -f
sudo docker image prune -a -f

# ==========================================
# LAB 3: Dockerfiles i Docker Compose (CI)
# ==========================================
sudo apt update && sudo apt install -y openjdk-17-jdk git docker-compose
git clone [https://github.com/spring-projects/spring-petclinic.git](https://github.com/spring-projects/spring-petclinic.git)
cd spring-petclinic/
./mvnw package -DskipTests
./mvnw test
cd ..
sudo docker run -it eclipse-temurin:17-jdk bash
sudo docker build -t petclinic-build -f Dockerfile.petClinic.build .
sudo docker build -t petclinic-test -f Dockerfile.petClinic.test .
sudo docker run --name tester-petclinic petclinic-test
sudo docker-compose up
sudo docker system prune -a

# ==========================================
# LAB 4: Woluminy, Sieci (iperf), SSH i Jenkins
# ==========================================
sudo docker volume create wejscie
sudo docker volume create wyjscie
sudo docker run --rm -v wejscie:/data alpine/git clone [https://github.com/spring-projects/spring-petclinic.git](https://github.com/spring-projects/spring-petclinic.git) /data/spring-petclinic
sudo docker run --rm -v wejscie:/app -v wyjscie:/out eclipse-temurin:17-jdk bash -c "cd /app/spring-petclinic && ./mvnw package -DskipTests && cp target/*.jar /out/"
sudo docker run --rm -v wyjscie:/out alpine ls -lh /out
sudo docker run -d --name serwer-iperf networkstatic/iperf3 -s
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' serwer-iperf
sudo docker run -it --rm networkstatic/iperf3 -c 172.17.0.2
sudo docker network create moja-siec
sudo docker run -d --name serwer-dns --network moja-siec networkstatic/iperf3 -s
sudo docker run -it --rm --network moja-siec networkstatic/iperf3 -c serwer-dns
sudo docker run -d --name serwer-ssh -p 2222:22 rastasheep/ubuntu-sshd:18.04
ssh root@localhost -p 2222
sudo docker network create jenkins
sudo docker run --name jenkins-blueocean --rm --detach --network jenkins --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 --publish 8080:8080 --publish 50000:50000 --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro jenkins/jenkins:lts
sudo docker run --rm -v jenkins-data:/var/jenkins_home alpine cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## Ważna adnotacja dotycząca użycia AI
Zgodnie z prośbą z Rules.md, daję znać, że przy rozwiązywaniu niektórych problemów technicznych i układaniu struktury sprawozdania korzystałem z pomocy LLM (Gemini).

**Główne zapytania wysłane do modelu z podziałem na etapy pracy:**

* **Zajęcia 01:**
  1. *"Gdzie znaleźć lub jak stworzyć personal access token (PAT) na GitHubie?"*
  2. *"Jakie mogą być bezpieczne klucze SSH inne niż przestarzały RSA? Podaj link do rzetelnego źródła na ten temat."*
  3. *"Jak zapewnić natychmiastową wymianę plików z maszyną wirtualną w VS Code bez użycia FileZilli?"*
* **Zajęcia 02:**
  1. *"Jak sprawdzić PID głównego procesu wewnątrz czystego kontenera Ubuntu? Komenda `ps` nie działa, jakich pakietów muszę użyć, aby to udowodnić?"*
* **Zajęcia 03:**
  1. *"Jakie są najpopularniejsze otwarte licencje repozytoriów na GitHubie spełniające wymogi zadań uczelnianych? Podaj link, skąd czerpiesz te informacje."*
  2. *"Wypisz różnice między obrazem a kontenerem w Dockerze. Co tak naprawdę pracuje w uruchomionym kontenerze? Podaj źródła do oficjalnej dokumentacji."*
* **Zajęcia 04:**
  1. *"Jakie są wady i zalety różnych sposobów dostarczania kodu do kontenera? Opisz dokładnie i porównaj: kontener pomocniczy z woluminem, bind mount z lokalnym katalogiem oraz bezpośrednie kopiowanie do /var/lib/docker. Podaj linki do czytelni."*
  2. *"Opisz zalety i wady (oraz przypadki użycia) komunikacji z uruchomionym kontenerem z wykorzystaniem zintegrowanej w nim usługi SSH. Dlaczego uważa się to za antywzorzec?"*

**Metody weryfikacji odpowiedzi:**
Odpowiedzi modelu traktowałem jako wskazówki. Weryfikowałem je na dwa sposoby: po pierwsze, uruchamiając podane komendy w maszynie wirtualnej (co widac na screenach), a po drugie, sprawdzając informacje z oficjalną dokumentacją Dockera i GitHuba.
1. **Weryfikacja praktyczna:** Wszelkie sugestie dotyczące komend powłoki (bash/docker/git) czy konfiguracji środowiska (np. rozszerzenia VS Code, woluminy) były najpierw analizowane merytorycznie, a następnie uruchamiane ręcznie w wyizolowanym środowisku. Dowodem ich poprawnego działania są uwiecznione logi i zrzuty ekranu.
2. **Sprawdzanie źródeł :** W przypadku zapytań o teorię, wady i zalety architektoniczne oraz prośby o linki, wygenerowane materiały były konfrontowane z oficjalną dokumentacją dostawców technologii (Docker Docs, GitHub Docs). Linki dostarczone przez AI były ręcznie odwiedzane w celu wykluczenia zjawiska "halucynacji" modelu i potwierdzenia rzetelności informacji zawartych w sprawozdaniu.