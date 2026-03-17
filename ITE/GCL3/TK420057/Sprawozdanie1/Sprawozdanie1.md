# Lab1

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

# Lab2

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

![Zrzut 14](img/6.png)
