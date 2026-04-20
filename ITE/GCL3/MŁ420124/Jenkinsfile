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