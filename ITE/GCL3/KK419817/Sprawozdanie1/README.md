Sprawozdanie metodyki devops
03.03.2026 Kryspin Kucha ITE gr.3

Git hook
```sh
REQUIRED_PREFIX="KK419817"

FIRST_LINE=$(head -n 1 "$1")

case "$FIRST_LINE" in
  "$REQUIRED_PREFIX"*) 
    exit 0
    ;;
  *)
    echo "Commit message must start with '$REQUIRED_PREFIX'"
    exit 1
    ;;
esac

```

Hook:
![Hook](image-0-1.png)

Maszyna wirtualna:
![Maszyna wirtualna](image-1-1.png)

PR do GCL3:
![PR do GCL3](image-2-1.png)

Użyte komendy po setupie
```
git checkout -b KK419817
git push --set-upstream origin KK419817
git commit -m 'add hook'
git push
```


# Zajecia 2




1.

```sh
sudo apt update
sudo apt install docker.io
```
![wersja ubuntu](image-3.png)

3.
```sh
docker pull hello-world
docker pull busybox
docker pull ubuntu
# ...

docker images
```
![alt text](image-4.png)


4.

```sh
docker run busybox
docker ps -a
```

![alt text](image-5.png)
![alt text](image-2.png)

```sh
docker run -it busybox sh
# w kontenerze
busybox --help
```

![alt text](image-6.png)

5.
![ubuntu](image.png)

![exit](image-1.png)


6.
dockerfile
```dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# install git and clean cache
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["bash"]
```

Usunięcie niepotrzebnych obrazów:
`docker image prune -a`
![prune](image-7.png)

# Zajecia 3

### Podstawowa instalacja
Do zajęć wykorzystano repozytorium expressjs
(https://github.com/expressjs/express?tab=readme-ov-file#installation)

Najpierw uruchomiłek lokalnie komendy:
```bash
sudo apt update
sudo apt install -y nodejs npm git

git clone https://github.com/expressjs/express.git --depth 1 && cd express
npm install
npm test
```
Wszystkie testy przeszły pomyślnie:

![testy](image-8.png)

### Tryb interaktywny

Następnie uruchomiłem wspomniane wyżej komendy w interaktywnym trybie dockera:
```Docker
docker run -it node:20-alpine sh
apk update
apk add git
# jw.
```
![dockerint](image-9.png)
![dockerinttest](image-10.png)


### Dockerfiles

Kolejno, utworzyłem plik [Dockerfile.build](lab2/Dockerfile.build)
```Docker
FROM node:20-alpine
WORKDIR /app
RUN apk update
RUN apk add git
RUN git clone https://github.com/expressjs/express.git .
RUN npm install
```

Oraz [Dockerfile.test](lab2/Dockerfile.test), który musi zostać wykonany po utworzeniu obrazu build o nazwie express-build

```Docker
FROM express-build
WORKDIR /app
CMD ["npm", "test"]
```


---

Build oraz uruchomienie konetenerów:
```Docker
docker build -f Dockerfile.build -t express-build .

docker build -f Dockerfile.test -t express-test .

docker run --rm express-test
```
![alt text](image-11.png)

### Docker compose

Instalacja:
`sudo apt  install docker-compose`

Utworzyłem plik [docker-compose.yml](lab2/docker-compose.yml), w którym utworzyłem dwa serwisy: build i test. Test jest zależny od build, przez co build jest automatycznie tworzony przed tworzeniem kontenera test

Build:
![alt text](image-12.png)

Uruchomiłem kontenery za pomocą komendy:

`docker-compose run --rm test`

![alt text](image-13.png)

Wszystko wykonało się poprawnie a testy ponownie przeszły.


# Zajecia 4

Eksponowanie portu i łączność między kontenerami

Server
```
docker run -it --name iperf-server alpine sh

apk add iperf3

# start listening:
iperf3 -s
```
![alt text](image-16.png)

Klient
```
docker run -it --name iperf-client alpine sh
apk add iperf3
```
![alt text](image-15.png)

Na hoscie:
```
docker inspect iperf-server
docker inspect iperf-server | grep IPAddress
```
![alt text](image-14.png)

Polaczenie z klienta, test łącza:
```
iperf3 -c iperf3 -c 172.17.0.2
```
![testpol](image-17.png)

