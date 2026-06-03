# Sprawozdanie Laboratorium 8: Automatyzacja i wdrożenie aplikacji za pomocą Ansible

**Autor:** Piotr Drożyński

---

## 1. Wstęp: Czym jest Ansible i co chcemy osiągnąć?

W nowoczesnym wytwarzaniu oprogramowania nie konfiguruje się serwerów ręcznie. Zamiast tego używa się narzędzi typu **Infrastructure as Code** (Infrastruktura jako Kod). Jednym z nich jest **Ansible**.

**Cel:** 
Mamy dwie maszyny. Pierwsza to „Dyrygent” (**Orchestrator**), a druga to „Wykonawca” (**Target**). Chcemy, aby Dyrygent automatycznie wysłał na drugą maszynę naszą aplikację, zainstalował potrzebne programy i sprawdził, czy wszystko działa – bez naszej ręcznej ingerencji na maszynie docelowej.

---

## 2. Przygotowanie maszyn (Adresowanie i Nazewnictwo)

Zaczynamy od tego, aby maszyny mogły się „rozpoznać”. Zamiast operować na adresach IP (np. 192.168.1.2), nadajemy maszynom czytelne nazwy.

![Konfiguracja hostname na głównej maszynie](lab8/screenshots/glowna_maszyna_hostnamectl.png)
*Nadanie nazwy "ansible-orchestrator" głównej maszynie.*

![Konfiguracja hostname na nowej maszynie](lab8/screenshots/nowa_maszyna_hostnamectl.png)
*Przygotowanie maszyny docelowej "ansible-target".*

Aby nazwy działały w sieci lokalnej, edytujemy plik `/etc/hosts`.

![Wpis w etc/hosts](lab8/screenshots/etc_hosts_ansible_target.png)
*Powiązanie adresu IP z nazwą maszyny docelowej.*

---

## 3. Bezpieczne połączenie bez haseł (SSH)

Ansible steruje innymi komputerami przez protokół SSH. Aby proces był w pełni automatyczny, maszyny muszą sobie ufać na tyle, by nie prosić nas o hasło przy każdym poleceniu.
Generujemy „cyfrowy klucz”. Klucz publiczny wysyłamy na maszynę docelową. Od teraz Dyrygent może wejść na serwer Wykonawcy tak, jakby miał własne klucze do drzwi.

![Istniejące klucze SSH](lab8/screenshots/istniejace_klucze.png)
*Sprawdzenie, czy na naszej maszynie są już wygenerowane klucze bezpieczeństwa.*

![Kopiowanie klucza SSH](lab8/screenshots/kopiowanie_klucza.png)
*Przekazanie klucza publicznego na maszynę docelową.*

![Logowanie bezhasłowe](lab8/screenshots/potwierdzenie_bezhaslowego_logowania.png)
*Test: Logujemy się na drugą maszynę i system nie pyta nas o hasło. Sukces.*

---

## 4. Inwentaryzacja

Musimy stworzyć listę maszyn, którymi Ansible ma zarządzać. Robi się to w pliku `hosts.ini`.

![Plik hosts.ini](lab8/screenshots/hosts_ini.png)
*Podział maszyn na grupy: Orchestrators (sterujące) i Endpoints (docelowe).*

Weryfikujemy, czy Ansible „widzi” te maszyny poleceniem `ping`.

![Test ping-pong](lab8/screenshots/ansible_all_hosts_ping_pong.png)
*Jeśli widzimy "pong" na zielono, oznacza to, że komunikacja działa wzorowo.*

---

## 5. Automatyzacja – Zadania systemowe

Zanim wgramy naszą aplikację, musimy przygotować serwer. Służy do tego playbook `system_setup.yml`.

**Co robi ten skrypt?**
- Aktualizuje system.
- Kopiuje pliki konfiguracyjne.
- Restartuje usługi bezpieczeństwa (SSH).

![Kod system_setup.yml](lab8/screenshots/system_setup.yml.png)
*Playbook z listą zadań administracyjnych.*

---

## 6. Rola i Wdrożenie Artefaktu

Zgodnie z profesjonalnymi standardami, instrukcje wdrożenia zamknęliśmy w tzw. **Roli**. Pozwala to na łatwe powtarzanie tego samego procesu na wielu serwerach naraz.

![Inicjalizacja roli](lab8/screenshots/inicjalizacja_roli.png)
*Tworzenie folderów dla roli "hiredis_deploy".*

Aby wszystko działo się automatycznie, musieliśmy rozwiązać problem uprawnień. Niektóre zadania wymagają „konta administratora” (Root). Skonfigurowaliśmy serwer tak, by ufał komendom Ansible bez pytania o hasło administratora.

![Rozwiązanie problemu sudo](lab8/screenshots/rozwiazanie_problemu_sudo.png)
*Konfiguracja uprawnień NOPASSWD*

### Co dzieje się podczas wdrożenia?

