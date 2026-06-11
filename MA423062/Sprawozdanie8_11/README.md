# Sprawozdanie z laboratoriów 8-11 - DevOps

*Opis wykonania zadań na podstawie rozmów i zrzutów ekranu*

| Pole | Wartość |
| --- | --- |
| Autor | Mateusz Adamczak |
| Repozytorium | InzynieriaOprogramowaniaAGH/MDO2026s_ITE |
| Gałąź robocza | MA423062 |
| Projekt bazowy | jq |
| Zakres | Lab 8: Ansible/Jenkins, Lab 9: Kickstart i runtime jq, Lab 10: Kubernetes rollout/rollback/canary, Lab 11: minikube/kubectl oraz skalowanie |

## Wprowadzenie

Celem laboratoriów 8-11 było przejście przez kilka etapów typowego procesu DevOps: automatyzację konfiguracji maszyn, przygotowanie instalacji systemu i środowiska uruchomieniowego, a następnie wdrażanie aplikacji w Kubernetes. Pracowałem na repozytorium MDO2026s_ITE na gałęzi MA423062, a aplikacją wykorzystywaną w zadaniach był projekt jq. W sprawozdaniu opisuję nie tylko końcowy stan, lecz także sposób dojścia do rozwiązania, ponieważ część screenshotów pokazuje błędne próby, naprawę konfiguracji i dopiero potem wynik poprawny.

Najważniejszy wniosek z całego zakresu jest taki, że laboratoria nie były oddzielnymi ćwiczeniami, tylko układały się w ciąg: najpierw konfiguracja i testowanie środowiska, potem automatyczna instalacja oraz przygotowanie runtime, a na końcu kontrolowane wdrożenie, skalowanie i wycofywanie zmian. Screeny zostały umieszczone przy tych fragmentach, które bezpośrednio dokumentują wykonany krok.

## Laboratorium 8 - Ansible, playbooki i integracja z Jenkins

**Cel laboratorium.** W labie 8 skonfigurowałem środowisko Ansible tak, aby host docelowy był opisany w inventory, możliwy do sprawdzenia przez moduł ping, a następnie zarządzany przez playbook. Druga część pracy polegała na połączeniu tego z istniejącą automatyzacją w repozytorium, czyli z plikami YAML/Jenkins i testami wykonywanymi po zmianach.

Pierwszym etapem było przygotowanie pliku inventory. To nie jest tylko lista nazw maszyn; inventory wiąże hosta logicznego z adresem, użytkownikiem i sposobem połączenia. Dopiero po poprawnym inventory można było sensownie uruchamiać moduły Ansible. Na podstawie screena widać, że host został zdefiniowany jako cel dla poleceń Ansible, a późniejszy test ping potwierdził, że połączenie działa.

![Plik inventory z hostem docelowym używanym przez Ansible.](assets/image1.png)

*Rys. 1. Plik inventory z hostem docelowym używanym przez Ansible.*

![Test połączenia Ansible ping zakończony poprawną odpowiedzią hosta.](assets/image2.png)

*Rys. 2. Test połączenia Ansible ping zakończony poprawną odpowiedzią hosta.*

Po potwierdzeniu połączenia uruchomiłem playbook. Screen z wynikiem playbooka pokazuje przejście zadań i podsumowanie zmian. Istotne jest rozróżnienie statusów: ok oznacza, że zadanie zostało wykonane lub stan był już zgodny z oczekiwanym, changed oznacza realną zmianę na hoście, a failed powinno natychmiast zatrzymać dalszą ścieżkę wdrożeniową. Dzięki temu Ansible nadaje się nie tylko do instalowania pakietów, ale też do kontroli powtarzalności konfiguracji.

![Poprawne wykonanie playbooka i podsumowanie zadań Ansible.](assets/image3.png)

*Rys. 3. Poprawne wykonanie playbooka i podsumowanie zadań Ansible.*

