# Lab1 Wprowadzenie, Git, Gałęzie, SSH

## 1. Treść githooka

```bash
#!/bin/bash

MESSAGE=$(cat $1)

if [[ "$MESSAGE" != TK420057* ]]; then
  echo "Commit message musi zaczynać się od TK420057"
  exit 1
fi
```
## 2. Zrzuty ekranu

![Zrzut 1](img/Obraz1.png)
![Zrzut 2](img/Obraz2.png)
![Zrzut 3](img/Obraz3.png)
![Zrzut 4](img/Obraz4.png)
![Zrzut 5](img/Obraz5.png)
![Zrzut 6](img/Obraz6.png)
![Zrzut 7](img/Obraz7.png)
![Zrzut 8](img/Obraz8.png)
![Zrzut 9](img/Obraz9.png)

## Próba włączenia gałęzi do gałęzi grupowej

![Zrzut 10](img/Obraz10.png)

# Lab2 Git, Docker

## Pobieranie i uruchamianie obrazów, sprawdzenie ich rozmiarów.

![Zrzut 11](img/1.png)

## Uruchomienie kontenera z obrazu busybox oraz wywołanie numeru wersji

![Zrzut 12](img/3.png)

## Uruchomienie systemu w kontenerze

![Zrzut 13](img/4.png)

## Stworzenie i uruchomienie pliku Dockerfile klnoującego repozytorium przedmiotowe

```dockerfile
FROM ubuntu

RUN apt update && apt install -y git

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["bash"]
```

![Zrzut 14](img/7.png)
![Zrzut 15](img/8.png)

## Wyczyszczenie obrazów przechowywanych w lokalnym magazynie

![Zrzut 16](img/6.png)

# Lab3 Dockerfiles, kontener jako definicja etapu

![Zrzut 30](../lab3/9.png)
![Zrzut 31](../lab3/10.png)
![Zrzut 32](../lab3/11.png)
![Zrzut 33](../lab3/12.png)
![Zrzut 34](../lab3/13.png)
![Zrzut 35](../lab3/14.png)
![Zrzut 36](../lab3/15.png)
![Zrzut 37](../lab3/16.png)

# Lab4 Dodatkowa terminologia w konteneryzacji, instancja Jenkins

## Zachowywanie stanu między kontenerami

![Zrzut 17](../lab4/Obraz1.png)
![Zrzut 18](../lab4/Obraz2.png)

## Eksponowanie portu i łaczność między kontenerami

![Zrzut 19](../lab4/Obraz3.png)
![Zrzut 20](../lab4/Obraz4.png)
![Zrzut 21](../lab4/Obraz5.png)
![Zrzut 22](../lab4/Obraz6.png)
![Zrzut 23](../lab4/Obraz7.png)
![Zrzut 24](../lab4/Obraz8.png)
![Zrzut 25](../lab4/Obraz9.png)
![Zrzut 26](../lab4/Obraz10.png)
![Zrzut 27](../lab4/Obraz11.png)

## Jenkins

![Zrzut 28](../lab4/Obraz12.png)
![Zrzut 29](../lab4/Obraz13.png)