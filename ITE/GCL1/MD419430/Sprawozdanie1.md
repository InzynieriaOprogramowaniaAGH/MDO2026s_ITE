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

![ss1](img/L1-01.png)
![ss2](img/L1-02.png)