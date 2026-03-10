Metodyki DevOps Sprawozdanie Illia Kuziv ITE gr.3

Git Hook 
```
#!/bin/sh

COMMIT_MSG=$(head -n 1 $1)

REGEX="^(IK424364: )"

if [[ ! $COMMITMSG =~ $REGEX ]]; then
	echo "Error: Commit message should start with $REGEX"
	echo "Your commit message: $COMMIT_MSG"
	exit 1
fi

exit 0
```

![scr1](./cw1/Screenshot_1.png)

Przykładowy kod Dockerfile:

```
FROM ubuntu:22.04

RUN apt update && apt install git -y

RUN git --version

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["/bin/bash"]
```