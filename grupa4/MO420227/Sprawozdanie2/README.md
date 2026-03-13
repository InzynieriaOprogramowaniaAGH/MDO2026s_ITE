# Sprawozdanie: Środowisko skonteneryzowane

**Autor:** MO420227
**Zadanie:** Zestawienie i weryfikacja środowiska kontenerów Docker.

## 1. Instalacja i test obrazów
Zainstalowano pakiet docker. Zweryfikowano działanie demona poprzez uruchomienie obrazu `hello-world`.

![alt text](1.png)

## 2. Praca z kontenerami (Busybox i Ubuntu)
Uruchomiono kontenery `busybox` oraz `ubuntu`. Przeprowadzono testy interaktywne, weryfikując wersje oprogramowania oraz strukturę procesów.

![alt text](2.png)

![alt text](3.png)

Zaktualizowano pakiety.

![alt text](4.png)

## 3. Własny Dockerfile
Stworzono plik `Dockerfile`, w którym zautomatyzowano instalację `git`-a oraz pobranie repozytorium przedmiotowego.

![alt text](5.png)

Zbudowano kontener.

![alt text](6.png)

![alt text](7.png)

Uruchomiono kontener w trybie interaktywnym celem weryfikacji poprawnego klonowania repozytorium.

![alt text](8.png)

## 4. Zarządzanie zasobami
W celu utrzymania porządku w magazynie lokalnym, wyświetlono wszystkie kontenery, a następnie przeprowadzono procedurę czyszczenia nieużywanych zasobów za pomocą komend `prune`.

![alt text](9.png)

Usunięto nieużywane kontenery.

![alt text](10.png)

Usunięto nieużywane obrazy.

![alt text](11.png)