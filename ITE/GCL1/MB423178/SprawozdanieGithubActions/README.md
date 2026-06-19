## Lab 12: Shift-left (GitHub Actions)

Celem ostatnich zajęć było zapoznanie się z koncepcją przenoszenia procesów CI/CD bliżej kodu źródłowego (tzw. podejście *Shift-left*) z wykorzystaniem natywnego narzędzia GitHub Actions. 

Przed przystąpieniem do pracy zapoznałem się z cennikiem i limitami darmowego planu GitHuba. Przewidziane 2000 darmowych minut na wykonanie akcji było wartością w zupełności wystarczającą do zrealizowania naszego projektu.

### 1. Przygotowanie niezależnego środowiska (Forkowanie)
Zgodnie z rygorystycznym wymogiem instruktorskim, nie mogłem modyfikować głównego repozytorium twórców oprogramowania. Zdecydowałem się wykorzystać oficjalny kod projektu **Spring PetClinic**, który sforkowałem (skopiowałem) na swoje prywatne konto na GitHubie. Zapewniło to bezpieczne środowisko do eksperymentów (tzw. piaskownicę), gdzie mogłem definiować potoki bez ryzyka, że zostaną odrzucone przez głównych kontrybutorów.

Następnie sklonowałem swoją prywatną kopię na maszynę wirtualną (poza główne repozytorium przedmiotowe, aby uniknąć konfliktów zagnieżdżonych repozytoriów Git). Po pobraniu plików utworzyłem wymaganą w poleceniu, dedykowaną gałąź o nazwie `ino_dev`.
Oryginalny kod posiadał już wbudowane, skomplikowane procesy CI/CD przygotowane przez twórców. Aby nie zakłócały one mojego zadania, usunąłem wszystkie dotychczasowe pliki konfiguracyjne z folderu `.github/workflows/`.

![Klonowanie, tworzenie gałęzi ino_dev oraz usuwanie starych akcji](screeny/Zrzut%20ekranu%202026-06-12%20100000.png)

### 2. Definicja i wdrożenie autorskiego potoku (YAML)
Stworzyłem własną akcję w pliku `.github/workflows/moj-pipeline.yml`, która odtwarza strukturę budowania używaną wcześniej w Jenkinsie. 

Kluczowym elementem konfiguracji był odpowiedni **trigger** (wyzwalacz) – potok został zaprogramowany tak, aby reagował **wyłącznie** na operację wysłania nowej rewizji (Push) na gałąź `ino_dev`.

Zdefiniowałem środowisko uruchomieniowe (darmowy runner `ubuntu-latest`) oraz cztery główne kroki akcji:
1. Pobranie kodu źródłowego (`actions/checkout`).
2. Konfigurację maszyny wirtualnej pod środowisko Java 17.
3. Budowanie projektu natywnym narzędziem Maven z flagą `-DskipTests` w celu przyspieszenia procesu.
4. Wyłuskanie pliku `.jar` i przesłanie go jako artefakt kompilacji.

Kod zaaplikowałem i wypchnąłem na GitHuba, autoryzując się odświeżonym tokenem dostępu (PAT).
![Wypchnięcie zmian z autorskim plikiem YAML na gałąź ino_dev](screeny/Zrzut%20ekranu%202026-06-12%20100247.png)

### 3. Weryfikacja działania środowiska CI i Artefakty
Zaraz po komendzie push, infrastruktura GitHub Actions przechwyciła zdarzenie i automatycznie uruchomiła potok zdefiniowany dla gałęzi `ino_dev`. 
![Potok GitHub Actions wykryty i uruchomiony w chmurze](screeny/Zrzut%20ekranu%202026-06-12%20100322.png)

Weryfikacja procesu przebiegła pomyślnie. Kod aplikacji został prawidłowo pobrany, środowisko Java skonfigurowane, a kompilator Maven zbudował projekt, co potwierdzają zielone statusy w szczegółach wykonania zadania `build-and-publish` (czas trwania: 44 sekundy).
![Szczegółowy widok kroków akcji zakończonych pełnym sukcesem](screeny/Zrzut%20ekranu%202026-06-12%20100400.png)

W ostatnim kroku wykorzystano dedykowaną akcję `actions/upload-artifact@v4`. Dzięki niej skompilowany plik wykonalny został przechwycony z maszyny wirtualnej GitHuba i opublikowany w zakładce *Summary*. Aplikacja w postaci archiwum o wadze 59.3 MB jest od teraz gotowa do bezpośredniego pobrania lub dalszego wdrażania (CD).
![Zbudowany artefakt załączony do wyników kompilacji](screeny/Zrzut%20ekranu%202026-06-12%20100447.png)

---

## Ważna adnotacja dotycząca użycia AI (Uzupełnienie dla Lab 12)
Podczas realizacji zagadnień z zakresu *Shift-left* wspomagałem się modelem językowym w celu:
1. **Analizy i projektowania środowiska:** Skonsultowałem z modelem problem konfliktów systemu kontroli wersji przy zagnieżdżonych repozytoriach. Model trafnie zasugerował wyjście poza folder główny repozytorium przedmiotowego (`cd ~`) przed sklonowaniem forka, co zapobiegło rozspójnieniu plików uczelnianych.
2. **Korekty składni CI:** Model wsparł mnie przy prawidłowym doborze wersji akcji na GitHubie (np. użycie `actions/setup-java@v4` w miejsce przestarzałych wersji) oraz w konstrukcji prawidłowego wyzwalacza `on: push` dla gałęzi `ino_dev`.
