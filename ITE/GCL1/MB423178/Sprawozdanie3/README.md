# Sprawozdanie - Metodyki DevOps (Zajęcia 8 - 11)

**Imię i nazwisko:** Mikołaj Bednarczyk  
**Grupa:** Gr 1 , ITE

**Nr indeksu:** 423178  
**Data:** 09.06.2026

---

## Środowisko uruchomieniowe
Wszystkie opisane poniżej kroki zostały wykonane w wyizolowanym środowisku.
* **System operacyjny:** Maszyna wirtualna z systemem Linux (Ubuntu).
* **Metoda dostępu:** Połączenie zdalne za pośrednictwem protokołu SSH (Secure Shell). Cała praca odbywała się na koncie standardowego użytkownika.
* **Narzędzia pracy:** Edytor Visual Studio Code z wtyczką *Remote - SSH*, zapewniający dostęp do terminala oraz zarządzanie plikami.

---

## Lab 8: Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

Celem zajęć było zapoznanie się z narzędziem Ansible, przeprowadzenie inwentaryzacji systemów oraz automatyzacja zadań konfiguracyjnych i wdrożeniowych na zdalnych maszynach zgodnie z paradygmatem *Infrastructure as Code*. 

### 1. Inwentaryzacja systemów, wymiana kluczy i realizacja zasady "Seamlessness"

Użyłem środowiska przygotowanego w ramach poprzedniego laboratorium Lab 7, gdzie zainstalowałem pakiet Ansible na maszynie głównej, stworzyłem lekką maszynę docelową Ubuntu Server o nazwie `ansible-target`, wyposażoną jedynie w demona OpenSSH (`sshd`) oraz narzędzie `tar`. Wymieniłem też klucze SSH, zapewniając bezpieczny dostęp bez konieczności wpisywania hasła.

**Klucze SSH:** Przesłałem klucz publiczny za pomocą komendy:

```bash
ssh-copy-id ansible@ansible-target
```

![Instalacja Ansible i generowanie kluczy SSH](screeny/lab7_4.png)

![Kopiowanie klucza publicznego na maszynę docelową](screeny/lab7_5.png)

![Test logowania na adres IP bez hasła](screeny/lab7_6.png)

![Weryfikacja zainstalowanej wersji Ansible](screeny/lab7_7.png)

### 2. Weryfikacja środowiska i aktualizacja adresacji
Ze względu na specyfikę przydzielania adresów przez wirtualny przełącznik w Hyper-V, po ponownym uruchomieniu środowiska adres IP mojej maszyny docelowej uległ zmianie. Aby móc odwoływać się do maszyny za pomocą nazwy DNS, zmieniłem plik `/etc/hosts` na głównej maszynie, aktualizując wpis dla hosta `ansible-target`.

Następnie przetestowałem połączenie. Ponieważ system SSH odnotował zmianę adresu IP pod znaną nazwą hosta, poprosił o akceptację nowego odcisku klucza. Po zatwierdzeniu, zostałem pomyślnie zalogowany do systemu z użyciem klucza wymuszającego brak hasła, co potwierdziło gotowość maszyny do pracy.

```bash
ssh ansible@ansible-target
```

![Połączenie SSH po nazwie hosta w nowym folderze roboczym](screeny/lab8_1.png)

### 3. Inwentaryzacja systemów i test łączności
Kolejnym krokiem było utworzenie pliku inwentaryzacji, dzięki któremu Ansible wie, jakimi maszynami zarządza. W dedykowanym folderze roboczym dla sprawozdania utworzyłem plik inventory.ini za pomocą edytora tekstowego:

```bash
nano inventory.ini
```

Zgodnie z wymaganiami, umieściłem w nim dwie sekcje maszyn. W sekcji Orchestrators zdefiniowałem maszynę lokalną sterującą, a w sekcji Endpoints wskazałem moją maszynę wirtualną wraz z parametrem określającym dedykowanego użytkownika:

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

