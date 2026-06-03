# Sprawozdanie 3 #

# Lab 8 #
Celem laboratorium było zapoznanie się z narzędziem Ansible służącym do automatyzacji administracji systemami oraz zdalnego wykonywania poleceń na wielu maszynach jednocześnie.
Wykonane kroki:
## 8.1. Przygotowanie środowiska
W pierwszym etapie przygotowano drugą maszynę wirtualną z systemem `linux` przeznaczoną do zarządzania przez Ansible.

### Konfiguracja nazwy hosta ###
Maszynie docelowej przypisano nazwę `ansible-target`, zgodnie z wymaganiami instrukcji.

![hostname](SS-2.png)

### Konfiguracja usługi SSH ###
Widoczny status `active (running)` potwierdza poprawne działanie serwera OpenSSH.

![konfiguracja](SS-1.png)

## 8.2. Instalacja Ansible
Na głównej maszynie wirtualnej zainstalowano pakiet Ansible z repozytorium systemowego Ubuntu.

![Ansible install](SS-3.png)

Po zakończeniu instalacji została sprawdzona poprawność wykonania polecenia:

![Ansible version](SS-4.png)

Wyświetlona wersja `ansible-core 2.16.3` potwierdza poprawną instalację narzędzia.

## 8.3. Konfiguracja komunikacji pomiędzy maszynami
Aby umożliwić komunikację przy użyciu nazw hostów, skonfigurowano plik `/etc/hosts`. Dodane do niego zostało IP oraz nazwa hosta na utworzonej maszyny ansible.

![plik /etc/hosts](SS-5.png)

Następnie zweryfikowano poprawność działania rozwiązywania nazw DNS poprzez wykonanie polecenia ping z nazwa hosta.

![ping host](SS-6.png)

Otrzymane odpowiedzi ICMP potwierdzają poprawną komunikację pomiędzy maszynami.

## 8.4. Konfiguracja uwierzytelniania SSH

W celu wyeliminowania konieczności podawania hasła podczas logowania wykonano wymianę kluczy SSH pomiędzy maszynami przy użyciu polecenia `ssh-copy-id`.

![ssh-copy-id](SS-7.png)

Następnie sprawdzono tego efekt, czyli możliwość logowania bez użycia hasła.

![SSH](SS-8.png)

Udało się nawiązać połączenie poprawnie, co potwierdza prawidłową konfigurację kluczy SSH.

## 8.5. Utworzenie pliku inwentaryzacji
Kolejnym krokiem było utworzenie pliku `inventory.ini`, zawierającego definicje grup zarządzanych hostów.

![inventory.ini](SS-9.png)

W pliku utworzono grupy:

`Orchestrators` – maszyna zarządzająca,
`Endpoints` – maszyna docelowa ansible-target.

## 8.6. Weryfikacja połączenia za pomocą modułu ping

Wykonano polecenie `ansible all -i inventory.ini -m ping`, aby sprawdzić działanie.

![ansible ping](SS-10.png)

Obie maszyny zwróciły odpowiedź `pong`, co potwierdza poprawną komunikację z wykorzystaniem Ansible.

## 8.7. Utworzenie pierwszego playbooka

Przygotowano prosty playbook o nazwie `ping.yml`, którego zadaniem było wykonanie testu połączenia dla wszystkich hostów.

### Kod playbooka: ###

![ping.yml](SS-11.png)

Treść playbooka wykorzystuje moduł `ansible.builtin.ping`, który służy do sprawdzenia dostępności hosta oraz poprawności komunikacji pomiędzy kontrolerem Ansible a maszyną zdalną. Moduł nie wysyła pakietów ICMP jak systemowe polecenie ping, lecz testuje możliwość wykonania modułów Ansible na zdalnym hoście i w przypadku sukcesu zwraca odpowiedź pong.

## 8.8. Uruchomienie playbooka

Playbook został wykonany za pomocą polecenia `ansible-playbook -i inventory.ini ping.yml`.

![playbook wynik](SS-12.png)

Wszystkie zadania zakończyły się statusem ok, a raport końcowy nie wykazał błędów ani niedostępnych hostów, więc wszystko wykonało się jak należy.


