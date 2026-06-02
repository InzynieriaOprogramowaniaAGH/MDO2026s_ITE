# Sprawozdanie 3 — Ansible + Kubernetes

## Część 1: Ansible

### Weryfikacja łączności

```
ubuntu@myserver:~/MDO2026s_ITE$ hostname
myserver
ubuntu@myserver:~/MDO2026s_ITE$ ssh ansible@ansible-target hostname
ansible-target
ubuntu@myserver:~/MDO2026s_ITE$ getent hosts ansible-target
192.168.2.3     ansible-target
ubuntu@myserver:~/MDO2026s_ITE$ getent hosts myserver
127.0.1.1       myserver myserver
ubuntu@myserver:~/MDO2026s_ITE$ ping -c 3 ansible-target
PING ansible-target (192.168.2.3) 56(84) bytes of data.
64 bytes from ansible-target (192.168.2.3): icmp_seq=1 ttl=64 time=0.536 ms
64 bytes from ansible-target (192.168.2.3): icmp_seq=2 ttl=64 time=0.875 ms
64 bytes from ansible-target (192.168.2.3): icmp_seq=3 ttl=64 time=0.779 ms

--- ansible-target ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2111ms
rtt min/avg/max/mdev = 0.536/0.730/0.875/0.142 ms
```

### Ansible ping

```
ubuntu@myserver:~/MDO2026s_ITE$ ansible -i ~/ansible/inventory.ini all -m ping
myserver | SUCCESS => { "ping": "pong" }
ansible-target | SUCCESS => { "ping": "pong" }
```

---

 Kubernetes (minikube)

### Instalacja minikube

System działa na architekturze `aarch64` (ARM64), dlatego pobrano właściwą wersję:

```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-arm64
sudo install minikube-linux-arm64 /usr/local/bin/minikube
rm minikube-linux-arm64
```

Uruchomienie klastra:

```bash
minikube start
```

```
😄  minikube v1.38.1 on Ubuntu 22.04 (arm64)
✨  Automatically selected the docker driver
🏄  Done! kubectl is now configured to use "minikube" cluster
```

### Uruchomienie poda nginx (manualnie)

```bash
minikube kubectl -- run nginx-app --image=nginx --port=80 --labels app=nginx-app
minikube kubectl -- get pods
```

```
NAME        READY   STATUS    RESTARTS   AGE
nginx-app   1/1     Running   0          51s   10.244.0.3   minikube
```

Przekierowanie portu i weryfikacja:

```bash
minikube kubectl -- port-forward pod/nginx-app 9090:80 --address 0.0.0.0 &
curl -o /dev/null -w "%{http_code}" http://localhost:9090
# 200
```

### Dashboard

```bash
minikube dashboard
```

Dashboard uruchomiony i dostępny w przeglądarce.

---

### Deployment YAML (nginx-deployment.yaml)

Plik `nginx-deployment.yaml` z 4 replikami:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

Wdrożenie:

```bash
minikube kubectl -- apply -f nginx-deployment.yaml
minikube kubectl -- rollout status deployment/nginx-deployment
```

```
deployment "nginx-deployment" successfully rolled out
```

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-569f95f5cb-8fhgd   1/1     Running   0          37s
nginx-deployment-569f95f5cb-jtm8x   1/1     Running   0          37s
nginx-deployment-569f95f5cb-n6v6v   1/1     Running   0          37s
nginx-deployment-569f95f5cb-ztqsn   1/1     Running   0          37s
```

---

### Zmiany w deploymencie

#### Scale up do 8 replik

```bash
# replicas: 8
minikube kubectl -- apply -f nginx-deployment.yaml
minikube kubectl -- rollout status deployment/nginx-deployment
```

```
deployment "nginx-deployment" successfully rolled out
# 8 podów Running
```

#### Scale down do 1 repliki

```bash
# replicas: 1
minikube kubectl -- apply -f nginx-deployment.yaml
```

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-569f95f5cb-n6v6v   1/1     Running   0          4m11s
```

#### Scale down do 0 replik

```bash
# replicas: 0
minikube kubectl -- apply -f nginx-deployment.yaml
minikube kubectl -- get pods -l app=nginx
```

```
No resources found in default namespace.
```

Deployment istnieje, ale nie ma żadnych podów.

#### Scale up do 4 replik

```bash
# replicas: 4
minikube kubectl -- apply -f nginx-deployment.yaml
minikube kubectl -- rollout status deployment/nginx-deployment
```

```
deployment "nginx-deployment" successfully rolled out
```

#### Aktualizacja obrazu: nginx:1.25 → nginx:1.26

```bash
# image: nginx:1.26
minikube kubectl -- apply -f nginx-deployment.yaml
minikube kubectl -- rollout status deployment/nginx-deployment
```

```
Waiting for deployment rollout to finish: 1 out of 4 new replicas have been updated...
...
deployment "nginx-deployment" successfully rolled out
```

Kubernetes zastępuje pody jeden po drugim (Rolling Update) — stare działają dopóki nowe nie są gotowe.

#### Cofnięcie do nginx:1.25

```bash
# image: nginx:1.25
minikube kubectl -- apply -f nginx-deployment.yaml
minikube kubectl -- rollout status deployment/nginx-deployment
```

```
deployment "nginx-deployment" successfully rolled out
```

#### Wadliwy obraz: nginx:99.99

```bash
# image: nginx:99.99
minikube kubectl -- apply -f nginx-deployment.yaml
sleep 15
minikube kubectl -- get pods -l app=nginx
```

