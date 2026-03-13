# Mateusz Sadowski - Labolatorium 1

### Środowisko wykonania

Maszyna wirtualna Oracle Virtual Box 7.2.6a z obrazem ISO Ubuntu 24.04.4 LTS. Maszyna posiada dostęp do 40 GB dostępnego obszaru na dysku, 2 rdzenie CPU oraz 4 GB pamięci ram.
Zastosowano przekierowanie portów (port forwarding), gdzie port 2222 na maszynie fizycznej (host) przekierowuje ruch na port 22 maszyny wirtualnej (guest), na którym pracuje serwer SSH.

### Git

Wykonano instalację środowiska Git (na serwerze) oraz następnie upewniono się, czy server obsługuje klucze SSH. Widać to na poniższym zrzucie ekranu:

![alt text](Sprawozdanie1/Git%20i%20obsługa%20SSH.png)

### SSH

#### Z poziomu Windows PowerShell dokonano połączenia z serverem:

        ssh sanioljr@127.0.0.1 -p 2222

#### Następnie utworzono personal access token:

Utworzenie tokenu zgodnie z instrukcją:

https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic

W dodatku zaznaczono **flagi: repo oraz admin:repo_hook**

![alt text](Sprawozdanie1/github%20token%20ustawienia.png)

Następnie sklonowano repozytorium za pomocą komendy git clone, po wykonaniu komndy git powinien zapytać o personal access token, nie stało się to jednak. Wynika to prawdopodobnie z faktu, że połączenie z serverem jest wykonane na maszynie, gdzie GitHub jest użytkowany na codzień, więc maszyna ma dostęp do odpowiedniego konta.

![alt text](Sprawozdanie1/clone%20repo.png)

Utworzono klucze SSH przy pomocy komendy:

        ssh-keygen -t <typ klucza> -C "<komentarz>"

**Poniżej widać jak ustawiono oba klucze\*.Warto podkreślić, że drugi klucz musiał być w innym folderze!**

![alt text](Sprawozdanie1/generowanie%202%20kluczy.png)

Następnie skonfigurowano klucz SSH jako metode dostępu do GitHub:

- **wyświetlono i skopiowano klucz publiczny w terminalu**

        cat ~/.ssh/id_ed25519.pub

- **w ustawieniach konta na GitHub (Settings -> SSH and GPG keys -> New SSH key) wklejono klucz z odpowiedznią nazwą, tak jak na poniższym zrzucie ekranu**

![alt text](Sprawozdanie1/GitHub%20klucz%20z%20nazwa.png)

#### Następnie odpowiednio sprawdzono czy GitHub rozpoznaje klucz:

![alt text](Sprawozdanie1/klucz%20rozpoznany%20github.png)

#### Nastepnie przy użyciu składni SSH pobrano repozytorium

![alt text](Sprawozdanie1/pobranie%20repo%20ssh.png)

### Narzędzia

#### Konfiguracja dostępu przez VS Code

Aby skonfigurować dostęp do repozytidoum w Visual Studio Code, należało pobrać rozszerzenie **Remote - SSH**, następnie w lewym dolnym rogu kliknąć ikonkę **><**, tam wpisać komendę dostępu

        <użytkownik>@<adres servera>

Później hasło do połączenia z serverem. Następnie w lewym górnym roku VS Code należało kliknąć **File -> Open Folder -> wyświeyliły się foldety jakie ma server, należało kliknąć "OK" i następnie ponownie wpisać hasło**.

**Poniżej przedstawiono efekt wykonanego połączenia:**

![alt text](Sprawozdanie1/vscode%20podpiety.png)

#### FileZilla

Skonfigurowanie FileZilla opierało się na kliknięciu w programie zakładki **Plik** a następnie **dodaniu adresu**, gdzie w oknie trzeba było wprowadzić następujące zmiany:

- uzupełnić adres servera,
- uzupełnić port na którym nasłuchuje,
- uzupełnić dane użytkownika
- zmienić protokół na SFTP
- Na końcu kliknąć **"Połącz"**

**Poniżej przedstaiwono efekt już wprowadzonych zmian**

![alt text](Sprawozdanie1/FileZilla%20-%20konfig%20polaczenia.png)

**Od tego momentu, możliwe było natychmiastowe przerzucanie plików za pomocą medenżera plików pomiędzy serverem a klientem. Widać do na poniższym screenshocie z ekranu głownego FileZilla:**

![alt text](Sprawozdanie1/Filezilla%20głowny%20widok%20po%20polaczeniu.png)

### Gałąź

Na początku upewniono się, że aktualny branch an jakim się znajdowano to był "main"

                gir branch

Przy pomocy poleceń

                git switch grupa5

oraz

                git checkout -b "MS423500"

przełączona się z brancha main na brancha grupa5, a następnie utworzono brancha "MS423500".

Tam przy pomocy polecenia

                mkdir "MS423500"

utworzono folder o konkretnej nazwie, odpowiadającej nazwie brancha, czyli inicjały studenta oraz jego numer albumu.

