# Sprawozdanie 3

[historia poleceń](command_history.txt)

## Laboratorium 8

#### Utworzono drugą maszynę wirtualną:
![](1.1.png)

#### Zapewniono obecność programu tar i serwera OpenSSH oraz utworzono użytkownika *ansible*:
![](1.2.png)

*hostname "ansible-target" został nadany już w trakcie konfiguracji maszyny*

#### Zainstalowano oprogramowanie Ansible na maszynie głównej:
![](1.3.1.png)
![](1.3.2.png)

#### Wymieniono klucze ssh między maszyną główną a użytkownikiem *ansible* z *ansible-target*:
![](1.4.png)

![](1.5.png)

*możliwe jest nawiązanie połączenia bez konieczności podawania hasła*

#### Nadanie maszynie głównej nowej nazwy:
![](1.6.png)

*nazewnictwo zostało zaktualizowane, ale pozostało niezmienione w interfejsie VS Code*

#### Zweryfikowano połączenie poprzez wykonanie *ping'u*:
![](1.7.png)

#### Stworzono [plik inwentaryzacji](inventory.ini) i wysłano za jego pośrednictwem żądanie *ping* do wszystkich maszyn:
![](1.8.png)

![](1.9.png)

#### Utworzono [playbook'a Ansible](pbook.yml):
![](1.10.png)

#### Uruchomiono playbook'a:
![](1.11.png)

#### Wyłączono obsługę ssh na *ansible-target* i uruchomiono ponownie playbook'a:
![](1.12.png)
![](1.13.png)