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
```
<img width="1072" height="668" alt="Zrzut ekranu 2026-03-06 093141" src="https://github.com/user-attachments/assets/dafbeb0d-83d5-4cee-aeef-8ade44e40c82" />
<img width="1034" height="684" alt="Zrzut ekranu 2026-03-06 093354" src="https://github.com/user-attachments/assets/2dbd0ad5-4d76-4afc-9406-0d0369e63182" />
<img width="1262" height="485" alt="Zrzut ekranu 2026-03-06 095359" src="https://github.com/user-attachments/assets/1a876885-c948-4c3f-802a-eb54fcf9ffbe" />
<img width="1473" height="143" alt="Zrzut ekranu 2026-03-06 095533" src="https://github.com/user-attachments/assets/fd45cab0-1df4-4483-9058-c6ccdd98afe6" />




# LAB 2 Docker
