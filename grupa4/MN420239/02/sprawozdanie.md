# Sprawozdanie z zajęć 02

Autor: **MN420239**  
Grupa: **grupa 4**  
Data: **13.03.2026**

---

W ramach ćwiczenia zainstalowano Dockera w systemie Ubuntu z użyciem repozytorium dystrybucji. 

![Instalacja Dockera](zdjecia/1.png)

Uruchomiono przykładowe obrazy Dockera: `hello-world`, `busybox` oraz `ubuntu`, sprawdzając ich rozmiary oraz kody wyjścia. 

![Lista obrazów i rozmiary](zdjecia/3.png)

Uruchomienie obrazu `busybox`

![Uruchomienie busybox](zdjecia/4.png)

Połączenie się z busybox interaktywnie oraz wywołanie numeru wersji

![Połączenie z busybox](zdjecia/5.png)


Uruchomienie kontener z systemem `ubuntu`, zaprezentowano proces `PID1` wewnątrz kontenera oraz procesy Dockera na hoście, a następnie zaktualizowano pakiety i zakończono pracę w kontenerze. 

![Ubuntu docker](zdjecia/8.png)

![Docker PID1](zdjecia/6.png)

Przygotowano własny plik `Dockerfile` (docker-test/Dockerfile) bazujący na obrazie `ubuntu:22.04`, instalujący `git` oraz klonujący repozytorium `MDO2026_ITE`. 

![Plik Dockerfile](zdjecia/16.png)

Następnie został zbudowany obraz kontenera na podstawie wcześniejszego pliku `Dockerfile`.  

![Zbudowany obraz](zdjecia/9.png)

Kontener uruchomiono w trybie interaktywnym i zweryfikowano obecność sklonowanego repozytorium.

![repozytorium](zdjecia/11.png)

Na koniec wyświetlono listę uruchomionych oraz zakończonych kontenerów, wyczyszczono zakończone kontenery i usunięto nieużywane obrazy z lokalnego magazynu. 

![Kontenery](zdjecia/13.png)

Czyszczenie obrazów

![czyszczenie obrazów](zdjecia/14.png)

Plik `Dockerfile` dodano do katalogu sprawozdania zgodnie z poleceniem. 

![Plik w katalogu sprawozdania](zdjecia/17.png)
