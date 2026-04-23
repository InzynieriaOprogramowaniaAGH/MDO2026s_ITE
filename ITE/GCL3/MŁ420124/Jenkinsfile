pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Image') {
            steps {
                sh 'docker build -t qrcodebld -f Dockerfile.qrcode.bld .'
            }
        }

        stage('Test') {
            steps {
                sh 'docker build -t qrcodetests -f Dockerfile.qrcode.tests .'
                sh 'docker run --rm qrcodetests'
            }
        }

        stage('Verify') {
            steps {
                script {
                    sh '''
                    docker run --rm -v $(pwd):/app -w /app qrcodebld bash -c "
                    dotnet new console -n TestProj --force
                    dotnet add TestProj/TestProj.csproj reference src/Genocs.QRCodeLibrary/Genocs.QRCodeLibrary.csproj
                    
                    cat <<EOF > TestProj/Program.cs
using System;
using System.IO;
using Genocs.QRCodeGenerator.Encoder;

try {
    var generator = new QRCodeGenerator();
    var data = generator.CreateQrCode(\\"https://jenkins.io\\", QRCodeGenerator.ECCLevel.Q);
    var qr = new BitmapByteQRCode(data);
    byte[] bmpBytes = qr.GetGraphic(5);
    File.WriteAllBytes(\\"qrcode.bmp\\", bmpBytes);
    Console.WriteLine(\\"Success! Test Passed.\\");
} catch (Exception ex) {
    Console.WriteLine(\\"Test Failed: \\" + ex.Message);
    Environment.Exit(1);
}
EOF
                    dotnet run --project TestProj/TestProj.csproj
                    "
                    '''
                }
            }
        }

        stage('NuGet Packaging') {
            steps {
                sh '''
                docker run --rm -v $(pwd):/app -w /app qrcodebld bash -c "
                dotnet build src/Genocs.QRCodeLibrary/Genocs.QRCodeLibrary.csproj -c Release
                dotnet pack src/Genocs.QRCodeLibrary/Genocs.QRCodeLibrary.csproj -c Release -o /app/final_artifacts
                "
                '''
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