Otrzymałem odpowiedź oznaczającą sukces, wartość SUCCESS oraz ping, zarówno z maszyny lokalnej, jak i zdalnej, co stanowiło ostateczne potwierdzenie bezproblemowej komunikacji między węzłami.

![Test łączności modułem ping w Ansible](screeny/lab8_2.png)

### 4. Zdalne wywoływanie procedur - Pierwszy Playbook
Zgodnie z poleceniem, zamiast wykonywać komendy ręcznie, przygotowałem plik konfiguracyjny Playbook, realizujący podstawową konfigurację maszyny docelowej. 

Utworzyłem plik `setup-system.yml` i zdefiniowałem w nim zadania (tasks) polegające na: wysłaniu testowego pingu, skopiowaniu pliku inwentaryzacji na serwer, zaktualizowaniu pakietów menedżerem APT oraz restarcie wymaganych usług `sshd` oraz `rngd`.

**Uwaga dotycząca bezpieczeństwa:**
Zadbałem o to, aby w plikach konfiguracyjnych nie znalazły się żadne zapisane czystym tekstem hasła. Zamiast tego, zagwarantowałem odpowiednie redukowanie uprawnień, łączę się z maszyną jako standardowy, nieuprzywilejowany użytkownik, a przy uruchamianiu playbooka korzystam z flagi `--ask-become-pass`, która interaktywnie prosi o hasło do podniesienia uprawnień na zdalnej maszynie na czas działania skryptu.

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

### 5. Zarządzanie stworzonym artefaktem (Wdrożenie aplikacji)
W kolejnym kroku zautomatyzowałem proces wdrożenia aplikacji z wykorzystaniem wygenerowanego na poprzednich laboratoriach pliku binarnego `spring-petclinic.jar`. Zgodnie z dobrymi praktykami CI/CD, nie kompilowałem aplikacji na serwerze docelowym, tylko pobrałem gotowy artefakt z serwera Jenkins i umieściłem go w katalogu roboczym obok playbooków.

Przygotowałem plik `deploy-app.yml`, który instaluje Dockera, kopiuje plik JAR, uruchamia go w kontenerze JRE, przeprowadza test dostępności usługi tzw. Smoke Test i czyści środowisko docelowe z wdrożonej aplikacji.

**Rozwiązanie problemów napotkanych podczas wdrożenia:**
Podczas pierwszego uruchomienia skryptu, playbook zakończył się niepowodzeniem na etapie kroku nr 7 (Smoke Test). Zdefiniowany warunek sprawdzał obecność dokładnej frazy "Welcome to Petclinic" w pobranym kodzie strony. Kod HTML serwowany przez aplikację zawierał jednak te słowa w osobnych znacznikach, nagłówek `<h2>Welcome</h2>` oraz tytuł `<title>PetClinic...</title>`. Ansible słusznie uznał test za niezaliczony i zatrzymał wykonanie skryptu.

Z uwagi na przerwanie skryptu, krok 8 usuwający kontener nie został wywołany. Zanim zaktualizowałem Playbook, musiałem ręcznie oczyścić maszynę ze zablokowanego kontenera. Wykorzystałem do tego nastepującą komendę w Ansible:

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

Po poprawkach, wdrożenie zainicjowane poniższym poleceniem wykonało się w pełni poprawnie, widoczny na zrzucie ekranu zielony status operacji:

```bash
ansible-playbook -i inventory.ini deploy-app.yml --ask-become-pass
```

![Poprawne wykonanie playbooka wdrażającego aplikację](screeny/lab8_5.png)

Wdrożenie zainicjowane poleceniem wykonało się w pełni poprawnie. Moduł uri wykorzystany w Smoke Teście z powodzeniem **wdał się w interakcję z aplikacją**, pobierając i weryfikując treść strony docelowej, co bezsprzecznie dowodzi jej poprawnego uruchomienia i wdrożenia.

