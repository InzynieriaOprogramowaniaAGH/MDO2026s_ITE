AMELIA KURSA | ITE GR.3 | 423554| LAB 1

SKRYPT:
```
#!/bin/bash
commit_msg=$(cat "$1")
pattern="^AK423554"

if [[ ! $commit_msg =~ $pattern ]]; then
  echo "Blad: wiadomosc musi sie zaczynac od AK423554"
  exit 1
fi
```
SCREENY:
<img width="958" height="271" alt="image" src="https://github.com/user-attachments/assets/d3c4612e-45af-40b3-b0ae-3b37288cc559" />

<img width="1475" height="985" alt="image" src="https://github.com/user-attachments/assets/985f7352-002c-4acc-b503-4bf5585ed102" />

<img width="1919" height="1023" alt="image" src="https://github.com/user-attachments/assets/e16cfea0-e4dd-4405-b1dc-2fc731a32e15" />
