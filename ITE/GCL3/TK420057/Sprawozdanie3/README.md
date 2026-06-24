# Sprawozdanie z lab 8-11

# Lab 8 - Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

## Instalacja zarządcy Ansible

Utworzono drugą maszynę wirtualną z systemem fedora. Zapewniono obecność programu tar i serwera OpenSSH.
Nadano maszynie hostname ansible-target oraz utworzono w systemie użytkownika ansible.

Następnie na głównej maszynie wirtualnej zainstalowano oprogramowanie Ansible z repozytorium dystrybucji.

![alt text](Obraz1.png)

Wygenerowano i wymieniono klucze SSH między użytkownikiem w głównej maszynie wirtualnej, a użytkownikiem ansible tak, by logowanie było bezhasłowe.

![alt text](Obraz2.png)

## Konfiguracja DNS i sprawdzenie łączności

Za pomocą narzędzia `hostnamectl` ustawiono przewidywalne nazwy dla maszyn wirtualnych. Następnie dokonano statycznego mapowania nazw na adresy IP poprzez edycję plików `/etc/hosts` na obu systemach.

* Konfiguracja na maszynie `ansible-manager`:

![alt text](Obraz3.png)

* Konfiguracja na maszynie `ansible-target`:

![alt text](Obraz4.png)

Po skonfigurowaniu lokalnego rozwiązywania nazw, zweryfikowano łączność sieciową za pomocą narzędzia `ping`. Maszyny bezproblemowo odnajdują się w sieci lokalnej przy użyciu aliasów:

* Test z poziomu `ansible-manager` do `ansible-target`:

![alt text](Obraz5.png)

* Test z poziomu `ansible-target` do `ansible-manager`:

![alt text](Obraz6.png)

Wdrożenie automatyzacji za pomocą Ansible wymaga bezhasłowego dostępu do zarządzanych węzłów. W tym celu na maszynie dyrygencie wygenerowano parę kluczy SSH, a nastepnie przesłano klucz publiczy na maszynę docelową przy pomocy polecenia:
```bash
ssh-copy-id ansible@ansible-target
```

## Plik inwentaryzacji oraz test modułu ping

W katalogu utworzono plik `inventory.ini`, w którym odseparowano rolę maszyn.

```ini
[Orchestrators]
ansible-manager ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible
```

Ostatecznym testem poprawności konfiguracji było wywołanie modułu `ping` z poziomu Ansible dla wszsytkich maszyn.

![alt text](Obraz7.png)

## Zdalne wywoływanie procedur

W pierwszej kolejności uruchomiono uproszczoną wersję `playbook.yaml`, która jedynie wykonywała jedynie ping do wszytkich maszyn oraz kopiowanie pliku inwentaryzacji na maszynę `Endpoints`.

![alt text](Obraz8.png)

Status zadania kopiowania pliku przy pierwszym uruchomieniu dla maszyny ansible-target zmienił się na changed, a na maszynie ansible-manager został pominięty.

* Utworzony plik na maszynie ansible-target:*

![alt text](Obraz9.png)

Następnie ponownie wywołano playbooka oraz rozszerzono go o wykonanie aktualizacji pakietów systemowych oraz restar usług `sshd` i `rngd`. W przypadku ponownego uruchomienia moduł copy zweryfikował, że plik na maszynie docelowej ma identyczną zawartość co plik źródłowy. W rezultacie status zadania zmienił się na `OK`.

![alt text](Obraz10.png)

Wszystkie operacje zakończyły się sukcesem i poprawnie się wykonały. Następnie wykonano test w którym tą samą operacje spróbowano wykonać z wyłączonym serwerem SSH.

![alt text](Obraz11.png)

Podczas uruchomienia playbooka, na etapie zbierania faktów Ansible zgłosił krytyczny błąd połączenia. Mechanizm poprawnie przerwał dalsze wykonywanie działań dla niedostępnego hosta.

## Zarządzanie stworzonym artefaktem

