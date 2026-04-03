# Sprawozdanie z laboratoriów 1-4

W tym pliku zebrałem przebieg czterech pierwszych laboratoriów z MDO. Pracowałem na własnej gałęzi `MA423062`, a do raportu wybrałem tylko te zrzuty, które faktycznie pokazują kolejne kroki, zamiast wrzucać wszystko po kolei.

## Laboratorium 1

Na początku przygotowałem środowisko pracy na maszynie z Ubuntu. Sprawdziłem połączenie z maszyną przez SSH z hosta Windows i upewniłem się, że usługa `ssh.service` działa poprawnie. Przy okazji ustawiłem też podstawową konfigurację Gita, czyli `user.name` i `user.email`.

![Logowanie do maszyny przez SSH](img/lab1/01_ssh_login.png)

Repozytorium przedmiotowe sklonowałem przez HTTPS poleceniem `git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git`. Do takiego dostępu potrzebny był token PAT zamiast zwykłego hasła.

![Klonowanie repozytorium przez HTTPS](img/lab1/02_git_clone.png)

Po sklonowaniu przeszedłem na `main`, potem na gałąź grupową, a z niej utworzyłem własną gałąź `MA423062`. W katalogu `GCL1/MA423062` umieściłem hook `commit-msg`, który pilnował, żeby każdy mój commit zaczynał się od numeru indeksu. Sam plik trzymałem w repozytorium, a do aktywnego hooka kopiowałem go do `.git/hooks/commit-msg`.

Treść hooka była taka:

```sh
#!/bin/sh

PREFIX="MA423062"
MSG_FILE="$1"
FIRST_LINE="$(head -n 1 "$MSG_FILE")"

case "$FIRST_LINE" in
  "$PREFIX"*)
    exit 0
    ;;
  *)
    echo "Błąd: commit message musi zaczynać się od '$PREFIX'" >&2
    exit 1
    ;;
esac
```

Najpierw sprawdziłem, czy hook rzeczywiście działa. Próba wykonania commita z komunikatem `zły commit` została od razu zatrzymana, więc warunek był ustawiony poprawnie. Osobno zachowałem też sam kod hooka jako zwykły plik w katalogu raportowym.

![Odrzucenie commita z błędnym prefiksem](img/lab1/03_hook_reject.png)

![Kod hooka zapisany w repozytorium](img/lab1/06_hook_code.png)

Do dalszej pracy skonfigurowałem Visual Studio Code i otworzyłem w nim repozytorium, żeby wygodnie edytować pliki na swojej gałęzi. Sprawdziłem też, że mogę połączyć się z katalogiem domowym maszyny przez SFTP z poziomu FileZilli. Ten screen traktuję jako potwierdzenie, że takie połączenie działało, a nie jako opis późniejszej pracy w tym programie.

![Potwierdzenie połączenia SFTP do maszyny](img/lab1/04_filezilla_access.png)

![Repozytorium otwarte w VS Code](img/lab1/05_vscode.png)

Na końcu wypchnąłem zmiany na swoją gałąź i przygotowałem pull request do gałęzi grupowej. Dzięki temu cały pierwszy etap miał już pełny przepływ: lokalna zmiana, kontrola komunikatu commita, push i zgłoszenie zmian do przeglądu.

![Porównanie gałęzi i przygotowanie pull requesta](img/lab1/07_pull_request.png)

## Laboratorium 2

Drugie laboratorium poświęciłem na oswojenie Dockera. Zacząłem od kilku gotowych obrazów: `hello-world`, `busybox`, `ubuntu`, `fedora`, `nginx` oraz obrazów .NET. Sprawdziłem ich rozmiary, żeby zobaczyć różnicę między bardzo małymi obrazami pomocniczymi a cięższymi środowiskami uruchomieniowymi.

![Uruchomienie kontenera hello-world i kod wyjścia 0](img/lab2/01_hello_world.png)

![Porównanie rozmiarów obrazów](img/lab2/02_image_sizes.png)

Potem uruchomiłem `busybox` w trybie interaktywnym i sprawdziłem wersję narzędzia. To był dobry, prosty test, czy kontener działa tak, jak zwykła mała powłoka użytkowa.

![Busybox uruchomiony interaktywnie](img/lab2/03_busybox_interactive.png)

Następnie uruchomiłem pełniejszy system w kontenerze na bazie Ubuntu. W środku sprawdziłem `PID 1` poleceniem `cat /proc/1/comm`, a potem wykonałem `apt update`. Po stronie hosta podejrzałem ten sam proces przez `docker top` i przez `ps`, żeby porównać widok z wnętrza kontenera i z zewnątrz.

