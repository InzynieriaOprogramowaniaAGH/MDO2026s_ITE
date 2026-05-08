# Sprawozdanie - Metodyki DevOps (Zajęcia 8 - .....)

**Imię i nazwisko:** Mikołaj Bednarczyk  
**Grupa:** Gr 1 , ITE

**Nr indeksu:** 423178  
**Data:** .2026

---

## Środowisko uruchomieniowe
Wszystkie opisane poniżej kroki zostały wykonane w wyizolowanym środowisku.
* **System operacyjny:** Maszyna wirtualna z systemem Linux (Ubuntu).
* **Metoda dostępu:** Połączenie zdalne za pośrednictwem protokołu SSH (Secure Shell). Cała praca odbywała się na koncie standardowego użytkownika.
* **Narzędzia pracy:** Edytor Visual Studio Code z wtyczką *Remote - SSH*, zapewniający dostęp do terminala oraz zarządzanie plikami.

---

## Lab 8: Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

Na poprzednich zajeciach sobie przygotowałem ansible target


Celem zajęć było zapoznanie się z narzędziem Ansible, przeprowadzenie inwentaryzacji systemów oraz automatyzacja zadań konfiguracyjnych i wdrożeniowych na zdalnych maszynach. Pracę oparłem na środowisku przygotowanym w ramach poprzedniego laboratorium (Lab 7), gdzie zainstalowałem pakiet Ansible na maszynie głównej, wykreowałem maszynę docelową o nazwie `ansible-target` oraz wymieniłem klucze SSH, zapewniając bezpieczny dostęp bez konieczności wpisywania hasła.

![Instalacja Ansible i generowanie kluczy SSH](screeny/lab7_4.png)

![Kopiowanie klucza publicznego na maszynę docelową](screeny/lab7_5.png)

![Test logowania na adres IP bez hasła](screeny/lab7_6.png)

![Weryfikacja zainstalowanej wersji Ansible](screeny/lab7_7.png)

### 1. Weryfikacja środowiska i aktualizacja adresacji (Specyfika Hyper-V)
Ze względu na specyfikę przydzielania adresów przez wirtualny przełącznik w Hyper-V, po ponownym uruchomieniu środowiska adres IP mojej maszyny docelowej uległ zmianie. Aby móc odwoływać się do maszyny za pomocą nazwy DNS, wyedytowałem plik `/etc/hosts` na głównej maszynie, aktualizując wpis dla hosta `ansible-target`.

Następnie przetestowałem połączenie. Ponieważ system SSH odnotował zmianę adresu IP pod znaną nazwą hosta, poprosił o akceptację nowego odcisku klucza (fingerprint). Po wpisaniu `yes`, zostałem pomyślnie zalogowany do systemu z użyciem klucza wymuszającego brak hasła, co potwierdziło gotowość maszyny do pracy.

```bash
ssh ansible@ansible-target
```

![Połączenie SSH po nazwie hosta w nowym folderze roboczym](screeny/lab8_1.png)

### 2. Inwentaryzacja systemów i test łączności
Kolejnym krokiem było utworzenie pliku inwentaryzacji, dzięki któremu Ansible wie, jakimi maszynami zarządza. W dedykowanym folderze roboczym dla sprawozdania utworzyłem plik inventory.ini za pomocą edytora tekstowego:

```bash
nano inventory.ini
```

Zgodnie z wymaganiami, umieściłem w nim dwie sekcje maszyn. W sekcji Orchestrators zdefiniowałem maszynę lokalną (sterującą), a w sekcji Endpoints wskazałem moją maszynę wirtualną wraz z parametrem określającym dedykowanego użytkownika:

```ini
[Orchestrators]
localhost ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible
```

Aby zweryfikować poprawność konfiguracji i komunikacji, wysłałem żądanie ping do wszystkich zdefiniowanych w inwentarzu maszyn, wykorzystując wbudowany moduł narzędzia Ansible:

```bash
ansible all -m ping -i inventory.ini
```

