## Zajęcia 08 – Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

Podczas zajęć przygotowano środowisko do zdalnego zarządzania maszynami za pomocą Ansible. Wykorzystano maszynę główną `server` oraz maszynę docelową `ansible-target`. Na maszynie głównej działał Ansible, natomiast na maszynie docelowej skonfigurowano użytkownika `ansible`, serwer SSH oraz wymagane narzędzia. Logowanie SSH odbywało się bez podawania hasła.

![Weryfikacja środowiska Ansible](screenshots/S3_Z08_00_instalacja-i-polaczenie-ansible.png)

Utworzono plik `inventory.ini` zawierający grupy `Orchestrators` oraz `Endpoints`. Poprawność konfiguracji sprawdzono za pomocą `ansible-inventory`, a następnie wykonano test `ping` do obu maszyn.

![Struktura inventory](screenshots/S3_Z08_01_inventory-struktura.png)

![Test ping Ansible](screenshots/S3_Z08_02_ping-wszystkie-maszyny.png)

Następnie przygotowano playbook realizujący test łączności oraz kopiowanie pliku inventory na maszynę docelową. Pierwsze wykonanie kopiowania zwróciło `changed=1`, natomiast ponowne uruchomienie tego samego playbooka zakończyło się wynikiem `changed=0`, co potwierdziło idempotentne działanie Ansible.

![Pierwsze wykonanie playbooka](screenshots/S3_Z08_03_playbook-ping-i-kopiowanie.png)

![Ponowne wykonanie playbooka](screenshots/S3_Z08_04_inventory-drugie-kopiowanie.png)

Za pomocą Ansible wykonano również aktualizację pakietów systemowych oraz zainstalowano `rng-tools5`. Następnie zrestartowano usługi `ssh` oraz `rngd`.

![Aktualizacja pakietów](screenshots/S3_Z08_05_aktualizacja-pakietow-ansible.png)

![Restart usług](screenshots/S3_Z08_06_restart-uslug-ssh-rngd.png)

Sprawdzono także zachowanie Ansible w sytuacjach awaryjnych. Po wyłączeniu usługi SSH maszyna została oznaczona jako `UNREACHABLE` z komunikatem `Connection refused`. Po odłączeniu karty sieciowej od przełącznika Hyper-V otrzymano `Connection timed out`.

![Wyłączony serwer SSH](screenshots/S3_Z08_07_ansible-wylaczony-ssh.png)

![Odłączona sieć](screenshots/S3_Z08_08_ansible-odpieta-siec.png)

W dalszej części zajęć wykorzystano artefakt `axios-1.20.0.tgz` utworzony podczas wcześniejszego pipeline'u Jenkins. Plik został pobrany z archiwum Jenkinsa i wysłany za pomocą Ansible na maszynę `ansible-target`. Poprawność transferu potwierdzono porównaniem sum SHA-256.

![Wysłanie artefaktu Axios](screenshots/S3_Z08_09_wyslanie-artefaktu-axios.png)

Docker nie był wcześniej zainstalowany na maszynie docelowej, dlatego jego instalację wykonano za pomocą Ansible. Następnie sprawdzono działanie usługi Docker oraz przeprowadzono sanity check przed wdrożeniem.

![Instalacja Dockera](screenshots/S3_Z08_10_instalacja-dockera-ansible.png)

![Sanity check](screenshots/S3_Z08_11_sanity-check-przed-wdrozeniem.png)

Dla artefaktu Axios przygotowano `Dockerfile` oraz prosty skrypt `verify-axios.js`. Obraz został zbudowany na maszynie docelowej, a następnie uruchomiono kontener wykorzystujący bezpośrednio plik `axios-1.20.0.tgz`.

![Budowanie obrazu Axios](screenshots/S3_Z08_12_budowanie-obrazu-axios.png)

Poprawne uruchomienie artefaktu potwierdzono wynikiem:

```text
Axios version: 1.20.0
Axios artifact loaded successfully
```

![Weryfikacja działania Axios](screenshots/S3_Z08_13_uruchomienie-i-weryfikacja-axios.png)

Po zakończeniu testów wykonano cleanup środowiska. Usunięto kontener, obraz Docker oraz katalog aplikacji, a następnie zweryfikowano brak pozostałości po wdrożeniu.

