FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /app

RUN dotnet new console -n QRTest --force

COPY *.dll ./QRTest/libs/
COPY Program.cs ./QRTest/Program.cs

RUN sed -i 's|</Project>||' QRTest/QRTest.csproj && \
    echo '  <ItemGroup><Reference Include="Genocs.QRCodeLibrary"><HintPath>libs/Genocs.QRCodeLibrary.dll</HintPath></Reference></ItemGroup></Project>' >> QRTest/QRTest.csproj

WORKDIR /app/QRTest
RUN dotnet build
RUN dotnet run