Otrzymałem odpowiedź oznaczającą sukces (wartość SUCCESS oraz "ping": "pong") zarówno z maszyny lokalnej, jak i zdalnej, co stanowiło ostateczne potwierdzenie bezproblemowej komunikacji między węzłami.

![Test łączności modułem ping w Ansible](screeny/lab8_2.png)

### 3. Zdalne wywoływanie procedur (Pierwszy Playbook)
Zgodnie z poleceniem, zamiast wykonywać komendy ręcznie, przygotowałem plik konfiguracyjny (Playbook), realizujący podstawową konfigurację maszyny docelowej. 

Utworzyłem plik `setup-system.yml` i zdefiniowałem w nim zadania (tasks) polegające na: wysłaniu testowego pingu, skopiowaniu pliku inwentaryzacji na serwer, zaktualizowaniu pakietów menedżerem APT oraz restarcie wymaganych usług (`sshd` oraz `rngd`).

**Uwaga dotycząca bezpieczeństwa:**
Zadbałem o to, aby w plikach konfiguracyjnych nie znalazły się żadne zapisane czystym tekstem hasła. Zamiast tego, przy uruchamianiu playbooka korzystam z flagi `--ask-become-pass`, która interaktywnie prosi o hasło do podniesienia uprawnień (`sudo`) na zdalnej maszynie na czas działania skryptu.

Kod playbooka `setup-system.yml`:

```yaml
---
- name: Podstawowa konfiguracja maszyn
  hosts: Endpoints
  become: yes
  tasks:
    - name: 1. Skopiowanie pliku inwentaryzacji
      ansible.builtin.copy:
        src: inventory.ini
        dest: /tmp/inventory.ini

    - name: 2. Aktualizacja pakietow systemowych
      ansible.builtin.apt:
        update_cache: yes
        upgrade: dist

    - name: 3. Instalacja rng-tools-debian (wymagane dla usługi rngd)
      ansible.builtin.apt:
        name: rng-tools-debian
        state: present

    - name: 4. Restart uslug sshd i rngd
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: restarted
      loop:
        - ssh
        - rng-tools-debian
```

Uruchomiłem skrypt poleceniem:

```bash
ansible-playbook -i inventory.ini setup-system.yml --ask-become-pass
```

![Poprawne wykonanie pierwszego Playbooka](screeny/lab8_3.png)

Po pomyślnym wykonaniu operacji (statusy ok i changed), przeprowadziłem wymagany test awarii. W menedżerze Hyper-V odłączyłem wirtualną kartę sieciową maszyny `ansible-target` i uruchomiłem Playbook ponownie.

Zgodnie z oczekiwaniami, narzędzie nie mogło nawiązać połączenia po protokole SSH i poprawnie zgłosiło błąd UNREACHABLE. Po teście przywróciłem połączenie sieciowe.

![Test awarii - błąd UNREACHABLE po odłączeniu sieci](screeny/lab8_4.png)

### 4. Zarządzanie stworzonym artefaktem (Wdrożenie aplikacji)
W kolejnym kroku zautomatyzowałem proces wdrożenia aplikacji z wykorzystaniem wygenerowanego na poprzednich laboratoriach pliku binarnego `spring-petclinic.jar`. Zgodnie z dobrymi praktykami CI/CD, nie kompilowałem aplikacji na serwerze docelowym, lecz pobrałem gotowy artefakt z serwera Jenkins i umieściłem go w katalogu roboczym obok playbooków.

Przygotowałem plik `deploy-app.yml`, który instaluje Dockera, kopiuje plik JAR, uruchamia go w kontenerze JRE, przeprowadza test dostępności usługi (Smoke Test) i czyści środowisko docelowe z wdrożonej aplikacji.

**Rozwiązanie problemów napotkanych podczas wdrożenia:**
Podczas pierwszego uruchomienia skryptu, playbook zakończył się niepowodzeniem na etapie kroku nr 7 (Smoke Test). Zdefiniowany warunek sprawdzał obecność dokładnej frazy "Welcome to Petclinic" w pobranym kodzie strony. Kod HTML serwowany przez aplikację zawierał jednak te słowa w osobnych znacznikach (nagłówek `<h2>Welcome</h2>` oraz tytuł `<title>PetClinic...</title>`). Ansible słusznie uznał test za niezaliczony i zatrzymał wykonanie skryptu.

