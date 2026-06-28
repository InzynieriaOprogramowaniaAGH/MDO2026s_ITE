# Zajęcia 01

---
# Wprowadzenie, Git, Gałęzie, SSH

Celem zajęć jest przygotowanie stanowiska pracy do dalszym toku przedmiotu. Scenariusz zakłada realizację wymagań wstępnych udostępnionych przed zajęciami.

## Zadania do wykonania

### Git
1. Zainstaluj klienta Git i obsługę kluczy SSH (w maszynie wirtualnej lub środowisku uniksowym)
2. Sklonuj nasze [repozytorium przedmiotowe](https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE) za pomocą HTTPS i [*personal access token*](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

### SSH
1. Utwórz klucze SSH
   - Utwórz dwa klucze SSH, inne niż RSA, w tym co najmniej jeden zabezpieczony hasłem
   - Skonfiguruj klucz SSH jako metodę dostępu do GitHuba
   - Sklonuj repozytorium **z wykorzystaniem protokołu SSH**
2. Skonfiguruj uwierzytelnianie dwuskładnikowe na swoim koncie GitHub

### Narzędzia
1. Skonfiguruj dostęp do repozytorium przedmiotowego (i maszyny wirtualnej) w edytorze IDE (np. [Visual Studio Code](https://code.visualstudio.com/) )
2. Skonfiguruj/zapewnij natychmiastową wymianę plików ze środowiskiem pracy za pomocą menedżera plików (np. FileZilla lub Windows File Explorer)

### Gałąź
1. Przełącz się na gałąź ```main```, a potem na gałąź swojej grupy (pilnuj gałęzi i katalogu!)
2. Utwórz gałąź o nazwie "inicjały & nr indeksu" np. ```KD232144```. Miej na uwadze, że odgałęziasz się od brancha grupy!
3. Rozpocznij pracę na nowej gałęzi
   - W katalogu właściwym dla grupy utwórz nowy katalog, także o nazwie "inicjały & nr indeksu" np. ```KD232144```
   - Napisz [Git hooka](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) - skrypt weryfikujący, że każdy Twój "commit message" zaczyna się od "twoje inicjały & nr indexu". (Przykładowe githook'i są w `.git/hooks`.)
   - Dodaj ten skrypt do stworzonego wcześniej katalogu.
   - Skopiuj go we właściwe miejsce, tak by uruchamiał się za każdym razem kiedy robisz commita.
   - Umieść treść githooka w sprawozdaniu.
   - W katalogu dodaj plik ze sprawozdaniem
   - Dodaj zrzuty ekranu (jako *inline*)
   - Wyślij zmiany do zdalnego źródła
   - Spróbuj wciągnąć swoją gałąź do gałęzi grupowej
   - Zaktualizuj sprawozdanie i zrzuty o ten krok i wyślij aktualizację do zdalnego źródła (na swojej gałęzi)