### 6. Ubieranie logiki w Role - Ansible Galaxy
Ostatnim etapem była refaktoryzacja kodu. Zamiast przechowywać wszystkie instrukcje w jednym pliku YAML, użyłem narzędzia szablonowania, aby przekształcić projekt w ustandaryzowaną rolę konfiguracyjną.

Wygenerowałem szkielet katalogów komendą:

```bash
ansible-galaxy role init deploy_petclinic
```

![generowanua szkieletuy](screeny/lab8_6.png)

Zadania skryptu wdrażającego przeniosłem bezpośrednio do wygenerowanego pliku `deploy_petclinic/tasks/main.yml`, oddzielając je od deklaracji hostów i uprawnień. Zaktualizowałem również metadane w pliku `deploy_petclinic/meta/main.yml`, definiując siebie jako autora oraz opisując cel roli. Wygenerowana w ten sposób struktura prezentuje się następująco:

![Struktura katalogów roli Ansible](screeny/lab8_7.png)

Na zakończenie laboratoriów, stworzone artefakty i zaktualizowaną dokumentację umieściłem w repozytorium.

## Lab 9: Pliki odpowiedzi dla wdrożeń nienadzorowanych Kickstart

Celem tego laboratorium było przygotowanie w pełni zautomatyzowanej instalacji nienadzorowanej systemu Fedora z wykorzystaniem technologii Kickstart oraz podejścia Infrastructure as Code.

### 1. Pierwsza próba: Użycie surowego pliku anaconda-ks.cfg
Rozpocząłem od zainstalowania "wzorcowej" maszyny wirtualnej UEFI z wykorzystaniem obrazu sieciowego *Everything Netinst*. Następnie pobrałem z niej automatycznie wygenerowany plik odpowiedzi `/root/anaconda-ks.cfg`. 

**Dlaczego domyślny plik nie zadziałał?**
Na początku po ręcznej instalacji testowej maszyny wyciągnąłem wygenerowany plik */root/anaconda-ks.cfg* i spróbowałem zainstalować kolejną maszynę używając go bez żadnych modyfikacji. Próba ta zakończyła się niepowodzeniem i obnażyła następujące problemy:
* **Konieczność interakcji:** Instalator wstrzymał pracę, domagając się ręcznego zatwierdzenia formatowania używanego dysku, co uniemożliwiało reinstalację "w kółko".
* **Brak pakietów:** Wersja *Netinst* bez zdefiniowanych zewnętrznych repozytoriów w pliku odpowiedzi nie potrafiła odnaleźć źródła plików instalacyjnych.
* **Brak automatyzacji po instalacji:** Maszyna zatrzymała się na ekranie końcowym przez brak automatycznego restartu, a sam system nie posiadał narzędzi, np. Dockera czy `wget`, potrzebnych do uruchomienia aplikacji.

### 2. Modyfikacja pliku odpowiedzi i udana instalacja nienadzorowana
Aby rozwiązać powyższe problemy i zrealizować założenia projektu, zmodyfikowałem plik `ks.cfg`:
* Dodałem dyrektywy `url` i `repo` wskazujące na oficjalne repozytoria Fedory 44.
* Wymusiłem bezwarunkowe formatowanie dysku (`zerombr`, `clearpart --all --initlabel`), co pozwala na bezdotykową reinstalację.
* **Polityka bezpieczeństwa haseł:** Usunąłem z pliku hasła zapisane jawnym tekstem (plaintext). Wygenerowałem bezpieczny skrót algorytmem SHA-512 za pomocą terminala (openssl passwd -6) i wkleiłem go z flagą --iscrypted, aby zabezpieczyć repozytorium przed wyciekiem poświadczeń.
* Skonfigurowałem nazwy hosta (`fedora-petclinic`), użytkownika z uprawnieniami administratora oraz wymusiłem zautomatyzowany restart (`reboot`) po zakończeniu procesu.
* Dodałem w sekcji `%packages` pakiety wymagane dla kontenerów (m.in. `moby-engine`).
* **Skrypt poinstalacyjny:** W sekcji `%post` dodałem logikę odpowiedzialną za wdrożenie aplikacji. Skrypt pobiera z udostępnionego przeze mnie lokalnego serwera HTTP zbudowany wcześniej plik JAR i za pomocą usługi `systemd` gwarantuje jego uruchomienie w kontenerze JRE natychmiast po pierwszym uruchomieniu systemu.

