Metodyki DevOps Sprawozdanie 1 Illia Kuziv ITE gr.3

Lab1

Git Hook 
```
#!/bin/sh

COMMIT_MSG=$(head -n 1 $1)

REGEX="^(IK424364: )"

if [[ ! $COMMITMSG =~ $REGEX ]]; then
	echo "Error: Commit message should start with $REGEX"
	echo "Your commit message: $COMMIT_MSG"
	exit 1
fi

exit 0
```

![scr1](./cw1/Screenshot_1.png)

Lab 2

Uruchomienie kontenera busybox:

```
docker run -it busybox
```

![scr1](./cw2/Screenshot_5.png)

Na zrzutach widać efekto izolowania kontenerów, widać, że na obu zrzutach jest proces shell-a, ale na hostie i w kontenerze ma różne PID:

![scr1](./cw2/Screenshot_6.png)

![scr1](./cw2/Screenshot_7.png)

Przykładowy kod Dockerfile:

```
FROM ubuntu:22.04

RUN apt update && apt install git -y

RUN git --version

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["/bin/bash"]
```

Po uruchomieniu kontenera widać, że repo ściągnięte:

```
docker run -it git-container .
```

![scr1](./cw2/Screenshot_0.png)

Lab 3

Repozytorium wykorzystywany do zajęć: https://github.com/alexey-lapin/realworld-backend-spring

Najpierw był zainstalowany JDK do buildowania i uruchomienia aplikacji i po tym udało uruchomić aplikację, oraz ją przetesatować

```
sudo apt update
sudo apt install openjdk-25-jdk

git clone https://github.com/alexey-lapin/realworld-backend-spring.git
cd realworld-backend-spring

./gradlew assemble --no-daemon

./gradlew test --no-daemon
```

![scr1](./cw3/Screenshot_1.png)

![scr1](./cw3/Screenshot_2.png)

Potem został stworzony kontener z Ubuntu 22 do przetestowania tych działń w nim:

```
docker run -it --name spring-build-env ubuntu:22.04 /bin/bash

sudo apt-get update && apt-get install -y openjdk-25-jdk git

git clone https://github.com/alexey-lapin/realworld-backend-spring.git
cd realworld-backend-spring

./gradlew assemble --no-daemon

./gradlew test --no-daemon
```

![scr1](./cw3/Screenshot_6.png)

![scr1](./cw3/Screenshot_7.png)

Potem zostały utworzone pliki Dockerfile do buildowania i do testowania

Dockerfile.build:

```
FROM eclipse-temurin:25-noble

WORKDIR app/

RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/alexey-lapin/realworld-backend-spring.git

WORKDIR /app/realworld-backend-spring

RUN ./gradlew dependencies --no-daemon

RUN ./gradlew assemble --no-daemon
```

Dockerfile.test:

```
FROM realworld-base

ENTRYPOINT ["./gradlew", "test", "--no-daemon"]
```

I zostały uruchomione komendy:

```
docker build -f Dockerfile.build -t realworld-base .
```

![scr1](./cw3/Screenshot_9.png)

```
docker build -f Dockerfile.test -t realworld-tester .
docker run --name test-run realworld-tester
```

![scr1](./cw3/Screenshot_9.png)

Lab 4

SSHD:
```
sudo docker run --rm --tty -i --name ssh-container ubuntu
apt update
apt install -y openssh-server
mkdir /var/run/sshd
echo 'root:password123' | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
/usr/sbin/sshd -D &
```