1. Zainstaluj Docker w systemie linuksowym
 - ![alt text](image-1.png)
2. Rozmiary obrazów
 - ![alt text](image-2.png)
3. uruchomienie obrazów:
    # hello-world
    - ![alt text](image-3.png)
    - ![alt text](image-4.png)
    # busybox
    - ![alt text](image-5.png)
    - ![alt text](image-6.png)
    # ubuntu
    - ![alt text](image-7.png)
    - ![alt text](image-8.png)
    # mariadb
    - ![alt text](image-9.png)
    - ![alt text](image-10.png)
    # runtime
    - ![alt text](image-11.png)
    # aspnet
    - ![alt text](image-12.png)
    # sdk 
    - ![alt text](image-13.png)
4. buisybox
    # uruchomienie
    - ![alt text](image-14.png)
    # tryb interaktywny
    - ![alt text](image-15.png)
 5. ubuntu
    # PID1
    - ![alt text](image-16.png)
    # procesy na hoscie
    - ![alt text](image-17.png)
    # aktualizacja pakietow
    - ![alt text](image-18.png)
 6. własny dockerfile:

FROM ubuntu:latest

RUN apt-get update && apt-get install -y git &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]
- ![alt text](image-19.png)
- ![alt text](image-20.png)
- ![alt text](image-21.png)

# uruchamiane kontenery
![alt text](image-22.png)

# czyszczenie
![alt text](image-23.png)
![alt text](image-24.png)