Dzięki tym poprawkom, kolejna instalacja nowej maszyny przebiegła w pełni bezobsługowo. Instalator pobrał konfigurację po dodaniu parametru `inst.ks=http://...` w menu GRUB i nie zadał ani jednego pytania.

![Proces instalacji nienadzorowanej 1](screeny/lab9_1.png)

![Proces instalacji nienadzorowanej 2](screeny/lab9_2.png)

![Proces instalacji nienadzorowanej 3](screeny/lab9_3.png)

### 3. Weryfikacja działania wdrożonego oprogramowania
Po zautomatyzowanym restarcie systemu zalogowałem się na stworzone konto użytkownika i zweryfikowałem, czy skrypt `%post` wykonał swoje zadanie. Sprawdzenie statusu Dockera poleceniem `sudo docker ps` potwierdziło, że usługa poprawnie uruchomiła środowisko kontenerowe z naszą aplikacją:

![Weryfikacja działającego kontenera Docker](screeny/lab9_4.png)

Następnie przetestowałem odpowiedź serwera narzędziem `curl`. Aplikacja prawidłowo i natychmiastowo obsłużyła żądanie sieciowe zwracając status `HTTP/1.1 200 OK` i udowadniając sukces pełnej automatyzacji.

![Test połączenia z aplikacją po instalacji](screeny/lab9_5.png)


# Sprawozdanie: Laboratorium 10 - Wdrażanie na zarządzalne kontenery - Kubernetes cz. 1

## 1. Przygotowanie obrazów - Docker Hub
W pierwszej części laboratorium odpowiednio zmodyfikowałem plik `Dockerfile` aplikacji PetClinic. Zbudowałem i wypchnąłem do repozytorium na Docker Hubie trzy wersje obrazu: `v1`, `v2` oraz `broken`. Wersja `broken` została specjalnie uszkodzona poprzez podmianę pliku JAR na nieprawidłowy plik tekstowy, co posłużyło do późniejszych testów aktualizacji klastra.
Pomyślnie uwierzytelniłem sesję CLI z platformą Docker:
![Logowanie do platformy Docker](screeny/Zrzut%20ekranu%202026-05-29%20081725.png)

## 2. Konfiguracja klastra i wdrożenie manualne
Uruchomiłem lokalny klaster Kubernetes przy użyciu narzędzia Minikube z wykorzystaniem sterownika Dockera (`--driver=docker`). Zarządzanie klastrem zweryfikowałem poprzez uruchomienie wbudowanego interfejsu graficznego Kubernetes Dashboard z wykorzystaniem polecenia `kubectl proxy`.
![Uruchomienie serwera proxy dla Dashboardu](screeny/Zrzut%20ekranu%202026-05-29%20080605.png)

Aplikację wdrożyłem początkowo w sposób manualny pod `petclinic-manual`, co zweryfikowałem w panelu administracyjnym klastra:

```bash
kubectl run petclinic-manual --image=13miki/petclinic:v1 --port=8080
```

![Ręczne wdrożenie poda - widok w Dashboardzie](screeny/Zrzut%20ekranu%202026-05-29%20082617.png)

Następnie przetestowałem bezpośredni dostęp do niej z poziomu przeglądarki używając mechanizmu przekierowania portów Port Forwarding:
![Działająca aplikacja po wyeksponowaniu portów](screeny/Zrzut%20ekranu%202026-05-29%20082946.png)

