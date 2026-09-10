# Proces CI dla projektu Axios

## Wymagania wstępne środowiska

Proces CI został przygotowany dla projektu Axios w wersji `1.20.0`.

Środowisko składa się z:

* maszyny `server` z zainstalowanym Dockerem,
* kontenera `jenkins-blueocean` z Jenkins,
* osobnego kontenera Docker-in-Docker `jenkins-docker`,
* repozytorium `MDO2026s_ITE` dostępnego w GitHub,
* osobistej gałęzi `DC417539`,
* pliku `Jenkinsfile` przechowywanego w:
  `ITE/GCL1/DC417539/Lab05/Jenkinsfile`,
* obrazu bazowego Buildera `node:26.8.1-bookworm`,
* obrazu runtime `node:26.8.1-bookworm-slim`.

Jenkins korzysta z osobnego demona Docker uruchomionego w kontenerze DIND. Obrazy tworzone przez pipeline są dzięki temu odseparowane od obrazów znajdujących się bezpośrednio na hoście.

## Przebieg procesu CI

Proces rozpoczyna się od etapu `Collect`, realizowanego przez automatyczny checkout SCM. Jenkins pobiera `Jenkinsfile` oraz pozostałe pliki z gałęzi `DC417539`.

Następnie wykonywany jest etap `Build`. Na podstawie `Dockerfile.build` tworzony jest obraz `axios-build:v1.20.0`, w którym pobierany jest kod Axios, instalowane są zależności i wykonywane jest `npm run build`.

Etap `Test` tworzy osobny obraz `axios-test:jenkins` na podstawie obrazu Buildera. W kontenerze uruchamiany jest zestaw testów jednostkowych projektu. Logi testów są dostępne w `Console Output` Jenkinsa, dzięki czemu możliwe jest ustalenie, które testy zakończyły się niepowodzeniem.

Etap `Report` jest realizowany przez logi Jenkinsa oraz wynik poszczególnych etapów pipeline'u. Niepowodzenie testów powoduje zatrzymanie dalszej części procesu.

Po poprawnym przejściu testów wykonywany jest `Deploy`. Tworzony jest pakiet `axios-1.20.0.tgz`, który następnie instalowany jest w osobnym obrazie runtime bazującym na `node:26.8.1-bookworm-slim`. Poprawność wdrożenia jest weryfikowana przez uruchomienie biblioteki i wyświetlenie jej wersji:

`Axios version: 1.20.0`

Ostatnim etapem jest `Publish`. Pipeline tworzy wersjonowany pakiet npm `axios-1.20.0.tgz` i zapisuje go w Jenkinsie przy użyciu `archiveArtifacts`. Artefakt jest następnie dostępny do pobrania z wyników konkretnego buildu.

## Diagram aktywności

Diagram aktywności procesu CI znajduje się w pliku:

`activity.puml`

Przedstawia on przepływ:

`Collect → Build → Test → Report → Deploy → Publish`

oraz przypadek zakończenia pipeline'u błędem, gdy testy nie przechodzą.

## Diagram wdrożeniowy

Diagram wdrożeniowy znajduje się w pliku:

`deployment.puml`

Przedstawia relacje pomiędzy maszyną `server`, kontenerem Jenkins, środowiskiem Docker-in-Docker, kontenerami Builder, Tester i Runtime, repozytorium GitHub oraz artefaktem `axios-1.20.0.tgz`.

## Uzasadnienie etapów Deploy i Publish

Axios jest biblioteką JavaScript przeznaczoną do instalacji jako zależność w innych projektach, a nie samodzielną aplikacją serwerową. Z tego powodu najbardziej naturalną formą redystrybucji jest wersjonowany pakiet npm.

W etapie `Publish` tworzony jest plik:

`axios-1.20.0.tgz`

przy użyciu polecenia `npm pack`. Pakiet zawiera kod biblioteki oraz pliki potrzebne do jej instalacji i wykorzystania przez użytkownika. Nie zawiera natomiast logów Jenkinsa ani wyników procesu CI. Gotowy plik `.tgz` jest archiwizowany przez Jenkins i udostępniany jako artefakt konkretnego buildu.

Dystrybucja Axiosa wyłącznie jako obrazu Docker nie jest podstawowym sposobem udostępniania tej biblioteki. Obraz Docker został wykorzystany w etapie `Deploy` jako środowisko docelowe pozwalające zweryfikować, czy przygotowany pakiet można poprawnie zainstalować i uruchomić w czystym środowisku runtime.

Obraz runtime nie powinien zawierać całego sklonowanego repozytorium, logów Jenkinsa, testów ani narzędzi wymaganych wyłącznie do budowania programu. Powinien zawierać jedynie środowisko wykonawcze i gotowy artefakt potrzebny do działania biblioteki.

Do budowania wykorzystano obraz:

`node:26.8.1-bookworm`

Natomiast obraz runtime bazuje na:

`node:26.8.1-bookworm-slim`

Pełny obraz `node` zawiera szerszy zestaw narzędzi i bibliotek systemowych, dlatego jest wygodniejszy podczas budowania oprogramowania. Wariant `node-slim` zawiera ograniczony zestaw pakietów systemowych i zajmuje mniej miejsca, dlatego lepiej nadaje się do obrazu przeznaczonego wyłącznie do uruchamiania gotowego artefaktu.

W etapie `Deploy` pakiet `axios-1.20.0.tgz` jest instalowany w osobnym obrazie runtime. Poprawność wdrożenia jest następnie sprawdzana przez uruchomienie Axiosa i odczyt jego wersji:

`Axios version: 1.20.0`

Takie podejście rozdziela środowisko budowania, testowania i uruchamiania oraz pozwala zweryfikować, że artefakt przygotowany do publikacji może zostać wykorzystany niezależnie od kontenera Buildera.

## Jenkins i Blue Ocean

Jenkins jest serwerem automatyzacji odpowiedzialnym za wykonywanie zadań CI/CD, zarządzanie projektami, uruchamianie pipeline'ów oraz przechowywanie ich wyników i logów.

Blue Ocean jest rozszerzeniem Jenkinsa udostępniającym alternatywny interfejs użytkownika, szczególnie przeznaczony do wizualizacji pipeline'ów. Nie zastępuje samego Jenkinsa ani jego mechanizmu wykonywania zadań.

W przygotowanym środowisku wykorzystano obraz bazowy jenkins/jenkins:2.568.3-jdk21, do którego doinstalowano między innymi plugin blueocean. Dzięki temu ten sam kontener udostępnia zarówno standardowy interfejs Jenkinsa, jak i widok Blue Ocean.