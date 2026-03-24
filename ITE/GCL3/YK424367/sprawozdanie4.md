
czesc 1


$ docker run -d --name server networkstatic/iperf3 -s
23e8d88ddd40...


$ docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server
172.17.0.2


$ docker run --rm --name client networkstatic/iperf3 -c 172.17.0.2 -t 5
Connecting to host 172.17.0.2, port 5201
[  5] local 172.17.0.3 port 51652 connected to 172.17.0.2 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  9.64 GBytes  82.8 Gbits/sec    0   3.10 MBytes
[  5]   1.00-2.00   sec  10.0 GBytes  86.0 Gbits/sec    0   3.10 MBytes
[  5]   2.00-3.00   sec  9.77 GBytes  83.9 Gbits/sec    0   3.10 MBytes
[  5]   3.00-4.00   sec  9.89 GBytes  85.0 Gbits/sec    0   3.10 MBytes
[  5]   4.00-5.00   sec  9.72 GBytes  83.5 Gbits/sec    0   3.10 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-5.00   sec  49.0 GBytes  84.2 Gbits/sec    0             sender
[  5]   0.00-5.00   sec  49.0 GBytes  84.2 Gbits/sec                  receiver

iperf Done.

$ docker run --rm networkstatic/iperf3 -c server -t 1
iperf3: error - unable to connect to server: Name or service not known



2 czesc



$ docker network create lab4
3a2d455ef16a...




$ docker run -d --name server --network lab4 networkstatic/iperf3 -s
5374cfb1a31e...

$ docker run --rm --name client --network lab4 networkstatic/iperf3 -c server -t 5
Connecting to host server, port 5201
[  5] local 172.19.0.3 port 60252 connected to 172.19.0.2 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  8.95 GBytes  76.9 Gbits/sec    0   3.11 MBytes
[  5]   1.00-2.00   sec  9.03 GBytes  77.5 Gbits/sec    0   3.11 MBytes
[  5]   2.00-3.00   sec  8.89 GBytes  76.4 Gbits/sec    0   3.11 MBytes
[  5]   3.00-4.00   sec  8.84 GBytes  75.9 Gbits/sec    0   3.11 MBytes
[  5]   4.00-5.00   sec  8.78 GBytes  75.4 Gbits/sec    0   3.11 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-5.00   sec  44.5 GBytes  76.4 Gbits/sec    0             sender
[  5]   0.00-5.00   sec  44.5 GBytes  76.4 Gbits/sec                  receiver

iperf Done.


$ docker network inspect lab4 --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'
server: 172.19.0.2/16


3 czesc


$ docker run -d --name server --network lab4 -p 5201:5201 networkstatic/iperf3 -s
fe0d3e9d8248...


$ iperf3 -c 127.0.0.1 -p 5201 -t 5
Connecting to host 127.0.0.1, port 5201
[  7] local 127.0.0.1 port 56536 connected to 127.0.0.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  7]   0.00-1.00   sec  7.91 GBytes  67.9 Gbits/sec    0   6.06 MBytes
[  7]   1.00-2.00   sec  7.99 GBytes  68.6 Gbits/sec    0   6.06 MBytes
[  7]   2.00-3.00   sec  8.11 GBytes  69.6 Gbits/sec    0   6.06 MBytes
[  7]   3.00-4.00   sec  7.92 GBytes  68.0 Gbits/sec    0   6.06 MBytes
[  7]   4.00-5.00   sec  8.09 GBytes  69.5 Gbits/sec    0   6.06 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  7]   0.00-5.00   sec  40.0 GBytes  68.7 Gbits/sec    0             sender
[  7]   0.00-5.00   sec  40.0 GBytes  68.7 Gbits/sec                  receiver

iperf Done.



$ iperf3 -c 192.168.2.2 -p 5201 -t 5
Connecting to host 192.168.2.2, port 5201
[  7] local 192.168.2.2 port 44768 connected to 192.168.2.2 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  7]   0.00-1.00   sec  8.23 GBytes  70.7 Gbits/sec    0   4.28 MBytes
[  7]   1.00-2.00   sec  8.44 GBytes  72.5 Gbits/sec    0   4.28 MBytes
[  7]   2.00-3.00   sec  8.32 GBytes  71.5 Gbits/sec    0   4.28 MBytes
[  7]   3.00-4.00   sec  8.40 GBytes  72.2 Gbits/sec    0   4.28 MBytes
[  7]   4.00-5.00   sec  8.63 GBytes  74.1 Gbits/sec    0   4.28 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  7]   0.00-5.00   sec  42.0 GBytes  72.2 Gbits/sec    0             sender
[  7]   0.00-5.00   sec  42.0 GBytes  72.1 Gbits/sec                  receiver

iperf Done.



$ docker logs server
-----------------------------------------------------------
Server listening on 5201 (test #1)
-----------------------------------------------------------
Accepted connection from 172.19.0.1, port 45530
[  5] local 172.19.0.2 port 5201 connected to 172.19.0.1 port 45546
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-5.00   sec  40.0 GBytes  68.7 Gbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201 (test #2)
-----------------------------------------------------------
Accepted connection from 192.168.2.2, port 44758
[  5] local 172.19.0.2 port 5201 connected to 192.168.2.2 port 44768
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-5.00   sec  42.0 GBytes  72.1 Gbits/sec                  receiver


