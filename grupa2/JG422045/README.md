# Jaromir Gas - Pełny zapis historii z zajęć 

Część historii z ćwiczeń 1 została utracona na skutek nieprzewidzianego wyłączenia komputera. <br>
Zachowała się dokumentacja zdjęciowa oraz wyniki tej pracy na maszynie wirtualnej. <br>

# Historia:
```
    1  logout
    2  sudo apt update
    3  sudo apt install openssh-server
    4  sudo systemctl enable --now ssh
    5  ip a
    6  sudo ufw allow ssh
    7  history
    8  ip a
    9  sudo systemctl status ssh
   10  logout
   11  ls
   12  sudo apt git -y
   13  sudo apt install git -y
   14  git config --global user.name "Jarimino"
   15  git config --global user.email "236237810+Jarimino@users.noreply.github.com"
   16  history
   17  ssh -T git@github.com
   18  ls
   19  cd ssh
   20  ls
   21  ssh -T git@github.com
   22  ssh -vT git@github.com
   23  cd ..
   24  ls -al ~/.ssh
   25  logout
   26  ls
   27  ssh -T git@github.com
   28  nano ~/.ssh/config
   29  ls
   30  ssh -T git@github.com
   31  cd ssh
   32  ls
   33  nano ~/.ssh/config
   34  ssh -T git@github.com
   35  nano ~/.ssh/config
   36  logout
   37  ssh -T git@github.com
   38  logout
   39  ls
   40  logout
   41  ls
   42  docker network create jenkins
   43  sudo apt update
   44  sudo apt install docker.io
   45  sudo systemctl start docker
   46  sudo systemctl enable docker
   47  docker network create jenkins
   48  sudo docker network create jenkins
   49  docker run   --name jenkins-docker   --rm   --detach   --privileged   --network jenkins   --network-alias docker   --env DOCKER_TLS_CERTDIR=/certs   --volume jenkins-docker-certs:/certs/client   --volume jenkins-data:/var/jenkins_home   --publish 2376:2376   docker:dind   --storage-driver overlay2
   50  sudo docker run   --name jenkins-docker   --rm   --detach   --privileged   --network jenkins   --network-alias docker   --env DOCKER_TLS_CERTDIR=/certs   --volume jenkins-docker-certs:/certs/client   --volume jenkins-data:/var/jenkins_home   --publish 2376:2376   docker:dind   --storage-driver overlay2
   51  vim Dockerfile
   52  ls
   53  sudo docker build -t myjenkins-blueocean:2.541.3-1 .
   54  ls
   55  vim Dockerfile
   56  sudo docker run   --name jenkins-blueocean   --restart=on-failure   --detach   --network jenkins   --env DOCKER_HOST=tcp://docker:2376   --env DOCKER_CERT_PATH=/certs/client   --env DOCKER_TLS_VERIFY=1   --publish 8080:8080   --publish 50000:50000   --volume jenkins-data:/var/jenkins_home   --volume jenkins-docker-certs:/certs/client:ro   myjenkins-blueocean:2.541.3-1
   57  ls
   58  docker logs jenkins-blueocean
   59  sudo docker logs jenkins-blueocean
   60  docker ps
   61  sudo docker ps
   62  sudo docker ps | grep jenkins-docker
   63  docker port jenkins-blueocean
   64  sudo docker port jenkins-blueocean
   65  ip addr show
   66  logout
   67  ls
   68  cd MDO2026_ITE/
   69  ls
   70  cd READMEs/
   71  ls
   72  cd..
   73  cd ..
   74  git checkout main READMEs/
   75  ls
   76  cd READMEs/
   77  cd..
   78  cd .
   79  cd ..
   80  ls
   81  cd ..
   82  ls
   83  cd MDO2026_ITE/
   84  ls
   85  cd READMEs/
   86  git checkout main READMEs/
   87  cd ..
   88  git checkout main READMEs
   89  git remote -v
   90  git fetch main
   91  git fetch origin main
   92  ls
   93  git checkout main READMEs
   94  cd READMEs/
   95  ls
   96  cd..
   97  git checkout main READMEs/
   98  cd ..
   99  git checkout main READMEs/
  100  git checkout main READMEs
  101  git checkout origins/main READMEs/
  102  git status
  103  git checkout origins/main -- READMEs/
  104  git checkout origin/main -- READMEs/
  105  ls
  106  cd READMEs/
  107  ls
  108  cd ..
  109  cd grupa2/
  110  LS
  111  ls
  112  cd JG422045/
  113  ls
  114  cd ..
  115  logout
  116  ls
  117  docker --version
  118  cd MDO2026_ITE/
  119  ls
  120  CD grupa2/
  121  cd grupa2/
  122  ls
  123  cd JG422045/
  124  ls
  125  mkdir Laboratorium_2
  126  ls
  127  cd Laboratorium_2/
  128  ls
  129  sudo docker run hello-world
  130  ls
  131  docker images
  132  sudo docker images
  133  docker ps -a
  134  sudo docker ps -a
  135  sudo docker run busybox
  136  sudo docker run ubuntu
  137  sudo docker run mariadb
  138  sudo docker run runtime
  139  sudo docker run mcr.microsoft.com/dotnet/runtime
  140  sudo docker run mcr.microsoft.com/dotnet/aspnet
  141  sudo docker run mcr.microsoft.com/dotnet/sdk
  142  sudo docker images
  143  sudo docker ps -a
  144  sudo docker run -it busybox
  145  sudo docker images
  146  sudo docker ps -a
  147  sudo docker run busybox echo "Test JG1"
  148  sudo docker images
  149  sudo docker ps -a
  150  docker run -it ubuntu bash
  151  sudo docker run -it ubuntu bash
  152  sudo docker images
  153  sudo docker ps -a
  154  cd ..
  155  logout
  156  ls
  157  cd MDO2026_ITE/
  158  ls
  159  cd grupa2/
  160  ls
  161  cd JG422045/
  162  ls
  163  cd ..
  164  sudo apt update
  165  sudo apt install software-properties-common
  166  sudo apt-add-repository --yes --update ppa:ansible/ansible
  167  sudo apt install ansible
  168  ls
  169  cd MDO2026_ITE/
  170  cd grupa2/
  171  cd JG422045/
  172  ls
  173  cd Laboratorium_2/
  174  ls
  175  sudo docker ps -a
  176  sudo docker images
  177  cd..
  178  cd ..
  179  ls
  180  gedit Dockerfile
  181  nano Dockerfile
  182  ls
  183  cd MDO2026_ITE/
  184  cd grupa2/
  185  cd JG422045/
  186  cd Laboratorium_2/
  187  ls
  188  nano Dockerfile
  189  ls
  190  hostnamectl
  191  nano Dockerfile
  192  ls
  193  docker build -t repolabJG
  194  nano Dockerfile
  195  sudo docker build -t repolabJG .
  196  docker build -t repolabjg .
  197  nano Dockerfile
  198  ls
  199  sudo docker build -t repolabjg .
  200  ls
  201  sudo docker run -it repolavjg
  202  sudo docker images
  203  sudo docker run -it repolabjg
  204  docker ps -a
  205  sudo docker ps -a
  206  docker container prune
  207  sudo docker ps -a
  208  sudo docker container prune
  209  sudo docker ps -a
  210  sudo docker image prune
  211  sudo docker images
  212  sudo docker ps -a --filter "ancestor=jenkins/jenkins:2.541.3-jdk21"
  213  sudo docker ps -a
  214  sudo docker rmi busybox
  215  sudo docker images
  216  sudo docker rmi hello-world
  217  sudo docker rmi mariadb
  218  sudo docker rmi mcr.microsoft.com/dotnet/aspnet
  219  sudo docker rmi mcr.microsoft.com/dotnet/runtime
  220  mcr.microsoft.com/dotnet/sdk
  221  sduo docker rmi mcr.microsoft.com/dotnet/sdk
  222  sudo docker rmi mcr.microsoft.com/dotnet/sdk
  223  sudo docker rmi repolabjg
  224  sudo docker rmi ubuntu
  225  sudo docker images
  226  sudo docker rmi ubuntu:24.04
  227  sudo docker images
  228  ls
  229  cd ..
  230  mkdir Laboratorium_3
  231  ls
  232  cd Laboratorium_3
  233  cd ..
  234  ls
  235  git clone https://github.com/redis/hiredis?tab=BSD-3-Clause-1-ov-file
  236  ls
  237  git clone https://github.com/redis/hiredis
  238  ls
  239  sudo apt update
  240  sudo apt install build-essential git -y
  241  ls
  242  cd hiredis
  243  ls
  244  make
  245  make hiredis-test
  246  ./hiredis-test
  247  echo $?
  248  cd..
  249  cd ..
  250  cd MDO2026_ITE/
  251  cd grupa2/
  252  cd Laboratorium_3
  253  ls
  254  docker run -it --name hiredis-doc gcc:latest /bin/bash
  255  sudo docker run -it --name hiredis-doc gcc:latest /bin/bash
  256  ls
  257  sudo docker ps -a
  258  sudo docker images
  259  history
  260  logout
  261  history
  262  logout
  263  ls
  264  vim Dockerfile
  265  cd MDO2026_ITE/
  266  ls
  267  cd grupa2/
  268  cd JG422045/
  269  ls
  270  cd Laboratorium_2
  271  ls
  272  cd ..
  273  cd Laboratorium_3
  274  ls
  275  cd ..
  276  nproc
  277  free -h
  278  df -h /
  279  logout
  280  ls
  281  cd MDO2026_ITE/
  282  cd grupa2/
  283  cd JG422045/
  284  ls
  285  cd Laboratorium_3
  286  ls
  287  cd ..
  288  sudo docker ps
  289  sudo docker images
  290  ls
  291  cd Laboratorium_
  292  cd Laboratorium_3
  293  ls
  294  sudo docker ps -a
  295  cd ..
  296  cd Laboratorium_2
  297  ls
  298  gedit Dockerfile
  299  vim Dockerfile
  300  cd ..
  301  cd Laboratorium_3
  302  ls
  303  vim DockerBuildFile
  304  ls
  305  vim DockerBuildFile
  306  nano DockerBuildFile
  307  ls
  308  nano DockerBuildFile
  309  nano DockerTestFile
  310  nano DockerBuildFile
  311  nano DockerTestFile
  312  nano DockerBuildFile
  313  ls
  314  nano DockerTestFile
  315  nano DockerBuildFile
  316  nano DockerTestFile
  317  ls
  318  sudo docker build -t hiredis-base:latest -f DockerBuildFile .
  319  nano DockerBuildFile
  320  sudo docker build -t hiredis-base:latest -f DockerBuildFile .
  321  sudo docker ps -a
  322  sudo docker images
  323  sudo docker build -t hiredis-test:latest -f DockerTestFile .
  324  sudo docker images
  325  sudo docker ps -a
  326  sudo docker run --name hiredis-testing hiredis-test:latest
  327  sudo docker ps -a
  328  sudo docker images
  329  logout
  330  ls
  331  cd MDO2026_ITE/
  332  ls
  333  cd grupa2/
  334  ls
  335  cd ..
  336  cd ITE/
  337  ls
  338  cd ..
  339  cd grupa2/
  340  cd JG422045/
  341  ls
  342  mkdir Laboratorium_13
  343  cd Laboratorium_
  344  cd Laboratorium_13
  345  ls
  346  cd ..
  347  ls
  348  git clone https://github.com/Jarimino/SIMPLE-fork
  349  ls
  350  cd SIMPLE-fork/
  351  ls
  352  git checkout -b ino_dev
  353  git branch --show-current
  354  git branch
  355  mkdir -p .github/workflows
  356  ls
  357  ls -a
  358  cd .github/workflows
  359  ls
  360  nano ShiftLeftAcitonsJG.yml
  361  logout
  362  history
  363  nano .ssh/config
  364  cd .ssh
  365  ls
  366  nano authorized_keys
  367  nano config
  368  cd ..
  369  ls
  370  cd ..
  371  ls
  372  cd jaromirg/
  373  ls
  374  cd ssh
  375  ls
  376  nano DevOpsKeys1JG
  377  nano DevOpsKeys1JG.pub
  378  ssh -T git@github.com
  379  history -w && grep "ssh-keygen" ~/.bash_history
  380  sudo history -w && sudo grep "ssh-keygen" /root/.bash_history
  381  cd ..
  382  ls
  383  cd MDO2026_ITE/
  384  git branch
  385  cd ..
  386  git remote -v
  387  cd ..
  388  ls
  389  cd jaromirg/
  390  git remote -v
  391  cd MDO2026_ITE/
  392  git remote -v
  393  git remote set-url origin git@github.com:Jarimino/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
  394  git remote -v
  395  cd ..
  396  cd .ssh
  397  ls
  398  nano config
  399  cd ..
  400  ssh -T git@github.com
  401  ls
  402  cd SIMPLE-fork/
  403  git branch
  404  cd .github/workflows/
  405  ls
  406  nano ShiftLeftAcitonsJG.yml
  407  cd ..
  408  ls
  409  nano CMakeLists.txt
  410  cd .github/workflows/
  411  nano ShiftLeftAcitonsJG.yml
  412  cd ..
  413  git remote -v
  414  git remote set-url origin git@github.com:Jarimino/SIMPLE-fork.git
  415  git remote -v
  416  git add .
  417  git branch
  418  git commit -m "Własny workflows do do automatycznego budowania i sprawdzania kodu."
  419  git push origin ino_dev
  420  cd .github/workflows/
  421  nano ShiftLeftAcitonsJG.yml
  422  cd ..
  423  git branch
  424  git add .
  425  git commit -m "Poprawa błędu załączania plików nagłówkowych w workflows."
  426  git push origin ino_dev
  427  cd .github/workflows/
  428  ls
  429  cd ..
  430  history
```