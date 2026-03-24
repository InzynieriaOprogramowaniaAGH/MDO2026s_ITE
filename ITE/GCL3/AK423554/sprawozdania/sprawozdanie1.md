Oto gotowy kod w formacie Markdown. Skopiuj całą zawartość poniższego bloku i wklej ją do swojego pliku .md – dzięki temu zachowasz odpowiednie formatowanie, nagłówki i bloki kodu.

Markdown
# Sprawozdanie z zajęć 1-4
**Lab1:** Wprowadzenie, Git, Gałęzie, SSH

---

## 1. Cel zajęć
Celem zajęć było poprawne przygotowanie stanowiska pracy, konfiguracja bezpiecznego połączenia z systemem kontroli wersji GitHub poprzez protokół SSH oraz wdrożenie automatyzacji pracy z commitami za pomocą mechanizmu Git Hooks.

---

## 2. Realizacja zadań

### Konfiguracja połączenia i kluczy
* **Instalacja:** Przygotowano środowisko uniksowe z zainstalowanym klientem Git.
* **Klucze SSH:** Wygenerowano dwa klucze (inne niż RSA, np. ED25519). Jeden z nich został zabezpieczony hasłem (passphrase).
* **GitHub:** Dodano publiczny klucz SSH do profilu GitHub oraz skonfigurowano uwierzytelnianie dwuskładnikowe (2FA).
* **Klonowanie:** Repozytorium zostało sklonowane dwukrotnie: najpierw przy użyciu HTTPS i Personal Access Token, a następnie przy użyciu protokołu SSH.


## 3. Praca na gałęziach
Zgodnie z instrukcją wykonano następujące kroki:
1. Przełączono się na gałąź grupy z poziomu gałęzi `main`.
2. Utworzono nową gałąź o nazwie `AK423554`.
3. Wewnątrz katalogu grupowego utworzono folder roboczy o tej samej nazwie.



---

## 4. Implementacja Git Hooka
W celu wymuszenia standardu nazewnictwa commitów, przygotowano skrypt `commit-msg`. Skrypt sprawdza, czy wiadomość zaczyna się od wymaganych inicjałów i numeru indeksu.

**Treść skryptu**
```#!/bin/bash
commit_msg=$(cat "$1")
pattern="^AK423554"

if [[ ! $commit_msg =~ $pattern ]]; then
  echo "Blad: wiadomosc musi sie zaczynac od AK423554"
  exit 1
fi

![alt text](image-2.png)