# LAB 3 - AMELIA KURSA

## Wybór oprogramowania na zajęcia - Fortify
<img width="1099" height="172" alt="image" src="https://github.com/user-attachments/assets/08e337e2-057f-4ec9-942a-d1b49e9c0711" />
<img width="945" height="691" alt="image" src="https://github.com/user-attachments/assets/a9b1742a-5727-4d26-9ac9-09838a180093" />

Podczas testów w kontenerze node:20 pojawiły się błędy w 7 przypadkach (np. ECONNREFUSED, timeout). Z logów wynika, że są one spowodowane ograniczeniami środowiska kontenerowego (sieć, zasoby), a nie błędami w konfiguracji aplikacji. Potwierdza to, że kontener działa w izolacji od systemu hosta.

## Izolacja i powtarzalność: build w kontenerze
<img width="1462" height="700" alt="image" src="https://github.com/user-attachments/assets/c8e261a0-ad21-4079-9b09-f58ca299e345" />
<img width="1091" height="605" alt="image" src="https://github.com/user-attachments/assets/7aa7ce8d-1ec5-4c49-9762-99b869f305b8" />
<img width="1001" height="644" alt="image" src="https://github.com/user-attachments/assets/6e34e5a6-72cf-49df-9239-7233e76d94c3" />
