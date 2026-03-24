# Sprawozdanie z zajęć 1-4
# **Lab1:** Wprowadzenie, Git, Gałęzie, SSH

---

## 1. Cel zajęć
Celem zajęć było poprawne przygotowanie stanowiska pracy, konfiguracja bezpiecznego połączenia z systemem kontroli wersji GitHub poprzez protokół SSH oraz wdrożenie automatyzacji pracy z commitami za pomocą mechanizmu Git Hooks.

---

## 2. Realizacja zadań

### Konfiguracja połączenia i kluczy
* **Instalacja:** Przygotowano środowisko uniksowe z zainstalowanym klientem Git.
* **Klucze SSH:** Wygenerowano dwa klucze. Jeden z nich został zabezpieczony hasłem.
* **GitHub:** Dodano publiczny klucz SSH do profilu GitHub oraz skonfigurowano uwierzytelnianie dwuskładnikowe.
* **Klonowanie:** Repozytorium zostało sklonowane dwukrotnie: najpierw przy użyciu HTTPS i Personal Access Token, a następnie przy użyciu protokołu SSH.


## 3. Praca na gałęziach
Zgodnie z instrukcją wykonano następujące kroki:
1. Przełączono się na gałąź grupy z poziomu gałęzi `main`.
2. Utworzono nową gałąź o nazwie `AK423554`.
3. Wewnątrz katalogu grupowego utworzono folder roboczy o tej samej nazwie.



---

## 4. Implementacja Git Hooka
W celu wymuszenia standardu nazewnictwa commitów, przygotowano skrypt `commit-msg`. Skrypt sprawdza, czy wiadomość zaczyna się od wymaganych inicjałów i numeru indeksu.


**Treść skryptu**
```#!/bin/bash
commit_msg=$(cat "$1")
pattern="^AK423554"

if [[ ! $commit_msg =~ $pattern ]]; then
  echo "Blad: wiadomosc musi sie zaczynac od AK423554"
  exit 1
fi
```
<img width="958" height="271" alt="image" src="https://github.com/user-attachments/assets/e0057d3b-e342-4dc5-bb77-e1e4215ce681" />
<img width="1919" height="1023" alt="image" src="https://github.com/user-attachments/assets/0ecc6f1d-5791-436c-985f-ed8d10d08fb3" />

---

# **Lab2:** Git, Docker i konteneryzacja środowiska

---

## 1. Cel zajęć
Celem zajęć było zestawienie skonteneryzowanego środowiska pracy, zapoznanie się z architekturą Docker oraz automatyzacja budowania obrazów przy użyciu plików Dockerfile w celu zapewnienia spójności repozytorium GitHub.

---

## 2. Realizacja zadań

### Instalacja i konfiguracja środowiska Docker
* **Instalacja:** Zainstalowano środowisko Docker w systemie Linux, korzystając z oficjalnych repozytoriów dystrybucji (unikając pakietów Snap/Flatpak dla lepszej wydajności i integracji).
* **Docker Hub:** Utworzono konto w serwisie Docker Hub i zapoznano się z oficjalnymi obrazami (m.in. `hello-world`, `busybox`, `ubuntu`, `node`).
* **Analiza obrazów:** Zweryfikowano rozmiary obrazów, kody wyjścia procesów oraz statusy kontenerów po zakończeniu pracy.

---

## 3. Praca z kontenerami


### Zapoznanie z obrazami
<img width="1475" height="606" alt="image" src="https://github.com/user-attachments/assets/3cfe3040-82e7-4450-b0a8-183eb5a840d9" />


### Kontener Busybox i interakcja
1. Uruchomiono kontener z obrazu `busybox`.
2. Nawiązano połączenie w trybie interaktywnym (`-it`), weryfikując wersję systemu wewnątrz kontenera.
<img width="555" height="111" alt="image" src="https://github.com/user-attachments/assets/9f6174a0-6f67-4c33-8a63-a2405b7e53ae" />