Z uwagi na przerwanie skryptu, krok 8 (usuwający kontener) nie został wywołany. Zanim zaktualizowałem Playbook, musiałem ręcznie oczyścić maszynę ze zablokowanego kontenera. Wykorzystałem do tego komendę ad-hoc w Ansible:

```bash
ansible Endpoints -i inventory.ini -m shell -a "docker rm -f petclinic-prod" -b --ask-become-pass
```

Następnie zaktualizowałem Playbook, modyfikując warunek `failed_when` przy użyciu operatora `or`, tak aby weryfikował obecność słów niezależnie od siebie:

```yaml
---
- name: Wdrozenie aplikacji PetClinic w kontenerze JRE
  hosts: Endpoints
  become: yes
  tasks:
    - name: 1. Sanity check - czy maszyna odpowiada przed wdrozeniem
      ansible.builtin.ping:
      ignore_unreachable: yes

    - name: 2. Instalacja Dockera za pomoca Ansible
      ansible.builtin.apt:
        name: docker.io
        state: present
        update_cache: yes

    - name: 3. Utworzenie katalogu na aplikacje
      ansible.builtin.file:
        path: /opt/petclinic
        state: directory
        mode: '0755'

    - name: 4. Wyslanie pliku binarnego (JAR) na zdalna maszyne
      ansible.builtin.copy:
        src: spring-petclinic.jar
        dest: /opt/petclinic/spring-petclinic.jar

    - name: 5. Uruchomienie aplikacji w kontenerze JRE
      ansible.builtin.shell: |
        docker run -d --name petclinic-prod -p 8080:8080 \
        -v /opt/petclinic/spring-petclinic.jar:/app.jar \
        eclipse-temurin:17-jre java -jar /app.jar

    - name: 6. Oczekiwanie na uruchomienie serwera aplikacji
      ansible.builtin.pause:
        seconds: 35

    - name: 7. Weryfikacja (Smoke Test) czy serwer odpowiada
      ansible.builtin.uri:
        url: http://localhost:8080
        return_content: yes
      register: webpage
      failed_when: "'Welcome' not in webpage.content or 'PetClinic' not in webpage.content"

    - name: 8. Oczyszczenie srodowiska (zatrzymanie i usuniecie kontenera)
      ansible.builtin.shell: |
        docker stop petclinic-prod
        docker rm petclinic-prod
```

Po poprawkach, wdrożenie zainicjowane poniższym poleceniem wykonało się w pełni poprawnie (widoczny na zrzucie ekranu zielony status operacji):

```bash
ansible-playbook -i inventory.ini deploy-app.yml --ask-become-pass
```

![Poprawne wykonanie playbooka wdrażającego aplikację](screeny/lab8_5.png)

### 5. Ubieranie logiki w Role (Ansible Galaxy)
Ostatnim etapem była refaktoryzacja kodu. Zamiast przechowywać wszystkie instrukcje w jednym płaskim pliku YAML, użyłem narzędzia szablonowania, aby przekształcić projekt w ustandaryzowaną rolę konfiguracyjną (Role).

Wygenerowałem szkielet katalogów komendą:

```bash
ansible-galaxy role init deploy_petclinic
```

![generowanua szkieletuy](screeny/lab8_6.png)

Zadania skryptu wdrażającego przeniosłem bezpośrednio do wygenerowanego pliku `deploy_petclinic/tasks/main.yml`, oddzielając je od deklaracji hostów i uprawnień. Zaktualizowałem również metadane w pliku `deploy_petclinic/meta/main.yml`, definiując siebie jako autora oraz opisując cel roli. Wygenerowana w ten sposób struktura prezentuje się następująco:

![Struktura katalogów roli Ansible](screeny/lab8_7.png)

Na zakończenie laboratoriów, stworzone artefakty i zaktualizowaną dokumentację umieściłem w repozytorium.