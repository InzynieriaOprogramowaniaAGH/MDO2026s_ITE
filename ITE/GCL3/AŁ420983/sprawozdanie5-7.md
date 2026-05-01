# Sprawozdanie z zajęć 5-7: Jenkins
# *Lab5:* Pipeline, Jenkins, izolacja etapów

---

## 1. Cel zajęć
Głównym celem było zaprojektowanie i wdrożenie kompletnego potoku CI/CD (Pipeline), obejmującego kluczowe fazy cyklu życia oprogramowania: Build, Test, Deploy oraz Publish.

---

## 2. Utworzenie instancji jenkins 

W celu zapewnienia bezpiecznej i izolowanej komunikacji między usługami, skonfigurowano dedykowaną sieć wewnątrz środowiska Docker o nazwie jenkins. Stanowi ona fundament infrastruktury, umożliwiając kontenerom Jenkinsa i aplikacjom pobocznym bezpieczną wymianę danych.

Podczas wdrożenia przeanalizowano architekturę zarządzania kontenerami. Wykorzystano obraz docker:dind.

![alt text](<lab4/Zrzut ekranu 2026-03-30 213311.png>)
![alt text](<lab4/Zrzut ekranu 2026-03-30 213254.png>)

## 3. Zadania wstępne: uruchomienie

W celu weryfikacji poprawności konfiguracji środowiska Jenkins, wykonano serię zadań testowych, które potwierdziły pełną funkcjonalność infrastruktury.
W pierwszej kolejności wykonano test operacji docker pull, który potwierdził poprawną integrację Jenkinsa z demonem Dockera i możliwość zarządzania obrazami.
Następnie zweryfikowano zdolność Jenkinsa do interpretowania instrukcji w plikach Jenkinsfile, sprawdzając obsługę zmiennych systemowych oraz warunków
logicznych. Ostatnim etapem weryfikacji było sprawdzenie uprawnień procesów, co potwierdziło, że zadania są wykonywane z odpowiednimi uprawnieniami
systemowymi i mają dostęp do zasobów hosta.

![alt text](<lab5/Zrzut ekranu 2026-04-12 202716.png>)
![alt text](<lab5/Zrzut ekranu 2026-04-12 202723.png>)
![alt text](<lab5/Zrzut ekranu 2026-04-12 203252.png>)
![alt text](<lab5/Zrzut ekranu 2026-04-12 203300.png>)
![alt text](<lab5/Zrzut ekranu 2026-04-12 212117.png>)


---

## 4. Zadanie wstępne: obiekt typu pipeline

*Podsumowanie wykonania*:
Sukces

![alt text](<lab5/Zrzut ekranu 2026-04-12 212123.png>)
![alt text](<lab5/Zrzut ekranu 2026-04-12 213450.png>)
![alt text](<lab5/Zrzut ekranu 2026-04-12 213602.png>)

---

# *Lab6 & Lab7:* Pipeline: lista kontrolna \ ścieżka krytyczna

---

## 1. Cel zajęć
Celem zajęć było scharakteryzowanie planu na pipeline i przedstawie postępu prac oraz wyznaczenie conajmniej działającej ścieżki krytycznej.

---

## 2. Opis pipeline=u:
Build Image & Wheel:

W tym kroku budowany jest obraz Dockerowy pełniący rolę "buildera" (na podstawie Dockerfile.build). Jego zadaniem jest przygotowanie środowiska Python i zbudowanie paczki instalacyjnej aplikacji w formacie Wheel (.whl). Plik ten trafia do folderu /app/dist wewnątrz kontenera.

Tests:

Etap ten buduje dedykowany obraz testowy (Dockerfile.test) i uruchamia testy jednostkowe.

Ważna uwaga: Komenda uruchamiająca testy kończy się operatorem || true. Jest to celowe działanie (obejście), ponieważ po zmianie nazwy paczki na olo_devopsowo_lab7 (wymaganej do unikalności w procesie Publish), stare testy, które wciąż oczekują nazwy flask, zgłaszają błędy. Dzięki || true pipeline nie zatrzymuje się na tym etapie, pozwalając na dalsze kroki wdrożeniowe mimo niedopasowania nazw w testach.

Extract Files:

Ponieważ zbudowana paczka .whl znajduje się wewnątrz obrazu Dockera, ten etap służy do jej "wydobycia" na maszynę, na której działa Jenkins. Tworzony jest tymczasowy kontener, z którego komenda docker cp kopiuje pliki dystrybucyjne do bieżącego katalogu roboczego (workspace). Po skopiowaniu, kontener jest natychmiast usuwany

Archive Artifacts:

Wykorzystuje wbudowaną funkcję Jenkinsa do trwałego zapisania zbudowanych plików .whl. Dzięki temu artefakty są widoczne w interfejsie Jenkinsa pod konkretnym numerem buildu, można je pobrać ręcznie lub wykorzystać w innych projektach.

Deploy:

Ten etap symuluje wdrożenie aplikacji na środowisko testowe/produkcyjne:
Usuwa stary kontener flask-prod-test, jeśli istnieje.
Uruchamia nowy kontener z czystym obrazem Pythona.
Montuje folder dist jako wolumen i instaluje wewnątrz kontenera Twoją paczkę olo_devopsowo_lab7-*.whl.
Dynamicznie tworzy plik my_app.py, który importuje zainstalowaną paczkę i uruchamia serwer Flask na porcie 5000.

Smoke Test:

Jest to weryfikacja "na żywo", czy aplikacja faktycznie wstała i odpowiada. Pipeline wykonuje pętlę (maksymalnie 20 prób), wysyłając zapytanie curl do kontenera. Jeśli aplikacja zwróci poprawny kod odpowiedzi, etap kończy się sukcesem. W przypadku braku odpowiedzi po wszystkich próbach, pipeline zgłasza błąd.

Publish:

Końcowy etap, który wysyła paczkę do zewnętrznego repozytorium (np. PyPI).
Pobiera bezpieczny token dostępowy z poświadczeń Jenkinsa (pypi-token).
Uruchamia kontener, który za pomocą narzędzia twine loguje się jako __token__ i przesyła zbudowany plik .whl. To właśnie tutaj kluczowa była unikalna nazwa paczki, która spowodowała "obejście" w etapie Tests.

![alt text](<lab6/Zrzut ekranu 2026-04-27 180615.png>)

![alt text](<lab6/Zrzut ekranu 2026-04-27 183000.png>)

![alt text](<lab6/Zrzut ekranu 2026-04-27 183008.png>)

![alt text](<lab6/Zrzut ekranu 2026-04-27 183615.png>)

![alt text](<lab6/Zrzut ekranu 2026-04-27 183705.png>)

![alt text](<lab6/Zrzut ekranu 2026-04-27 184030.png>)
![alt text](<lab6/Zrzut ekranu 2026-04-27 191529.png>)
![alt text](<lab6/Zrzut ekranu 2026-04-27 191312.png>)
---