![PID 1 w kontenerze i aktualizacja pakietów](img/lab2/04_pid1_update.png)

![Proces kontenera widziany z hosta](img/lab2/05_host_processes.png)

Kolejnym krokiem było przygotowanie własnego `Dockerfile`. Zbudowałem obraz na bazie `ubuntu:24.04`, ustawiłem `DEBIAN_FRONTEND=noninteractive`, doinstalowałem `git` i `ca-certificates`, a potem sklonowałem repozytorium na gałęzi `MA423062` do katalogu `/workspace/repo`. Na końcu zostawiłem `CMD ["bash"]`, żeby można było wygodnie wejść do środka i sprawdzić efekt.

![Mój plik Dockerfile](img/lab2/06_dockerfile.png)

![Budowanie własnego obrazu](img/lab2/07_build_image.png)

Po uruchomieniu kontenera od razu sprawdziłem, czy `git` jest dostępny, czy repozytorium rzeczywiście zostało sklonowane i czy aktywna gałąź zgadza się z moją gałęzią roboczą. W tym kroku chodziło mi już nie tylko o sam start kontenera, ale o potwierdzenie, że obraz zawiera wszystko, co było potrzebne do dalszej pracy.

![Repozytorium obecne wewnątrz kontenera](img/lab2/08_repo_in_container.png)

Na końcu zrobiłem porządki. Najpierw wyświetliłem wszystkie kontenery przez `docker ps -a`, potem usunąłem zakończone kontenery komendą `docker container prune -f`, a na koniec wyczyściłem obrazy zalegające w lokalnym magazynie poleceniem `docker image prune -a -f`. Gotowy `Dockerfile` przeniosłem do katalogu `Sprawozdanie1` i wypchnąłem do repozytorium.

![Lista wszystkich kontenerów przed czyszczeniem](img/lab2/09_docker_ps_a.png)

![Usuwanie zakończonych kontenerów](img/lab2/10_container_prune.png)

![Czyszczenie niepotrzebnych obrazów](img/lab2/11_image_prune.png)

![Dodanie Dockerfile do katalogu Sprawozdanie1 i push](img/lab2/12_repo_update.png)

## Laboratorium 3

Na trzecie laboratorium wybrałem projekt `jq`. To repozytorium było publiczne, miało klasyczny proces budowania przez `make` i zawierało testy, więc dobrze nadawało się do pokazania powtarzalnego etapu build/test.

Najpierw sklonowałem repozytorium `https://github.com/jqlang/jq.git`, a potem dociągnąłem submoduły. Następnie uruchomiłem `autoreconf -i`, `./configure --with-oniguruma=builtin` i zbudowałem projekt przez `make -j"$(nproc)"`. Dzięki temu konfiguracja i build korzystały z dołączonej wersji Onigurumy, a sam build wykorzystywał wszystkie dostępne rdzenie procesora.

![Klonowanie repozytorium jq](img/lab3/01_clone_jq.png)

![Konfiguracja z opcją --with-oniguruma=builtin](img/lab3/02_configure_builtin.png)

