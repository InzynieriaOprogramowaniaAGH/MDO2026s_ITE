```bash
exit
ls
ls -a
ls -l
ping github.com
ssh git@github.com
git --version
ssh -T git@github.com
git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE
ls
cd MDO2026s_ITE/
git branch -a\
git branch -a
git fetch
ls
git branch
git checkout GCL3
git branch
git checkout -b MŻ422030
git branch
ls
cd ITE/
ls
cd GCL3/
ls
cat README.md 
mkdir MŻ422030
cd MŻ422030/
ls
mkdir Sprawozdanie1
touch README.md
ls
nano README.md 
ls
cat README.md 
git add .
git commit -m "Lab1"
git branch
git push -u origin MŻ422030
git remote -v
git remote set-url origin git@github.com:InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git
git remote -v
git push -u origin MŻ422030
git remote -v
nano commit-msg
ls
cp ITE/GCL3/MŻ422030/commit-msg .git/hooks/commit-msg
cp commit-msg ../../../.git/hooks/commit-msg
chmod +x ../../../.git/hooks/commit-msg
git commit -m "test hooka"
git commit -m "MŻ422030 test hooka"
git add commit-msg
git commit -m "test hooka"
git commit -m "MŻ422030 test hooka"
git branch
git push
ls
git status
exit
ls
cd MDO2026s_ITE/
ls
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cd MDO2026s_ITE/
ls
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cat README.md 
mv README.md Sprawozdanie1.md
ls
cd Sprawozdanie1/
git status
git branch
git fetch origin
ls
cd ..
ls
git reset --hard origin/MŻ422030
ls
cd Sprawozdanie1/
ls
cd ..
ls
em Sprawozdanie1.md
rm Sprawozdanie1.md
ls
cd Sprawozdanie1/
ls
touch README.md
touch Sprawozdanie1.md
ls
git add .
git commit -m "MŻ422030 sprawozdanie"
git reset --soft HEAD~1
cd ..
git add .
cd ..
git add .
git commit -m "MŻ422030 sprawozdanie"
git branch
git push
clear
git --version
ls
cd MDO2026s_ITE/
ls
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
mkdir L1
mkdir L2
ls
mv ~/MDO2026s_ITE/ITE/GCL3/MŻ422030/commit-msg ~/MDO2026s_ITE/ITE/GCL3/MŻ422030/L1/
ls
cd L1
ls
cp ~/MDO2026s_ITE/ITE/GCL3/MŻ422030/L1/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
cd ..
cp ~/MDO2026s_ITE/ITE/GCL3/MŻ422030/L1/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
pwd
git status
git branch
cd MDO2026s_ITE/
git branch
git status
cp ~/MDO2026s_ITE/ITE/GCL3/MŻ422030/L1/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
git status
git commit -m "test"
git add .
git commit -m "test"
git commit -m "422030 test"
git commit -m "MŻ422030 test"
git branch
git push
ls
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cd L2
ls
clear
cd ..
sudo apt update
sudo apt install docker.io
ls
git ps
clear
docker ps
docker p -a
docker ls
clear
docker
docker images
clear
docker volume create mdo_in
docker volume create mdo_out
docker volume ls
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sshd-container
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ssh
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sshd-container
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sshd-
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sshd-container
ls
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cd L3
ls
clear
docker run --name iperf-server networkstatic/iperf3
docker ps
docker run --help
docker inspect '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server
docker run -d --name iperf-server networkstatic/iperf3
docker: Error response from daemon: Conflict. The container name "/iperf-server" is already in use by container "5f58848328f74c6a754b017bcaf36458d042c70ccbc74dfaecde37b0dddbaa2b". You have to remove (or rename) that container to be able to reuse that name.
Run 'docker run --help' for more information
docker rm -f iperf-server
docker run -d --name iperf-server networkstatic/iperf3
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server
docker rm -f iperf-server
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server -s
docker run -d --name iperf-server networkstatic/iperf3 -s
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server -s
docker run --rm -it networkstatic/iperf3 -c 172.17.03
docker run -d --name iperf-server networkstatic/iperf3 -s
docker ps -a
docker rm iperf-server
docker stop iperf-server
docker rm iperf-server
docker run -d --name iperf-server networkstatic/iperf3 -s
docker ps
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server
docker run --rm -it networkstatic/iperf3 -c 172.17.0.2
docker run --rm -it networkstatic/iperf3 -c 172.17.0.3
docker ps
clear
docker network create mybridge
docker network ls
docker run -d --name iperf-server --network mybridge networkstatic/iperf3 -s
docker stop iperf-server
docker rm iperf-server
docker run -d --name iperf-server --network mybridge networkstatic/iperf3 -s
docker ps
docker network inspect mybridge
docker run --rm -it --network mybridge networkstatic/iperf3 -c iperf-server
docker run -d --name sshd-container -p 2222:22 ubuntu:22.04
apt update
apt install -y openssh-server
sudo apt update
sudo apt install -y openssh-server
mkdir /var/run/sshd
sudo mkdir /var/run/sshd
/usr/sbin/sshd
sudo /usr/sbin/sshd
docker ps
docker start -ai sshd-container
apt update
apt install -y openssh-server
mkdir /var/run/sshd
sudo apt update
apt install -y openssh-server
mkdir /var/run/sshd
sudo apt install -y openssh-server
/usr/sbin/sshd
sudo /usr/sbin/sshd
docker run -it -p 2222:22 --name sshd-container ubuntu:24.04 bash
exit
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sshd-test
ssh root@172.17.0.2
ssh root@localhost -p 2222
clear
exit
docker volume prune
docker volume ls
docker volume prune -af
docker volume ls
clear
docker volume create minpy_in
docker volume create minpy_out
docker volume ls
docker run --rm -it --mount type=volume,src=minpy_in,dst=/in --mount type=volume,src=minpy_out,dst=/out python:3.13-slim bash
clear
docker run --rm -it --mount type=bind,src=/home/vboxuser/MDO2026s_ITE/ITE/GCL3/MŻ422030/L2/minimalpy,dst=/src --mount type=volume,src=minpy_in,dst=/in python:3.13-slim bash
docker ps
docker run --rm -it --mount type=volume,src=minpy_in,dst=/in python:3.13-slim bash
docker run --rm -it --mount type=volume,src=minpy_in,dst=/work --mount type=volume,src=minpy_out,dst=/out python:3.13-slim bash
docker run --rm -it --mount type=volume,src=minpy_out,dst=/out python:3.13-slim bash
docker volume rm minpy_in
docker volume create minpy_in
docker volume ls
docker run --rm -it --mount type=volume,src=minpy_in,dst=/in ubuntu:24.04 bash
docker run --rm -it --mount type=volume,src=minpy_in,dst=/in ubuntu:22.04 bash
docker run --rm -it --mount type=volume,src=minpy_in,dst=/in python:3.13-slim bash
clear
ls
docker ps
docker rm -f
docker ps -a
docker run -it --name sshd-test ubuntu:22.04 bash
docker run -it -p 2222:22 ubuntu:22.04 bash
clear
docker network create jenkins-net
docker run -d --name jenkins-dind --network jenkins-net -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts
docker ps
docker exec jenkins-dind cat /var/jenkins_home/secrets/initialAdminPassword
ip route | grep default
ip addr show
docker run -p 8080:8080 jenkins/jenkins:lts
clear
exit
docker run -it -p 2222:22 ubuntu:22.04 bash
ls
docker ps
docker stop iperf-server 
docker rm iperf-server 
clear
docker run -it -p 2222:22 ubuntu:22.04 bash
ssh devuser@localhost -p 2222
docker run --rm -it --mount type=volume,src=minpy_in,dst=/in ubuntu:24.04 bash
docker run --rm -it --mount type=volume,src=minpy_in,dst=/in ubuntu:22.04 bash
docker run --rm -it --mount type=volume,src=minpy_in,dst=/in python:3.13-slim bash
clear
ls
docker ps
docker rm -f
docker ps -a
docker run -it --name sshd-test ubuntu:22.04 bash
docker run -it -p 2222:22 ubuntu:22.04 bash
clear
docker network create jenkins-net
docker run -d --name jenkins-dind --network jenkins-net -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts
docker ps
docker exec jenkins-dind cat /var/jenkins_home/secrets/initialAdminPassword
ip route | grep default
ip addr show
docker run -p 8080:8080 jenkins/jenkins:lts
clear
exit
docker run -it -p 2222:22 ubuntu:22.04 bash
ls
docker ps
docker stop iperf-server 
docker rm iperf-server 
clear
docker run -it -p 2222:22 ubuntu:22.04 bash
ssh devuser@localhost -p 2222
clear
ls
cd ..
ls
cd 
cd MDO2026s_ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cd L2
ls
python main.py
python3 main.py
cd minimalpy/
ls
cd minimalpy/
ls
cd ..
ls
cd deploy/
ls
cd ..
clear
ls
pip install build
sudo pip install build
pip install -r requirements.txt
python3 -m venv venv
source venv/bin/activate
apt install python3.12-venv
sudo apt install python3.12-venv
pip install -r requirements.txt
sudo pip install -r requirements.txt
python3 -m venv venv
source venv/bin/activate
sudo pip install -r requirements.txt
pip install -r requirements.txt
exit
ps aux
ps aux | grep docker
clear
ps aux | grep docker
clear
exit
docker run -it -p 2222:22 ubuntu:22.04 bash
ls
docker ps
docker stop iperf-server 
docker rm iperf-server 
clear
docker run -it -p 2222:22 ubuntu:22.04 bash
ssh devuser@localhost -p 2222
history
clear
history
clear
ls
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cd L2
ls
cd minimalpy/
ls
cler
clear
docker images
docker run -it --name test python:3.13-slim bash
clear
git --version
ssh -V
git remote -v
cd ..
git remote -v
clear
docker run -it busybox
docker run --rm busybox busybox --version
docker run --rm busybox --version
clear
docker run -it busybox
clear
docker run -it ubuntu:22.04
ls
clear
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cd L2/
ls
cd minimalpy/
ls
pip install -r requirements.txt
python3 -m venv .venv
pip install -r requirements.txt
source .venv/bin/activate
pip install -r requirements.txt
python3 -m venv .venv
exit
ls
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cd L2
ls
cd minimalpy/
clear
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
docker run -it python:3.13-slim bash
exit
ls
cd ITE/
ls
cd GCL3/
ls
cd MŻ422030/
ls
cd L2
ls
docker run -it python:3.13-slim bash
docker images
history
docker ps
docker images
docker run -d -p 8080:8080 --name jenkins jenkins/jenkins:lts
docker ps
docker stop jenkins
```