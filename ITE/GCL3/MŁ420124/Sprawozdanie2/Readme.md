# Sprawozdanie 2

## Class 05

### Wstęp

```bash
sudo docker network create jenkins
sudo docker network ls
sudo docker run   --name jenkins-docker   --rm   --detach   --privileged   --network jenkins   --network-alias docker   --env DOCKER_TLS_CERTDIR=/certs   --volume jenkins-docker-certs:/certs/client   --volume jenkins-data:/var/jenkins_home   --publish 2376:2376   docker:dind   --storage-driver overlay2
sudo docker build -t myjenkins-blueocean:2.541.3-1 .
sudo docker build -t myjenkins-blueocean:2.541.3-1 -f ./Dockerfile.jenkins .
sudo docker run   --name jenkins-blueocean   --restart=on-failure   --detach   --network jenkins   --env DOCKER_HOST=tcp://docker:2376   --env DOCKER_CERT_PATH=/certs/client   --env DOCKER_TLS_VERIFY=1   --publish 8080:8080   --publish 50000:50000   --volume jenkins-data:/var/jenkins_home   --volume jenkins-docker-certs:/certs/client:ro   myjenkins-blueocean:2.541.3-1
sudo docker ps
sudo docker network inspect jenkins

sudo docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword
2f3df83f0662438eb60f21eede0d2574
```


Skrypt `uname-test`
```bash
uname -a
```

Skrypt `hour-test`
```bash
hour=$(date +%H)

if [ $((hour % 2)) -ne 0 ]; then
  echo "Errpr, hour is odd"
  exit 1
else
  echo "Hour is even"
fi
```

Skrypt `docker-pull-test` (pipeline)
```bash
pipeline {
    agent any

    stages {
        stage('Pull Docker Image') {
            steps {
                sh '''
                {
                    docker pull ubuntu
                }
                '''
            }
        }
    }
}
```

