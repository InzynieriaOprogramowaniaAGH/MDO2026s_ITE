```sh
MSG_FILE="$1"
MSG="$(sed -n '1p' "$MSG_FILE")"

PREFIX="YK424367"

echo "$MSG" | grep -q "^$PREFIX" || {
  echo "No '$PREFIX'" >&2
  exit 1
}

exit 0
```

## Zrzuty ekranu

![VM](Screenshot%202026-03-03%20at%2009.27.05.png)

![Klonowanie repozytorium po SSH](Screenshot%202026-03-03%20at%2009.38.40.png)

REPOSITORY                         TAG       IMAGE ID       CREATED         SIZE
mcr.microsoft.com/dotnet/sdk       latest    b04611ee9e1b   2 weeks ago     942MB
mcr.microsoft.com/dotnet/runtime   latest    c29a58701692   2 weeks ago     232MB
mariadb                            latest    b5e2b28c0536   2 weeks ago     362MB
fedora                             latest    db87ba79973f   4 weeks ago     193MB
hello-world                        latest    ca9905c726f0   7 months ago    5.2kB
busybox                            latest    cd9176cd36f9   17 months ago   4.11MB

CONTAINER ID   IMAGE                              COMMAND                  CREATED          STATUS                      PORTS     NAMES
bef7a2ca6a9b   mcr.microsoft.com/dotnet/sdk       "/bin/bash"              46 seconds ago   Exited (0) 45 seconds ago             practical_turing
f2d09e98052a   mcr.microsoft.com/dotnet/runtime   "/bin/bash"              4 minutes ago    Exited (0) 4 minutes ago              gracious_montalcini
d2af9b1d4d47   mariadb                            "docker-entrypoint.s…"   5 minutes ago    Exited (1) 5 minutes ago              vigilant_khayyam
12f3ddb5be00   fedora                             "/bin/bash"              7 minutes ago    Exited (0) 7 minutes ago              sleepy_clarke
5d2bfffc6dae   busybox                            "sh"                     8 minutes ago    Exited (0) 8 minutes ago              keen_margulis
98b6b7dc5de4   hello-world                        "/hello"                 10 minutes ago   Exited (0) 10 minutes ago             beautiful_bohr

sudo docker run -it busybox
/ # busybox --version
--version: applet not found
/ # busybox --help
BusyBox v1.37.0 (2024-09-26 21:31:42 UTC) multi-call binary.
BusyBox is copyrighted by many authors between 1998-2015.
Licensed under GPLv2. See source distribution for detailed
copyright notices.

[root@8d7eee9ccca3 /]# ps -p 1
    PID TTY          TIME CMD
      1 pts/0    00:00:00 bash

sudo docker ps -a -l
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS                      PORTS     NAMES
8d7eee9ccca3   fedora    "/bin/bash"   5 minutes ago   Exited (0) 10 seconds ago             nifty_lovelace

ubuntu@myserver:~/MDO2026s_ITE/ITE/GCL3/YK424367/Sprawozdanie2$ sudo docker run -it mdo-ite:sprawozdanie2
[root@ea68b3384e6c]# ls
MDO2026s_ITE
[root@ea68b3384e6c]# cd MDO2026s_ITE/
[root@ea68b3384e6c MDO2026s_ITE]# ls
README.md  READMEs
[root@ea68b3384e6c MDO2026s_ITE]# 