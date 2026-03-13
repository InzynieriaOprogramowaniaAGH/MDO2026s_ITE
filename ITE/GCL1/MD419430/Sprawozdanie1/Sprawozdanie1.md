# Laboratorium1
## 1. Implementacja Githooka (commit-msg)

W ramach zadania przygotowałem skrypt typu `githook`, który wymusza określoną strukturę wiadomości commita. Każdy commit musi zaczynać się od identyfikatora `MD419430`.

### Kod skryptu:
```bash
#!/bin/bash

message=$(cat "$1")

pattern="^MD419430"

if [[ ! $message =~ $pattern ]]; then
    echo "Błąd: commit message musi zaczynać się od MD419430"
    exit 1
fi

```
![alt text](../img/L1/L1-01.png)
![alt text](../img/L1/L1-02.png) 

## 2. Pull request'u
Utworzono Pull Request z gałęzi MD419430 do gałęzi grupowej GCL1.
Pull Request zawiera dwa commity:
- MD419430 pierwszy commit
- MD419430 dodanie sprawozdania

![alt text](../img/L1/L1-03.png) 
![alt text](../img/L1/L1-04.png)

# Laboratorium2
![alt text](../img/L2/L2-01.png)
![alt text](../img/L2/L2-02.png)
![alt text](../img/L2/L2-03.png) 
![alt text](../img/L2/L2-04.png) 
![alt text](../img/L2/L2-05.png) 
![alt text](../img/L2/L2-06.png) 
![alt text](../img/L2/L2-07.png) 
![alt text](../img/L2/L2-08.png) 
![alt text](../img/L2/L2-09.png) 
![alt text](../img/L2/L2-10.png) 
![alt text](../img/L2/L2-11.png) 
![alt text](../img/L2/L2-12.png)