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


## Zadanie 2 i 3: Docker - Instalacja, obrazy i kody wyjścia

Zgodnie z instrukcją zainstalowałem Dockera, pobrałem wymagane obrazy (w tym te z repozytorium Microsoftu) oraz sprawdziłem ich rozmiary i kod wyjścia (dla hello-world). Poniżej pełna dokumentacja z tych kroków:

![Krok 1](docker1screen.png)

![Krok 2](docker2screen.png)

![Krok 3](docker2-2screen.png)

![Krok 4](docker3screen.png)

## Pozostałe zrzuty ekranu z wykonanych zadań (Zadania 4-9)

 dokumentacjaa z dalszej pracy z Dockerem (interaktywna praca z kontenerami, budowanie własnego obrazu z pliku Dockerfile oraz czyszczenie środowiska):

![Screen](docker3screen.png)
![Screen](docker4screen.png)
![Screen](docker5screen.png)
![Screen](docker6screen.png)
![Screen](<dockerScreen (1).png>)
![Screen](<dockerScreen (2).png>)
![Screen](<dockerScreen (3).png>)
![Screen](<dockerScreen (4).png>)
![Screen](<dockerScreen (5).png>)
![Screen](<dockerScreen (6).png>)
![Screen](<dockerScreen (7).png>)
![Screen](<dockerScreen (8).png>)
![Screen](<dockerScreen (9).png>)
