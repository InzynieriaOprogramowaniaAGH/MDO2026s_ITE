# Sprawozdanie 2

## Lab 5: Pipeline, Jenkins, izolacja etapów

**Środowisko: Maszyna wirtualna Ubuntu Server w Hyper-V na systemie operacyjnym Windows 11**  

Wymusiłam zakończenie działania kontenera jenkins-server z poprzednich zajęć, by postawić nowego Jenkinsa z Blue Ocean.  

![kill jenkins-server](<Lab5/Zrzut ekranu 2026-06-25 154206.png>)  

Uruchomiłam obraz Jenkinsa, który ma już wbudowane paczki Blue Ocean i sprawdziłam logi.   

![jenkins-blueocean](<Lab5/Zrzut ekranu 2026-06-25 155235.png>)  

Z sukcesem otworzyłam Blue Ocean w przeglądarce.  

![blue ocean](<Lab5/Zrzut ekranu 2026-06-25 155825.png>)  

Kolejne zadanie źle zrozumiałam i próbowałam je wykonać przez Jenkinsfile'a. Głównym problemem okazało się uruchomienie polecenia *docker pull*. Próbowałam rozwiązać problem z pomocą AI wklejając jako promty moje błędy zwrócone przez konsolę w Jenkinsie. Na początku dodałam Jenkinsfile do mojego githuba i połączyłam się z moją gałęzią na Jenkinsie.   

![branch indexing](<Lab5/Zrzut ekranu 2026-06-28 131023.png>)  

Większość błędów wyświetlanych przez Jenkinsa to *docker: not found*. Pierwszą próbą naprawienia było podpięcie socketa dockera.  

![socket](<Lab5/Zrzut ekranu 2026-06-28 133720.png>)  

Następnie usunęłam zbędne obrazy i komendy.  

![usunięcie mavena](<Lab5/Zrzut ekranu 2026-06-28 133916.png>)  

Okazało się jednak, że błędnie próbowałam sprecyzować agenta.  

![invalid agent type specified](<Lab5/Zrzut ekranu 2026-06-27 143258.png>)  

Pobrałam wszystkie pluginy związane z Dockerem.  

![pluginy](<Lab5/Zrzut ekranu 2026-06-25 165311.png>)  

Próbowałam również użyć obrazu ubuntu z poziomu agenta.  

![obraz ubuntu](<Lab5/Zrzut ekranu 2026-06-28 140414.png>)  

Błąd wykazał, że klient nie wysłał żądania do kontenera DinD.  

![API error](<Lab5/Zrzut ekranu 2026-06-27 143431.png>)  

Dodałam więc zmienne środowiskowe, które powinny pozwolić połączyć się klientowi z kontenerem DinD za pomocą sieci.  

![zmienne środowiskowe](<Lab5/Zrzut ekranu 2026-06-28 171120.png>)  

Wewnątrz nowo utworzonego kontenra brakowało certyfikatów TLS.  

![cert error](<Lab5/Zrzut ekranu 2026-06-27 143558.png>)  

W związku z tym, połączyłam się testowo po zwykłym porcie HTTP, by nie były wymagane certyfikaty.  

![HTTP error](<Lab5/Zrzut ekranu 2026-06-27 143603.png>)  

Po teście połączyłam się w ten sam sposób wewnątrz sieci mostkowej, wcześniej przeze mnie utworzonej.  

![jenkins-net](<Lab5/Zrzut ekranu 2026-06-28 172604.png>)  

Zadanie wykonało się poprawnie, ale błąd wystąpił wewnątrz wtyczki, prawdopodbnie przy pobraniu informacji na temat obiektów Dockera.  

![docker inspekt fail](<Lab5/Zrzut ekranu 2026-06-25 171936.png>)  

Zamiast wtyczki, spróbowałam rozwiązać wszystko poprzez bash. Dodałam zmienną środowiskową wewnątrz skryptu.  

![zmienna w bashu](<Lab5/Zrzut ekranu 2026-06-28 173501.png>)  

Otrzymałam błąd związany z demonem - klient nie był w stanie skomunikować się z nim.  

![daemon error](<Lab5/Zrzut ekranu 2026-06-27 143633.png>)  

Moje błędy wynikały z niezrozumienia Docker-in-Docker. Dlatego też rozwiązaniem problemu było pobranie dockera wewnątrz kontenera Jenkinsa - jest on potrzebny wewnątrz niego jako program, który wysyła polecenia do demona wewnątrz DinD. Zrezygnowałam również z Jenkinsfile'a, by powrócić do niego w momencie wyznaczonym przez instrukcję.  

![docker install](<Lab5/Zrzut ekranu 2026-06-28 125343.png>)  

Wszystkie zadania zwróciły sukces, co dowodzi temu, że Jenkins działa.    

![success](<Lab5/Zrzut ekranu 2026-06-28 125502.png>)  

Zadanie wyświtlające uname.  

![uname](<Lab5/Zrzut ekranu 2026-06-27 213503.png>)  

Zadanie zwracające błąd, gdy godzina jest nieparzysta.  

![hour even](<Lab5/Zrzut ekranu 2026-06-27 213410.png>)  

Zadanie pobierające obraz ubuntu.  

![docker pull](<Lab5/Zrzut ekranu 2026-06-28 130431.png>)  

Następnie napisałam pipeline, który sklonował repo przedmiotowe, zrobił checkout do pliku *Docker.builder* z poprzednich zajęć i zbudował go.  

![pipeline Docker.builder](<Lab5/Zrzut ekranu 2026-06-28 192132.png>)  

Za piewrszym razem pipeline wykonywał się 2 min i 8 s.

![pierwszy pipeline](<Lab5/Zrzut ekranu 2026-06-28 192149.png>)  

Za drugim uruchomieniem tylko 3.4 s. Związane jest to z cachem - Docker ma wbudowany mechanizm pamięci podręcznej, który sprawdza identyfikator obrazu oraz czy pliki w projekcie się zmieniły od ostatniego razu.  

![drugi pipeline](<Lab5/Zrzut ekranu 2026-06-28 192157.png>)  


Opracowałam pdf z wymaganym wstępnym środowiskiem diagramem aktywności oraz wdrożeniowym -> json_java_CI.pdf.  
 




## Lab 6: Pipeline: lista kontrolna

**Środowisko: Maszyna wirtualna Ubuntu Server w Hyper-V na systemie operacyjnym Windows 11**  


## Lab 7: Jenkinsfile: lista kontrolna

**Środowisko: Maszyna wirtualna Ubuntu Server w Hyper-V na systemie operacyjnym Windows 11**  


## Promty AI
AI używałam do rozwiązywania błędów oraz doprecyzowywania zagadnień, gdy nie rozumiałam w jaki sposób dane narzędzie działa:
- Błędy związane z uruchomieniem docker pull
- Jak działa cache w pipeline
- Przekonwertuj tego jsona w stringa (przekazałam mu plik pobrany z internetu)