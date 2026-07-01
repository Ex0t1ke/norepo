#!/bin/bash
# ============================================
# ЧИСТЫЙ СКРИПТ — только команды
# Каждая команда выводится в терминал (set -x)
# Ты объясняешь каждую на словах
# ============================================
set -x

# Определяем реального пользователя (не root)
if [[ -z "$SUDO_USER" || "$SUDO_USER" == "root" ]]; then
    SUDO_USER=$(logname 2>/dev/null || echo "$(who am i | awk '{print $1}')" || echo "student")
fi
REAL_USER="$SUDO_USER"

# --- 0. Обновление системы ---
apt update -qq && apt upgrade -y -qq

# --- 1a. Русская локаль, раскладка, часовой пояс ---
apt install -y language-pack-ru -qq
locale-gen ru_RU.UTF-8
update-locale LANG=en_US.UTF-8 LC_ALL=ru_RU.UTF-8 2>/dev/null || true
localectl set-x11-keymap us,ru "" "" grp:alt_shift_toggle 2>/dev/null || true
localectl set-keymap ru 2>/dev/null || true
timedatectl set-timezone Europe/Moscow
timedatectl set-ntp true 2>/dev/null || true

# --- 1. Настройка ядра (sysctl) ---
cp /etc/sysctl.conf /etc/sysctl.conf.backup
cat >> /etc/sysctl.conf << EOF

net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
vm.swappiness = 10
net.core.somaxconn = 65535
fs.file-max = 100000
kernel.pid_max = 65536
EOF
sysctl -p

# --- 2. SSH ---
apt install -y openssh-server -qq
systemctl enable ssh --now

# --- 3. Сеть: интерфейсы ---
ip a
ip route | grep default

# --- 4. Проверка соединения ---
ping -c 4 8.8.8.8
ping -c 2 google.com

# --- 5. Базовое ПО ---
apt install -y htop curl wget git vim nano net-tools screen tmux tree unzip p7zip-full sshfs build-essential python3-pip libreoffice -qq

# --- 6. Шрифты Windows ---
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
apt install -y ttf-mscorefonts-installer -qq
apt install -y fonts-dejavu-core fonts-dejavu-extra fonts-liberation -qq
fc-cache -f

# --- 7. Пакеты Python для .odt ---
apt install -y python3-odf -qq
pip3 install odfpy -q 2>/dev/null || true

# --- 8. Виртуальный принтер PDF ---
apt install -y cups cups-pdf -qq
systemctl restart cups
systemctl enable cups --now

# --- 9. Резервное копирование /etc ---
mkdir -p /backup/system
tar -czf /backup/system/etc-backup-$(date +%Y%m%d).tar.gz /etc
sfdisk -d /dev/sda > /backup/system/partition-table-$(date +%Y%m%d).bak 2>/dev/null || true

# --- 10. Демо-образ системы ---
mkdir -p /backup/image
dd if=/dev/zero of=/backup/image/system.img bs=1M count=100 2>/dev/null
mkfs.ext4 -F /backup/image/system.img 2>/dev/null

# --- 11. Точки восстановления (timeshift) ---
apt install -y timeshift -qq
timeshift --create --comments "Первый снепшот после установки" 2>/dev/null || true

# --- 12. Группы пользователей ---
groupadd developers 2>/dev/null
groupadd admins 2>/dev/null
usermod -aG developers $SUDO_USER
usermod -aG admins $SUDO_USER
useradd -m -G developers -s /bin/bash testuser 2>/dev/null
echo "testuser:testpass123" | chpasswd 2>/dev/null

# --- 13. Права доступа ---
mkdir -p /srv/projects
chown root:developers /srv/projects
chmod 775 /srv/projects
mkdir -p /srv/admin
chown root:admins /srv/admin
chmod 770 /srv/admin
touch /srv/projects/readme.md
chmod 664 /srv/projects/readme.md

# --- 14. Аутентификация и пароли ---
apt install -y libpam-pwquality -qq
sed -i 's/# minlen = 8/minlen = 8/' /etc/security/pwquality.conf 2>/dev/null || true
chage -M 90 $SUDO_USER 2>/dev/null || true
chage -W 7 $SUDO_USER 2>/dev/null || true
chage -M 90 testuser 2>/dev/null || true
chage -W 7 testuser 2>/dev/null || true

# --- 15. Журнал мониторинга (auditd) ---
apt install -y auditd audispd-plugins -qq
systemctl enable auditd --now
auditctl -e 1
auditctl -w /etc/passwd -p wa -k passwd_changes
apt install -y logwatch -qq