![Lokalny build z make -j\"$(nproc)\"](img/lab3/03_make_parallel.png)

Po buildzie uruchomiłem `make check`. Na lokalnym środowisku etap testów biblioteki Oniguruma przechodził poprawnie, więc miałem potwierdzenie, że zależności i konfiguracja są ustawione sensownie przed przeniesieniem procesu do kontenera.

![Lokalne uruchomienie make check](img/lab3/04_make_check_local.png)

Druga część laboratorium polegała już na zamknięciu tego procesu w kontenerach. Przygotowałem dwa pliki. `Dockerfile.build` instalował wymagane pakiety, klonował `jq`, dociągał submoduły i wykonywał cały build. `Dockerfile.test` bazował na obrazie `jq-build:local` i uruchamiał tylko `make check`, bez ponownego budowania. Dzięki temu etap testów był oddzielony od etapu budowania.

![Dockerfile.build użyty do etapu build](img/lab3/05_dockerfile_build.png)

Do uruchamiania całości użyłem `docker-compose.yml`. Najpierw zbudowałem obrazy `build-shell` i `test-runner`, a potem odpaliłem je osobno. `build-shell` pozwalał wejść do środka i ręcznie sprawdzić środowisko, natomiast `test-runner` startował od razu z poleceniem `make check`.

![Budowanie usług przez docker compose](img/lab3/06_compose_build.png)

![Interaktywne uruchomienie build-shell](img/lab3/07_compose_shell.png)

Najciekawszy był właśnie wynik etapu testowego. Kontener testowy wystartował poprawnie i uruchomił pełny zestaw testów, ale jeden z nich, `tests/shtest`, zakończył się błędem. Dla mnie to akurat był dobry przykład sensu CI: kontener nie miał niczego ukrywać, tylko w powtarzalny sposób dać jasny wynik, nawet jeśli kończy się on niepowodzeniem.

![Start kontenera testowego](img/lab3/08_test_runner_start.png)

![Jednoznaczny wynik testów w kontenerze](img/lab3/09_test_runner_result.png)

Jeżeli chodzi o wdrożenie końcowe, to `jq` lepiej nadaje się do dystrybucji w postaci binarki albo pakietu systemowego niż jako stale uruchomiona usługa w kontenerze. Kontener dobrze sprawdził się tutaj jako powtarzalne środowisko build/test. Etap publikacji warto rozdzielić od etapu testowego i przygotować osobny obraz albo osobny krok generujący końcowy artefakt.

## Laboratorium 4

### Woluminy i trwałość danych

Na początku zbudowałem obraz `my-builder-no-git:latest`. Celowo nie instalowałem w nim Gita. Obraz miał tylko to, co było potrzebne do samego budowania, czyli między innymi `build-essential`, `make` i `ca-certificates`. Po uruchomieniu od razu sprawdziłem, że `git --version` kończy się komunikatem `git: command not found`.

![Budowanie obrazu bazowego bez Gita](img/lab4/01_builder_no_git_build.png)

![Potwierdzenie, że Git nie jest dostępny w obrazie](img/lab4/02_git_not_found.png)

Następnie utworzyłem dwa woluminy: `repo_in` jako wejście z kodem źródłowym i `repo_out` jako miejsce na artefakty. W tym ćwiczeniu to rozdzielenie miało sens, bo od razu było wiadomo, skąd kontener bierze kod i gdzie odkłada wynik działania.

![Tworzenie i podgląd woluminów](img/lab4/03_volumes_create.png)

Kod źródłowy sklonowałem do woluminu wejściowego przez pomocniczy kontener Ubuntu z doinstalowanym `git` i `ca-certificates`. Wybrałem taki wariant dlatego, że nie chciałem kopiować plików ręcznie do katalogów Dockera na hoście, a jednocześnie obraz budujący miał dalej pozostać bez Gita. Po klonowaniu sprawdziłem zawartość woluminu i było widać całe repozytorium wraz z katalogami `GCL1`, `ITE`, `READMEs` i `Sprawozdanie1`.

![Klonowanie repozytorium do woluminu wejściowego](img/lab4/04_clone_to_input_volume.png)

![Sprawdzenie zawartości woluminu wejściowego](img/lab4/05_volume_listing.png)

Właściwy build uruchomiłem już w kontenerze bazowym z podpiętymi dwoma woluminami. W katalogu `/workspace/demo-build` wykonałem `make`, a gotowy plik `demo` skopiowałem do `/artifacts`. Po wyjściu z kontenera artefakt dalej był dostępny w `repo_out`, więc cel ćwiczenia został osiągnięty.

![Build w kontenerze i zapis pliku do /artifacts](img/lab4/06_build_with_volumes.png)

![Artefakt widoczny na woluminie wyjściowym po zakończeniu kontenera](img/lab4/08_output_volume.png)

Ten sam pomysł powtórzyłem jeszcze raz w wariancie, w którym klonowanie wykonałem wewnątrz tymczasowego kontenera. Najpierw doinstalowałem tam `git` i `ca-certificates`, a dopiero później zrobiłem `git clone` do woluminu wejściowego. To rozwiązanie też zadziałało, tylko było nieco mniej czyste niż użycie osobnego pomocniczego kontenera przygotowanego od razu do pobierania kodu.

![Doinstalowanie Gita w kontenerze i klonowanie do woluminu](img/lab4/07_install_git_in_container.png)

Ten sam efekt można też osiągnąć w `docker build` z BuildKitem i `RUN --mount`, ale w tym ćwiczeniu zwykłe woluminy wyraźnie rozdzielały wejście i wyjście procesu.

### Sieć i iperf3

W części sieciowej uruchomiłem `iperf3` jako serwer w jednym kontenerze i drugi kontener jako klient. Najpierw działałem na domyślnej sieci bridge i łączyłem się po adresie IP kontenera. Test w obie strony pokazał przepustowość w okolicach 27 Gbit/s, więc komunikacja między kontenerami na tym samym hoście działała poprawnie.

![Uruchomienie klienta iperf3 w drugim kontenerze](img/lab4/09_iperf_client_container.png)

![Pomiar przepustowości i test reverse](img/lab4/10_iperf_test.png)

Później utworzyłem własną sieć mostkową `lab-net`. Dzięki temu połączenie można było wykonywać po nazwach kontenerów zamiast po adresach IP, co uprościło komunikację między usługami.

![Utworzenie własnej sieci lab-net](img/lab4/11_custom_network.png)

Serwer wystawiłem też na hosta. Z poziomu Ubuntu na hoście zrobiłem test po `127.0.0.1` na portach `5201` i `5202`. Wynik był dalej bardzo wysoki, około 23 Gbit/s, bo ruch wciąż zostawał lokalnie na tej samej maszynie.

![Połączenie do iperf3 z hosta Ubuntu](img/lab4/12b_iperf_from_host.png)

Na końcu sprawdziłem połączenie spoza hosta, z Windowsa. W tym wariancie wynik był już dużo niższy, około 1.10 Gbit/s, co dobrze pokazało różnicę między ruchem lokalnym a rzeczywistym połączeniem przez sieć.

![Połączenie do iperf3 z komputera poza hostem](img/lab4/12c_iperf_from_remote.png)

### SSHD w kontenerze

Kolejnym krokiem było przygotowanie kontenera z usługą SSH. Zbudowałem prosty obraz na bazie `ubuntu:24.04`, doinstalowałem `openssh-server`, utworzyłem użytkownika `student`, ustawiłem mu hasło i jako proces główny zostawiłem `/usr/sbin/sshd -D`.

![Dockerfile dla kontenera z SSHD](img/lab4/12_ssh_dockerfile.png)

Po uruchomieniu kontenera połączyłem się do niego komendą `ssh student@127.0.0.1 -p 2222`. Sam dostęp działał poprawnie i dało się wejść do środka tak, jak do zwykłej usługi.

![Logowanie do kontenera przez SSH](img/lab4/13_ssh_login.png)

Zaletą tego podejścia jest możliwość połączenia się do kontenera jak do zwykłej usługi SSH. Wadą pozostaje dokładanie kolejnej usługi, otwartego portu i osobnych danych logowania do środowiska, w którym część zadań da się wykonać prościej przez `docker exec` albo woluminy.

### Jenkins z DIND

Na końcu przygotowałem konteneryzowaną instancję Jenkinsa z pomocnikiem DIND. Własny obraz zbudowałem na bazie `jenkins/jenkins:2.541.3-jdk21`, dodałem Docker CLI i doinstalowałem wtyczki `blueocean`, `docker-workflow` oraz `json-path-api`.

![Dockerfile dla własnego obrazu Jenkinsa](img/lab4/14_jenkins_dockerfile.png)

![Budowanie obrazu myjenkins-blueocean](img/lab4/15_jenkins_build.png)

Po zbudowaniu obrazu uruchomiłem zestaw kontenerów zgodnie z dokumentacją Jenkinsa: kontener z `docker:dind`, kontener pomocniczy `jenkins-docker` oraz właściwy `jenkins-blueocean`. Sprawdziłem listę działających kontenerów, żeby potwierdzić, że całość wstała poprawnie i że porty zostały wystawione.

![Działające kontenery Jenkinsa i DIND](img/lab4/16_jenkins_containers.png)

Do pierwszego logowania potrzebne było hasło startowe z pliku `initialAdminPassword`. Odczytałem je z kontenera i użyłem przy inicjalizacji serwera.

![Odczyt initialAdminPassword z kontenera](img/lab4/17_initial_password.png)

Na końcu sprawdziłem ekran logowania oraz pierwszy ekran konfiguracji Jenkinsa z wyborem wtyczek. To potwierdziło, że instancja została poprawnie uruchomiona i jest gotowa do dalszej konfiguracji pipeline'ów.

![Ekran logowania Jenkinsa](img/lab4/18_jenkins_login.png)

![Pierwszy ekran konfiguracji Jenkinsa](img/lab4/19_jenkins_setup.png)

## Wnioski

Cztery pierwsze laboratoria zbudowały spójny ciąg pracy: od przygotowania środowiska i repozytorium, przez pracę z obrazami i kontenerami, aż do uruchomienia usług potrzebnych w CI. Kolejne ćwiczenia rozwijały poprzednie etapy, dlatego w praktyce dało się przejść od podstawowego użycia Gita do bardziej złożonych zadań związanych z konteneryzacją i automatyzacją.

Najważniejszym efektem tych laboratoriów było uporządkowanie procesu pracy. W laboratorium 3 kontener został wykorzystany jako powtarzalne środowisko build/test, które zwraca jednoznaczny wynik także wtedy, gdy test kończy się błędem. W laboratorium 4 woluminy, sieć oraz kontenery pomocnicze pozwoliły rozdzielić kod źródłowy, artefakty i komunikację między usługami, co dobrze pokazuje praktyczne zastosowanie kontenerów w środowisku CI.
