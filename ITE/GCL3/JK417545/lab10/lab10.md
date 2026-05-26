## Laboratorium 10

### Przygotowanie

#### 1: Pobranie i instalacja minikube i kubectl

```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
```

#### 2: Uruchomienie minicube

```bash
minikube start --driver=docker
```
![](zdj/l10-z1.png)

Dzialający kontener/worker

![](zdj/l10-z2.png)

#### 3: Dashboard

Żeby polączyć się z dashboardem, z racji tego że VM ma NAT z port forwardingiem zastosowano tunelowanie żeby wystawić dashboard dla hosta
```bash
ssh -N -L 40541:127.0.0.1:40541 jakkone3@127.0.0.1 -p 2222
```

```bash
kubectl create deployment test-nginx --image=nginx:alpine
deployment.apps/test-nginx created

kubectl scale deployment test-nginx --replicas=2
deployment.apps/test-nginx scaled
```

![](zdj/l10-z3.png)
![](zdj/l10-z4.png)
![](zdj/l10-z5.png)
![](zdj/l10-z6.png)
### Wnioski laboratorium 10
