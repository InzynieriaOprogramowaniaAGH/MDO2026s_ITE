# SPRAWOZDANIA - MK421268

---

## LAB 1

### VM

Zastosowanie Ubuntu Server 22.04 LTS na Hyper-V w Windows 11
![alt text](../lab1/zdj.png)

### GIT

Utworzenie własnego brancha oraz 2 kluczy SSH (ed25519 z hasłem oraz ECDSA bez hasła)
![alt text](../lab1/zdj1.png)

### Hook

Dodanie gitHooka

![alt text](../lab1/zdj2.png)
![alt text](../lab1/zdj3.png)

---

## LAB 2

### DOCKER

Uruchomienie obrazu hello-world
![alt text](../lab2/img1.png)

Uruchomienie busybox i ubuntu
![alt text](../lab2/img2.png)

Sprawdzenie ich rozmiarów oraz kodu wyjścia
![alt text](../lab2/img3.png)
![alt text](../lab2/img4.png)

Polaczenie sie do kontenera interaktywnie z obrazu busybox
![alt text](../lab2/img5.png)

Uruchomienie kontenera z obrazu ubuntu (PID1 info i zaktualizowanie)
![alt text](../lab2/img6.png)

Utworzenie Dockerfile oraz zbudowanie własnego obrazu
![alt text](../lab2/img7.png)

Sprawdzenie działających kontenerów i ich czyszczenie za pomocą instrukcji prune
![alt text](../lab2/img8.png)

---

## LAB 3

### KONTENERY

Wybór oprogramowania
![alt text](../lab3/img.png)

Uruchomienie bez Dockera i zależności
![alt text](../lab3/img2.png)
![alt text](../lab3/img3.png)

Zbudowanie obrazów w dockerze
![alt text](../lab3/img4.png)

Utworzenie pliku Dockerfile.build
![alt text](../lab3/img5.png)

Utworzenie pliku Dockerfile.test
![alt text](../lab3/img6.png)

Utworzenie pliku docker-compose.yml
![alt text](../lab3/img7.png)

Uruchomienie kontenera
![alt text](../lab3/img8.png)

---

## LAB 4

### Zachowywanie stanu między kontenerami

Utworzenie 2 woluminów 
![alt text](../lab4/img1.png)

Wykorzystanie tymczasowego kontenera pomocniczego
![alt text](../lab4/img2.png)

Uruchomienie procesu budowania aplikacji w kontenerze bazowym z systemem Node.js
![alt text](../lab4/img3.png)

Zastosowanie alternatywnego podejścia: instalacja narzędzia Git "w locie" wewnątrz kontenera bazowego, a następnie pobranie repozytorium i budowanie projektu w ramach jednego procesu.
![alt text](../lab4/img4.png)

Weryfikacja pomyślnego zakończenia procesu budowania aplikacji.
![alt text](../lab4/img5.png)

Weryfikacja zawartości woluminu wyjściowego.
![alt text](../lab4/img6.png)

Testowanie komunikacji w domyślnej sieci Dockera.
![alt text](../lab4/img7.png)

Testowanie komunikacji we własnej sieci mostkowej (Custom Bridge)
![alt text](../lab4/img8.png)

Eksponowanie portów na zewnątrz.
![alt text](../lab4/img9.png)

Konfiguracja usługi SSH w kontenerze.
![alt text](../lab4/img10.png)

Zalogowanie sie do kontenera z usługą SSH.
![alt text](../lab4/img11.png)

Przygotowanie i uruchomienie infrastruktury Jenkinsa za pomocą narzędzia Docker Compose.
![alt text](../lab4/img12.png)

Weryfikacja działających usług.
![alt text](../lab4/img13.png)

Odczytanie logów startowych kontenera Jenkinsa
![alt text](../lab4/img14.png)

Weryfikacja ekranu powitalnego i kreatora konfiguracji początkowej Jenkinsa w przeglądarce internetowej.
![alt text](../lab4/img15.png)
