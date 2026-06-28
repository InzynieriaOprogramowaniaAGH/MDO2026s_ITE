# Zajęcia 04
---
# Dodatkowa terminologia w konteneryzacji, instancja Jenkins

Celem zajęć jest uruchomienie instancji Jenkins w środowisku skonteneryzowanym. Potrzebna jest do tego dodatkowa wiedza dotycząca kontenerów.

## Zadania do wykonania

### Zachowywanie stanu między kontenerami

* Zapoznaj się z dokumentacją:
  * https://docs.docker.com/storage/volumes/
  * https://docs.docker.com/engine/storage/bind-mounts/
  * https://docs.docker.com/engine/storage/volumes/
  * https://docs.docker.com/reference/dockerfile/#volume
  * https://docs.docker.com/reference/dockerfile/#run---mount
* Przygotuj woluminy wejściowy i wyjściowy, o dowolnych nazwach, i podłącz je do kontenera bazowego (np. tego, z którego rozpoczynano poprzednio pracę).
* ⚠️ **Kontener bazowy to ten, który umie budować nasz projekt** (ma zainstalowane wszystkie dependencje, `git` nią nie jest i/lub nie musi nią być)
* Uruchom kontener, zainstaluj niezbędne wymagania wstępne lub upewnij się że są obecne (jeżeli istnieją), ale *bez Gita*. Nie chcemy żeby był obecny, nie chcemy z niego korzystać z poziomu kontenera
* Sklonuj repozytorium na wolumin wejściowy
  * Opisz dokładnie, jak zostało to zrobione **i powiedz dlaczego**
    * Wolumin/kontener pomocniczy?
    * *Bind mount* z lokalnym katalogiem?
    * Kopiowanie do katalogu z woluminem na hoście (`/var/lib/docker`)?
    * Jeszcze inaczej?
 * Uruchom build w kontenerze (potrzebny jest dostęp do kodu)
 * Zapisz powstałe/zbudowane pliki na woluminie "wyjściowym", tak by były dostępne po wyłączeniu kontenera.
* Pamiętaj, aby udokumentować wyniki.
* Ponów operację, ale klonowanie na wolumin "wejściowy" przeprowadź wewnątrz kontenera (teraz już możesz użyć Gita w kontenerze)
* Przedyskutuj możliwość wykonania ww. kroków za pomocą `docker build` i pliku `Dockerfile`. (podpowiedź: `RUN --mount`)

### Eksponowanie portu i łączność między kontenerami
* Zapoznaj się z dokumentacją [programu IPerf](https://iperf.fr/)
* Uruchom wewnątrz kontenera serwer iperf (`iperf3`)
* Uruchom drugi kontener
* Znajdź ich adresy IP
* Połącz się z nim z drugiego kontenera, zbadaj ruch
* Zapoznaj się z dokumentacją `network create` : https://docs.docker.com/engine/reference/commandline/network_create/
* Ponów ten krok, ale wykorzystaj własną dedykowaną sieć mostkową (zamiast domyślnej). Użyj **rozwiązywania nazw** (wskazuj na kontener za pomocą nazwy, nie adresu IP)
* Połącz się spoza kontenera (z hosta i **spoza hosta**)
* Przedstaw przepustowość komunikacji lub problem z jej zmierzeniem (wyciągnij log z kontenera, woluminy mogą pomóc, ale nie są konieczne)

### Usługi w rozumieniu systemu, kontenera i klastra
* Zestaw w kontenerze ubuntu/fedora usługę SSHD
* Połącz się z nią
* Opisz zalety i wady (przypadki użycia...?) komunikacji z kontenerem z wykorzystaniem SSH

### Przygotowanie do uruchomienia serwera Jenkins
* Zapoznaj się z dokumentacją [serwera CI Jenkins](https://www.jenkins.io/doc/book/installing/docker/)
* Przeprowadź instalację **skonteneryzowanej** instancji Jenkinsa z pomocnikiem DIND
* Zainicjalizuj instację, wykaż działające kontenery, pokaż ekran logowania