Następnie utworzono w tym folderze plik o nazwie "prepare-commit-msg". Jest to git hook, czyli plik ze skryptem, który git odpala za każdym razem, gdy się tworzy commita. W przypadku prepare-commit-msg, git odpala hooka chwil zanim zapisze wiadomość przekazana do commita. Dzięki czemu można ją np. edytować, takie też było zastosowanie tego pliku - dodanie do każdego commita na poczętek jego wiadomości inicjałów studenta oraz jego numer albumu.

#### Kod pliku:

                !/bin/bash

                #dodawanie MS423500 przed tekstem wpisywanym w commit message
                echo "MS423500: $(cat $1)" > $1

**Aby plik zadziałał należało go przenieść do odpowiegniego katalogu w repozytorium.**
Zrobiono to przy pomocy kompilacji poleceń

                ls -la

oraz

                cd <nazwa katalogu>

Po znalezieniu się w lokalizacji ../.git/hooks wywołano polecenie kopiujące plik ze skryptem

                cp /home/sanioljr/MDO2026_ITE/MS423500/prepare-commit-msg .

oraz nadano temu plikowi uprawnienie do wykonywania go.

                chmod +x prepare-commit-msg

Następnie skonfigurowano git auto-detect, wykonano commita zawierające wszyskie zmiany oraz sprawdzono jego ostateczną treść co pokazuje poniższy zrzut ekranu:

![alt text](Sprawozdanie1/git%20udany%20commit.png)

Jak na nim widać, ostateczną nazwę commita sprawdzono przy pomocy komendy

                git log -1

Później wrzucono przy pomocy programu FileZilla sprawozdania oraz folderu ze zrzutami ekranu to utowrzonego wcześniej katalogu.

**Aby wciągnąć własną gałąź do gałęzi grupowej przełączono się na gałąź gtupową, pobrano aktualności, a następnie wykonano git merge i zpushowano zmiany. Przedstawia to poniższy screenshot:**

![alt text](Sprawozdanie1/przelaczenie%20na%20grupa5%20branch.png)

### Propmty użyte do LLM:

- Jaka jest komenda na sprawdzenie wersji ssh (linux)
- Jak sklonować repozytorium za pomocą HTTPS i github personal access token?
- Linux - jak utworzyć klucze SSH i jak mogę je konfigurować?
- Jak skonfigurować klucz SSH jako metode dostepu do GitHub a nastepnie sklonować repozytorium z wykorzystaniem protokołu SSH tak by nie przeszło automatycznie?
- Wytłumacz składnie i każdą linijke kodu podstaowego git hooka prepare-comimit-msg oraz jak działa ten kod tych hooków

### Historia z terminala:

**Niestety poprzez nagłę zamknięcie sesji utraciłem dostęp do historii z terminala dotyczącej wykonywania labolatorium, za wyjątkiem cześć dedykowanej Gałęzi. Historia ta jednak jest przedstawiona na powyższych zrzutach ekranu wraz z odpowiedziami systemu.**

#### Przepisane komendy z zrzutów ekranu:

                sudo apt install git

                git --version

                ssh -v

                ssh sanioljr@127.0.0.1 -p 2222

                git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE

                ssh-keygen -t ed25519 -C "klucz1"

                ssh-keygen -t ed25519 -C "klucz2bezhasla"

                n

                ssh-keygen -t ed25519 -C "klucz2bezhasla"

                /home/sanioljr/.ssh/id_klucz_projekt2

                cat ~/.ssh/id_ed25519.pub

                ssh -T git@github.com

                y

                yes

                cat

                ls

                git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

#### Kopia historii dotyczącej części "Gałąź":

                53  ls

                54  cd MDO2026_ITE

                55  git branch -a

                56  git switch grupa5

                57  git branch

                58  git fetch

                59  git branch

                60  git checkout -b "MS423500"

                61  git branch

                62  ls

                63  mkdir MS423500

                64  ls

                65  cd MS*

                66  touch prepare-commit-msg

                67  ls -la

                68  cd

                69  ls -la

                70  git rev-parse --show-toplevel

                71  git -v

                72  cd MDO*

                73  la -la

                74  cd .git

                75  ls

                76  cd hooks

                77  ls

                78  nano prepare-commit-msg.sample

                79  cp MDO2026_ITE/MS423500/prepare-commit-msg .

                80  cp /home/sanioljr/MDO2026_ITE/MS423500/prepare-commit-msg .

                81  ls

                82  chmod +x .git/hooks/prepare-commit-msg

                83  chmod +x prepare-commit-msg

                84  cd ..

                85  git add .

                86  git commit -m "git hook: prepare-commit-hook"

                87  git config --global user.email "mateusz.sadowski04@wp.pl"

                88  git config --global user.name "sanioljr"

                89  git commit -m "git hook: prepare-commit-hook"

                90  git log -1

                91  ls

                92  cd MS*

                93  ls

                94  cd Sprawozdanie1

                95  ls

                96  cd ..

                97  git add .

                98  git commit -m "dodanie sprawozdania"

                99  git branch

                100  git push -u origin MS423500

                101  git checkout grupa5

                102  git pull origin grupa5

                103  git merge MS423500

                104  git push origin grupa5

                105  clear

                106  history

