# Sprawozdanie nr 3

#### Wszystkie zadania wykonałam na Ubuntu Server 24.04 LTS w Hyper-V, poprzez połączenie zdalne przez protokół SSH z poziomu Visual Studio Code.

### Lab8

### Instalacja zarządcy Ansible

Laboratoria rozpoczęłam od utworzenia drugiej maszyny wirtualnej (ansible-target) w wersji Minimized. Zgodnie z wymaganiami, zapewniłam obecność pakietu tar oraz skonfigurowałam serwer OpenSSH, aby umożliwić zdalną automatyzację.

![Błąd wyświetlania](lab8_ss/lab8ss2.png)

Następnie sprawdziłam adres IP nowej maszyny, a następnie na maszynie głównej skonfigurowałam plik /etc/hosts, aby umożliwić komunikację po nazwie hostname.

![Błąd wyświetlania](lab8_ss/lab8ss1.png)

![Błąd wyświetlania](lab8_ss/lab8ss3.png)

![Błąd wyświetlania](lab8_ss/lab8ss4.png)

Po przejściu powyższych etapów wszytsko zadziałało poprawnie:

![Błąd wyświetlania](lab8_ss/lab8ss5.png)

### Inwentaryzacja

Zgodnie z dobrą praktyką dokonałam zmiany nazwy głównej maszyny wirtualnej. Za pomocą narzędzia hostnamectl nadałam mojej maszynie głównej nazwę ansible-controller.

![Błąd wyświetlania](lab8_ss/lab8ss6.png)

Widać, że nazwa została poprawnie zmieniona:

![Błąd wyświetlania](lab8_ss/lab8ss7.png)

Ponieważ tworząc maszynę wirtualną ansible od razu nazwałam ją ansible-target, teraz nie musiałam już tego robić.

Następnie sprawdziłam adresy ip obu maszyn i wpisałam je do pliku /etc/hosts.

![Błąd wyświetlania](lab8_ss/lab8ss8.png)

Następnie zweryfikowałam łączność za pomocą polecenia ping. Otrzymałam odpowiedź spod adresu ip przypisanego do ansible-target, zatem wszystko zadziałało poprawnie.

![Błąd wyświetlania](lab8_ss/lab8ss9.png)

Następnie przeszłam do utworzenia pliku inwentaryzacji.

![Błąd wyświetlania](lab8_ss/lab8ss10.png)

Aby zweyfikować poprawność wysłałam żądanie ping do wszystkich maszyn.

![Błąd wyświetlania](lab8_ss/lab8ss11.png)

Wnikiem jest success w obu przypadkach oraz odpowiedź pong, co wskazuje na poprawne wykonanie konfiguracji. Potwierdza to też, że Ansible poprawnie odczytał plik inventory.ini i znalazł oba hosty.