# Sprawozdanie 1 - Wprowadzenie, Git, Gałęzie, SSH
## Zajęcia 01 - Git
Na maszynie wirtualnej z systemem Ubuntu zainstalowano klienta Git z wykorzystaniem
systemowego menedżera pakietów `apt`. Repozytorium przedmiotowe zostało najpierw
sklonowane przez HTTPS z użyciem Personal Access Token (PAT). Przed zajęciami
zainstalowano plugin do Visual Studio Code dla SSH oraz skonfigurowano również

narzędzia pomocnicze (Visual Studio Code Remote-SSH oraz FileZilla do transferu SFTP).
Następnie wygenerowano nowoczesne klucze SSH (Ed25519 zabezpieczony hasłem oraz
ECDSA bez hasła), dodano klucz do platformy GitHub i sklonowano repozytorium przy
użyciu protokołu SSH.
Skonfigurowano globalne ustawienia wymagane do poprawnego podpisywania commitów:
```bash
git config --global user.name "HaatLukas"
git config --global user.email "lcurylo@student.agh.edu.pl"
```

![FileZilla](./img/L0_Start_0.png)
![Instalacja Pluginu Visual Studio Code](./img/L0_Start_1.png)
![Potwierdzenie połączenia SSH](./img/L0_Start_2.png)
![Klonowanie nr1](./img/L0_Start_3.png)
Sklonowanie repozytorium z użyciem protokołu SSH:
```bash
git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git
```

![SSH1](./img/L0_Start_6_SSH.png)
![SSH2](./img/L0_Start_7_SSH.png)
![SSH3](./img/L0_Start_8_SSH.png)
Przygotowanie gałęzi (branchy):
![Branch1](./img/L0_Start_Branche_4.png)
![BranchSkrypt](./img/L0_Start_Branche_5.png)
Napisano skrypt weryfikujący (Git Hook), sprawdzający poprawność wpisywanych
wiadomości:
```bash
#!/bin/bash
PREFIX="LC417617"

COMMIT_MSG=$(head -n 1 "$1")
if [[ ! $COMMIT_MSG == $PREFIX* ]]; then
echo "=========================================="
echo "BŁĄD COMMITA!"
echo "Wiadomość musi zaczynać się od '$PREFIX'."
echo "Twoja wiadomość: $COMMIT_MSG"
echo "=========================================="
exit 1
fi
exit 0
```

Skrypt został skopiowany do katalogu `.git/hooks/commit-msg` i nadano mu uprawnienia do
wykonywania poleceniem `chmod +x`. Każdy commit bez prefiksu `LC417617` jest
rygorystycznie odrzucany przez system kontroli wersji, co przetestowano w praktyce
podczas próby scalenia (merge) historii z serwera.
![Zapisanie skryptu i nadanie uprawnień](./img/L0_Start9_End.png)


## Użycie narzędzi Generatywnej AI

W celu sprawnego przygotowania, ustrukturyzowania oraz poprawnego sformatowania dokumentacji technicznej, skonsultowano się z modelem LLM.

### Treść wysłanego zapytania (Prompt):
> "Pomóż mi poprawnie sformatować i uporządkować plik README.md na potrzeby sprawozdania z zajęć z Gita. Mam przygotowaną treść oraz zrzuty ekranu o nazwach od L0_Start_0 itd. Jak poprawnie ułożyć strukturę w języku Markdown, aby całość wyrenderowała się na GitHubie?

### Metoda weryfikacji i modyfikacji:
Zaproponowany przez model układ dokumentu został ręcznie zweryfikowany w edytorze Visual Studio Code. Dokonano manualnej korekty ścieżek do zrzutów ekranu (dodano brakujące rozszerzenie `.png` przy pliku L0_Start_0). Bloki kodu Bash zawierające komendy konfiguracyjne tożsamości (`git config`) oraz strukturę skryptu Git Hook zostały poprawnie domknięte znacznikami Markdown, eliminując błędy formatowania tekstu ciągłego.