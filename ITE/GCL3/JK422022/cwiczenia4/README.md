wykorzystane komendy do voluminów:
docker volume create _nazwa
![volume_create](voluminy.jpeg)

-polecenie na kontener pomocniczy
docker run --rm -v vol-in:/data alpine/git
clone https://github.com/docker/getting-started-app /data 

![podpiecie wolumina](podpiecie.jpeg)

-weryfikacja
docker run --rm -v volumin_wyjsciowy:/data busybox ls -F /data
![weryfikacja](weryfikacja.jpeg)


zadanie iperf:
utworzono docker na server
![iperf](iperf1.jpeg)

 i sprawdzono jego ip
![ip](ip.jpeg)

nawiazano polaczenie miedzy 2 dockerami

![polaczenie](klient.jpeg)

nastepnie stworzono wlasna siec i do niej docker

![siec](siec.jpeg)

nawiazano polaczenie na sieci 

![połączenie](polaczenie.jpeg)


połączenie spoza hosta
![spoza hosta](host.jpeg)

zadanie 3 ubuntu przez ssh
wykorzystano nastepujace komendy
![komendy](komendy.jpeg)
i nawiazano polaczenie
![polaczenie ssh na ubuntu](ubuntu.jpeg)
wykorzystane polecenia do utworzenia jenkins:
docker network create jenkins
docker volume create jenkins_docker
docker volume create jenkins_docker
docker run --name jenkins-docker --detach   --privileged --network jenkins --network-alias docker   --env DOCKER_TLS_CERTDIR=/certs   --volume jenkins_docker:/certs   --volume jenkins_data:/var/jenkins_home   --publish 2376:2376   docker:dind
docker run --name jenkins-server --detach   --network jenkins --env DOCKER_HOST=tcp://docker:2376   --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1   --publish 8080:8080 --publish 50000:50000   --volume jenkins_data:/var/jenkins_home   --volume jenkins_docker:/certs/client:ro   jenkins/jenkins:lts


![jenkins](jenkins1.jpeg)
![jenkins](jenkins2.jpeg)

aby wszystko działało dodano przekierowanie portów 5201 i 8080
