# Sprawozdanie 1
Bartosz Bodulski, grupa 1, Tematy 1 - 4
## Temat 1
Cel zajęć - przygotowanie stanowiska pracy do dalszych zajęć.

Przygotowanie odpowiednich narzędzi:

```bash
sudo apt install git openssh -y; 
ssh-keygen -t ed25519; 
# dodatkowo opcja -c dla ssh-keygen powiązuje klucz z podanym adresem email
```

Klonowanie repozytorium:

```bash
git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git #https
git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git #ssh
```
Wymiana plików między klientem a serwerem odbywa się za pomocą oprogramowania FileZilla. Połączenie polega na podaniu nazwy użytkownika na serwerze z jego adresem IPv4. Wymiana pilków realizowana jest protokołem SFTP za pomocą wcześniej utworzonych kluczy.


Przejście do odpowiednich branch'y:

![img1](../screenshots/Zrzut%20ekranu%202026-03-06%20173954.png)

Utworzenie nowej gałęzi:

```bash
git checkout -b BB419678;
```

Stworzenie nowego folderu:

```bash
mkdir BB419678; cd BB419678;
```
![img3](../screenshots/Zrzut%20ekranu%202026-03-06%20092930.png)

Utworzenie hook'a:
```bash
code ~/MDO2026s_ITE/.git/hooks/commit-msg; 
```

![img4](../screenshots/Zrzut%20ekranu%202026-03-06%20091316.png)

```bash
chmod +x ~/MDO2026s_ITE/.git/hooks/commit-msg;
```

Testowanie hook'a dla git'a:

![img4](../screenshots/Zrzut%20ekranu%202026-03-06%20165005.png)


Próba wciągnięcią gałęzi do grupowej:

![img4](../screenshots/Zrzut%20ekranu%202026-03-06%20172309.png)

Jak widać, bez odpowiedniego formatu "commit message", nie jesteśmy w stanie spushować zmian na nasz branch w repozytorium.



## Temat 2

Cel zajęć: zestawienie środowiska skonteneryzowanego do dalszych ćwiczeń.

Instalacja środowiska docker:

Instalujemy dockera za pomocą repozytorium dystrybucji ubuntu server.

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker
```
![img5](../screenshots/Zrzut%20ekranu%202026-03-13%20081912.png)

Żeby nie pisać cały czas sudo docker ... możemy dodać siebie do specjalnej grupy docker:

![img6](../screenshots/Zrzut%20ekranu%202026-03-13%20082126.png)

Dodatkowo musimy się zalogować:

![img7](../screenshots/Zrzut%20ekranu%202026-03-13%20090233.png)

Po zalogowaniu normalnie przechodzimy do testowania kilku przykładowych obrazów.

hello-world:

![img8](../screenshots/Zrzut%20ekranu%202026-03-13%20083608.png)

Wygląda na to, że wszystko zostało poprawnie zainstalowane.

busybox:

ITE/GCL1/BB419678/screenshots/Zrzut ekranu 2026-03-13 084152.png
![img9](../screenshots/Zrzut%20ekranu%202026-03-13%20084152.png)