### Zarządzanie procesami (System w kontenerze)
1. Uruchomiono system (Ubuntu) wewnątrz kontenera.
2. Zweryfikowano **PID 1** wewnątrz kontenera oraz porównano listę procesów widoczną na hoście.
3. Przeprowadzono aktualizację pakietów systemowych wewnątrz działającej instancji.
<img width="1028" height="870" alt="image" src="https://github.com/user-attachments/assets/986d09f7-a72e-45d2-b933-35cc81b0d3fd" />


---

## 4. Własny obraz: Dockerfile
Stworzono własny plik `Dockerfile`, który automatyzuje przygotowanie środowiska z dostępem do Git.
Treść pliku:
```
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["/bin/bash"]
```

<img width="1454" height="915" alt="image" src="https://github.com/user-attachments/assets/485f6cca-2b36-4d34-94cc-664237b040f8" />

---

## 5. Sprzątanie
<img width="1481" height="314" alt="image" src="https://github.com/user-attachments/assets/c737cbff-30a8-445e-a66b-0b86ef163ec0" />
<img width="1462" height="511" alt="image" src="https://github.com/user-attachments/assets/09479e3d-b94a-4da5-8fd7-e50f12dd66a9" />

---

# **Lab3:** Dockerfiles – kontener jako definicja etapu

---

## 1. Cel zajęć
Celem zajęć było stworzenie powtarzalnego, przenośnego środowiska budowania oraz testowania oprogramowania przy użyciu kontenerów Docker. Skoncentrowano się na izolacji procesów CI od systemu operacyjnego hosta.

---

## 2. Wybór oprogramowania
Do realizacji zadań wybrano następujące oprogramowanie:
* **Nazwa projektu:** `fastify`
* **System budowania:** `npm`

---

## 3. Budowanie i testowanie (Local vs Container)

### Próba lokalna

<img width="1099" height="172" alt="image" src="https://github.com/user-attachments/assets/2aeae09b-b4ed-46bc-b4d5-d9dd0fb03780" />

<img width="945" height="691" alt="image" src="https://github.com/user-attachments/assets/36a23ab0-26c4-43bb-b770-b2d12c73de0e" />

Podczas testów w kontenerze node:20 pojawiły się błędy w 7 przypadkach (np. ECONNREFUSED, timeout). Z logów wynika, że są one spowodowane ograniczeniami środowiska kontenerowego (sieć, zasoby), a nie błędami w konfiguracji aplikacji. Potwierdza to, że kontener działa w izolacji od systemu hosta.

### Izolacja w kontenerze
<img width="1462" height="700" alt="image" src="https://github.com/user-attachments/assets/472201c8-682c-47c8-ac38-f902e3f42f8e" />
<img width="1091" height="605" alt="image" src="https://github.com/user-attachments/assets/193799f5-0615-4225-b89e-7e547b0c3cd8" />
<img width="1001" height="644" alt="image" src="https://github.com/user-attachments/assets/cf46cfcd-9655-45ee-9491-a9a58e24a694" />
, gdzie Dockerfile.build

```
FROM node:20

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --depth 1 https://github.com/fastify/fastify.git .

RUN npm install
```

Dockerfile.test

```
FROM fastify-builder:latest

CMD ["npm", "test"]
```

# **Lab4:** Dodatkowa terminologia w konteneryzacji, komunikacja i instancja Jenkins

---

## 1. Cel zajęć
Celem zajęć było zgłębienie zaawansowanych mechanizmów składowania danych, konfiguracja sieci między kontenerami oraz uruchomienie skonteneryzowanej instancji serwera CI Jenkins.

---

## 2. Zachowywanie stanu i praca na wolumenach

### Bez gita

<img width="1438" height="779" alt="image" src="https://github.com/user-attachments/assets/3731440e-916b-4c92-81d4-25b63a6d686c" />

