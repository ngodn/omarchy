# Ensure iwd service will be started
sudo systemctl enable iwd.service

# Configure iwd to handle DHCP automatically
sudo mkdir -p /etc/iwd
sudo tee /etc/iwd/main.conf <<'EOF' >/dev/null
[General]
EnableNetworkConfiguration=true

[Network]
EnableIPv6=true
NameResolvingService=systemd
EOF

# Prevent systemd-networkd-wait-online timeout on boot
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
