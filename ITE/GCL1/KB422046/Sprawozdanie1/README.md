# Sprawozdanie 1

#### Informacje wstępne
Zgodnie z wymaganiami wstepnymi określonymi przez Prowadzącego środowisko do pracy zostało skonfigurowane przed pierwszymi zajęciami. Z tego też powodu proces ten nie został udokumentowany zrzutami ekranu.

Gotowe stanowisko do pracy obejmuje: maszyne wirtualną postawioną w Hyper-v (na bazie obrazu Ubuntu Serwer 24.04.4), edytor VS Code połączony zdalnie z maszyną oraz program FileZilla dla ułatwionego przesyłania plików.

Wszystkie zawarte w poniższym sprawozdaniu polecenia (oprócz jednego [wyjątku](####Połączono-się-z-serwerem-spoza-hosta:)) wykonane zostały z poziomu wbudowanego terminala VS Code. Szczegółowa historia poleceń została zawarta w oddzielnym [pliku](command_history.txt).

## Laboratorium 1

#### Przełączono się na gałąź *main*, a następnie na grupową:
![Przejscie do odpowiednich branchy: ](1.1_main_i_grupa.png)

#### Utworzono własną gałąź (składającą się z inicjałów i numeru indeksu):
![Utworzenie wlasnej galezi: ](1.2_moj_branch.png)

#### Utworzono własny folder (o tej samej nazwie co gałąź):
![Utworzenie wlasnego folderu: ](1.3_moj_folder.png)

#### Utworzono Git hook'a i dodano go do katalogu:
![Utworzenie hook'a i dodanie go do katalogu: ](1.4_moj_hook.png)

#### [Hook](commit-msg.sh):
![Tresc hook'a: ](1.5_moj_hook_kod.png)

*skrypt ma za zadanie weryfikować, czy każda wiadomość commit'a zaczyna się od inicjałów i numeru indeksu*

#### Skopiowano hook'a do utworzonego wcześniej folderu:
![Skopiowanie hook'a do odpowiedniego folderu: ](1.6_przeniesienie_hooka.png)

#### Zmodyfikowano uprawnienia hook'a:
![Modyfikacja uprawnien hook'a: ](1.7_uprawnienia_hooka.png)

*hook musi mieć nadane uprawnienia wykonania, by móc poprawnie funkcjonować*

#### Dodano sprawozdanie i zrzuty ekranu:
![Dodanie sprawozdania i zrzutow ekranu: ](1.8_sprawozdanie_i_zrzuty.png)

#### Efekt działania hook'a:
![Efekt dzialania hook'a: ](1.9_niepoprawny_commit.png)

*nieprawidłowe nazwanie commit'a skutkuje odrzuceniem wykonania operacji*

#### Dokonano próby wciągnięcia gałęzi własnej do grupowej:
![Proba wciagniecia wlasnej galezi do grupowej: ](1.10_proba_merge.png)

*zabezpieczenia gałęzi grupowej nie pozwalają osobom nieuprawnionym na wypchnięcie zmian*

## Laboratorium 2

#### Zainstalowano Docker'a:
![Instalacja Docker'a: ](2.1.1_instalacja_dockera.png)
![Instalacja Docker'a: ](2.1.2_instalacja_dockera.png)

#### Zweryfikowano instalację:
![Weryfikacja instalacji: ](2.2_weryfikacja_instalacji.png)

#### Zarejestrowano się do Docker Hub'a:
![Zarejestrowanie sie do Docker Hub'a: ](2.3_rejestracja_docker_hub.png)

#### Uruchomiono wyznaczone obrazy i sprawdzono ich kody wyjścia:

* hello-world

![hello-world: ](2.4_hello-world.png)

* busybox

![busybox: ](2.4_busybox.png)

* ubuntu

![ubuntu: ](2.4_ubuntu.png)

* fedora

![fedora: ](2.4_fedora.png)

* mariadb

![mariadb: ](2.4.1_mariadb.png)
![mariadb: ](2.4.2_mariadb.png)
![mariadb: ](2.4.3_mariadb.png)
![mariadb: ](2.4.4_mariadb.png)

* runtime

![runtime: ](2.4_ms_runtime.png)

* aspnet

![aspnet: ](2.4_ms_aspnet.png)

* sdk

![sdk: ](2.4_ms_sdk.png)

*wszystkie obrazy zostały pobrane, a utworzone na ich podstawie kontenery poprawnie się uruchomiły*

#### Sprawdzono rozmiary obrazów:
![Sprawdzenie rozmiarow obrazow: ](2.5_rozmiary_obrazow.png)

#### Uruchomiono kontener z obrazu Busybox:
![Uruchomienie kontenera z obrazu Busybox: ](2.6_busybox_uruchomienie.png)

*kontener zakończył działanie krótko po uruchomienu, jako że nie zostało mu przypisane żadne konkretne zadanie*

#### Podłaczono się do kontenera interaktywnie i sprawdzono jego wersję:
![Podlaczenie i sprawdzenie wersji: ](2.7_busybox_wersja.png)

#### Uruchomiono kontener z obrazu Ubuntu, zaprezentowano PID1, dokonano aktualizacji pakietów i prezentacji procesów Docker'a na hoście:
![Uruchomienie kontenera z obrazu Ubuntu (prezentacja procesow, aktualizacja pakietow): ](2.8.1_ubuntu.png)
![Uruchomienie kontenera z obrazu Ubuntu (prezentacja procesow, aktualizacja pakietow): ](2.8.2_ubuntu.png)

#### Stworzono własny obraz [Dockerfile](Dockerfile):
![Stworzenie wlasnego obrazu: ](2.9.1_moj_obraz.png)
![Stworzenie wlasnego obrazu: ](2.9.2_moj_obraz.png)

*uruchomiony na podstawie obrazu kontener zawiera sklonowane repozytorium*

#### Zaprezentowano uruchomione kontenery:
![Uruchomione kontenery: ](2.10_uruchomione_kontenery.png)

*dwa nadmiarowe kontenery obrazu busybox stanowią pozostałości po uruchomieniach testowych, niebędących częścią przeprowadzanego laboratorium*

#### Pozbyto się zakończonych kontenerów:
![Pozbycie sie zakonczonych kontenerow: ](2.11_czyszczenie_kontenerow.png)

#### Pozbyto się obrazów:
![Pozbycie sie obrazow](2.12_czyszczenie_obrazow.png)

## Laboratorium 3

Realizacja laboratorium zakłada znalezienie repozytorium oprogramowania z otwartą licencją, mozliwością zbudowania kodu i uruchamialnymi testami. Zdecydowano się na narzędzie [*curl*](https://github.com/curl/curl).

#### Zainstalowano zależności wymagane do uruchomienia wybranego oprogramowania:
![Instalacja zaleznosci: ](3.1.1_instalacja_zaleznosci.png)
![Instalacja zaleznosci: ](3.1.2_instalacja_zaleznosci.png)

#### Sklonowano repozytorium zawierające kod wybranego oprogramowania:
![Sklonowanie repozytorium: ](3.2_sklonowanie_repozytorium.png)

#### Przygotowanie:
![Przygotowanie: ](3.3_przygotowanie.png)

#### Konfiguracja:
![Konfiguracja: ](3.4.1_konfiguracja.png)
![Konfiguracja: ](3.4.2_konfiguracja.png)

*w celu uproszczenia procesu narzędzie skonfigurowano bez obsługi SSL*

#### Budowanie:
![Budowanie: ](3.5.1_build.png)
![Budowanie: ](3.5.2_build.png)

#### Testy:
![Testy: ](3.6.1_testy.png)
![Testy: ](3.6.2_testy.png)

*wszystkie testy zakończyły się powodzeniem - oprogramowanie zostało poprawnie skonfigurowane i zbudowane*

Wszystkie przeprowadzone do tej pory z poziomu hosta operacje mają teraz zostać wykonane interaktywnie, z wnętrza kontenera.

#### Uruchomiono kontener:
![Uruchomienie kontenera: ](3.7_uruchomienie_kontenera.png)

#### Zainstalowano wewnątrz wymagane zależności:
![Instalacja zaleznosci: ](3.8.1_instalacja_zaleznosci.png)
![Instalacja zaleznosci: ](3.8.2_instalacja_zaleznosci.png)
![Instalacja zaleznosci: ](3.8.3_instalacja_zaleznosci.png)

#### Sklonowano repozytorium:
![Sklonowanie repozytorium: ](3.9_sklonowanie_repozytorium.png)

#### Przygotowanie:
![Przygotowanie: ](3.10_przygotowanie.png)

#### Konfiguracja:
![Konfiguracja: ](3.11_konfiguracja.png)

#### Budowanie:
![Budowanie: ](3.12.1_build.png)
![Budowanie: ](3.12.2_build.png)

#### Testy:
![Testy: ](3.13.1_testy.png)
![Testy: ](3.13.2_testy.png)

#### Zaprezentowano kontener i obraz:
![Kontenery i obrazy: ](3.14_kontener_i_obraz.png)

Teraz proces ma zostać zautomatyzowany poprzez wykorzystanie dwóch kontenerów, pomiędzy które rozdzielone zostaną zadania.

#### [Dockerfile.build](Dockerfile.build):
![Dockerfile.build: ](3.15_Dockerfile.build.png)

#### [Dockerfile.test](Dockerfile.test):
![Dockerfile.test: ](3.16_Dockerfile.test.png)

#### Budowanie i testowanie:
![Budowanie i testowanie: ](3.17.1_Dockerfile_build.png)
![Budowanie i testowanie: ](3.17.2_Dockerfile_build.png)
![Budowanie i testowanie: ](3.17.3_Dockerfile_build.png)
![Budowanie i testowanie: ](3.17.4_Dockerfile_build.png)
![Budowanie i testowanie: ](3.17.5_Dockerfile_build.png)

Zastąpiono ręczne wdrażanie kontenerów kompozycją.

#### [Dockerfile-compose](docker-compose.yml):
![Dockerfile-compose: ](3.18_dockerfile-compose.png)

#### Budowanie:
![Budowanie: ](3.19.1_docker-compose_build.png)
![Budowanie: ](3.19.2_docker-compose_build.png)

#### Zaprezentowano kontenery:
![Kontenery: ](3.20_kontenery.png)

#### Zaprezentowano obrazy:
![Obrazy: ](3.21_obrazy.png)

## Laboratorium 4

#### Przygotowano woluminy (wejściowy i wyjściowy:)
![Wolumin wejsciowy i wyjsciowy: ](4.1_utworzenie_woluminow.png)

#### Sklonowano repozytorium na wolumin wejściowy za pomocą kontenera pomocniczego:
![Sklonowanie repozytorium na wolumin wejściowy za pomocą kontenera pomocniczego:](4.2_klonowanie_bez_gita.png)

*zastosowanie kontenera pomocniczego pozwala na sklonowanie repozytorium bez instalowania git'a w kontenerze docelowym*

#### Uruchomiono budowanie w kontenerze i zapisano powstałe pliki na woluminie wyjściowym:
![Budowanie: ](4.3.1_uruchomienie_i_build.png)
![Budowanie: ](4.3.2_uruchomienie_i_build.png)
![Budowanie: ](4.3.3_uruchomienie_i_build.png)
![Budowanie: ](4.3.4_uruchomienie_i_build.png)
![Budowanie: ](4.3.5_uruchomienie_i_build.png)

*operacja sprowadza się do zbudowania i przetestowania oprogramowania z poprzedniego laboratorium w kontenerze, ale z wykorzystaniem woluminów i bez użycia git'a*

Ponowne przeprowadzenie powyższych działań, ale wykonując klonowanie wewnątrz kontenera.

#### Utworzono nowy wolumin wejściowy:
![Utworzenie nowego woluminu wejściowego:](4.4_utworzenie_dodatkowego_woluminu.png)

#### Uruchomiono budowanie w kontenerze i zapisano powstałe pliki na woluminie wyjściowym:
![Budowanie: ](4.5_uruchomienie_i_build_druga_metoda.png)

#### Zaprezentowano wyniki:
![Zbudowane pliki: ](4.6_zbudowane_pliki.png)
![Zbudowane pliki: ](4.7.1_pliki_zbudowane_metoda_1.png)
![Zbudowane pliki: ](4.7.2_pliki_zbudowane_metoda_2.png)

*pliki zbudowane obydwoma metodami znajdują się w woluminie wyjściowym*

#### Uruchomiono serwer iperf i sprawdzono jego adres IP:
![Uruchomienie serwera iperf i sprawdzenie adresu IP: ](4.8_serwer_iperf.png)

#### Połączono się z drugiego kontenera z serwerem:
![Połączenie z drugiego kontenera z serwerem: ](4.9_polaczenie_iperf.png)

Powtórne wykonanie powyższych operacji, ale z wykorzystaniem własnej sieci mostkowej.

#### Utworzono własną sieć i uruchomiono w niej serwer iperf:
![Utworzenie własnej sieci i uruchomienie w niej serwera iperf:](4.10_serwer_iperf_z_wlasna_siecia.png)

#### Połączono się z drugiego kontenera z serwerem wykorzystując rozwiązywanie nazw:
![Połączenie z drugiego kontenera z serwerem: ](4.11_polaczenie_iperf_z_wlasna_siecia.png)

#### Uruchomiono nowy serwer iperf:
![Uruchomienie serwera iperf: ](4.12_serwer_iperf.png)

#### Połączono się z serwerem z hosta:
![Połączenie z serwerem z hosta: ](4.13_polaczenie_iperf_z_hosta.png)

#### Połączono się z serwerem spoza hosta:
![Połączenie z serwerem spoza hosta:](4.14_polaczenie_iperf_spoza_hosta.png)

#### Zestawiono w kontenerze usługę ssh:
![Zestawienie usługi ssh w kontenerze: ](4.15_zestawienie_uslugi_ssh.png)

#### Połączono się z usługą ssh:
![Połączenie z usługą ssh:](4.16_polaczenie_z_usluga_ssh.png)

#### Utworzono sieć i woluminy dla Jenkins'a:
![Utworzenie sieci i woluminów dla Jenkins'a: ](4.17_siec_i_woluminy_jenkinsa.png)

#### Zainstalowano Jenkins'a:
![Instalacja Jenkins'a:](4.18_instalacja_jenkinsa.png)

#### Zainicjalizowano instancję Jenkins'a:
![Inicjalizacja instancji Jenkins'a: ](4.19_inicjalizacja_instancji.png)

#### Zaprezentowano kontenery:
![Prezentacja kontenerów: ](4.20_wykaz_kontenerow.png)

#### Zweryfikowano poprawność uruchomienia Jenkins'a:
![Weryfikacja poprawności uruchomienia Jenkins'a: ](4.21_naglowek_http_jenkinsa.png)

#### Ekran logowania:
![Ekran logowania: ](4.22_ekran_logowania.png)

#### Zalogowano się do Jenkins'a:
![Zalogowanie sie do Jenkins'a: ](4.23_strona_glowna_jenkinsa.png)

Odpowiedzi na pytania:
* Repozytorium zostało sklonowane na wolumin wejściowy za pomocą kontenera pomocniczego z Gitem, aby nie musieć instalować go w kontenerze budującym. Alternatywnie mozna użyć *bind mount'a* z lokalnego katalogu lub ręcznie skopiować pliki na wolumin. Budowanie można zautomatyzować poprzez wykorzystanie *RUN --mount* w Dockerfile'u - pozwala to na tymczasowe podłączenie woluminów podczas budowania obrazu. Dzięki temu możliwe jest chociażby pobranie kodu źródłowego do obrazu bez trwałego kopiowania plików, co zmniejsza jego finalny rozmiar.
* Zaletą użycia SSH w kontenerze jest zapewnienie łatwego zdalnego dostępu. Co za tym idzie wadą jest więc zwiększone ryzyko bezpieczeństwa. Ponadto takie rozwiązanie łamie zasadę przypisania maksymalnie jednego procesu do pojedynczego kontenera.