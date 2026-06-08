## Temat 10

#### Cel zajęć - Wdrażanie oprogramowania na zarządzalne kontenery: Kubernetes


W ramach ćwiczenia wykorzystałem obraz `nginx:alpine` zamiast wcześniej zbudowanego oprogramowania, gdyż pozwoli to na lepsze zobrazowanie różnych scenariuszy zmiany konfiguracji wdrożeń nowszych wersji.

Na początku instaluje minikube oraz kubectl zgodnie z dokumentacją:

```sh
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```
```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
Włączam klaster na 2 CPU i 2GB RAM:
```sh
minikube start --cpus=2 --memory=2048 --driver=docker
```
Sprawdzam dashboard (narazie jest pusty):
```sh
minikube dashboard &
```
Dodatkowo tworze prosty dockerfile dla mojej aplikacji, który zostaje później użyty do deploymentu jej różnych wersji:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```
Na podstawie tych faktów przystępuje do czynów. Na początku ładuje wcześniej utworzony obraz do minikube, "modyfikuje" wersję programu, buduje wersje nr. 2, ładuje ją do minikube, dodaktowo tworzę trzecią "zepsutą" wersje aplikacji i ponownie ładuję ją do klastra.
![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20090134.png)
Na początku sprawdzam działanie pojedyńczego poda, gdzie przekierowuje nginx na port 8081 i sprawdzam działanie narzędziem curl:

```bash
kubectl run moj-pod --image=moj-app:v1 --port=80 --image-pull-policy=Never --labels app=moj-pod

kubectl port-forward pod/moj-pod 8081:80 &
```
![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20090517.png)

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20090507.png)



![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20090544.png)
Jak widać, pokazuje się wersja 1 aplikacji narazie, co jest zgodne z poleceniem.

Pod można usunąć poleceniem:

```bash
kubectl delete pod moj-pod
```
Następnie tworze plik deployment.yaml, dzięki któremu moge zautomatyzować wdrożenie wersji aplikacji na klaster:

```yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: kontener-aplikacji
        image: moj-app:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: lab-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

```

Tworzymy tutaj deployment, który utworzy 4 pody zawierają wersję v1 nginx. 
Dodatkowo dodaję jeszcze serwis, który bedzie przekazywał port jednego z podów na local, dzięki czemu bedzie można sprawdzić działanie deploymentu.

Włączam deployment poniższą komendą:

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091137.png)

Sprawdzam status deploymentu - czy nie ma żadnych błędów (nie ma):


![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091159.png)

Dodatkowo na dashboardzie widać nasze 4 pody z deploymentu, każdy z nich używa obrazu moj-app:v1, co jest zgodne z plikiem wdrożenia.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091219.png)

Przekazuje porty i sprawdzam działanie deploymentu - jak widać działa poprawnie na porcie 8082.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091511.png)

Następnie zmieniam liczbę podów w wdrożeniu z 4 na 8 za pomocą polecenienia `kubectl scale` i ponownie sprawdzam ich liczbę. Analogicznie można skalować w dół oraz do 0, daje to podobne wynki do tego:


![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091626.png)

Aktualizuję obraz do wersji moj-app:v2 za pomocą polecenia `kubectl set image` oraz sprawdzam stan klastra poleceniem `kubectl rollout status` 

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20091700.png)

Ponownie przekierowuje porty i sprawdzam działanie za pomocą narzędzia curl - wynikiem jest komunikat "Wersja V2 - po aktualizacji" - pody poprawnie zmieniły obraz w ramach modyfikacji deploymentu.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20092234.png)

Dodatkowo na dashboardzie wszystkie pody początkowego deploymentu teraz mają obraz V2, natomiast widzimy dwa deploymenty w ReplicaSet, jeden V1, drugi V2.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20092308.png)

Następnie zmieniam wersje obrazu na V3 w celu sprawdzenia czy klaster przyjmie wadliwy obraz - wynikiem jest zepsucie połowy kontenerów, w związku z czym  trzeba zrobić `kubectl rollout undo` aby powrócić do poprzedniego stanu.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-05-29%20092743.png)

Następnie tworzę prosty skrypt, który sprawdza staus deploymentu i zwraca odpowiedni komunikat:

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20224727.png)

Prechodzę do kwestii rodzajów wdrożeń - zacznę od recreate. Ten typ wdrożenia zabije wszystkie pody ze starą wersją, po czym podnosi je z nowszą wersją oprogramowania:

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-deployment
spec:
  replicas: 4
  strategy:
      type: Recreate
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: kontener-aplikacji
        image: moj-app:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: lab-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20225434.png)

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20225521.png)

Kolejny jest rolling update, gdzie określona część kontenerów zostanie podmnieniona w płynny sposób, a reszta pozostanie w tym czasie w wersji poprzedniej, aby uniknąć przerwy w dostarczanku usług.

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-deployment
spec:
  replicas: 4
  strategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1
        maxSurge: 25%  # 1 kontener przy 4 replikach
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: kontener-aplikacji
        image: moj-app:v2
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: lab-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```
Wynikiem tego jest 3 kontenery w wersji v2 oraz 1 w wersji v1, który pod koniec zmienia się w kontener wersji v2.

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20230424.png)

Na koniec mamy deployment typu canary, gdzie najpierw musimy wyłączyć wszystkie pody podchodzący pod nasz pierwotny deployment. Ten typ wdrożeń polega na tagach, gdzie tylko ustalona część klientów ma dostęp do podów z nowszą wersją oprogramowania, w porównaniu do Rolling Update to przejście na nowszą wersję jest prawie natychmiastowe, oczywiscie po poprawnie zaliczonym zbiorze testów.

Do zrobienia wdrożenia ponownie modfyikujemy nasz plik wdrożenia:

```yml

---
# (Wspólny punkt wejścia)
apiVersion: v1
kind: Service
metadata:
  name: canary-service
spec:
  selector:
    app: aplikacja-lab  # Złapie wszystkie pody z tą etykietą
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

---
# wdrozenie stabilne v1 - 75% ruchu
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-stable
spec:
  replicas: 3
  selector:
    matchLabels:
      app: aplikacja-lab
      track: stable       # Unikalna etykieta stabilna
  template:
    metadata:
      labels:
        app: aplikacja-lab
        track: stable
    spec:
      containers:
      - name: kontener
        image: moj-app:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80

---
# wdrozenie "canary" - 25% ruchu
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aplikacja-lab
      track: canary       # Unikalna etykieta kanarka
  template:
    metadata:
      labels:
        app: aplikacja-lab
        track: canary
    spec:
      containers:
      - name: kontener
        image: moj-app:v2
        imagePullPolicy: Never
        ports:
        - containerPort: 80

```

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20230845.png)

![img](../screenshots/lab10/Zrzut%20ekranu%202026-06-02%20231151.png)