#!/bin/bash
# ============================================
# ГЕНЕРАТОР КОМАНД — выводит все команды списком
# Ты их копируешь и вставляешь в терминал
# История сохраняется 100%
# ============================================

cat << 'COMMANDS'

=== 0. ОБНОВЛЕНИЕ ===
sudo apt update -qq && sudo apt upgrade -y -qq

=== 0a. РУССКАЯ ЛОКАЛЬ + ЧАСОВОЙ ПОЯС ===
sudo apt install -y language-pack-ru -qq
sudo locale-gen ru_RU.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=ru_RU.UTF-8
sudo timedatectl set-timezone Europe/Moscow
sudo timedatectl set-ntp true

=== 1. НАСТРОЙКА ЯДРА (sysctl) ===
sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
sudo tee -a /etc/sysctl.conf << 'EOF'
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
vm.swappiness = 10
net.core.somaxconn = 65535
fs.file-max = 100000
kernel.pid_max = 65536
EOF
sudo sysctl -p

=== 2. SSH ===
sudo apt install -y openssh-server -qq
sudo systemctl enable ssh --now

=== 3. СЕТЬ ===
ip a
ip route | grep default

=== 4. ПРОВЕРКА СОЕДИНЕНИЯ ===
ping -c 4 8.8.8.8
ping -c 2 google.com

=== 5. БАЗОВОЕ ПО ===
sudo apt install -y htop curl wget git vim nano net-tools screen tmux tree unzip p7zip-full sshfs build-essential python3-pip libreoffice -qq

=== 6. ПРИНТЕР PDF ===
sudo apt install -y cups cups-pdf -qq
sudo systemctl restart cups
sudo systemctl enable cups --now

=== 7. РЕЗЕРВНОЕ КОПИРОВАНИЕ ===
sudo mkdir -p /backup/system
sudo tar -czf /backup/system/etc-backup-$(date +%Y%m%d).tar.gz /etc

=== 8. TIMESHIFT ===
sudo apt install -y timeshift -qq
sudo timeshift --create --comments "Первый снепшот"

=== 9. ГРУППЫ ПОЛЬЗОВАТЕЛЕЙ ===
sudo groupadd developers
sudo groupadd admins
sudo usermod -aG developers $USER
sudo usermod -aG admins $USER
sudo useradd -m -G developers -s /bin/bash testuser
echo testuser:testpass123 | sudo chpasswd

=== 10. ПРАВА ДОСТУПА ===
sudo mkdir -p /srv/projects /srv/admin
sudo chown root:developers /srv/projects
sudo chmod 775 /srv/projects
sudo chown root:admins /srv/admin
sudo chmod 770 /srv/admin

=== 11. БЕЗОПАСНОСТЬ ===
sudo apt install -y libpam-pwquality -qq
sudo chage -M 90 $USER
sudo chage -W 7 $USER

=== 12. АУДИТ ===
sudo apt install -y auditd audispd-plugins -qq
sudo systemctl enable auditd --now
sudo auditctl -e 1
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
sudo apt install -y logwatch -qq

COMMANDS

echo ""
echo "КОПИРУЙ команды выше и вставляй в терминал!"
echo "Чтобы вставить в Ubuntu терминал: Shift+Insert"
echo "После каждой команды смотри вывод и объясняй преподу что сделал."