![Cleanup środowiska](screenshots/S3_Z08_14_cleanup-axios.png)

![Weryfikacja cleanupu](screenshots/S3_Z08_15_weryfikacja-cleanup.png)

Na końcu utworzono rolę `axios_deploy` za pomocą `ansible-galaxy role init`. Uzupełniono plik `meta/main.yml`, zdefiniowano zmienne oraz przeniesiono do roli zadania odpowiedzialne za przygotowanie środowiska, wysłanie artefaktu, budowanie obrazu, uruchomienie aplikacji, weryfikację oraz cleanup.

![Utworzenie roli Ansible](screenshots/S3_Z08_16_ansible-galaxy-role-init.png)

Pełne uruchomienie roli zakończyło się bez błędów i ponownie potwierdziło poprawne działanie Axios w wersji `1.20.0`.

![Pełne wykonanie roli](screenshots/S3_Z08_17_rola-axios-pelny-przebieg.png)

Cała struktura `Lab08` została następnie dodana do repozytorium i wysłana na branch `DC417539` w commicie `DC417539 Lab08`.


## Zajęcia 09 – Instalacja nienadzorowana systemu Fedora z użyciem Kickstart

Podczas zajęć przygotowano automatyczną instalację systemu Fedora Server 43 z wykorzystaniem pliku odpowiedzi Kickstart. W Hyper-V utworzono nową maszynę wirtualną drugiej generacji z UEFI, dyskiem 30 GB oraz dostępem do sieci przez `Default Switch`.

Najpierw wykonano standardową instalację systemu Fedora w celu uzyskania wygenerowanego przez instalator pliku `/root/anaconda-ks.cfg`. Plik został następnie skopiowany i zmodyfikowany tak, aby umożliwiał wielokrotną, całkowicie nienadzorowaną reinstalację systemu.

W konfiguracji Kickstart ustawiono m.in. automatyczne czyszczenie dysku za pomocą `clearpart --all --initlabel`, automatyczne partycjonowanie, hostname `fedora`, użytkownika `daniel`, wyłączenie kreatora pierwszego uruchomienia oraz automatyczny restart po zakończeniu instalacji.

Plik `ks.cfg` został udostępniony z maszyny `server` przez prosty serwer HTTP. Podczas uruchamiania instalatora do parametrów startowych dodano:

```text
inst.ks=http://172.22.199.112:8000/ks.cfg ip=dhcp
```

![Parametr Kickstart podczas uruchamiania instalatora](screenshots/S3_Z09_01_kickstart-parametr-startowy.png)

Poprawne pobranie pliku odpowiedzi przez instalator potwierdzono w logu serwera HTTP. Żądanie do `/ks.cfg` zakończyło się kodem odpowiedzi `200`.

![Pobranie pliku Kickstart przez HTTP](screenshots/S3_Z09_02_kickstart-http-200.png)

Po sprawdzeniu podstawowej instalacji plik Kickstart rozszerzono o dodatkowe repozytoria Fedory oraz pakiety `nodejs`, `nodejs-npm` i `python3`, potrzebne do uruchomienia artefaktu przygotowanego wcześniej przez pipeline Jenkins.

W sekcji `%post` dodano mechanizm pobierający artefakt `axios-1.20.0.tgz`, jego instalację za pomocą `npm` oraz utworzenie prostej aplikacji wykorzystującej bibliotekę Axios. Przygotowano również usługę `systemd` o nazwie `axios-app.service`, która jest automatycznie włączana podczas instalacji. Dodatkowo w konfiguracji firewalla otwarto port `3000/tcp`.

Po zakończeniu finalnej instalacji system automatycznie uruchomił się ponownie. Sprawdzenie usługi wykazało, że `axios-app.service` jest ustawiona jako `enabled` oraz działa ze statusem `active (running)`. W logu usługi widoczna była również informacja o uruchomieniu Axios w wersji `1.20.0`.

![Automatyczne uruchomienie usługi Axios](screenshots/S3_Z09_03_axios-systemd-active.png)

Na końcu sprawdzono dostęp do aplikacji z maszyny `server`. Odpowiedź z portu `3000` potwierdziła poprawne działanie wdrożonego artefaktu:

```text
Axios 1.20.0 działa na Fedora Lab09
```

![Weryfikacja działania Axios przez sieć](screenshots/S3_Z09_04_axios-http-response.png)

Finalny plik `ks.cfg` został dodany do katalogu `Lab09` i wysłany na branch `DC417539` w commicie `DC417539 Lab09`.


# Zajęcia 10 — Wdrażanie aplikacji w Kubernetes

## Przygotowanie klastra Kubernetes

Na początku sprawdzono dostępność Minikube, klienta `kubectl` oraz Dockera. Zweryfikowano również zasoby maszyny, takie jak liczba procesorów, pamięć RAM oraz wolne miejsce na dysku. Maszyna posiadała ograniczoną ilość pamięci RAM, jednak klaster udało się poprawnie uruchomić.

![Minikube i wymagania sprzętowe](screenshots/S3_Z10_01_minikube-i-wymagania.png)

Sprawdzono również sposób instalacji Minikube. Program był uruchamiany przez zwykłego użytkownika, natomiast jego plik wykonywalny należał do użytkownika `root` i nie posiadał ustawionego bitu `setuid`.

![Bezpieczeństwo instalacji Minikube](screenshots/S3_Z10_02_bezpieczenstwo-minikube.png)

Następnie uruchomiono klaster Minikube z wykorzystaniem sterownika Docker. Sprawdzono stan klastra oraz działający węzeł Kubernetes. Wszystkie podstawowe komponenty działały poprawnie, a node `minikube` miał status `Ready`.

![Działający klaster Kubernetes](screenshots/S3_Z10_03_dzialajacy-klaster-worker.png)

Uruchomiono również Kubernetes Dashboard i sprawdzono możliwość dostępu do niego z poziomu przeglądarki.

![Kubernetes Dashboard](screenshots/S3_Z10_04_kubernetes-dashboard.png)

## Przygotowanie aplikacji do wdrożenia

Najpierw sprawdzono wcześniej przygotowany obraz `axios-runtime:v1.20.0`. Kontener poprawnie uruchamiał bibliotekę Axios i wypisywał jej wersję, jednak natychmiast kończył działanie. Z tego powodu nie nadawał się jako kontener działający stale w Kubernetes.

![Kontener Axios kończący działanie](screenshots/S3_Z10_05_axios-nie-nadaje-sie-do-deploy.png)

Na potrzeby dalszej części ćwiczenia przygotowano własny obraz oparty na `nginx:alpine`. Dodano własną stronę HTML oraz konfigurację nginx. Po uruchomieniu kontenera sprawdzono jego stan oraz odpowiedź aplikacji za pomocą `curl`.

![Własny kontener nginx](screenshots/S3_Z10_06_wlasny-nginx-dzialajacy-kontener.png)

## Uruchomienie aplikacji w Kubernetes

Obraz `lab10-nginx:v1` został załadowany do Minikube, a następnie uruchomiono go jako pojedynczy pod. Jego działanie sprawdzono zarówno za pomocą `kubectl`, jak i Kubernetes Dashboard.

![Pod widoczny w kubectl](screenshots/S3_Z10_07_pod-kubectl.png)

![Pod widoczny w Dashboard](screenshots/S3_Z10_08_pod-dashboard.png)

Za pomocą `port-forward` przekierowano port poda na port lokalny i potwierdzono dostęp do aplikacji przy użyciu `curl`.

![Port forwarding do poda](screenshots/S3_Z10_09_port-forward-i-komunikacja.png)

## Deployment i Service

Ręczne uruchomienie aplikacji zastąpiono plikiem `deployment.yaml`. Początkowo Deployment posiadał jedną replikę, a następnie zwiększono ich liczbę do czterech. Stan wdrożenia sprawdzono poleceniem `kubectl rollout status`.

![Deployment z czterema replikami](screenshots/S3_Z10_10_deployment-4-repliki-rollout.png)

Deployment został następnie udostępniony jako Service typu `ClusterIP`. Port serwisu przekierowano na lokalny port i ponownie sprawdzono działanie aplikacji.

![Komunikacja przez Service](screenshots/S3_Z10_11_serwis-port-forward.png)

## Wersje obrazu i skalowanie