```
NAME                                READY   STATUS         RESTARTS   AGE
nginx-deployment-569f95f5cb-69p5b   1/1     Running        0          31s
nginx-deployment-569f95f5cb-sb5h9   1/1     Running        0          30s
nginx-deployment-569f95f5cb-spphl   1/1     Running        0          29s
nginx-deployment-9f8c59964-m2pgt    0/1     ErrImagePull   0          15s
nginx-deployment-9f8c59964-srzs6    0/1     ErrImagePull   0          15s
```

Kubernetes nie usuwa starych podów gdy nowe nie startują — stare 3 pody pozostają `Running`.

---

### Historia wdrożeń i rollback

```bash
minikube kubectl -- rollout history deployment/nginx-deployment
```

```
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
4         <none>
```

```bash
minikube kubectl -- rollout undo deployment/nginx-deployment
minikube kubectl -- rollout status deployment/nginx-deployment
```

```
deployment.apps/nginx-deployment rolled back
deployment "nginx-deployment" successfully rolled out
```

Po rollback wszystkie 4 pody powróciły do stanu `Running`.

---

### Eksponowanie deploymentu jako serwis

```bash
minikube kubectl -- expose deployment nginx-deployment --port=80 --type=ClusterIP
minikube kubectl -- get services
```

```
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP   24m
nginx-deployment   ClusterIP   10.110.87.132   <none>        80/TCP    0s
```

Port-forward do serwisu (nie do konkretnego poda):

```bash
minikube kubectl -- port-forward service/nginx-deployment 9091:80 --address 0.0.0.0 &
curl -o /dev/null -w "%{http_code}" http://localhost:9091
# 200
```

---

### Skrypt weryfikacji wdrożenia (check-deployment.sh)

```bash
#!/bin/bash
DEPLOYMENT=${1:-nginx-deployment}
TIMEOUT=60

echo "Checking deployment: $DEPLOYMENT (timeout: ${TIMEOUT}s)"

if minikube kubectl -- rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s; then
    echo "SUCCESS: Deployment $DEPLOYMENT rolled out within ${TIMEOUT}s"
    exit 0
else
    echo "FAILED: Deployment $DEPLOYMENT did not complete within ${TIMEOUT}s"
    minikube kubectl -- get pods -l app=nginx
    exit 1
fi
```

Wynik uruchomienia:

```
Checking deployment: nginx-deployment (timeout: 60s)
deployment "nginx-deployment" successfully rolled out
SUCCESS: Deployment nginx-deployment rolled out within 60s
```

---

## Strategie wdrożeń

### Recreate (nginx-recreate.yaml)

Strategia `Recreate` usuwa **wszystkie** stare pody przed stworzeniem nowych. Powoduje krótki downtime.

```yaml
strategy:
  type: Recreate
```

```bash
minikube kubectl -- apply -f nginx-recreate.yaml
minikube kubectl -- set image deployment/nginx-recreate nginx=nginx:1.26
```

Przy zmianie obrazu wszystkie 4 pody zostają usunięte jednocześnie, następnie tworzone są nowe.

---

### Rolling Update z parametrami (nginx-rolling.yaml)

`maxUnavailable: 2` — maksymalnie 2 pody mogą być niedostępne podczas aktualizacji.
`maxSurge: 25%` — można uruchomić o 25% więcej podów niż replicas (czyli 1 dodatkowy pod).

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 2
    maxSurge: 25%
```

```bash
minikube kubectl -- apply -f nginx-rolling.yaml
minikube kubectl -- set image deployment/nginx-rolling nginx=nginx:1.26
```

Obserwacja — 3 nowe pody tworzone jednocześnie (maxUnavailable: 2 + maxSurge: 1):

```
nginx-rolling-c6668c7bf-6zv7c    1/1     Running             0
nginx-rolling-c6668c7bf-bbgpd    0/1     ContainerCreating   0
nginx-rolling-c6668c7bf-hm2gn    0/1     ContainerCreating   0
nginx-rolling-c6668c7bf-vvpsl    0/1     ContainerCreating   0
```

---

### Canary Deployment (nginx-canary-stable.yaml + nginx-canary-new.yaml)

Canary to wzorzec z dwoma osobnymi deploymentami i wspólnym serwisem. Serwis kieruje ruch do obu przez etykietę `app: nginx-canary`.

- `nginx-canary-stable`: 3 repliki, `nginx:1.25`, etykieta `track: stable`
- `nginx-canary-new`: 1 replika, `nginx:1.26`, etykieta `track: canary`

```bash
minikube kubectl -- apply -f nginx-canary-stable.yaml
minikube kubectl -- apply -f nginx-canary-new.yaml
minikube kubectl -- get pods -l app=nginx-canary --show-labels
```

```
NAME                                   READY   STATUS    LABELS
nginx-canary-new-5446876775-ngksg      1/1     Running   app=nginx-canary,track=canary
nginx-canary-stable-5d6f45b8d7-6fwgp   1/1     Running   app=nginx-canary,track=stable
nginx-canary-stable-5d6f45b8d7-t2q79   1/1     Running   app=nginx-canary,track=stable
nginx-canary-stable-5d6f45b8d7-xnkn9   1/1     Running   app=nginx-canary,track=stable
```

Serwis `nginx-canary` dystrybuuje ruch: **75% → stable (nginx:1.25)**, **25% → canary (nginx:1.26)**.
Gdy canary jest stabilny — można zwiększyć jego repliki i zmniejszyć stable, stopniowo przenosząc cały ruch.
