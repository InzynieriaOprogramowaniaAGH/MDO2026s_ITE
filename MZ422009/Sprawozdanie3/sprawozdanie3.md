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
Kolejnym krokiem było utworzenie pliku [inventory.ini](inventory.ini), zawierającego definicje grup zarządzanych hostów.

![inventory.ini](SS-9.png)

W pliku utworzono grupy:

`Orchestrators` – maszyna zarządzająca,
`Endpoints` – maszyna docelowa ansible-target.

## 8.6. Weryfikacja połączenia za pomocą modułu ping

Wykonano polecenie `ansible all -i inventory.ini -m ping`, aby sprawdzić działanie.

![ansible ping](SS-10.png)

Obie maszyny zwróciły odpowiedź `pong`, co potwierdza poprawną komunikację z wykorzystaniem Ansible.

## 8.7. Utworzenie pierwszego playbooka

Przygotowano prosty playbook o nazwie [ping.yml](ping.yml), którego zadaniem było wykonanie testu połączenia dla wszystkich hostów.

### Kod playbooka: ###

![ping.yml](SS-11.png)

Treść playbooka wykorzystuje moduł `ansible.builtin.ping`, który służy do sprawdzenia dostępności hosta oraz poprawności komunikacji pomiędzy kontrolerem Ansible a maszyną zdalną. Moduł nie wysyła pakietów ICMP jak systemowe polecenie ping, lecz testuje możliwość wykonania modułów Ansible na zdalnym hoście i w przypadku sukcesu zwraca odpowiedź pong.

## 8.8. Uruchomienie playbooka

Playbook został uruchomiony za pomocą polecenia `ansible-playbook -i inventory.ini ping.yml`.

![playbook wynik](SS-12.png)

Wszystkie zadania zakończyły się statusem ok, a raport końcowy nie wykazał błędów ani niedostępnych hostów, więc wszystko wykonało się jak należy.


## 8.9. Kopiowanie pliku inwentaryzacji na maszynę docelową
Przygotowano playbook o nazwie [copy_inventory.yml](copy_inventory.yml), którego zadaniem było skopiowanie pliku `inventory.ini` na maszynę z grupy `Endpoints`.

![playbook copy](SS-59.png)

Do wykonania zadania użyto modułu `ansible.builtin.copy`, który umożliwia kopiowanie plików z maszyny zarządzającej na hosty zdalne. Wynik changed=1 oznacza, że plik został utworzony lub zmodyfikowany na maszynie docelowej.

Następnie ten sam playbook został uruchomiony ponownie, bez zmiany pliku źródłowego, jednak wynik był już inny. `changed=0` oznacza, że Ansible wykrył zgodność stanu docelowego z oczekiwanym i nie wykonał niepotrzebnej zmiany. Pokazuje to stabilne działanie playbooków.

![playbook copy again](SS-60.png)

## 8.10. Aktualizacja pakietów systemowych
W tym podpunkcie przygotowano playbook [update_system.yml](update_system.yml), który aktualizuje listę pakietów oraz wykonuje aktualizację zainstalowanego oprogramowania na maszynie docelowej. 

![playbook update](SS-61.png)

Tym razem do wykonania operacji użyto modułu `ansible.builtin.apt`, przeznaczonego do zarządzania pakietami w systemach Ubuntu. Playbook został wykonany z uprawnieniami administratora przez `become: yes`.

## 8.11. Restart usług sshd i rngd
Podobnie jak we wcześniejszych przypadkach utworzono nowy playbook [restart_ssh.yml](restart_ssh.yml), którego zadaniem jest wykonanie restartu usługi SSH na maszynie docelowej. Wykorzystano kolejny moduł, tym razem `ansible.builtin.service`. 

![playbook restart](SS-62.png)

Adekwatnie wykonano polecenie dla usługi rngd. Playbook [restart_rngd.yml](restart_rngd.yml). 

![playbook restart rngd](SS-63.png)

Po tym etapie zostało sprawdzone jeszcze działanie przy niedostępnym hoście. Aby to przetestować wstrzymano usługę SSH na maszynie `ansible-target`, a nastepnie wykonano test połączenia Ansible, który oznaczył maszynę docelową jako `UNREACHABLE`, co potwierdza brak możliwości połączenia.

## 8.12. Instalacja Dockera na maszynie docelowej
Znowu przygotowano playbook, tym razem taki który instaluje pakiety `docker.io` oraz `python3-docker` na maszynie docelowej, a następnie uruchomiono go. Playbook [install_docker.yml](install_docker.yml).

![playbook docker install](SS-64.png)

Poprawność wykonania zweryfikowałem wykonując na maszynie docelowej polecenia, `docker --version` i `systemctl status docker`.

## 8.13. Pobranie obrazu z Docker Hub
Za pomocą playbooka [pull_image.yml](pull_image.yml) pobrano obraz aplikacji opublikowany wcześniej w Docker Hub. 
Do pobrania obrazu wykorzystano moduł `community.docker.docker_image`, który pozwala zarządzać obrazami Docker z poziomu Ansible.

![playbook pullimage](SS-65.png)

## 8.14. Uruchomienie kontenera na maszynie docelowej
Następnie przygotowano playbook [run_container.yml](run_container.yml), który uruchamia kontener z obrazem `zucho/express-deploy:latest`.

![playbook run](SS-66.png)

Po wykonaniu playbooka sprawdzono listę działających kontenerów na maszynie docelowej poleceniem `docker ps`.

![docker ps](SS-67.png)


## 8.15. Zatrzymanie i usunięcie kontenera
Przygotowano playbook [remove_container.yml](remove_container.yml), którego miał zatrzymać oraz usunąć kontener `express-app`.

![playbook remove](SS-68.png)

Po wykonaniu tego na maszynie docelowej kontener nie był już widoczny jak wcześniej.

![docker ps -a](SS-69.png)


## 8.16. Sanity check maszyny docelowej
Na końcu przygotowano prosty playbook [sanity_check.yml](sanity_check.yml), którego zadaniem było sprawdzenie podstawowego stanu maszyny docelowej przed lub po wdrożeniu.
Playbook sprawdza dostępność usługi SSH, działanie Dockera oraz wyświetla jego wersję. Pozwala to szybko potwierdzić, że środowisko docelowe jest gotowe do dalszych operacji.

![playbook sanity](SS-70.png)


## 8.17. Utworzenie roli Ansible
Na koniec tych laboratorium, aby uporządkować playbooki utworzyłem szkielet roli Ansible za pomocą polecenia `ansible-galaxy role init`. Polecenie utworzyło strukturę katalogów roli docker_deploy, zawierającą między innymi katalogi `tasks`, `handlers`, `defaults`, `vars` oraz plik `meta/main.yml`. Taka struktura umożliwia późniejsze przeniesienie zadań z playbooków do roli i wielokrotne wykorzystanie ich w innych projektach.

![tree](SS-71.png)

