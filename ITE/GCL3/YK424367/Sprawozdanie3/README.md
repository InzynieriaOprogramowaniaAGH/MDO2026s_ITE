ubuntu@myserver:~/MDO2026s_ITE$ hostname
myserver
ubuntu@myserver:~/MDO2026s_ITE$ ssh ansible@ansible-target hostname
ansible-target
ubuntu@myserver:~/MDO2026s_ITE$ getent hosts ansible-target
192.168.2.3     ansible-target
ubuntu@myserver:~/MDO2026s_ITE$ getent hosts myserver
127.0.1.1       myserver myserver
ubuntu@myserver:~/MDO2026s_ITE$ ping -c 3 ansible-target
PING ansible-target (192.168.2.3) 56(84) bytes of data.
64 bytes from ansible-target (192.168.2.3): icmp_seq=1 ttl=64 time=0.536 ms
64 bytes from ansible-target (192.168.2.3): icmp_seq=2 ttl=64 time=0.875 ms
64 bytes from ansible-target (192.168.2.3): icmp_seq=3 ttl=64 time=0.779 ms

--- ansible-target ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2111ms
rtt min/avg/max/mdev = 0.536/0.730/0.875/0.142 ms
ubuntu@myserver:~/MDO2026s_ITE$ ssh ansible@ansible-target ping -c 3 myserver
PING myserver (192.168.2.2) 56(84) bytes of data.
64 bytes from myserver (192.168.2.2): icmp_seq=1 ttl=64 time=0.195 ms
64 bytes from myserver (192.168.2.2): icmp_seq=2 ttl=64 time=0.855 ms
64 bytes from myserver (192.168.2.2): icmp_seq=3 ttl=64 time=0.983 ms

--- myserver ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2093ms
rtt min/avg/max/mdev = 0.195/0.677/0.983/0.345 ms
ubuntu@myserver:~/MDO2026s_ITE$ ssh -o BatchMode=yes ansible@ansible-target hostname
ansible-target
ubuntu@myserver:~/MDO2026s_ITE$ cat ~/ansible/inventory.ini
[Orchestrators]
myserver ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible
ubuntu@myserver:~/MDO2026s_ITE$ ansible -i ~/ansible/inventory.ini all -m ping
myserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
ansible-target | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
ubuntu@myserver:~/MDO2026s_ITE$ ansible -i ~/ansible/inventory.ini Orchestrators -m ping
myserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
ubuntu@myserver:~/MDO2026s_ITE$ ansible -i ~/ansible/inventory.ini Endpoints -m ping
ansible-target | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
ubuntu@myserver:~/MDO2026s_ITE$ 