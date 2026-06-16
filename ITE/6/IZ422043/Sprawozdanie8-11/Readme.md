# Sprawozdanie podsumowujące – Automatyzacja wdrożeń i zarządzanie aplikacjami w środowiskach Linux oraz Kubernetes

# 1. Cel realizowanych ćwiczeń

Celem zrealizowanych ćwiczeń było poznanie nowoczesnych metod automatyzacji administracji systemami, wdrażania aplikacji oraz zarządzania środowiskami kontenerowymi. W ramach zajęć wykorzystano narzędzia Ansible, Kickstart, Docker, Podman oraz Kubernetes. Ćwiczenia obejmowały zarówno automatyzację konfiguracji systemów operacyjnych, jak i wdrażanie, skalowanie oraz udostępnianie aplikacji działających w kontenerach.

# 2. Zakres wykonanych prac
## 2.1. Automatyzacja administracji przy użyciu Ansible

Przygotowano środowisko składające się z kilku maszyn wirtualnych, pomiędzy którymi skonfigurowano komunikację SSH opartą o klucze publiczne. Utworzono plik inventory definiujący zarządzane hosty, a następnie wykonano szereg operacji administracyjnych za pomocą playbooków Ansible.

W ramach ćwiczenia:

- zweryfikowano komunikację pomiędzy hostami,
- kopiowano pliki na zdalne maszyny,
- aktualizowano pakiety systemowe,
- restartowano usługi,
- analizowano zachowanie systemu w przypadku niedostępności hosta,
- wdrażano aplikację w kontenerze Docker,
- utworzono własną rolę Ansible umożliwiającą automatyzację procesu wdrożeniowego.

Szczególną uwagę zwrócono na mechanizm idempotencji, dzięki któremu wielokrotne uruchomienie tych samych zadań nie powodowało zbędnych zmian w systemie.

## 2.2. Automatyczna instalacja systemu Fedora z wykorzystaniem Kickstart

Drugie ćwiczenie dotyczyło przygotowania całkowicie nienadzorowanej instalacji systemu Fedora.

Na podstawie wygenerowanego pliku Kickstart skonfigurowano:

- źródło pakietów instalacyjnych,
- ustawienia sieciowe,
- nazwę hosta,
- użytkownika administracyjnego,
- automatyczne partycjonowanie i formatowanie dysku,
- automatyczny restart po zakończeniu instalacji.

W sekcji %packages zdefiniowano wymagane pakiety, natomiast w sekcji %post przygotowano skrypty odpowiedzialne za pobranie oraz uruchomienie aplikacji webowej w kontenerze Podman.

Dodatkowo utworzono usługę systemd zapewniającą automatyczne uruchamianie aplikacji po każdym restarcie systemu.

Efektem ćwiczenia było uzyskanie w pełni automatycznego procesu instalacji i konfiguracji systemu operacyjnego bez konieczności interwencji użytkownika.

# 2.3. Wdrażanie aplikacji w Kubernetes

Kolejnym etapem było poznanie podstaw działania platformy Kubernetes na lokalnym klastrze Minikube.

W ramach ćwiczenia:

- uruchomiono klaster Kubernetes,
- skonfigurowano dostęp do dashboardu administracyjnego,
- utworzono i uruchomiono pojedynczy pod z serwerem Nginx,
- zbudowano własny obraz kontenera,
- wdrożono aplikację za pomocą Deploymentu,
- utworzono Service zapewniający dostęp do aplikacji,
- przeprowadzono skalowanie wdrożenia,
- wykonano aktualizację aplikacji do nowej wersji,
- przetestowano mechanizm rollback,
- przeanalizowano zachowanie klastra po wdrożeniu błędnej wersji aplikacji.

Ćwiczenie pozwoliło zapoznać się z podstawowymi mechanizmami orkiestracji kontenerów oraz sposobami zapewniania wysokiej dostępności aplikacji.

# 2.4. Eksponowanie aplikacji i skalowanie w Kubernetes

Ostatnie ćwiczenie koncentrowało się na sposobach udostępniania aplikacji działających w Kubernetes oraz zarządzaniu liczbą replik.

Przygotowano Deployment zawierający dużą liczbę instancji aplikacji webowej, a następnie przetestowano różne metody dostępu:

- bezpośrednio do pojedynczego poda,
- poprzez Deployment,
- poprzez Service typu ClusterIP.

Dodatkowo wykonano skalowanie aplikacji:

- metodą imperatywną przy użyciu polecenia kubectl scale,
- metodą deklaratywną poprzez modyfikację plików YAML.

Zaobserwowano automatyczne dostosowywanie liczby uruchomionych podów do wartości zadeklarowanej w konfiguracji Deploymentu.

# 3. Wnioski

Przeprowadzone ćwiczenia pokazały, że automatyzacja stanowi kluczowy element współczesnej administracji systemami i procesów DevOps. Narzędzia takie jak Ansible oraz Kickstart znacząco upraszczają konfigurację środowisk i eliminują konieczność wykonywania wielu powtarzalnych czynności ręcznie.

Z kolei technologie kontenerowe i Kubernetes umożliwiają efektywne wdrażanie, aktualizowanie oraz skalowanie aplikacji przy zachowaniu wysokiej dostępności usług. Mechanizmy Deploymentów, Service'ów, automatycznego utrzymywania replik oraz rollbacku zwiększają niezawodność wdrożeń i ułatwiają zarządzanie aplikacjami.

Ćwiczenia pozwoliły zdobyć praktyczne doświadczenie w zakresie automatyzacji infrastruktury, konteneryzacji oraz orkiestracji aplikacji, które są obecnie jednymi z najważniejszych obszarów nowoczesnej administracji systemami informatycznymi.