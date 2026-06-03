#version=F40

text
skipx
reboot

lang en_US.UTF-8
keyboard us
timezone Europe/Warsaw --utc

network --bootproto=dhcp --device=link --activate --hostname=jq-host

cdrom

# Użytkownicy
rootpw --plaintext root
user --name=mateusz --groups=wheel --password=student --plaintext

# Dysk
zerombr
clearpart --all --initlabel
autopart --type=lvm

bootloader --append="rhgb quiet"

%packages
@^server-product-environment
openssh-server
curl
wget
tar
podman
%end

%post --log=/root/ks-post.log
set -eux

echo "Kickstart post section started" > /root/lab09-status.txt

systemctl enable sshd


mkdir -p /opt/jq-runtime

cat > /usr/local/bin/run-jq-runtime.sh <<'EOF'
#!/bin/bash
set -eux



podman load -i jq-runtime.tar
echo '{"anwser":42}' | podman run --rm -i jq-runtime:3 '.anwser' > /opt/jq-runtime/result.txt

echo "Lab09 first boot script executed" > /opt/jq-runtime/status.txt
EOF

chmod +x /usr/local/bin/run-jq-runtime.sh

cat > /etc/systemd/system/jq-runtime.service <<'EOF'
[Unit]
Description=Run jq runtime container after first boot
After=docker.service network-online.target
Wants=docker.service network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/run-jq-runtime.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable jq-runtime.service

echo "Kickstart post section finished" >> /root/lab09-status.txt
%end
