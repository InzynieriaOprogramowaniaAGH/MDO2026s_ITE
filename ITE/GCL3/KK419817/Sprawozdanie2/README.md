


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


