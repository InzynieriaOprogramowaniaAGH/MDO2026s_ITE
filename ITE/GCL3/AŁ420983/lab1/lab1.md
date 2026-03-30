# Sprawozdanie - Zajęcia 01

**Autor:** Aleksander Łatas
**Indeks:** 420983

## 1. Konfiguracja SSH
Wygenerowano dwa klucze SSH (typ Ed25519 oraz ECDSA). Klucz `id_ed25519` został zabezpieczony hasłem i dodany do profilu GitHub.

## 2. Git Hook
Stworzono skrypt `commit-msg`, który weryfikuje format wiadomości.

**Treść skryptu:**
```bash

#!/bin/bash
commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

pattern="^AŁ420983"

if [[ ! $commit_msg =~ $pattern ]]; then
  echo "BŁĄD: Wiadomość commita musi zaczynać się od: AŁ420983"
  exit 1
fi

```

### Test poprawności działania Git hooka
Poniżej znajduje się zrzut ekranu przedstawiający blokadę commita przy błędnej wiadomości oraz poprawnie wykonany commit:

![Zrzut ekranu testu hooka](test_hooka.png)