Następnie zmieniłem konfigurację plików YAML w repozytorium. Celem było ustawienie automatyzacji tak, aby pipeline korzystał z przygotowanych kroków i przechodził przez testy. Screen z plikiem main.yml pokazuje etap, w którym konfiguracja przestała być pojedynczym ręcznym poleceniem, a stała się częścią wersjonowanego procesu. To jest praktyczny sens CI/CD: konfiguracja procesu jest w repozytorium, więc można ją odtworzyć i przejrzeć tak samo jak kod aplikacji.

![Zmodyfikowany plik main.yml jako element automatyzacji pipeline.](assets/image4.png)

*Rys. 4. Zmodyfikowany plik main.yml jako element automatyzacji pipeline.*

Końcowy test potwierdził, że po zmianach ścieżka przechodzi poprawnie. W tym labie istotne było też to, że wcześniejsze próby z błędami nie były bezużyteczne: pozwalały sprawdzić, czy pipeline rzeczywiście wykrywa problem. Poprawny wynik testów jest więc wartościowy dopiero wtedy, gdy wiadomo, że w razie błędnej konfiguracji proces potrafi się zatrzymać.

![Poprawne przejście testów po konfiguracji automatyzacji.](assets/image5.png)

*Rys. 5. Poprawne przejście testów po konfiguracji automatyzacji.*

**Wnioski z labu 8.** Najważniejszy wniosek jest taki, że Ansible wymaga najpierw poprawnego modelu hostów i łączności, a dopiero potem ma sens pisanie właściwych playbooków. Sam playbook powinien być idempotentny, bo w automatyzacji konfiguracji nie chodzi o jednorazowe wykonanie komendy, lecz o doprowadzenie systemu do opisanego stanu. Integracja z Jenkins/YAML pokazuje, że konfiguracja infrastruktury i procesu CI powinna być wersjonowana razem z kodem, bo inaczej trudno odtworzyć, co dokładnie zostało wykonane.

## Laboratorium 9 - Kickstart, sieć, transfer plików i runtime dla jq

**Cel laboratorium.** W labie 9 skupiłem się na automatyzacji instalacji i przygotowaniu środowiska uruchomieniowego. Wykorzystałem konfigurację sieci, przesyłanie plików przez scp, modyfikację parametrów startowych oraz uruchomienie jq w przygotowanym runtime.

Początek pracy dotyczył konfiguracji sieci. Screen z nmcli pokazuje, że sprawdzałem połączenia sieciowe oraz parametry interfejsu. To było konieczne, ponieważ Kickstart i pobieranie plików instalacyjnych są bardzo wrażliwe na poprawny adres, bramę, DNS oraz dostępność źródła pliku konfiguracyjnego. Błąd w tej warstwie powodowałby, że instalator nie doszedłby nawet do właściwej części automatyzacji.

![Sprawdzenie konfiguracji sieci przez nmcli przed pracą z Kickstart.](assets/image6.png)

*Rys. 6. Sprawdzenie konfiguracji sieci przez nmcli przed pracą z Kickstart.*

Następnie przenosiłem wymagane pliki pomiędzy środowiskami. Screen scp dokumentuje etap, w którym lokalne pliki konfiguracyjne zostały przeniesione do maszyny podczas instalacji. W praktyce scp był tutaj prostym sposobem na dostarczenie pliku Kickstart bez ręcznego przepisywania ich w maszynie wirtualnej.

![Transfer plików przez scp do środowiska instalacyjnego.](assets/image7.png)

*Rys. 7. Transfer plików przez scp do środowiska instalacyjnego.*

Kolejny etap polegał na zmianie parametrów rozruchowych. W Kickstart sam plik konfiguracyjny nie wystarczy; instalator musi jeszcze wiedzieć, gdzie go szukać. Screen z modyfikacją parametrów jądra pokazuje dopisanie informacji potrzebnych do automatycznego pobrania konfiguracji. Ten krok jest krytyczny, bo literówka w ścieżce lub adresie powoduje przejście instalatora w tryb ręczny.

