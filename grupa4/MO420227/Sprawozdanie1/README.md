# Sprawozdanie MO420227

## 1. Konfiguracja środowiska
* **Git:** Zainstalowano, skonfigurowano dane użytkownika i sklonowano repozytorium przez SSH.
* **SSH:** Wygenerowano klucze (Ed25519 z hasłem oraz ECDSA). 
![alt text](ssh1.png)
![alt text](ssh2.png)
Skonfigurowano dostęp do GitHub.
![alt text](ssh_w_git.png)
* **IDE:** Skonfigurowano zdalną pracę w VS Code (Remote-SSH).

## 2. Praca z gałęziami i Git Hook
* Utworzono gałąź: `MO420227`.
![alt text](branch.png)
* Wdrożono skrypt `commit-msg` w `.git/hooks/`, wymuszający prefiks `MO420227`.
![alt text](hook.png)
![alt text](test_hooka.png)

## 3. Dowody
**Zrzut z Pull Requesta:**
![Pull Request](pull-request.png)