## 3. Przekucie wdrożenia w plik YAML - Infrastructure as Code
Po usunięciu ręcznie wdrożonego Poda, zdefiniowałem konfigurację środowiska w pliku `deploy-kubernetes-app.yml`. 
Plik zawierał konfigurację dwóch zasobów:
* **Deployment:** zarządzający pożądanym stanem aplikacji narazie ustawiono 4 repliki.
* **Service (NodePort):** udostępniający aplikację na zewnątrz oraz pełniący rolę load balancera pomiędzy replikami.

Konfigurację zaaplikowałem poprzez terminal:

```bash
kubectl apply -f deploy-kubernetes-app.yml
```

![Wdrożenie konfiguracji YAML](screeny/Zrzut%20ekranu%202026-05-29%20085955.png)

Poprawność wdrożenia zweryfikowałem w Dashboardzie, gdzie zobaczyć można 4 poprawnie działające pody kontrolowane przez nowy Deployment:
![Wdrożenie 4 replik - widok w Kubernetes Dashboard](screeny/Zrzut%20ekranu%202026-05-29%20090117.png)

## 4. Skalowanie i mechanizm aktualizacji - Rolling Updates
Wdrożenie przetestowałem pod kątem elastyczności i niezawodności operacyjnej.
**Skalowanie:** Użyłem polecenia `kubectl scale`, by zmienić liczbę działających replik z 4 do 8 , następnie do 1, 0, i z powrotem do 4.

```bash
kubectl scale deployment petclinic-deployment --replicas=8
```

![Przeskalowanie wdrożenia do 8 replik](screeny/Zrzut%20ekranu%202026-05-29%20090402.png)

**Aktualizacja wersji i obsługa awarii:** Podmieniłem w locie obraz wdrożenia na `v2`. Następnie spróbowałem wdrożyć uszkodzony obraz `broken`. Kubernetes poprawnie zidentyfikował problem z uruchomieniem kontenera, nałożył na uszkodzone pody status `CrashLoopBackOff` i wstrzymał dalszą aktualizację, co ochroniło aplikację przed całkowitą awarią. Wykonałem udany rollback poleceniem `kubectl rollout undo`) do w pełni stabilnej i działającej wersji.

## 5. Strategie wdrożenia
Na koniec przetestowałem i porównałem metody wdrażania aktualizacji:
* **Rolling Update (Domyślna):** Nowe pody są uruchamiane równolegle z wyłączaniem starych, co zapewnia brak przerw w dostępie do usługi (Zero-Downtime Deployment).
* **Recreate:** Po dodaniu parametrów strategii `Recreate` do pliku YAML zaobserwowałem, że Kubernetes podczas modyfikacji wersji najpierw bezwzględnie zatrzymuje i usuwa wszystkie dotychczasowe pody, a dopiero potem podnosi nowe. Strategia ta generuje krótkotrwałą niedostępność usługi, ale wyklucza sytuację jednoczesnego działania dwóch różnych wersji aplikacji.


# Sprawozdanie: Laboratorium 11 - Wdrażanie na zarządzalne kontenery - Kubernetes cz. 2

## 1. Wdrożenie web-serwera za pomocą Deploymentu 
Zgodnie z instrukcją, przygotowałem plik konfiguracyjny `lab11-petclinic-deployment.yml` w oparciu o obraz z poprzednich zajęć (`13miki/petclinic:v1`). Aplikacja została wdrożona w dużej liczbie replik. 

Początkowo klaster podjął próbę uruchomienia 36 podów, co z racji wysokiego zapotrzebowania aplikacji Spring Boot na zasoby (RAM), doprowadziło do testu granic wydajności środowiska Minikube. 
![Lista 36 podów próbujących wystartować](screeny/lab11_2.png)

