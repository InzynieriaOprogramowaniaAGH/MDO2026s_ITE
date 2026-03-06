# Sprawozdanie - MB423178

## 1. Mój Git Hook
Oto skrypt, który napisałem, aby wymusić poprawne nazewnictwo commitów:

```bash
#!/bin/bash
PREFIX="MB423178"
commit_msg=$(head -n1 "$1")
if [[ ! $commit_msg == $PREFIX* ]]; then
    echo "BŁĄD: Twój commit message musi zaczynać się od: $PREFIX"
    exit 1
fi

<img width="1034" height="684" alt="Zrzut ekranu 2026-03-06 093354" src="https://github.com/user-attachments/assets/9de751e3-f5c9-4aae-99d2-36e44054f6c2" />


<img width="1072" height="668" alt="Zrzut ekranu 2026-03-06 093141" src="https://github.com/user-attachments/assets/fb345d48-c797-437b-ab45-405266efca51" />