Przygotowano drugą wersję obrazu `lab10-nginx:v2` oraz celowo wadliwą wersję `lab10-nginx:bad`. Wadliwy obraz kończył działanie kodem błędu `1`.

![Wadliwy obraz kontenera](screenshots/S3_Z10_12_wadliwy-obraz.png)

Następnie sprawdzono skalowanie Deploymentu. Liczbę replik zwiększono do ośmiu.

![Skalowanie do ośmiu replik](screenshots/S3_Z10_13_skalowanie-do-8-replik.png)

Deployment zmniejszono następnie do jednej repliki.

![Skalowanie do jednej repliki](screenshots/S3_Z10_14_skalowanie-do-1-repliki.png)

Sprawdzono również skalowanie do zera, co spowodowało zatrzymanie wszystkich podów należących do Deploymentu.

![Skalowanie do zera](screenshots/S3_Z10_15_skalowanie-do-0-replik.png)

Na końcu ponownie zwiększono liczbę replik do czterech.

![Ponowne skalowanie do czterech replik](screenshots/S3_Z10_16_skalowanie-z-0-do-4-replik.png)

## Aktualizacje i rollback

Deployment zaktualizowano z obrazu `lab10-nginx:v1` do `lab10-nginx:v2`. Kubernetes wykonał aktualizację i uruchomił nowe pody.

![Aktualizacja obrazu do v2](screenshots/S3_Z10_17_aktualizacja-do-v2.png)

Następnie ponownie zastosowano starszą wersję `v1`.

![Powrót do obrazu v1](screenshots/S3_Z10_18_powrot-do-v1.png)

Kolejnym testem było zastosowanie obrazu `lab10-nginx:bad`. Nowe pody nie były w stanie poprawnie się uruchomić i przechodziły w stany `Error` oraz `CrashLoopBackOff`. Polecenie sprawdzające rollout zakończyło się przekroczeniem limitu czasu.

![Wdrożenie wadliwego obrazu](screenshots/S3_Z10_19_wadliwy-obraz.png)

Za pomocą historii rolloutów sprawdzono wcześniejsze rewizje Deploymentu. Poszczególne rewizje odpowiadały obrazom `v2`, `v1` oraz `bad`.

![Historia wdrożenia](screenshots/S3_Z10_20_historia-wdrozenia.png)

Wadliwe wdrożenie cofnięto poleceniem `kubectl rollout undo`. Po rollbacku Deployment ponownie działał na obrazie `lab10-nginx:v1` i posiadał cztery gotowe repliki.

![Rollback wdrożenia](screenshots/S3_Z10_21_rollout-undo.png)

## Kontrola wdrożenia

Przygotowano skrypt `check-deployment.sh`, który sprawdza, czy Deployment zakończy rollout w czasie maksymalnie 60 sekund. Dla poprawnego wdrożenia skrypt zakończył się powodzeniem.

![Skrypt kontroli wdrożenia](screenshots/S3_Z10_22_skrypt-kontroli-wdrozenia.png)

## Strategie wdrożenia

Pierwszą sprawdzoną strategią było `Recreate`. Podczas aktualizacji wszystkie stare pody zostały najpierw zatrzymane, a dopiero później uruchomiono nowe.

![Strategia Recreate](screenshots/S3_Z10_23_strategia-recreate.png)

Następnie sprawdzono `RollingUpdate` z parametrami `maxUnavailable: 2` oraz `maxSurge: 50%`. Podczas aktualizacji stare i nowe pody przez pewien czas działały równocześnie.

![Strategia Rolling Update](screenshots/S3_Z10_24_strategia-rolling-update.png)

Na końcu przygotowano wdrożenie Canary. Utworzono trzy repliki stabilnej wersji `v1` oraz jedną replikę nowej wersji `v2`. Oba Deploymenty korzystały ze wspólnej etykiety i były dostępne przez jeden Service.

![Strategia Canary](screenshots/S3_Z10_25_strategia-canary.png)

Krótko porównując strategie: `Recreate` usuwa stare pody przed uruchomieniem nowych, `RollingUpdate` stopniowo zastępuje stare pody nowymi, natomiast `Canary` pozwala jednocześnie uruchomić wersję stabilną i nową wersję aplikacji.

## Zajęcia 11 – Kubernetes (2)

