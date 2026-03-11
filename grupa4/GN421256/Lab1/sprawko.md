# Git pobrany na maszynie
![Git dziala](git.png)
# Klonowanie repo
![Klonowanie repo](git_clone.png)
użyto personal access token githuba

# Tworzenie kluczy SSH
1. Chroniony hasłem klucz ed25519
![ed25519](sshed25519.png)
2. Nie chroniony klucz ecdsa
![ecdsa](ecdsa.png)

Jeden z tych kluczy został dodany do konta github aby służyć jako klucz dostępu, dzięki czemu możemy sklonować repo przez ssh, lecz najpierw sprawdzimy czy działa połączenie
![sprawdzenie](sprawdzeniesshgit.png)
Po otrzymaniu takiego komunikatu wiadomo że jest ok
![sshgit](sshgit.png)

# Tworzenie nowej gałęzi repozytorium
![main](checkoutmain.png)
![grupa](checkoutgrupa4.png)
![nowybranch](nowybranch.png)

Po stworzeniu odpowiedniego katalogu został napisany git hook (treść na końcu sprawozdania)

![hookdziala](githookdziala.png)


```{bash}
git
git clone {link}
ssh-keygen -t ed25519 -C "Klucz-Na-Zaj-ed25519" -f ~/.ssh/id_ed25519_na_zaj
ssh-keygen -t ecdsa -b 521 -C "Klucz-Na-Zaj-ed25519" -f ~/.ssh/id_ed25519_na_zaj
ssh -T git@github
git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
git checkout main
git checkout grupa4
git checkout -b GN421256


```

# Treść GitHook
```{bash}
#!/bin/bash

PREFIX="GN421256: "

if ! grep -q "^$PREFIX" "$1"; then
    echo "Commit message must start with $PREFIX"
  exit 1
fi
```