Ostatnim etapem laboratorium było spakowanie kompletnego potoku budowania, testowania i wdrażania aplikacji w rolę Ansible o nazwie `deploy_app`. Strukturę roli zainicjalizowano poleceniem `ansible-galaxy role init deploy_app` i umieszczono w katalogu lab8. Główny plik zadań `deploy_app/task/main.yaml` realizuję proces wdrażania dzieląc się na poszczególne bloki operacyjne. Na koniec wykonywany jest smoke test w celu potwierdzenia działania aplikacji oraz po weryfikacji następuje automatyczne czyszczenie środowiska docelowego.

Całość została wywołana za pomocą dedykowanego pliku `run_deploy_app.yaml`:

```yaml
- name: Uruchomienie pelnego wdrozenia za pomoca roli
  hosts: Endpoints
  become: true
  roles:
    - deploy_app
```

![alt text](Obraz12.png)

# Lab 9 - Pliki odpowiedzi dla wdrożeń nienadzorowanych

## Pobranie pliku odpowiedzi

Na nowo utworzonej maszynie wirtualnej UEFI zainstalowano system fedora w wersji 44 stosując instalator sieciowy (Everything Netinst). Po przejściu przez instalację przy użyciu polecenia `sudo cat /root/anaconda-ks.cfg` wyśweitlono treść pliku odpowiedzi i skopiowano do pliku ks.cfg.

![alt text](Obraz13.png)

![alt text](Obraz14.png)

Następnie wzbogacono plik o zdefiniowanie zewnętrznych repozytoriów sieciowych dla Fedory 44. Dodano flagi `text` (instalacja w trybie tekstowym) oraz `reboot` (automatyczny restart po zakończeniu pracy instalatora). Zapewniono możliwość czyszczenia nośnika i instalacji "w kółko" poprzez dyrektywę `clearpart --all --initlabel --drives=sda`.

## Instalacja nienadzorowana

Utworzono maszynę wirtualną w trybie UEFI. Podczas bootowania instalatora z płyty ISO Fedora Everything Netinst, w menu GRUB przekazano parametrem ścieżkę do przygotowanego pliku odpowiedzi za pomocą dyrektywy `inst.ks=hd:LABEL=OEMDRV:/ks.cfg`.

![alt text](Obraz15.png)

Instalator pomyślnie przetworzył plik `ks.cfg` tym samym wykonując cały proces w pełni bezobsługowo.

![alt text](Obraz16.png)

## Automatyczne wdrożenie aplikacji w sekcji `%post`

Ponieważ artefaktem w tym wariancie zadania była paczka dsytrybucyjna Pythona, w sekcji `%post` zaimplementowano pełny proces instalacji zależności oraz aplikacji. Po automatycznym restarcie maszyny wirtualnej, zweryfikowano stan środowiska oraz działania utworzonej i zajerestrowanej usługi systemowej o nazwie `flaskapp.service`.

![alt text](Obraz17.png)

![alt text](Obraz18.png)

# Lab 10 - Wdrażanie na zarządzalne kontenery: Kubernetes

## Inicjalizacja klastra Minikube

Jako lokalną implementację stosu Kubernetes wykorzystano narzędzie Minikube. Środowisko uruchomiono poleceniem `minikube start`. W celu spełnienia wymagań sprzętowych i zapewnienia stabilności klastra, przydzielono zasoby maszyny wirtualnej (2 CPU, minimalna przestrzeń pamięci RAM oraz sterownik Docker).

![alt text](Obraz19.png)

W celu uniknięcia konfliktów z ewentualnymi innymi instalacjami k8s, polecenia administracyjne wywoływano poprzez wbudowany wariant klastra: `minikube kubectl --`.

Poprwaność startu środowiska sprawdzono za pomocą poleceń:

```bash
minikube status
minikube kubectl -- get nodes
```

![alt text](Obraz20.png)

Następnie uruchomiono dashboard którego następnie otwarto w przeglądarce i przedstawiono łączność.

![alt text](Obraz21.png)

## Analiza posiadanego kontenera

