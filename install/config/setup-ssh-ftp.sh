#!/bin/bash

echo "Setting up SSH and FTP services..."

# Install openssh and vsftpd
sudo pacman -S --noconfirm --needed openssh vsftpd

# Configure SSH on port 8622
sudo tee /etc/ssh/sshd_config <<'EOF' >/dev/null
# Include drop-in configurations
Include /etc/ssh/sshd_config.d/*.conf

Port 8622
AddressFamily any
ListenAddress 0.0.0.0

AuthorizedKeysFile	.ssh/authorized_keys

PasswordAuthentication yes

Subsystem	sftp	/usr/lib/ssh/sftp-server
EOF

# Configure vsftpd
sudo tee /etc/vsftpd.conf <<'EOF' >/dev/null
anonymous_enable=NO
local_enable=YES
write_enable=YES
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
listen=YES
pam_service_name=vsftpd
EOF

# Enable and start services
sudo systemctl enable --now sshd
sudo systemctl enable --now vsftpd

echo "SSH configured on port 8622"
echo "FTP (vsftpd) configured with local user authentication"
