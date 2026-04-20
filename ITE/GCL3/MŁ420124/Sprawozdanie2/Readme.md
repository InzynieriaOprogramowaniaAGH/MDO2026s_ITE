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

Skrypt `docker-pull-test` (pipeline)
```bash
pipeline {
    agent any
    stages {
        stage('clone repository') {
            steps {
                git branch: 'MŁ420124',
                url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
            }
        }
        stage('build docker image') {
            steps {
                script {
                    dir('ITE/GCL3/MŁ420124/Dockerfiles') {
                        def customImage = docker.build(
                            "devskillerbld:${env.BUILD_ID}",
                            "-f Dockerfile.devskiller.bld ."
                        )
                    }
                }
            }
        }
    }
}
```

## Class06

- Aplikacja została wybrana. Wybrano repozyturium https://github.com/Genocs/qrcode. Jest to .NET biblioteczny, możliwy do zbudowania za pomocą polecenia `dotnet build` oraz posiadający szereg testów do przeprowadzania ćwiczenia.

- Licencja potwierdza możliwość swobodnego obrotu kodem. Kod korzysta z licencji MIT.

- Wybrany program buduje się oraz przechodzą dołączone do niego testy.

- Zdecydowano, czy jest potrzebny fork własnej kopii repozytorium. Potrzebne jest napisanie pliku, który posłuży do przetestowania działania biblioteki. Dokonano własnego forka: https://github.com/maksluczak/qrcode#

- Stworzono diagram UML zawierający planowany pomysł na proces CI/CD

- Wybrano kontener bazowy lub stworzono odpowiedni kontener wstepny (runtime dependencies). Zdecydowano, że będzie to mcr.microsoft.com/dotnet/sdk:8.0 odpowiadający wymaganiom aplikacji.

- Build został wykonany wewnątrz kontenera. Stworzono Dockerfile `Dockerfile.qrcode.bld`, a następnie uruchomiono go w wyizolowanym środowisku za pomocą 

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0

RUN apt-get update && apt-get install -y git
WORKDIR /App

RUN git clone https://github.com/maksluczak/qrcode.git

WORKDIR /App/qrcode

RUN dotnet restore
RUN dotnet build
```

a następnie uruchomiono go w wyizolowanym środowisku za pomocą 

```bash
sudo docker build -t qrcodebld -f ./Dockerfile.qrcode.bld .
```

- Testy zostały wykonane wewnątrz kontenera (kolejnego). Kontener testowy jest oparty o kontener build

```dockerfile
FROM qrcodebld:latest

WORKDIR /App/qrcode

RUN dotnet test
```

```bash
sudo docker build -t qrcodetests -f ./Dockerfile.qrcode.tests .
```

- Logi z procesu są odkładane jako numerowany artefakt, niekoniecznie jawnie

- Zdefiniowano kontener typu 'deploy' pełniący rolę kontenera, w którym zostanie uruchomiona aplikacja (niekoniecznie docelowo - może być tylko integracyjnie)

```bash
sudo docker create --name temp_conteiner qrcodebld
sudo docker cp temp_conteiner:/app/src/Genocs.QRCodeLibrary/bin/Release/net8.0/Genocs.QRCodeLibrary.dll ./Genocs.QRCodeLibrary.dll
sudo docker rm temp_conteiner
```

- Uzasadniono czy kontener buildowy nadaje się do tej roli/opisano proces stworzenia nowego, specjalnie do tego przeznaczenia

- Wersjonowany kontener 'deploy' ze zbudowaną aplikacją jest wdrażany na instancję Dockera

- Następuje weryfikacja, że aplikacja pracuje poprawnie (smoke test) poprzez uruchomienie kontenera 'deploy'

- Zdefiniowano, jaki element ma być publikowany jako artefakt

- Uzasadniono wybór: kontener z programem, plik binarny, flatpak, archiwum tar.gz, pakiet RPM/DEB

- Opisano proces wersjonowania artefaktu (można użyć semantic versioning)

- Dostępność artefaktu: publikacja do Rejestru online, artefakt załączony jako rezultat builda w Jenkinsie

```bash
pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'sudo docker build -t qrcodebld -f Dockerfile.qrcode.bld .'
            }
        }

        stage('Test') {
            steps {
                sh 'sudo docker build -t qrcodetests -f Dockerfile.qrcode.tests .'
                sh 'sudo docker run --rm qrcodetests'
            }
        }

        stage('Verify') {
            steps {
                script {
                    sh 'sudo docker create --name temp_container qrcodebld'
                    sh 'sudo docker cp temp_container:/app/src/Genocs.QRCodeLibrary/bin/Release/net8.0/Genocs.QRCodeLibrary.dll ./Genocs.QRCodeLibrary.dll'
                    sh 'sudo docker rm temp_container'

                    sh 'dotnet new console -n TestProj --force'
                    
                    writeFile file: 'TestProj/TestProj.csproj', text: """
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="Genocs.QRCodeLibrary">
      <HintPath>../Genocs.QRCodeLibrary.dll</HintPath>
    </Reference>
  </ItemGroup>
</Project>
"""
                    writeFile file: 'TestProj/Program.cs', text: """
using System;
using System.IO;
using Genocs.QRCodeGenerator.Encoder;

try {
    var generator = new QRCodeGenerator();
    var data = generator.CreateQrCode("https://example.com", QRCodeGenerator.ECCLevel.Q);
    var qr = new BitmapByteQRCode(data);
    byte[] bmpBytes = qr.GetGraphic(5);
    File.WriteAllBytes("qrcode.bmp", bmpBytes);
    Console.WriteLine("Success! Test Passed.");
} catch (Exception ex) {
    Console.WriteLine("Test Failed: " + ex.Message);
    Environment.Exit(1);
}
"""
                    dir('TestProj') {
                        sh 'dotnet run'
                    }
                }
            }
        }

        stage('NuGet Packaging') {
            steps {
                sh 'sudo docker run --name pack_job qrcodebld dotnet pack src/Genocs.QRCodeLibrary/Genocs.QRCodeLibrary.csproj -c Release -o /app/pkg'
                sh 'mkdir -p ./final_artifacts'
                sh 'sudo docker cp pack_job:/app/pkg/. ./final_artifacts/'
                sh 'sudo docker rm pack_job'
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'final_artifacts/*.nupkg, TestProj/qrcode.bmp', fingerprint: true
            echo "Task completed successfully. Artifacts saved."
        }
        failure {
            echo "Pipeline terminated with error."
        }
    }
}
```

- Przedstawiono sposób na zidentyfikowanie pochodzenia artefaktu

- Pliki Dockerfile i Jenkinsfile dostępne w sprawozdaniu w kopiowalnej postaci oraz obok sprawozdania, jako osobne pliki

- Zweryfikowano potencjalną rozbieżność między zaplanowanym UML a otrzymanym efektem