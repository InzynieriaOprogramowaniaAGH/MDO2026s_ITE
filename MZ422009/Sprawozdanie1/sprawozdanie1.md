# Sprawozdanie 1 #

## Lab 1 ##

### Wykonane kroki: ###
1) Dodanie klucza SSH do GitHub.

2) Utworzenie nowej własnej gałęzi (branch) oraz sprawdzenie poprawności wybrania odpowiedniego brancha.

![Branch](SS-1.png)

3) Napisanie skryptu Git hooka - commit-msg, który werfikuje czy każdy commit zaczyna się poprawnym kodem (inicjały&nrindeksu).

![Hook](SS-2.png)
Skrypt należy umieścić w odpowiednim miejscu (.git/hooks), aby uruchamiał się przy każdym commicie.

Testowanie:
Wykonanie commitu z celowym bledem, aby sprawdzic poprawnosc skryptu.

![Wrong commit](SS-3.png)

Wykonanie prawidlowego commita.

![Right commit](SS-4.png)

4) Polecenie git push -> wysłanie zrobionych rzeczy do githuba.

![git push](SS-5.png)


## Lab 2 ##

### Wykonane kroki: ###
1) Zainstalowanie dockera w systemie linuksowym.
![Docker-version](SS-6.png)

2) Pobrane obrazy.
![Downloaded images](SS-7.png)

3) Uruchomienie obrazu hello-world.
![hello-world image](SS-8.png)

4) Podlaczenie sie interaktywnie do kontenera z obrazu busybox.
![busybox image](SS-9.png)

5) Uruchomienie "systemu w kontenerze"(ubuntu) + zaprezentowanie PID1.
![ubuntu image](SS-10.png)

6) Plik Dockerfile.
![Dockerfile](SS-11.png)

7) Zbudowanie.
![Build](SS-12.png)

8) Uruchomienie w trybie interaktywnym + weryfikacja repozytorium.
![Run](SS-13.png)

9) Uruchomione kontenery.
![Running containers](SS-14.png)

10) Usuniecie kontenerow i obrazow:
![Containers remove](SS-15.png)

![Images remove](SS-16.png)