Poniższy kod to mózg całej operacji. Ansible wykonuje te kroki po kolei:
1. Instaluje Dockera (izolowane środowisko dla aplikacji).
2. Przesyła bibliotekę `hiredis` (nasz artefakt z Lab 7).
3. Kompiluje program testowy.
4. Uruchamia bazę danych Redis.
5. Sprawdza, czy aplikacja potrafi „rozmawiać” z bazą.

```yaml
---
- name: 1. Kopiowanie inwentarza na węzeł docelowy
  copy:
    src: hosts.ini
    dest: /home/ansible/hosts_backup.ini

- name: 2. Aktualizacja pakietów (Update i Upgrade)
  apt:
    update_cache: yes
    upgrade: safe

- name: 3. Restart usług SSH (z zapewnieniem bezpieczeństwa)
  service:
    name: ssh
    state: restarted
  ignore_errors: yes

- name: 4. Instalacja silnika Docker i kompilatora GCC
  apt:
    name: [docker.io, python3-docker, build-essential, libhiredis-dev]
    state: present

- name: 5. Start usługi Docker (silnik aplikacji)
  service:
    name: docker
    state: started
    enabled: yes

- name: 6. Stworzenie folderu na naszą aplikację
  file:
    path: /opt/hiredis_app
    state: directory
    mode: '0755'

- name: 7. Transfer biblioteki (.tar.gz) i kodu źródłowego (.c)
  copy:
    src: "{{ item }}"
    dest: "/opt/hiredis_app/"
  loop:
    - "hiredis-v1.0-b7-PD420765.tar.gz"
    - "sample.c"

- name: 8. Rozpakowanie przesłanej biblioteki
  unarchive:
    src: "/opt/hiredis_app/hiredis-v1.0-b7-PD420765.tar.gz"
    dest: "/opt/hiredis_app/"
    remote_src: yes

- name: 9. Kompilacja: zamiana kodu tekstowego na program binarny
  shell:
    cmd: "gcc sample.c -o hiredis_test -L. -lhiredis -I/usr/local/include/hiredis"
    chdir: /opt/hiredis_app

- name: 10. Naprawa linkowania bibliotek (Symlink)
  file:
    src: "/opt/hiredis_app/libhiredis.so"
    dest: "/opt/hiredis_app/libhiredis.so.1.3.0"
    state: link

- name: 11. Konfiguracja "lokalnego adresu" dla bazy Redis
  lineinfile:
    path: /etc/hosts
    line: "127.0.0.1 redis-server"
    state: present

- name: 12. Uruchomienie bazy danych Redis w Dockerze
  docker_container:
    name: redis-server-lab8
    image: redis:alpine
    state: started
    network_mode: host

- name: 13. TEST KOŃCOWY: Uruchomienie aplikacji
  shell:
    cmd: "export LD_LIBRARY_PATH=/opt/hiredis_app && ./hiredis_test"
    chdir: /opt/hiredis_app
  register: app_output

- name: 14. Sprawdzenie wyniku (Czy odpowiedź to PONG?)
  debug:
    msg: "Wynik z serwera: {{ app_output.stdout }}"
  failed_when: "'PONG' not in app_output.stdout"
```
## 8. Wykonanie i wyniki (Sanity Check)

Główny proces automatyzacji został wywołany z maszyny sterującej za pomocą poniższego polecenia:

ansible-playbook -i hosts.ini site.yml

Podczas pracy Ansible przeszedł przez wszystkie zdefiniowane etapy. Warto zauważyć, że w zadaniu nr 3 wystąpił błąd przy próbie restartu usługi rng-tools (wynikający z braku tej specyficznej usługi na systemie Ubuntu 24.04). Dzięki zastosowaniu instrukcji ignore_errors: yes, proces nie został przerwany, co pozwoliło na skuteczne przejście do kluczowej części, czyli wdrożenia aplikacji.

Najważniejszym dowodem poprawności wdrożenia jest wynik zadania nr 14 (Sanity Check). Ansible połączył się z bazą danych uruchomioną w Dockerze i odebrał od niej sygnał zwrotny, co potwierdziło, że cała infrastruktura „rozmawia” ze sobą prawidłowo.

![Logi z wykonania playbooka](lab8/screenshots/ansible_logi.png)
*Raport z terminala*

**Interpretacja wyniku widocznego na zrzucie ekranu:**
- **ok=15**: Wszystkie zadania konfiguracyjne i testowe zostały pomyślnie przetworzone.
- **changed=4**: Ansible wprowadził trwałe zmiany na serwerze docelowym (np. przesłał pliki, stworzył linki do bibliotek i dodał wpisy w konfiguracji DNS).
- **ignored=1**: System poprawnie zidentyfikował brak usługi rng-tools i zgodnie z instrukcją pominął ten błąd, kontynuując pracę.
- **PONG**: To finalny dowód sukcesu. Oznacza, że nasza biblioteka hiredis została poprawnie zbudowana przez Jenkinsa, przesłana przez Ansible, skompilowana na nowym serwerze i ostatecznie nawiązała połączenie z bazą danych.