![Modyfikacja parametrów startowych instalatora pod automatyczne użycie Kickstart.](assets/image8.png)

*Rys. 8. Modyfikacja parametrów startowych instalatora pod automatyczne użycie Kickstart.*

Po przygotowaniu instalacji sprawdziłem działanie projektu jq w środowisku docelowym. Screeny z jq pokazują, że aplikacja została uruchomiona i zwróciła poprawny wynik. Osobno sprawdzałem też runtime, czyli środowisko potrzebne do uruchomienia programu bez pełnego zestawu narzędzi budujących. To jest ważne rozdzielenie: obraz lub środowisko build może być cięższe, ale runtime powinien zawierać tylko to, co jest potrzebne do wykonania programu.

![Poprawne uruchomienie jq po przygotowaniu środowiska.](assets/image9.png)

*Rys. 9. Poprawne uruchomienie jq po przygotowaniu środowiska.*

![Uruchomienie jq w środowisku runtime.](assets/image10.png)

*Rys. 10. Uruchomienie jq w środowisku runtime.*

**Wnioski z labu 9.** Automatyczna instalacja nie sprowadza się do samego pliku Kickstart. Działa dopiero wtedy, gdy poprawne są trzy warstwy: sieć, dostępność pliku konfiguracyjnego i parametry przekazane instalatorowi. Drugi praktyczny wniosek dotyczy runtime: środowisko uruchomieniowe powinno być możliwie proste, bo wtedy łatwiej wykryć brakujące zależności i uniknąć sytuacji, w której program działa tylko dlatego, że przypadkiem uruchamiamy go w zbyt bogatym środowisku deweloperskim.

## Laboratorium 10 - Kubernetes: deployment, service, skalowanie, rollout i canary

**Cel laboratorium.** W labie 10 przeniosłem pracę na Kubernetes. Celem było uruchomienie lokalnego klastra przez minikube, przygotowanie deploymentu i service, sprawdzenie działania aplikacji przez curl, a następnie przećwiczenie skalowania, rollout/rollback oraz wdrożenia canary.

Najpierw uruchomiłem minikube i sprawdziłem stan klastra. Screeny z minikube i kubectl pokazują, że lokalny klaster był dostępny, a polecenia kubectl mogły komunikować się z API Kubernetes. To jest warunek startowy dla dalszych zadań: bez działającego klastra pliki YAML są tylko konfiguracją, której nie ma gdzie zastosować.

![Uruchomienie lokalnego środowiska minikube.](assets/image11.png)

*Rys. 11. Uruchomienie lokalnego środowiska minikube.*

![Sprawdzenie statusu środowiska Kubernetes.](assets/image12.png)

*Rys. 12. Sprawdzenie statusu środowiska Kubernetes.*

Właściwa aplikacja została opisana deklaratywnie w plikach YAML. Deployment określał obraz, liczbę replik i etykiety podów, a Service dawał stabilny punkt dostępu do grupy podów. Zależność między nimi opierała się na selectorach: Service kierował ruch do tych podów, których etykiety pasowały do jego selektora. To było jedno z najważniejszych miejsc labu, ponieważ błąd w label albo selector powoduje, że Service istnieje, ale nie ma backendów.

![Plik deployment.yaml definiujący aplikację i jej repliki.](assets/image13.png)

*Rys. 13. Plik deployment.yaml definiujący aplikację i jej repliki.*

![Plik service.yaml wystawiający aplikację przez stabilny Service.](assets/image14.png)

*Rys. 14. Plik service.yaml wystawiający aplikację przez stabilny Service.*

