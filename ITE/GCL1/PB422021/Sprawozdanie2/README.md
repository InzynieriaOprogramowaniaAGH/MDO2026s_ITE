# Sprawozdanie nr 2

#### Wszystkie zadania wykonałam na Ubuntu Server 24.04 LTS w Hyper-V, poprzez połączenie zdalne przez protokół SSH z poziomu Visual Studio Code.


# Lab5

### Przygotowanie 

Laboratorium rozpoczęłam od przygotowania Jenkinsa z ostatnich zajęć. Na poprzednich zajęciach już go poprawnie skonfigurowałam, więc teraz wystarczyło go poprawnie uruchomić.

Standardowy Jenkind od Blue Ocean różni się głównie interfejsem. Blue Ocean oferuje czytelny graf etapów, dzięki czemu można łatwo zobaczyć, w którym momencie (np. budowanie, testy lub deploy) wystąpił błąd.

![Błąd wyświetlania](lab5_ss/lab5ss1.png)
![Błąd wyświetlania](lab5_ss/lab5ss2.png)

Następnie wpisując odpowiedni adres do przeglądarki i uzyskując wcześniej unikalne hasło z logów zalogowałam się pomyślnie na Jenkinsa.

![Błąd wyświetlania](lab5_ss/lab5ss3.png)


Aby zabezpieczyć logi Jenkinsa zastosowałam woluminy. Główny katalog Jenkinsa został zamapowany poleceniem --volume jenkins-data:/var/jenkins_home. Komenda docker volume inspect jenkins-data potwierdza, że dane są bezpiecznie archiwizowane bezpośrednio na dysku hosta.

![Błąd wyświetlania](lab5_ss/lab5ss4.png)



### Zadanie wstępne: uruchomienie 

- Projekt wyświetlający uname 

Utworzyłam nowy projekt i konsola zwróciła informacje o moim Linuxie, zatem wynik jest poprawny.

![Błąd wyświetlania](lab5_ss/lab5ss5.png)
![Błąd wyświetlania](lab5_ss/lab5ss6.png)
![Błąd wyświetlania](lab5_ss/lab5ss7.png)
![Błąd wyświetlania](lab5_ss/lab5ss8.png)

- Projekt zwracający błąd, kiedy godzina jest nieparzysta


```bash
GODZINA=$(date +%H)
echo "Aktualna godzina: $GODZINA"

if [ $((GODZINA % 2)) -ne 0 ]; then
  echo "Błąd! Godzina jest nieparzysta!"
  exit 1
else
  echo "Godzina jest parzysta!"
  exit 0
fi
```

W przypadku, gdy godzina jest parzysta:

![Błąd wyświetlania](lab5_ss/lab5ss9.png)

W przypadku, gdy godzina jest nieparzysta:

![Błąd wyświetlania](lab5_ss/lab5ss10.png)

- Pobranie obrazu kontenera ubuntu

Utworzyłam nowy projekt i chciałam pobrać obraz dockera. 

![Błąd wyświetlania](lab5_ss/lab5ss11.png)
![Błąd wyświetlania](lab5_ss/lab5ss12.png)

Okazało się jednak, że domyślnie mam niepoprawne ścieżki do certyfikatów TLS wewnątrz kontenera Jenkins. Dlatego musiałam ustawić odpowiednią ścieżkę, aby wszystko zadziałało poprawnie. 

![Błąd wyświetlania](lab5_ss/lab5ss13.png)
![Błąd wyświetlania](lab5_ss/lab5ss14.png)

Aby sprawdzić jeszcze czy poprawnie działa mi dind chwilowo go wyłączyłam zostawiając jedynie blueocean, a następnie uruchomiłam docker pull ubuntu.

![Błąd wyświetlania](lab5_ss/lab5ss15.png)
![Błąd wyświetlania](lab5_ss/lab5ss16.png)

Jak widać w tym przypadku operacja nie zadziałała, co oznacza, że dind działa w sposób poprawny. 


Do dalszej pracy ponownie go uruchomiłam.

![Błąd wyświetlania](lab5_ss/lab5ss17.png)


### Zadanie wstępne: obiekt typu pipeline

Utworzyłam nowy obiekt typu pepieline.

![Błąd wyświetlania](lab5_ss/lab5ss18.png)

Treść pipelinu:

```bash
pipeline {
    agent any
    
    environment {
        DOCKER_CERT_PATH = '/certs/client/client'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'PB422021', 
                    url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git'
            }
        }

        stage('Build Builder Image') {
            steps {
                script {
                    sh 'docker build -f ITE/GCL1/PB422021/Sprawozdanie1/Dockerfile.build -t app-build ITE/GCL1/PB422021/Sprawozdanie1'
                }
            }
        }

        stage('Build Tester Image') {
            steps {
                sh 'docker build -f ITE/GCL1/PB422021/Sprawozdanie1/Dockerfile.test -t tester ITE/GCL1/PB422021/Sprawozdanie1'
                echo 'Testy zakończone sukcesem'
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker image prune -f'
            }
        }
    }
}
```

Zapisałam skrypt i go uruchomiłam. Wszystko przeszło pomyślnie.

![Błąd wyświetlania](lab5_ss/lab5ss19.png)
![Błąd wyświetlania](lab5_ss/lab5ss20.png)
![Błąd wyświetlania](lab5_ss/lab5ss21.png)

Grafika interfejsu blue ocean przedstawia poprawny przebieg wszystkich zdefiniowanych etapów: pobranie kodu, budowanie obrazu builder, budowanie obrazu tester oraz czyszczenie środowiska.


Uruchomiłam pipeline ponownie i widać, że czas budowania był krótszy. Wynika to z tego, że przy pierwszym uruchomieniu Docker musiał pobrać obraz Node.js, zainstalować pakiety i zbudować wszystko od zera.

![Błąd wyświetlania](lab5_ss/lab5ss22.png)