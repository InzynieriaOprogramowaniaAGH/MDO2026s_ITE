# Ansible
1. Konfiguracja bezhasłowego logowania SSH
Skonfigurowano dostęp SSH z maszyny głównej na docelową z użyciem kluczy publicznych.

![alt text](<Zrzut ekranu 2026-05-28 223554.png>)

2. Inwentaryzacja i konfiguracja lokalnego DNS
Utworzono plik inventory.ini oraz przypisano nazwy maszyn do ich adresów IP w /etc/hosts.

![alt text](image.png)

![alt text](image-1.png)

3. Uruchomienie playbooka i weryfikacja idempotencji
Utworzono i uruchomiono playbook aktualizujący system oraz instalujący pakiety. Wykazano zjawisko idempotencji (brak powtarzania niepotrzebnych akcji).

![alt text](image-2.png)

![alt text](<Zrzut ekranu 2026-05-28 224543.png>)

![alt text](<Zrzut ekranu 2026-05-28 224638.png>)

4. Symulacja awarii sieci (Sanity check)
Odłączono wirtualną kartę sieciową w Hyper-V maszyny docelowej i przetestowano zachowanie Ansible.

![alt text](<Zrzut ekranu 2026-05-28 224955.png>)

![alt text](<Zrzut ekranu 2026-05-28 225141.png>)

5. Automatyzacja wdrożenia (Deployment do Dockera)
Napisano playbook instalujący Dockera, przesyłający plik artefaktu (.tar.gz) i uruchamiający go wewnątrz kontenera. Po weryfikacji środowisko zostało automatycznie oczyszczone.

![alt text](image-3.png)

![alt text](image-4.png)

6. Generowanie struktury roli (Ansible Galaxy)
Stworzony kod wdrożeniowy przeniesiono do ustandaryzowanej struktury roli Ansible, wygenerowanej poleceniem ansible-galaxy.

![alt text](image-6.png)

![alt text](image-5.png)


# Kickstart
1. Przygotowanie pliku odpowiedzi (Kickstart) i serwera HTTP
Utworzono plik ks.cfg z pełną konfiguracją dla Fedory 44 (partycje, nazwa hosta fedora-autodeploy, użytkownik student, repozytoria). Następnie uruchomiono serwer WWW w Pythonie, aby udostępnić ten plik maszynie instalacyjnej.

![alt text](image-7.png)

![alt text](<Zrzut ekranu 2026-05-29 002704.png>)

2. Mechanizm wdrożenia (CD) w sekcji %post
Aby ominąć brak Dockera podczas instalacji, w sekcji %post pliku Kickstart napisano własną usługę systemd (uruchom-fmt.service). Gwarantuje ona, że przy pierwszym uruchomieniu po instalacji system sam pobierze artefakt i wystartuje kontener.

![alt text](image-9.png)

3. Zautomatyzowana instalacja Fedory
Uruchomiono maszynę wirtualną, a w menu GRUB dopisano parametr inst.ks=... wskazujący na nasz plik odpowiedzi. Instalacja przebiegła od tego momentu w 100% bezdotykowo.

![alt text](image-8.png)

![alt text](<Zrzut ekranu 2026-05-29 004419.png>)

4. Weryfikacja działania środowiska po restarcie
Po samoczynnym restarcie maszyny zalogowano się na konto student i sprawdzono, czy plik odpowiedzi oraz skrypt uruchomieniowy zadziałały poprawnie.

![alt text](<Zrzut ekranu 2026-05-29 005243.png>)

# Kubernetes
1. Instalacja klastra Kubernetes (Minikube)
Uruchomiono klaster Minikube z wykorzystaniem demona Docker. Zapewniono odpowiednie zasoby sprzętowe (CPU/RAM) i zweryfikowano działanie narzędzia kubectl oraz samego węzła.

![alt text](image-10.png)

2. Uruchomienie Dashboardu i weryfikacja łączności
Wyeksponowano panel graficzny Kubernetes za pomocą polecenia kubectl proxy (z wyłączeniem filtrów), co pozwoliło na połączenie się z panelem bezpośrednio z przeglądarki na maszynie hosta (Windows).

![alt text](image-11.png)

3. Ręczne uruchamianie Poda i przekierowanie portów (Port-Forwarding)
Ze względu na brak interfejsu sieciowego w budowanej wcześniej aplikacji kompilowanej, przygotowano własne obrazy oparte na Nginx. Uruchomiono z nich pojedynczego Poda i wyeksponowano jego ruch komendą kubectl port-forward.

![alt text](image-12.png)

![alt text](image-13.png)

4. Skalowanie z użyciem pliku Deployment YAML
Przekuto ręczne wdrożenie na deklaratywny plik konfiguracyjny (Deployment). Przetestowano płynne zarządzanie klastrem poprzez komendy skalowania replik.

![alt text](image-14.png)

5. Wersjonowanie (Rollout), symulacja awarii i wycofanie zmian (Undo)
Wykorzystano kubectl set image do aktualizacji aplikacji (V2), a następnie zasymulowano błąd celowo wdrażając wadliwy obraz. Awarię zdiagnozowano i pomyślnie cofnięto za pomocą poleceń rollout history oraz rollout undo. Zbudowano też skrypt weryfikujący (monitor.sh).

![alt text](image-15.png)

![alt text](image-16.png)

![alt text](image-17.png)

![alt text](image-18.png)

![alt text](image-19.png)

6. Przygotowanie strategii wdrożeń (Pliki konfiguracyjne)
Zrozumiano i zdefiniowano różnice w strategiach (Recreate - wiążący się z przerwą w działaniu; RollingUpdate - płynny; Canary - ułamek ruchu na testową wersję). Utworzono dla nich dedykowane pliki YAML.

![alt text](image-20.png)

![alt text](image-21.png)

![alt text](image-22.png)

![alt text](image-23.png)

# Kubernetes 2

1. Wdrożenie masowe (36 replik)
Utworzono plik deploy11.yaml z definicją wdrożenia (Deployment) web-serwera, w którym zadeklarowano masowe uruchomienie 36 replik aplikacji.

![alt text](<Zrzut ekranu 2026-06-10 231048.png>)

![alt text](<Zrzut ekranu 2026-06-10 231142.png>)

2. Eksponowanie ruchu sieciowego na kilka sposobów
Udostępniono dostęp do serwera za pomocą czterech metod: przekierowania bezpośrednio do Poda, przekierowania do Deploymentu, wygenerowania Serwisu z palca (kubectl expose) oraz utworzenia Serwisu z pliku konfiguracyjnego service11.yaml.

![alt text](image-24.png)

![alt text](<Zrzut ekranu 2026-06-10 231233.png>)

3. Skalowanie metodą imperatywną i deklaratywną
Przetestowano i udowodniono działanie dwóch metod skalowania. Najpierw użyto bezpośredniej komendy kubectl scale aby zredukować liczbę replik do 10. Następnie wyedytowano plik YAML (na 15 replik) i zaaplikowano nowy stan komendą kubectl apply -f.

![alt text](<Zrzut ekranu 2026-06-10 232527.png>)

![alt text](<Zrzut ekranu 2026-06-10 232553.png>)