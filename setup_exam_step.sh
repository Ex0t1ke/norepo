#!/bin/bash
# ============================================
# ПОШАГОВЫЙ СКРИПТ — команда за командой
# Каждая команда: выводится → Enter → выполняется
# И попадает в ~/.bash_history
# ============================================

# Определяем реального пользователя (не root)
if [[ -z "$SUDO_USER" || "$SUDO_USER" == "root" ]]; then
    SUDO_USER=$(logname 2>/dev/null || echo "$(who am i | awk '{print $1}')" || echo "student")
fi
REAL_USER="$SUDO_USER"
HISTFILE="/home/$REAL_USER/.bash_history"

step() {
    local cmd="$1"
    echo ""
    echo "=========================================="
    echo ">>> СЛЕДУЮЩАЯ КОМАНДА:"
    echo "$ $cmd"
    echo "=========================================="
    echo ""
    echo "Нажми Enter, чтобы выполнить (или Ctrl+C для выхода)..."
    read -r

    # Выполняем команду
    eval "$cmd"

    # Записываем команду в историю пользователя
    echo "$cmd" >> "$HISTFILE"

    echo ""
    echo "--- [ГОТОВО] ---"
    echo "Нажми Enter для продолжения..."
    read -r
}

# ===== САМИ КОМАНДЫ =====

# --- 0. Обновление системы ---
step "apt update -qq && apt upgrade -y -qq"

# --- 1a. Русская локаль, раскладка, часовой пояс ---
step "apt install -y language-pack-ru -qq"
step "locale-gen ru_RU.UTF-8"
step "update-locale LANG=en_US.UTF-8 LC_ALL=ru_RU.UTF-8"
step "localectl set-x11-keymap us,ru \"\" \"\" grp:alt_shift_toggle"
step "timedatectl set-timezone Europe/Moscow"
step "timedatectl set-ntp true"

# --- 1. Настройка ядра (sysctl) ---
step "cp /etc/sysctl.conf /etc/sysctl.conf.backup"
step "cat >> /etc/sysctl.conf << 'EOF'
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
vm.swappiness = 10
net.core.somaxconn = 65535
fs.file-max = 100000
kernel.pid_max = 65536
EOF"
step "sysctl -p"

# --- 2. SSH ---
step "apt install -y openssh-server -qq"
step "systemctl enable ssh --now"

# --- 3. Сеть ---
step "ip a"
step "ip route | grep default"

# --- 4. Проверка соединения ---
step "ping -c 4 8.8.8.8"
step "ping -c 2 google.com"

# --- 5. Базовое ПО ---
step "apt install -y htop curl wget git vim nano net-tools screen tmux tree unzip p7zip-full sshfs build-essential python3-pip libreoffice -qq"

# --- 6. Виртуальный принтер PDF ---
step "apt install -y cups cups-pdf -qq"
step "systemctl restart cups"
step "systemctl enable cups --now"

# --- 7. Резервное копирование ---
step "mkdir -p /backup/system"
step "tar -czf /backup/system/etc-backup-\$(date +%Y%m%d).tar.gz /etc"
step "sfdisk -d /dev/sda > /backup/system/partition-table-\$(date +%Y%m%d).bak"

# --- 8. Демо-образ ---
step "mkdir -p /backup/image"
step "dd if=/dev/zero of=/backup/image/system.img bs=1M count=100"
step "mkfs.ext4 -F /backup/image/system.img"

# --- 9. Timeshift ---
step "apt install -y timeshift -qq"
step "timeshift --create --comments \"Первый снепшот\""

# --- 10. Группы пользователей ---
step "groupadd developers"
step "groupadd admins"
step "usermod -aG developers $REAL_USER"
step "usermod -aG admins $REAL_USER"
step "useradd -m -G developers -s /bin/bash testuser"
step "echo testuser:testpass123 | chpasswd"

# --- 11. Права доступа ---
step "mkdir -p /srv/projects"
step "chown root:developers /srv/projects"
step "chmod 775 /srv/projects"
step "mkdir -p /srv/admin"
step "chown root:admins /srv/admin"
step "chmod 770 /srv/admin"
step "touch /srv/projects/readme.md"

# --- 12. Аутентификация ---
step "apt install -y libpam-pwquality -qq"
step "sed -i 's/# minlen = 8/minlen = 8/' /etc/security/pwquality.conf"
step "chage -M 90 $REAL_USER"
step "chage -W 7 $REAL_USER"
step "chage -M 90 testuser"
step "chage -W 7 testuser"

# --- 13. Аудит (auditd) ---
step "apt install -y auditd audispd-plugins -qq"
step "systemctl enable auditd --now"
step "auditctl -e 1"
step "auditctl -w /etc/passwd -p wa -k passwd_changes"
step "apt install -y logwatch -qq"

echo ""
echo "=========================================="
echo " ВСЕ ШАГИ ВЫПОЛНЕНЫ!"
echo "=========================================="
echo "Проверь history — там все команды:"
echo "  history | tail -50"