<img width="840" height="851" alt="image" src="https://github.com/user-attachments/assets/4324b063-2ca3-4661-a6e4-f203f3be831b" />

<img width="1482" height="828" alt="image" src="https://github.com/user-attachments/assets/dd70e19c-82bf-4888-9491-5dcc8ba0e059" />

### Z gitem

<img width="925" height="852" alt="image" src="https://github.com/user-attachments/assets/52eb7cbd-6d08-4b75-bc11-cb9ef4ba3936" />

<img width="1462" height="915" alt="image" src="https://github.com/user-attachments/assets/4167d3e6-8867-4465-b26c-cd764a621066" />

Ręczne zarządzanie woluminami pozwala na pełną kontrolę nad cyklem życia danych, ale jest procesem powolnym i podatnym na błędy ludzkie. Wykorzystanie Dockerfile z instrukcją `RUN --mount` automatyzuje ten proces, oferując przyspieszenie dzięki mechanizmowi cache oraz mniejszy rozmiar obrazu wynikowego dzięki montowaniu typu bind.

---

## 3. Łączność i sieć 

### Badanie ruchu po ip

<img width="1164" height="913" alt="image" src="https://github.com/user-attachments/assets/bbe1a4c7-55c4-4bb2-b641-bb8059415c43" />

<img width="613" height="540" alt="image" src="https://github.com/user-attachments/assets/c8ae482a-edea-45ae-82c4-879e1c3ce0db" />

<img width="1249" height="888" alt="image" src="https://github.com/user-attachments/assets/077606a2-075d-4f9d-952c-37db0595497c" />

### Badanie ruchu z użyciem nazw

<img width="751" height="611" alt="image" src="https://github.com/user-attachments/assets/47650bdc-480c-48d9-abc7-cc3732cd18b3" />

### Połączenie spoza kontenera

<img width="1301" height="792" alt="image" src="https://github.com/user-attachments/assets/5b8a06cc-ce4f-4026-97d2-f10807965160" />

<img width="998" height="333" alt="image" src="https://github.com/user-attachments/assets/4c72f9ef-4544-4736-afca-34ea6636a972" />

Wygenerowany log logi_przepustowosci.txt przedstawia proces instalacji narzędzia iperf3 wewnątrz kontenera oraz pomyślne uruchomienie go w trybie serwera na porcie 5201. Pomiary wykazują bardzo wysoką przepustowość na poziomie około 23.3 Gbits/sec, co potwierdza, że komunikacja między hostem (172.17.0.1) a kontenerem (172.17.0.2) odbywa się bez ograniczeń fizycznego łącza sieciowego. Na końcu logu widoczny jest błąd Bad file descriptor, który wynika z gwałtownego przerwania sesji przez klienta, jednak nie wpływa on na wiarygodność zebranych wcześniej danych o transferze.

### Usługi w rozumieniu systemu, kontenera i klastra

<img width="1011" height="198" alt="image" src="https://github.com/user-attachments/assets/fea9264e-530a-4a0f-b797-502e03bc2c4a" />

<img width="1051" height="761" alt="image" src="https://github.com/user-attachments/assets/7e103b0c-7875-463b-837c-adb500fd15c6" />

Zaletą SSH jest możliwość korzystania ze standardowych narzędzi do zarządzania plikami oraz łatwiejsze debugowanie w środowiskach typu legacy. Główną wadą jest łamanie zasady jeden proces na kontener, co niepotrzebnie zwiększa zużycie zasobów i rozszerza pole ataku na bezpieczeństwo systemu.

### Przygotowanie do uruchomienia serwera Jenkins

<img width="1050" height="531" alt="image" src="https://github.com/user-attachments/assets/8364eeeb-b9ad-4000-96a7-39e8d4d49c63" />

<img width="1460" height="979" alt="image" src="https://github.com/user-attachments/assets/480cae49-7b23-4203-9e13-bbb8c67e8904" />








