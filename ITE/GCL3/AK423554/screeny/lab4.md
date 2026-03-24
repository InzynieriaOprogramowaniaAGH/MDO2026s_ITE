# LAB 4 - Kursa

## Zachowywanie stanu między kontenerami

bez gita:
<img width="1438" height="779" alt="image" src="https://github.com/user-attachments/assets/7cff0028-9185-4eb1-8244-d401f7053533" />

<img width="840" height="851" alt="image" src="https://github.com/user-attachments/assets/569040d2-f51d-4ab7-8644-8ac08d8f6a22" />

<img width="1482" height="828" alt="image" src="https://github.com/user-attachments/assets/83eea321-9f3f-473e-9421-91c2b601947b" />

z gitem:
<img width="925" height="852" alt="image" src="https://github.com/user-attachments/assets/3d956c95-3275-4f4f-8726-462ea3aa9c6b" />

<img width="1462" height="915" alt="image" src="https://github.com/user-attachments/assets/9bb8099b-aa0c-4468-a1c8-8f4de46dbebe" />


Ręczne zarządzanie woluminami pozwala na pełną kontrolę nad cyklem życia danych, ale jest procesem powolnym i podatnym na błędy ludzkie.
Wykorzystanie Dockerfile z instrukcją RUN --mount automatyzuje ten proces, oferując przyspieszenie dzięki mechanizmowi cache
oraz mniejszy rozmiar obrazu wynikowego dzięki montowaniu typu bind.

## Eksponowanie portu i łączność między kontenerami

badanie ruchu po ip:
<img width="1164" height="913" alt="image" src="https://github.com/user-attachments/assets/543c12d7-a30d-497b-9624-977df2feff59" />

<img width="613" height="540" alt="image" src="https://github.com/user-attachments/assets/f8e1a73a-5a42-4c2b-bfe9-436a1594b34e" />

<img width="1249" height="888" alt="image" src="https://github.com/user-attachments/assets/469a8c78-2d1a-43f8-b1d2-787ad688f9ef" />

badanie ruchu z użyciem nazw:
<img width="751" height="611" alt="image" src="https://github.com/user-attachments/assets/dd9737f8-fa25-41c5-8a85-de90ab371293" />

połączenie spoza kontenera:
<img width="1301" height="792" alt="image" src="https://github.com/user-attachments/assets/ea6083d5-21b4-4e32-bc15-54474cece5fc" />
<img width="998" height="333" alt="image" src="https://github.com/user-attachments/assets/eb4f51d7-c6ed-449f-8e47-972ef87c9f1e" />

Wygenerowany log logi_przepustowosci.txt przedstawia proces instalacji narzędzia iperf3 wewnątrz kontenera oraz pomyślne uruchomienie go w trybie serwera na porcie 5201. 
Pomiary wykazują bardzo wysoką przepustowość na poziomie około 23.3 Gbits/sec, co potwierdza, że komunikacja między hostem (172.17.0.1) a kontenerem 
(172.17.0.2) odbywa się bez ograniczeń fizycznego łącza sieciowego. Na końcu logu widoczny jest błąd Bad file descriptor, który wynika z gwałtownego
przerwania sesji przez klienta, jednak nie wpływa on na wiarygodność zebranych wcześniej danych o transferze.

## Usługi w rozumieniu systemu, kontenera i klastra

## Przygotowanie do uruchomienia serwera Jenkins
