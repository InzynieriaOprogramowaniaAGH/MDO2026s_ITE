# Zajęcia 09
---
# Pliki odpowiedzi dla wdrożeń nienadzorowanych

## Zagadnienie
Niniejszy temat jest poświęcony przygotowaniu źródła instalacyjnego systemu dla maszyny wirtualnej/fizycznego serwera/środowiska IoT. Źródła takie stosowane są do zautomatyzowania instalacji środowiska testowego dla oprogramowania, które np. nie pracuje w całości w kontenerze.

### Cel zadania
* Utworzyć źródło instalacji nienadzorowanej dla systemu operacyjnego hostującego nasze oprogramowanie
* Przeprowadzić instalację systemu, który po uruchomieniu rozpocznie hostowanie naszego programu
  * Automatycznie wdrożyć/zainstalować oprogramowanie z *pipeline'u* podczas instalacji i/lub pierwszego uruchomienia

## Zadania do wykonania

🌵 Przeprowadź instalację nienadzorowaną systemu Fedora z pliku odpowiedzi z naszego repozytorium

* Utwórz nową maszynę wirtualną UEFI
* Zainstaluj [system Fedora](https://download.fedoraproject.org/pub/fedora/linux/releases/)
  * zastosuj instalator sieciowy (*Everything Netinst*) lub
  * zastosuj instalator wariantu *Server* z wbudowanymi pakietami, przyjmujący plik odpowiedzi (dobra opcja dla osób z ograniczeniami transferu internetowego)
* 🌵 Pobierz plik odpowiedzi `/root/anaconda-ks.cfg`
* Zapoznaj się z [dokumentacją pliku odpowiedzi](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html) i zmodyfikuj swój plik:
  * Dodaj informację o źródle instalacyjnym. Jeżeli Twoja płyta instalacyjna nie zawiera pakietów, dodaj wzmiankę o zewnętrznych repozytoriach skąd je pobrać. Na przykład, dla systemu Fedora 38:
      * `url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-38&arch=x86_64`
      * `repo --name=update --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f38&arch=x86_64`
  * Plik odpowiedzi musi pozwalać na reinstalację "w kółko", a początkowo może zakładać pusty dysk, co umożliwi tylko jednorazową instalację. Zapewnij, że zawsze będzie formatować wszystkie stosowne nośniki.
  * Ustaw *hostname* inny niż domyślny `localhost`, a użytkownika na coś innego niż `user`.
* Użyj pliku odpowiedzi do przeprowadzenia [instalacji nienadzorowanej](https://docs.fedoraproject.org/en-US/fedora/f36/install-guide/advanced/Kickstart_Installations/)
  * 🌵 Uruchom nową maszynę wirtualną z płyty ISO i wskaż instalatorowi przygotowany plik odpowiedzi stosowną dyrektywą uruchomieniową
  * Instalator nie powinien zadać ani jednego pytania i pozwalać na "bezdotykowe" czyszczenie maszyny i reinstalację.
---
* Rozszerz plik odpowiedzi o repozytoria i oprogramowanie potrzebne do uruchomienia programu, zbudowanego w ramach projektu - naszego *pipeline'u*. 
  * W przypadku kontenera, jest to po prostu Docker.
    * Utwórz w [sekcji `%post`](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#chapter-6-post-installation-script) mechanizm umożliwiający pobranie i uruchomienie kontenera
    * Jeżeli efektem pracy pipeline'u nie był kontener, a aplikacja samodzielna - zainstaluj ją
    * Pamiętaj, że **Docker zadziała dopiero na uruchomionym systemie!** - nie da się wdać w interakcję z Dockerem z poziomu instalatora systemu: polecenia `docker run` nie powiodą się na tym etapie. Nie zadziała też `systemctl start` (ale `systemctl enable` już tak)
  * Gdy program pracuje poza kontenerem, potrzebny jest cały łańcuch dependencji oraz sam program.
    * Użyj sekcji `%post`, by pobrać z Jenkinsa zbudowany artefakt
    * Rozważ stworzenie repozytorium ze swoim programem i dodanie go dyrektywą `repo` oraz zainstalowanie pakietu sekcją `%packages`
    * Jeżeli nie jest to możliwe/wykonalne, użyj dowolnego serwera SFTP/FTP/HTTP aby "zahostować" program - następnie pobierz go z tak hostującego serwera (stosując np. `wget`)
    * Umieść program w ścieżce stosownej dla binariów `/usr/local/bin/` (lub w katalogu, w którym instaluje go stworzony w *pipeline'ie* RPM, o ile taki istnieje)
    * Zadbaj w sekcji `%packages`, by system zainstalował wszystkie dependencje potrzebne do działania programu
  * Wybierz oprogramowanie na podstawie poprzedniego sprawozdania.
* Zadbaj o automatyczne ponowne uruchomienie maszyny na końcu instalacji (nie chcemy by instalator zawisł na ostatnim ekranie!)
* Zapewnij, by od razu po pierwszym uruchomieniu systemu, oprogramowanie zostało uruchomione (w dowolny sposób)

## Zakres rozszerzony
* Zapewnij, aby działania z sekcji `%post` wyświetlały się na ekranie
* Połącz plik odpowiedzi z nośnikiem instalacyjnym lub zmodyfikuj nośnik tak, by wskazywał na plik odpowiedzi w sieci i nie trzeba było tego podawać ręcznie (plan minimum: wskaź nośnikowi, aby użył pliku odpowiedzi)
* Zautomatyzuj proces tworzenia maszyny wirtualnej i uruchomienia instalacji nienadzorowanej. Użyj np. [wiersza poleceń VirtualBox](https://www.virtualbox.org/manual/ch08.html) lub [cmdletów Hyper-V](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/try-hyper-v-powershell)
* Wykaż, że system zainstalował się, a wewnątrz pracuje odpowiedni program