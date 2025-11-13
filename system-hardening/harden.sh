
#!/usr/bin/env bash
# ----------------------------------------
# Linux System Hardening Script
# Author: Meisam Amiri
# ----------------------------------------

set -euo pipefail

echo "🔒 Starting System Hardening..."

# 1️⃣ Update and upgrade system
echo "[1/8] Updating system packages..."
apt update -y && apt upgrade -y

# 2️⃣ Disable root SSH login
echo "[2/8] Disabling root SSH login..."
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# 3️⃣ Create a new admin user
echo "[3/8] Creating secure admin user..."
if ! id "secureadmin" &>/dev/null; then
  useradd -m -s /bin/bash secureadmin
  echo "secureadmin:ChangeMe123!" | chpasswd
  usermod -aG sudo secureadmin
fi

# 4️⃣ Enable UFW Firewall
echo "[4/8] Configuring UFW firewall..."
apt install ufw -y
ufw allow OpenSSH
ufw enable

# 5️⃣ Remove unnecessary packages
echo "[5/8] Removing unwanted packages..."
apt purge -y telnet rsh-server rsh-client
apt autoremove -y

# 6️⃣ Set file permissions
echo "[6/8] Setting file permissions..."
chmod 600 /etc/shadow
chmod 600 /etc/ssh/sshd_config

# 7️⃣ Enable automatic updates
echo "[7/8] Enabling unattended upgrades..."
apt install unattended-upgrades -y
dpkg-reconfigure -f noninteractive unattended-upgrades

# 8️⃣ Check for world-writable files
echo "[8/8] Checking for world-writable files..."
find / -xdev -type f -perm -0002 -print > /root/world_writable_files.txt

echo "✅ Hardening complete. Please reboot for all changes to take effect."
