uname

<img width="1372" height="494" alt="image" src="https://github.com/user-attachments/assets/dce8eb8a-9050-4b10-ac7c-7c28bfd85fd6" />

odd_hour

<img width="1216" height="584" alt="image" src="https://github.com/user-attachments/assets/0dfa10c3-8f9d-419c-8a64-37da8ebf7de5" />

pipeline

<img width="1836" height="860" alt="image" src="https://github.com/user-attachments/assets/3fd639de-4a2d-45ed-9d6f-66782f5408f4" />

<img width="896" height="535" alt="image" src="https://github.com/user-attachments/assets/db54bb4d-c69c-4016-8580-7f17fe6cee8e" />

<img width="861" height="636" alt="image" src="https://github.com/user-attachments/assets/c92512a8-d2cb-44cd-ad26-895285233b2b" />

<img width="660" height="202" alt="image" src="https://github.com/user-attachments/assets/aeb5b3db-66b8-4367-825f-423213c9e653" />

W ramach etapu `Build & Run Tests` uruchomiono pełny zestaw testów frameworka Fastify. Pipeline pomyślnie wyizolował proces testowy w dedykowanym kontenerze.

**Podsumowanie wykonania:**
* **Status Pipeline:** FAILURE.
* **Sukcesy:** Poprawnie wykonano setki testów dotyczących schematów, enkapsulacji oraz obsługi błędów.
* **Wykryte problemy:**
    * Wykryto błąd połączenia `ECONNREFUSED` w testach `clientError`, co może sugerować restrykcyjne ustawienia sieciowe wewnątrz kontenera.
    * Wykryto rozbieżność w formatowaniu komunikatów błędów dla `non-numeric content-length`.

**Wniosek techniczny:**
Pipeline spełnił swoje zadanie – zbudował obraz. Dzięki izolacji w Dockerze, błędy w testach nie wpłynęły na stabilność serwera Jenkins, a logi pozwoliły na szybką identyfikację problematycznych modułów.