Do wykonania tego zadania wykorzystano wcześniej sforkowane repozytorium Flaska na którym z wcześniejszych zajęć znajdowały się pliki Dockerfile. Jako bazę do wdrożenia w klastrze Kubernetes wykorzystano kontener produkcyjny.

W katalogu roboczym, zawierającym sklonowane (sforkowane) repozytorium aplikacji, zainicjalizowano czyste środowisko wirtualne `venv`. Następnie przy użyciu pliku definicji `Dockerfile.deploy`, zbudowano produkcyjny obraz kontenera.

![alt text](Obraz22.png)

![alt text](Obraz23.png)

## Uruchamianie oprogramowania

Następnie tak powstały obraz Docker załadowano do minikube i sprawdzono poprawność jego działania.

![alt text](Obraz24.png)

![alt text](Obraz25.png)

## Wdrożenie jako plik YML

Poprzednie wdrożenie zapisano do pliku `deployment.yaml`. Następnie przeprowadzono próbne wdrożenie za pomocą `minikube kubectl -- apply deployment.yaml`.

![alt text](Obraz26.png)

Następnie dokonano modyfikacji pliku wdrożenia i zmieniono ilość replik na 4 i ponownie rozpoczęto wdrożenie.

![alt text](Obraz27.png)

## Przygotowanie nowego obrazu

Wykorzystując to samo podejście co przy budowie piewrszego obrazu wykonano w ten sam sposób dwa kolejne obrazy z czego jeden był dobry, a drugi zwracał błąd.

![alt text](Obraz28.png)

## Zmiany w deploymencie i kontrola wdrożeń

Zgodnie z wytycznymi z polecenia przeprowadzono następujące aktualizację pliku YAML z wdrożeniem.

![alt text](Obraz29.png)

![alt text](Obraz30.png)

![alt text](Obraz31.png)

![alt text](Obraz32.png)

![alt text](Obraz33.png)

![alt text](Obraz34.png)

![alt text](Obraz35.png)

Skrypt weryfikujący `verify_deployment.sh`:

```bash
#!/bin/bash

echo "Rozpoczynam weryfikację wdrożenia..."

if minikube kubectl -- rollout status deployment/flask-deployment --timeout=60s; then
    echo "Sukces! Wdrożenie zakończyło się pomyślnie w 60sekund."
    exit 0
else
    echo "Błąd! Wdrożenie zakończyło sie niepowodzeniem w 60 sekund."
    exit 1
fi
```

## Strategie wdrożeń

Przygotowano wersje wdrożeń stosujące różne strategie.

-Recreate: Wszytkie pody starej wersji były jednocześnie usuwane, a dopiero po ich całkowitym zamknięciu klastry uruchamiały nową wersję.

-Rolling Update: Nowa wersja była wdrażana partiami przy jednoczesnym powolnym wygaszaniu starej wersji.

-Canary: Nowa wersja jest wprowadzana tylko dla pojedynczych przypadków.

![alt text](Obraz36.png)

![alt text](Obraz37.png)

![alt text](Obraz38.png)

![alt text](Obraz39.png)

![alt text](Obraz40.png)

# Lab 11 - Kubernetes (2)

## Eksponowanie

![alt text](Obraz41.png)

Dokonano wdrożenia web-serwera za pomocą deploymentu w pliku YAML. Wdrożono początkowo liczbę podów w ilości 36, a następnie weksponowano dostęp do web-serwera.

* Do jednego poda:*

![alt text](Obraz42.png)

![alt text](Obraz43.png)

* Do deploymentu:*

![alt text](Obraz44.png)

![alt text](Obraz45.png)

* Do serwisu (poleceniem i plikiem yaml):*

![alt text](Obraz46.png)

![alt text](Obraz47.png)

## Skalowanie

Przeskalowanie wdrożenia przy pomocy dyrektywy `scale` oraz nowego pliku yaml.

![alt text](Obraz48.png)

![alt text](Obraz49.png)

![alt text](Obraz50.png)
