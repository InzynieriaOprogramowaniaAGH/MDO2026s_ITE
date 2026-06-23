# Jaromir Gas - Sprawozdanie 1 - wprowadzenie, Git, gałęzie, SSH

Do realizacji zadań użyłem laptopa z systemem operacyjnym Windows 11. <br>
Do zarządania maszynami wirtualnymi i ich tworzenia użyłem Oracle VirtualBox. <br>
Ćwiczenie realizowałem na maszynie wirtualnej z systemem Ubuntu Serwer. <br>
Do przekazywania plików między maszyną wirtualną a fizyczną użyłem FileZilla. <br>
Nielicząc procesu konfiguracji połączenia SSH i tworzenia maszyny, nie korzystałem z okna samej maszyny wirtualnej do pracy na niej. <br>
Zamiast tego łączyłem się z nią przez SSH, pracując na niej z poziomu terminalu laptopa. <br>

# Realizacja ćwiczenia

Ćwiczenie rozpocząłem od utworzenia połączenia SSH między moim laptopem a maszyną wirtualną Ubuntu Serwer. <br>
W tym celu zainstalowałem openssh-serwer, uruchomiłem usługę i skonfigrowałem tak, by uruchomiała się automatycznie <br>
przy uruchamianiu maszyny wirtualnej i możliwy był powiązany z nią ruch sieciowy. <br>
<br>
Następnie zainstalowałem git, skonfigurowałem go na moje konto Github i połączony z nim adres email. <br>
Używając wygenerowany tymczasowy acces token DevOps1 z GitHub pobrałem repozytorium. <br>
<br>
Wygenerowałem 2 pliki klucze ssh - jeden publiczny oraz drugi prywatny zabezpieczone hasłem. <br>
Polecenia generowania kluczy nie zapisały się w historii (ze względu na nieprzewidziane wyłączenie komputera część danych w historii nie została zapisana), ale użyłem ssh-keygen -t ed25519 -C nazwa_pliku. <br>
Klucz publiczny (jego treść) skopiowałem do ustawień na GitHub aby skonfigurować połączenie. <br>
Kolejnym krokiem było wypełnienie pliku .ssh/config w celu konfiguracji połączenia ssh z github za pomocą podanych plików. <br>

<!--<img src="Zdjęcia/Pchełki.png" alt="Zdjęcie" width="=800">-->


