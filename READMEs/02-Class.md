# Zajęcia 02

---

# Git, Docker

Celem zajęć jest zestawienie środowiska skonteneryzowanego do pracy nad CI i potwierdzenie łączności/możliwośi utrzymywania kodu w repozytorium GitHub.

## Zadania do wykonania

### Zestawienie środowiska skonteneryzowanego

1. Zainstaluj Docker w systemie linuksowym
   - użyj repozytorium swojej dystrybucji, jeżeli to możliwe (zamiast Community Edition - dystrybucyjne pakiety są lepiej dostosowane)
   - rozważ niestosowanie rozwiązania Snap (w Ubuntu) i FlatPak
2. Zarejestruj się w [Docker Hub](https://hub.docker.com/) i zapoznaj z sugerowanymi obrazami
3. Zapoznaj się z obrazami `hello-world`, `busybox`, `ubuntu` lub `fedora`, `mariadb`, `node` (dla Node.js), `runtime`, `aspnet` i `sdk` (dla Microsoft .NET)
   - uruchom je
   - sprawdź ich rozmiary
   - sprawdź kod wyjścia
4. Uruchom kontener z obrazu `busybox`
   - Pokaż efekt uruchomienia kontenera
   - Podłącz się do kontenera **interaktywnie** i wywołaj numer wersji
5. Uruchom "system w kontenerze" (czyli kontener z obrazu `fedora` lub `ubuntu`)
   - Zaprezentuj `PID1` w kontenerze i procesy dockera na hoście
   - Zaktualizuj pakiety
   - Wyjdź
7. Stwórz własnoręcznie, zbuduj i uruchom prosty plik `Dockerfile` bazujący na wybranym systemie i sklonuj w nim nasze repozytorium.
   - Kieruj się [dobrymi praktykami](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
   - Upewnij się że obraz będzie miał `git`-a
   - Uruchom w trybie interaktywnym i zweryfikuj że jest tam ściągnięte nasze repozytorium
8. Pokaż uruchomione ( != "działające" ) kontenery, wyczyść zakończone.
9. Wyczyść obrazy przechowywane w lokalnym magazynie 
10. Dodaj stworzone pliki `Dockerfile` do folderu `Sprawozdanie1` w swoim katalogu, na odpowiedniej gałęzi w repozytorium.
