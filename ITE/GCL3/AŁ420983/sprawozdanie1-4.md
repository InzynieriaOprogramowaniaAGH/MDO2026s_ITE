# Sprawozdanie z zajęć 1-4
# **Lab1:** Wprowadzenie, Git, Gałęzie, SSH

<img width="562" height="156" alt="image" src="https://github.com/user-attachments/assets/665df81d-453d-4f1a-a2f2-74b593af6889" />


---

##  Git Hook

**Treść skryptu**
```#!/bin/bash
commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

pattern="^AŁ420983"

if [[ ! $commit_msg =~ $pattern ]]; then
  echo "BŁĄD: Wiadomość commita musi zaczynać się od: AŁ420983"
  exit 1
fi
```

<img width="562" height="156" alt="image" src="https://github.com/user-attachments/assets/e6b9f2db-b28b-4fd6-8af4-dfc8f6afcba3" />

---

# **Lab2:** Git, Docker i konteneryzacja środowiska

---

## Praca z kontenerami
<img width="1190" height="486" alt="image" src="https://github.com/user-attachments/assets/51afd61f-4431-4ca6-a3bc-7335c0ece98b" />
<img width="371" height="83" alt="image" src="https://github.com/user-attachments/assets/2d48b874-a5ce-4527-a9ac-03759289de3b" />
<img width="572" height="95" alt="image" src="https://github.com/user-attachments/assets/901ec00d-6fcf-4be7-b613-dd4971e81d29" />
<img width="1543" height="228" alt="image" src="https://github.com/user-attachments/assets/ccb6fcd5-d608-4974-9ffa-eeb5939246c3" />
<img width="593" height="461" alt="image" src="https://github.com/user-attachments/assets/77e5b127-030f-4e54-96c9-844344c3e1a0" />


---

## 4. Dockerfile
Treść pliku:
```
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026s_ITE.git

CMD ["/bin/bash"]
```


# **Lab3:** Dockerfiles – kontener jako definicja etapu

## Wybór oprogramowania
* **Nazwa projektu:** `flask`
* **System budowania:** `py`

---

## Budowanie i testowanie


<img width="1054" height="313" alt="image" src="https://github.com/user-attachments/assets/82464d6b-7f1a-4c0d-87f1-71a1fbd1c6ff" />
<img width="887" height="443" alt="image" src="https://github.com/user-attachments/assets/aecdd82b-e8c1-4914-89ae-f2ad575f45fb" />

, gdzie Dockerfile.build

```
FROM python:3.12-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --depth 1 https://github.com/pallets/flask.git .

RUN pip install --no-cache-dir .[test]
RUN pip install pytest
```

Dockerfile.test

```
FROM flask-builder:latest

WORKDIR /app

CMD ["pytest"]
```

# **Lab4:** Dodatkowa terminologia w konteneryzacji, komunikacja i instancja Jenkins

---
<img width="1571" height="1004" alt="image" src="https://github.com/user-attachments/assets/0a8c2ab3-f223-4973-b3e7-b58b421e974d" />
<img width="1327" height="667" alt="image" src="https://github.com/user-attachments/assets/2521be33-7ca2-4afa-a7f0-e05cf39721eb" />
<img width="1321" height="939" alt="image" src="https://github.com/user-attachments/assets/a2e66f5d-ea22-41d4-b626-ad4a377ecc14" />
<img width="1250" height="550" alt="image" src="https://github.com/user-attachments/assets/8134abc2-3c53-4678-b97c-162e8790f214" />
<img width="1231" height="454" alt="image" src="https://github.com/user-attachments/assets/17ab5859-2e89-4ddb-975f-427aeee291bf" />
<img width="1333" height="414" alt="image" src="https://github.com/user-attachments/assets/e437a323-18ab-40d7-96a2-5da93abce8d7" />
<img width="1147" height="264" alt="image" src="https://github.com/user-attachments/assets/707df137-9be8-4cec-85ce-b03b9a481890" />
<img width="1283" height="481" alt="image" src="https://github.com/user-attachments/assets/59603d3b-089d-4f33-a990-5127fc0ba2af" />
<img width="710" height="795" alt="image" src="https://github.com/user-attachments/assets/753e1fb2-35b8-4fb9-a777-4eddec0583bf" />

<img width="1017" height="897" alt="image" src="https://github.com/user-attachments/assets/f39ab5f7-fd3c-44b1-947a-13dae0568ff8" />




