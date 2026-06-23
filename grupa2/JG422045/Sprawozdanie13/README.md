# Jaromir Gas - Sprawozdanie 13 - Shift-left: GitHub Actions

Do realizacji zadań użyłem laptopa z systemem operacyjnym Windows 11. <br>
Do zarządania maszynami wirtualnymi i ich tworzenia użyłem Oracle VirtualBox. <br>
Ćwiczenie realizowałem na maszynie wirtualnej z systemem Ubuntu Serwer. <br>
Do przekazywania plików między maszyną wirtualną a fizyczną użyłem FileZilla. <br>
Nielicząc procesu konfiguracji połączenia SSH i tworzenia maszyny, nie korzystałem z okna samej maszyny wirtualnej do pracy na niej. <br>
Zamiast tego łączyłem się z nią przez SSH, pracując na niej z poziomu terminalu laptopa. <br>

# Realizacja ćwiczenia

Ćwiczenia rozpocząłem od znalezienia repozytorium na GitHubie, które nie byłoby zbyt skomplikowane i miałoby otwartoźródłową licencję. Znalezione repozytorium SIMPLE okazało się spełniać te warunki, więc sforkowałem je tworząc własną kopię. Poniżej zdjęcia i link do oryginalnego repozytorium: <br><br>

<img src="Zdjęcia/Zrzut ekranu 2026-06-19 104252.png" alt="Zdjęcie" width="=800"> <br><br>
<img src="Zdjęcia/Zrzut ekranu 2026-06-19 104304.png" alt="Zdjęcie" width="=800"> <br><br>
Link do oryginalnego repozytorium: https://github.com/CMAKE-EXAMPLES/SIMPLE <br>

Sforkowaną kopię prokjektu pobrałem na moją maszynę wirtualną Ubuntu Serwer. Od razu utowrzyłem i przełączyłem się na nową gałąź "ino_dev". Następnie utworzyłem ukryty katalog .github/workflows i plik yaml ShiftLeftActionsJG.yml w jego wnętrzu. GitHub automatycznie sprawdza czy w podanej lokalizacji znajduje się taki plik, i jeśli tak to tworzy na jego podstawie akcje ułatwiające zautomatyzowanie budowania i testowania aplikacji podczas pracy nad kodem. <br><br>

<img src="Zdjęcia/Zrzut ekranu 2026-06-19 105018.png" alt="Zdjęcie" width="=800"> <br><br>
<img src="Zdjęcia/Zrzut ekranu 2026-06-19 115824.png" alt="Zdjęcie" width="=800"> <br><br>

Poniżej zamieściłem treść utworzonego pliku. Na początku znajduje się nazwa tego pipeline. Następnie podane jest kiedy akcje mają się uruchamiać - w tym przypadku przy spushowaniu lub pull requeście dla gałęzi ino_dev, na której pracowałem. Ostatnia sekcja, "jobs" określa zadania do wykonania wraz z krokami, nazwami kroków i specyfikacją. Uruchomienie na środowisku wirtualnym ubuntu pozwala uniknąć dodatkowych opłat podczas korzystania z GitHub Actionso raz jest najbliższe użytemu przeze mnie prostemu programowi ze względu na używane przez niego do budowy CMake. <br><br>

<img src="Zdjęcia/Zrzut ekranu 2026-06-23 202732.png" alt="Zdjęcie" width="=800"> <br><br>

Zadaniem konfiguracji jest wybudowanie i przetestowanie aplikacji po spushowaniu lub pull requeście w sposób automatyczny. Wykonywane jest w tym celu jedno zadanie "build" podzielone na kolejne kroki:<br>
* Checkout code: pobiera obecnie aktualny kod źródłowy na maszynę wirtualną.
* Install build tools and code quality linters: instaluje na maszynie wirtualnej używane oprogramowanie.
* Run Cppcheck: uruchamia narzędzie czytające kod C pod katem błędów. W razie nieprawidłowości rzuca błąd co jest przydatne by unikać prostych pomyłek przy aktualizacjach. W przypadku większych projektów warto dopilnować aby skan kodu był prowadzony tylko na zmienionych plikach a całość była sprawdzana poza czasem pracy na przykład w nocy. W pierwotnej wersji informacja o lokalziacji plików nagłówkowych była źle podana co spowodowało błąd po wypchnięciu.
* Configure CMake and build: wybudowanie (kompilacja) przy użyciu CMake z oryginalnego projektu ze wsparciem g++.
* Upload compiled binary artifact: tworzy artefakt potoku w postaci folderu zip z plikiem wykonywalnym aplikacji gotowy do pobrania.
<br><br>
Parametr "retention-days" określa czas przechowywania archiwum zip z ostatniego kroku (tutaj na 5 dni), co pozwala uniknąć dodatkowych kosztów.
<br><br>
Po wypełnieniu pliku wypchnąlem go na GitHub. Ponieważ okazało się, że lokalizacja plików nagłówkowych w pliku konfiguracyjnym nie była dobrze wskazana, poprawiłem go i wysłałem jeszcze raz:<br><br>

<img src="Zdjęcia/Zrzut ekranu 2026-06-23 201900.png" alt="Zdjęcie" width="=800"> <br><br>
<img src="Zdjęcia/Zrzut ekranu 2026-06-23 202926.png" alt="Zdjęcie" width="=800"> <br><br>

Gałąź "ino_dev" została wypchnięta poprawnie. Pierwsza wersja konfiguracji od razu wykryła błąd związany z plikami nagłówkowymi, a poprawiona działała przez jakiś czas, by poprawnie zbudować apliację.<br><br>

<img src="Zdjęcia/Zrzut ekranu 2026-06-23 202949.png" alt="Zdjęcie" width="=800"> <br><br>
<img src="Zdjęcia/Zrzut ekranu 2026-06-23 203004.png" alt="Zdjęcie" width="=800"> <br><br>

Poniżej widoczna w GitHub Actions poprawność wykonywania kroków oraz same akcje: <br><br>

<img src="Zdjęcia/Zrzut ekranu 2026-06-23 203538.png" alt="Zdjęcie" width="=800"> <br><br>
<img src="Zdjęcia/Zrzut ekranu 2026-06-23 203618.png" alt="Zdjęcie" width="=800"> <br><br>
<img src="Zdjęcia/Zrzut ekranu 2026-06-23 204347.png" alt="Zdjęcie" width="=800"> <br><br>

# Wnioski i zagadnienie

hift-left to podejście, które zakłada utworzenie w pierwszej kolejności systemu automatyzacji testowania i budowania aplikacji przy każdym kolejnym jej rozszerzeniu, zanim rozpoczną się intensywne prace nad samą jej treścią. Znacząco ułatwia to dalszą pracę, pozwalając na bieżąco sprawdzać poprawność wprowadzanych zmian, również pod kątem jakości i struktury.
<br><br>
GitHub Actions to narzędzie, które pozwala na realizację tego podejścia, automatycznie realizujące powierzone zadania, gdy nastąpią czynniki wyzwalające (w tym przypadku push lub pull request dla wybranej gałęzi).
<br><br>
Poznana technika i narzędzie mogą być bardzo pomocne w ułatwieniu sobie pracy nad projektem już na samym początku jego tworzenia oraz pozwalają uniknąć wykrycia kluczowych błędów strukturalnych dopiero tuż przed wdrożeniem projektu lub w jego trakcie.