Podczas zajęć kontynuowano pracę z Kubernetes. Przygotowano deployment wykorzystujący wcześniej utworzony obraz `lab10-nginx:v1`. Początkowo uruchomiono 36 replik aplikacji, a następnie sprawdzono różne sposoby udostępniania aplikacji oraz skalowania wdrożenia.

Deployment został zdefiniowany w pliku `deployment.yaml` z liczbą `36` replik. Po zastosowaniu manifestu wszystkie pody zostały poprawnie uruchomione.

![Deployment z 36 podami](screenshots/S3_Z11_01_deployment-36-podow.png)

### Eksponowanie pojedynczego poda

W pierwszej kolejności udostępniono bezpośrednio jeden wybrany pod za pomocą polecenia `port-forward`. Przekierowano port `18081` hosta na port `80` kontenera. Poprawność działania sprawdzono wykonując zapytanie HTTP do lokalnego portu.

![Eksponowanie pojedynczego poda](screenshots/S3_Z11_02_eksponowanie-jednego-poda.png)

### Eksponowanie deploymentu

Następnie wykonano przekierowanie portu bezpośrednio do deploymentu `lab11-nginx`. W tym przypadku nie wskazywano konkretnego poda, tylko cały deployment.

![Eksponowanie deploymentu](screenshots/S3_Z11_03_eksponowanie-deploymentu.png)

### Service utworzony poleceniem `kubectl expose`

Kolejnym sposobem udostępnienia aplikacji było utworzenie serwisu typu `ClusterIP` za pomocą polecenia:

```bash
minikube kubectl -- expose deployment lab11-nginx \
  --name=lab11-nginx-service \
  --type=ClusterIP \
  --port=80 \
  --target-port=80
```

Dostęp do utworzonego serwisu sprawdzono przez `port-forward` oraz zapytanie HTTP.

![Service utworzony przez kubectl expose](screenshots/S3_Z11_04_service-kubectl-expose.png)

### Service utworzony z pliku YAML

Następnie ten sam rodzaj serwisu utworzono deklaratywnie za pomocą pliku `service.yaml`. Manifest zawierał selektor `app: lab11-nginx`, dzięki któremu Service kierował ruch do podów należących do deploymentu.

Po zastosowaniu pliku YAML ponownie sprawdzono działanie aplikacji przez przekierowanie portu.

![Service utworzony z pliku YAML](screenshots/S3_Z11_05_service-yaml.png)

### Skalowanie za pomocą polecenia `scale`

Pierwsze skalowanie wykonano za pomocą polecenia:

```bash
minikube kubectl -- scale deployment lab11-nginx --replicas=12
```

Liczba replik została zmniejszona z 36 do 12. Kubernetes zakończył nadmiarowe pody, pozostawiając 12 aktywnych replik.

![Skalowanie poleceniem scale](screenshots/S3_Z11_06_scale-command.png)

### Skalowanie za pomocą nowego pliku YAML

Drugie skalowanie wykonano deklaratywnie. Utworzono plik `deployment-scaled.yaml`, w którym zmieniono liczbę replik z `36` na `20`.

Różnicę pomiędzy manifestami pokazano za pomocą polecenia:

```bash
diff -u deployment.yaml deployment-scaled.yaml
```

Najważniejsza zmiana wyglądała następująco:

```diff
-  replicas: 36
+  replicas: 20
```

Po zastosowaniu nowego manifestu deployment został przeskalowany do 20 działających replik.

![Skalowanie za pomocą pliku YAML](screenshots/S3_Z11_07_scale-yaml.png)

### Sprawdzenie rozdzielania ruchu pomiędzy pody

W ramach zadania dodatkowego sprawdzono, do których podów trafiają żądania kierowane do serwisu. Do adresu `ClusterIP` wysłano serię zapytań HTTP, a następnie przeanalizowano logi nginx.

W logach widoczne były odpowiedzi pochodzące z wielu różnych podów, co potwierdziło, że Service rozdziela ruch pomiędzy repliki deploymentu.

![Rozdzielanie ruchu pomiędzy pody](screenshots/S3_Z11_08_load-balancing-pody.png)

W ramach zajęć przećwiczono więc udostępnianie aplikacji na poziomie pojedynczego poda, deploymentu oraz Service, a także dwa
