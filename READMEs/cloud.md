# Prawo Conway'a i AWS
- Uzupełnienie do opcjonalnego sprawozdania nr 4

## Zadania do wykonania
Celem ćwiczenia jest wdrożenie dowolnej aplikacji webowej na chmurze AWS w [formie](https://www.melconway.com/Home/Conways_Law.html) *three-tier architecture*. Aplikacja powinna składać się co najmniej z następujących komponentów:
- *frontend*, np. React, Vue
- *backend*, np. Nodejs, Django
- baza danych z puli dostępnych na chmurze.
Nie ma wymagań co do funkcjonalności - może to być wyświetlanie treści zwracanej przez jeden *endopoint*, uzupełnianej o dane z bazy danych.

## Polecenia
0. Upewnij się, że wykorzystujesz zasoby regionu `us-east-1`
1. Stwórz trzy [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html), umieszczając je w domyślnym [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) (Virtual Private Cloud):
    - Dla bazy danych - pozwól na dowolny ruch wychodzący (outbound rules) oraz na _bezpieczny_ przychodzący (inbound rules).
    - Dla aplikacji backendowej - pozwól na dowolny ruch wychodzący (outbound rules) oraz na _bezpieczny_ przychodzący (inbound rules). Testowo należy dodać możliwość komunikacji poprzez SSH.
    - Dla aplikacji frontendowej - pozwól na dowolny ruch wychodzący (outbound rules) oraz _bezpieczny_ przychodzący (inbound rules). Testowo należy dodać możliwość komunikacji poprzez SSH.
2. Stwórz maszyny wirtualne dla aplikacji `backend` oraz `frontend` w ramach usługi [EC2](https://aws.amazon.com/ec2/). Zalecane parametry:
    - System operacyjny: [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/)
    - Typ instancji: [`t2.micro`](https://aws.amazon.com/ec2/instance-types/t2/)
    - [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html): użyj stworzonego domyślnie
    - Umieść maszyny we właściwych Security Groupach stworzonych w punkcie 2
3. Skonfiguruj maszyny wirtualne dla aplikacji  `backend` oraz `frontend`, by mogły zostać prawidłowo uruchomione.
4. Stwórz bazę danych w dowolnej usłudze bazodanowej. Zalecane parametry:
    - Usługa [RDS](https://aws.amazon.com/rds/)
    - Baza MySQL
    - Template: *free tier*
    - Typ instancji: dowolny `micro` lub `small`
    - Dostęp publiczny ustawić na wyłączony (domyślna wartość)
    - Umieść tworzoną bazę w Security Groupie stworzonej w punkcie 2b
    - Wyłącz [*performance insights*](https://aws.amazon.com/rds/performance-insights/), backup oraz encryption (mogą mieć wpływ na koszty)
5. Zweryfikuj:
    - Połączenie pomiędzy backendem a bazą danych. W razie potrzeby wgraj backup bazy z poziomu maszyny EC2.
    - Połączenie pomiędzy frontendem a backendem.
    - Dostępność frontendu z adresu publicznego.
    - Brak dostępu do backendu oraz bazy danych z adresów publicznych.
	- Po weryfikacji usuń **wszystkie** zasoby, stworzone w ramach ćwiczenia. Udokumentuj to w sprawozdaniu!