Po zastosowaniu konfiguracji obserwowałem pody i repliki. Skalowanie pokazało, że nie tworzę ręcznie wielu kontenerów, tylko zmieniam oczekiwany stan Deploymentu. Kubernetes sam tworzy lub usuwa pody, aby stan rzeczywisty zgadzał się z deklaracją. Dodatkowo sprawdziłem zachowanie dla zera replik i późniejszego zwiększenia liczby podów.

![Lista podów po zwiększeniu liczby replik.](assets/image15.png)

*Rys. 15. Lista podów po zwiększeniu liczby replik.*

![Potwierdzenie poprawnego działania przy większej liczbie replik.](assets/image16.png)

*Rys. 16. Potwierdzenie poprawnego działania przy większej liczbie replik.*

Następnie celowo wprowadziłem scenariusz błędny, aby sprawdzić mechanizm rollout/rollback. Screen z błędnym podem pokazuje, że niepoprawna wersja obrazu lub konfiguracji nie przechodzi poprawnie. Potem wykonałem rollback i przywróciłem działającą wersję. To jest realny mechanizm bezpieczeństwa: w Kubernetes nie wystarczy umieć wdrożyć nową wersję, trzeba też umieć ją szybko wycofać, gdy health check, obraz albo start kontenera nie działają.

![Błędny stan poda po nieudanym wdrożeniu.](assets/image17.png)

*Rys. 17. Błędny stan poda po nieudanym wdrożeniu.*

![Udany rollback do działającej wersji deploymentu.](assets/image18.png)

*Rys. 18. Udany rollback do działającej wersji deploymentu.*

Ostatni etap dotyczył wdrożenia canary. W tym wariancie część ruchu trafia do nowej wersji, a część do starej. Test curl wykonywany kilka razy pozwalał sprawdzić, czy odpowiedzi pochodzą z różnych wersji aplikacji. To pokazuje praktyczne znaczenie etykiet i selektorów: przez odpowiednie opisanie podów można kontrolować, które wersje aplikacji obsługuje jeden Service.

![Test curl potwierdzający działanie scenariusza canary.](assets/image19.png)

*Rys. 19. Test curl potwierdzający działanie scenariusza canary.*

**Wnioski z labu 10.** Najważniejszy wniosek jest taki, że Kubernetes zarządza stanem zadeklarowanym, a nie pojedynczymi komendami uruchamiającymi kontenery. Deployment odpowiada za utrzymanie liczby replik i aktualizację wersji, Service daje stabilny dostęp niezależny od nazw konkretnych podów, a rollout/rollback zabezpiecza przed błędnymi wdrożeniami. Canary ma sens dopiero wtedy, gdy rozumiem relację między etykietami podów i selektorem Service, bo to one decydują o tym, gdzie faktycznie trafia ruch.

## Laboratorium 11 - minikube, kubectl, pod, deployment, service i skalowanie

**Cel laboratorium.** Lab 11 był samodzielnym przejściem przez podstawowy cykl pracy w Kubernetes: instalacja lub naprawa kubectl, utworzenie poda z nginx, przejście do Deploymentu, wystawienie aplikacji przez Service, a następnie skalowanie liczby replik i zapis konfiguracji w plikach YAML.

Na początku pojawił się problem techniczny: polecenie kubectl nie było dostępne w systemie. To oznaczało brak klienta Kubernetes w PATH, a nie błąd samego klastra. Po doinstalowaniu kubectl mogłem wykonywać polecenia diagnostyczne i pracować z minikube. Screen dokumentuje etap, w którym kubectl działał już poprawnie i można było przejść do zadań właściwych.

![Naprawione środowisko kubectl i możliwość wykonywania poleceń Kubernetes.](assets/image20.png)

*Rys. 20. Naprawione środowisko kubectl i możliwość wykonywania poleceń Kubernetes.*

Pierwszym uruchomionym obiektem był prosty pod z nginx. Ten etap był potrzebny, żeby zobaczyć najniższy poziom uruchomienia aplikacji w Kubernetes. Pod sam w sobie jest jednak niewygodny jako docelowy sposób wdrażania, bo nie opisuje mechanizmu samonaprawy, aktualizacji i skalowania tak dobrze jak Deployment.