## 2. Eksponowanie dostępu do aplikacji (Service/Wbudowane mechanizmy)
Przeprowadziłem serię wdrożeń udowadniających możliwość zestawienia komunikacji z aplikacją na trzech różnych warstwach architektury Kubernetes za pomocą mechanizmu `port-forward`.

* **Eksponowanie pojedynczego poda:** Ruch z portu lokalnego `8080` skierowano bezpośrednio do instancji kontenera.
```bash
kubectl port-forward pod/nazwa-poda-petclinic 8080:8080
```
* **Eksponowanie do Deploymentu:** Ruch z portu lokalnego `8081` skierowano do kontrolera wdrożenia.
```bash
kubectl port-forward deployment/petclinic-deployment-lab11 8081:8080
```
* **Eksponowanie do Serwisu:** Utworzyłem Serwisy typu `LoadBalancer`. Pierwszy za pomocą polecenia `kubectl expose` udostępniony na porcie lokalnym `8082`, a drugi deklaratywnie za pomocą przygotowanego pliku `lab11-petclinic-service.yml` udostępniony na porcie lokalnym `8083`.
```bash
kubectl apply -f lab11-petclinic-service.yml
kubectl port-forward service/petclinic-svc-yaml 8083:8080
```

Działanie równoległego przekierowania portów:
![Równoległe przekierowanie portów 8080, 8081 i 8082 w terminalach](screeny/lab11_3.png)
![Widok przeglądarek potwierdzający działanie 3 portów](screeny/lab11_6.png)
![Utworzenie i przekierowanie Serwisu z pliku YAML na port 8083](screeny/lab11_7.png)

## 3. Skalowanie wdrożenia
Aby zweryfikować elastyczność klastra oraz odciążyć węzeł, zmniejszałem i zwiększałem liczbę replik na dwa zalecone sposoby:
1.  **Za pomocą dyrektywy z linii poleceń:** Użycie `kubectl scale deployment ... --replicas=6` wymusiło natychmiastowe usunięcie nadmiarowych podów.
    ![Skalowanie komendą scale](screeny/lab11_12.png)
2.  **Za pomocą modyfikacji pliku YAML:** Zmodyfikowałem wartość `replicas: 8` w pliku deklaratywnym i wdrożyłem zmiany poleceniem `kubectl apply`. Klaster dostosował pożądany stan, uruchamiając brakujące kontenery.
    ![Skalowanie z wykorzystaniem pliku YAML](screeny/lab11_14.png)

## 4. Zadanie z Bonusem: Weryfikacja działania LoadBalancera
Ostatnim etapem było udowodnienie mechanizmu działania Serwisu. Po przekierowaniu ruchu wygenerowałem zapytania HTTP do aplikacji. Za pomocą polecenia `kubectl logs -l app=petclinic-web -f --max-log-requests=10` nasłuchiwałem logów ze wszystkich działających replik jednocześnie.

Zgodnie z przewidywaniami, logi potwierdziły, że żądania przesyłane do głównego Serwisu są naprzemiennie rozdzielane pomiędzy różnymi podami, realizując tym samym funkcję równoważenia obciążenia Load Balancing.
![Logi napływające ze skalowanego środowiska](screeny/lab11_17.png)

## 5. Troubleshooting (Rozwiązywanie problemów)
W trakcie trwania laboratorium środowisko deweloperskie uległo **prawdopodobnie** całkowitemu wyczerpaniu zasobów pamięci. Wynikało to ze specyfiki aplikacji napisanej w frameworku Spring Boot (Java), która rezerwuje dużo zasobów na starcie. Próba podniesienia 36 takich procesów zadławiła maszynę. Spowodowało to brak odpowiedzi API Servera (TLS handshake timeout) oraz błędy zestawiania połączeń do portów (Connection refused), wynikające ze wstrzymania inicjalizacji procesów Javy. Próby awaryjnego zatrzymania klastra również zawieszały terminal.
Aby uratować środowisko, musiałem zrestartować główną usługę Dockera z poziomu samego systemu Ubuntu, aby siłowo wyczyścić RAM i zabić zablokowane procesy:

