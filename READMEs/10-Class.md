# Zajęcia 10

# Wdrażanie na zarządzalne kontenery: Kubernetes

## Zadania do wykonania
### Instalacja klastra Kubernetes
 * 🌵 Zaopatrz się w implementację stosu k8s: [minikube](https://minikube.sigs.k8s.io/docs/start/)
 * Przeprowadź instalację, wykaż poziom bezpieczeństwa instalacji
 * Zaopatrz się w polecenie `kubectl` w wariancie minikube, może być alias `minikubctl`, np. jeżeli masz już "prawdziwy" `kubectl`
 * Uruchom Kubernetes, pokaż działający kontener/worker
 * Zmityguj problemy wynikające z wymagań sprzętowych lub odnieś się do nich (względem dokumentacji)
 * 🌵 Uruchom *Dashboard*, otwórz w przeglądarce, przedstaw łączność
 * Zapoznaj się z koncepcjami funkcji wyprowadzanych przez Kubernetesa (*pod*, *deployment* itp)
 
### Analiza posiadanego kontenera
 * Zdefiniuj krok "Deploy" swojego projektu jako "Deploy to cloud":
   * Deploy zbudowanej aplikacji powinien się odbywać "na kontener"
   * Przygotuj obraz Docker ze swoją aplikacją - sprawdź, że Twój kontener Deploy na pewno **pracuje**, a nie natychmiast kończy pracę! 😎
   * Jeżeli wybrana aplikacja nie nadaje się do pracy w kontenerze i nie wyprowadza interfejsu funkcjonalnego przez sieć, wymień projekt na potrzeby tego zadania:
     * Optimum:
       * obraz-gotowiec (czyli po prostu inna aplikacja, np. `nginx`, ale **z dorzuconą własną konfiguracją**)
       * samodzielnie wybrany program i obraz zbudowany na jego bazie, niekoniecznie via *pipeline*
     * Plan max: obraz wygenerowany wskutek pracy *pipeline'u* (125% oceny)
   * Wykaż, że wybrana aplikacja pracuje jako kontener
   
### Uruchamianie oprogramowania
 * 🌵 Uruchom kontener ze swoją/wybraną aplikacją na stosie k8s
 * Kontener uruchomiony w minikubie zostanie automatycznie "ubrany" w *pod*.
 * ```minikube kubectl run -- <nazwa-jednopodowego-wdrożenia> --image=<obraz-docker> --port=<wyprowadzany port> --labels app=<nazwa-jednopodowego-wdrożenia>```
 * Przedstaw że *pod* działa (via Dashboard oraz `kubectl`)
 * Wyprowadź port celem dotarcia do eksponowanej funkcjonalności
 * ```kubectl port-forward pod/<nazwa-wdrożenia> <LO_PORT>:<PODMAIN_CNTNR_PORT> ```
 * Przedstaw komunikację z eskponowaną funkcjonalnością
 
### Przekucie wdrożenia manualnego w plik wdrożenia
 * Zapisz [wdrożenie](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) jako plik YML
 * Przeprowadź próbne wdrożenie przykładowego *deploymentu* (może być `nginx`)
   * Wykonaj ```kubectl apply``` na pliku
   * Upewnij się, że posiadasz wdrożenie zapisane jako plik
   * Wzbogać swój *deployment* o 4 repliki
   * Rozpocznij wdrożenie za pomocą ```kubectl apply```
   * Zbadaj stan za pomocą ```kubectl rollout status```
 * Wyeksponuj wdrożenie jako serwis
 * Przekieruj port do serwisu (tak, jak powyżej)

### Przygotowanie nowego obrazu
 * Zarejestruj nową wersję swojego obrazu `Deploy` (w Docker Hub lub [lokalnie+przeniesienie](https://minikube.sigs.k8s.io/docs/commands/image/#minikube-image-load))
 * Upewnij się, że dostępne są dwie co najmniej wersje obrazu z wybranym programem
 * Jeżeli potrzebny jest "gotowiec" z powodu problemów z `Deploy`, można użyć np `httpd`, ale powinien to być **własny** kontener: zmodyfikowany względem oryginału i opublikowany na własnym koncie Docker Hub.
 * Będzie to wymagać 
   * przejścia przez *pipeline* dwukrotnie, lub
   * ręcznego zbudowania dwóch wersji, lub
   * przepakowania wybranego obrazu samodzielnie np przez ```commit```
 * Przygotuj kolejną wersję obrazu, którego uruchomienie kończy się błędem
  
### Zmiany w deploymencie
 * 🌵 Aktualizuj plik YAML z wdrożeniem i przeprowadzaj je ponownie po zastosowaniu następujących zmian:
   * zwiększenie replik np. do 8
   * zmniejszenie liczby replik do 1
   * zmniejszenie liczby replik do 0
   * ponowne przeskalowanie w górę do 4 replik (co najmniej)
   * Zastosowanie nowej wersji obrazu
   * Zastosowanie starszej wersji obrazu
   * Zastosowanie "wadliwego" obrazu
 * Przywracaj poprzednie wersje wdrożeń za pomocą poleceń
   * ```kubectl rollout history```
   * ```kubectl rollout undo```

### Kontrola wdrożenia
 * Zidentyfikuj historię wdrożenia i zapisane w niej problemy, skoreluj je z wykonywanymi czynnościami
 * Napisz skrypt weryfikujący, czy wdrożenie "zdążyło" się wdrożyć (60 sekund)
 * Zakres rozszerzony: Ujmij skrypt w pipeline Jenkins (o ile `minikube` jest dostępny z zewnątrz)
 
### Strategie wdrożenia
 * Przygotuj wersje [wdrożeń](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) stosujące następujące strategie wdrożeń
   * Recreate
   * Rolling Update (z parametrami `maxUnavailable` > 1, `maxSurge` > 20%)
   * Canary Deployment workload
 * Zaobserwuj i opisz różnice
 * Uzyj etykiet
 * Dla wdrożeń z wieloma replikami, używaj [serwisów](https://kubernetes.io/docs/concepts/services-networking/service/)