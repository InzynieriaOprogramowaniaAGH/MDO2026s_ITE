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

# Zajecia 3

Do zajęć wykorzystano repozytorium nodebestpractices

```bash
sudo apt update
sudo apt install -y nodejs npm git

git clone https://github.com/chalk/chalk.git

cd chalk
npm install
```
![alt text](image-7.png)

![alt text](image-8.png)


Następnie utworzyłem odpowiedni plik dockerfile.build i dockerfile.test

`docker run -it chalk-build bash`
```
FROM node:20

WORKDIR /app

RUN apt update && apt install -y git
RUN git clone https://github.com/chalk/chalk.git .

RUN npm install

RUN npm run build
```

```
FROM chalk-build

WORKDIR /app

# run tests only
CMD ["npm", "test"]
```