```bash
sudo systemctl restart docker
```

![Logi demona Docker potwierdzające obciążenie zasobów i restart usługi](screeny/lab11_9.png)
Powyższe problemy posłużyły jako studium przypadku do diagnostyki stanu aplikacji za pomocą kolumny statusu oraz analizy logów startowych podów, po czym środowisko pomyślnie ustabilizowałem do założonego w poleceniu stanu.

## Wnioski ze skalowalności i testów sieciowych
**Pomiary i Wnioski ze skalowalności:** Skomponowane wdrożenie poprawnie się skaluje (co zmierzyłem dla wartości 0, 4 i 8 replik). Aplikacja błyskawicznie powołuje brakujące kontenery. Jednakże, próba masowego wyskalowania do 36 podów doprowadziła do globalnej awarii węzła z powodu wyczerpania RAM-u (OOM). Główny wniosek: aplikacje oparte na platformie Java/Spring bezwzględnie wymagają sztywnej konfiguracji limitów pamięci (resources.limits) w pliku YAML, w przeciwnym razie replikator Kubernetes doprowadzi do paraliżu fizycznego sprzętu.
**Wnioski sieciowe:**
 Dostęp do wdrożenia z powodzeniem został wyprowadzony za pomocą wbudowanych mechanizmów sieciowych k8s. Wykorzystanie wbudowanego obiektu typu Service zadeklarowanego z pliku YAML udowadnia, że ruch został wystawiony i był prawidłowo równoważony przez LoadBalancer (co udowodniły testy logów w zadaniu bonusowym).

# Ważna adnotacja dotycząca użycia AI
Zgodnie z wymaganiami z pliku Rules.md, informuję, że podczas pisania tego sprawozdania wspomagałem się modelem językowym (LLM) jako narzędziem do korekty tekstu oraz rozwiązywania niektórych problemów tehcnicznych.

**Przykładowe prompty użyte podczas pracy nad sprawozdaniem (Lab 8-11):**
1. *"Sprawdź i popraw błędy składniowe oraz gramatyczne w poniższym tekście mojego sprawozdania."*
2. *"Zablokował mi się kontener Dockera na hoście po przerwaniu skryptu. Jak jednym poleceniem ad-hoc w Ansible wymusić jego usunięcie na zdalnej maszynie, bez konieczności logowania się tam przez SSH?"*
3. *"Dlaczego po ustawieniu 36 replik aplikacji Spring Boot w Kubernetes wywala mi w terminalu błąd 'API TLS handshake timeout', a minikube całkowicie przestaje reagować na komendę stop?"*
4. *"Jak wygenerować bezpieczny hash hasła w terminalu Linuxa, żeby nie wpisywać go czystym tekstem w pliku ks.cfg dla instalatora Fedory i móc go bezpiecznie wrzucić na GitHuba?"*


**Metody weryfikacji odpowiedzi:**
Odpowiedzi modelu traktowałem jako wskazówki. Weryfikowałem je na dwa sposoby:
1. **Weryfikacja praktyczna:** Wszelkie sugestie dotyczące komend powłoki czy konfiguracji środowiska były najpierw analizowane merytorycznie, a następnie uruchamiane ręcznie w wyizolowanym środowisku. Dowodem ich poprawnego działania są uwiecznione logi i zrzuty ekranu.
2. **Sprawdzanie źródeł :** W przypadku zapytań o konfigurację plików YAML, różnice między strategiami wdrożeń w Kubernetesie czy flagi w systemie Kickstart, wygenerowane informacje były bezpośrednio konfrontowane z oficjalną dokumentacją dostawców (Kubernetes, Ansible, Red Hat). Linki dostarczone przez AI były ręcznie odwiedzane w celu potwierdzenia rzetelności informacji zawartych w sprawozdaniu.