![Uruchomienie nginx jako prostego poda testowego.](assets/image21.png)

*Rys. 21. Uruchomienie nginx jako prostego poda testowego.*

Dalsza część ćwiczenia polegała na skalowaniu. Najpierw zwiększyłem liczbę replik, a potem zmniejszałem ją do mniejszych wartości. Screeny pokazują, że po zmianie replik Kubernetes tworzył lub usuwał pody. To nie jest ręczne uruchamianie wielu kontenerów, tylko zmiana oczekiwanego stanu kontrolera Deployment.

![Skalowanie deploymentu i obserwacja zmian w liczbie podów.](assets/image22.png)

*Rys. 22. Skalowanie deploymentu i obserwacja zmian w liczbie podów.*

![Stan po ustawieniu ośmiu replik.](assets/image23.png)

*Rys. 23. Stan po ustawieniu ośmiu replik.*

![Stan po zmniejszeniu liczby replik do trzech.](assets/image24.png)

*Rys. 24. Stan po zmniejszeniu liczby replik do trzech.*

Na końcu przygotowałem wersję deklaratywną przez pliki YAML. Deployment definiował obraz, etykiety i liczbę replik, a Service typu ClusterIP wskazywał na pody po etykiecie. Ten etap jest najbardziej zgodny z podejściem DevOps, bo zamiast odtwarzać konfigurację z historii terminala można zapisać ją w repozytorium i zastosować ponownie komendą kubectl apply.

![Deklaratywny Deployment dla lab11-nginx-yaml.](assets/image25.png)

*Rys. 25. Deklaratywny Deployment dla lab11-nginx-yaml.*

![Deklaratywny Service typu ClusterIP dla aplikacji z labu 11.](assets/image26.png)

*Rys. 26. Deklaratywny Service typu ClusterIP dla aplikacji z labu 11.*

**Wnioski z labu 11.** Lab 11 pokazał różnicę między trzema poziomami pracy: pojedynczy Pod uruchamia jedną instancję, Deployment utrzymuje żądaną liczbę instancji, a Service daje stabilny dostęp do grupy podów. Problem z brakiem kubectl był też praktycznym przypomnieniem, że narzędzia klienckie są częścią środowiska DevOps; bez nich poprawna konfiguracja klastra nie wystarczy. Najlepszym końcowym stanem jest konfiguracja zapisana w YAML, bo daje powtarzalność i nadaje się do commita w repozytorium.

## Podsumowanie końcowe

Rozwiązanie laboratoriów 8-11 pokazało pełniejszy obraz pracy DevOps niż pojedyncze uruchamianie kontenerów. W labie 8 automatyzowałem konfigurację hosta i pipeline przez Ansible oraz YAML. W labie 9 przygotowałem instalację i środowisko uruchomieniowe tak, aby aplikacja jq działała w kontrolowanych warunkach. W labach 10 i 11 przeszedłem do Kubernetes, gdzie najważniejsze było już nie samo uruchomienie programu, lecz utrzymywanie oczekiwanego stanu, skalowanie, wystawianie usługi i wycofywanie błędnych zmian.

Najbardziej praktyczny wniosek jest taki, że każde narzędzie rozwiązuje inny problem. Ansible dobrze nadaje się do konfiguracji maszyn i powtarzalnego wykonania zadań. Kickstart automatyzuje instalację systemu, ale zależy od poprawnej sieci i dostępu do plików. Docker/runtime pomaga oddzielić budowanie od uruchamiania. Kubernetes zarządza aplikacją jako zbiorem deklarowanych obiektów, a nie jako jednorazowym procesem. Dopiero połączenie tych elementów daje sensowny proces DevOps: zmiana jest opisana w repozytorium, wykonywana automatycznie, testowana, wdrażana i możliwa do cofnięcia.
