#!/bin/bash
# ============================================
# ПОШАГОВЫЙ СКРИПТ с историей
# Команды сохраняются в ~/.bash_history
# ============================================

# Определяем реального пользователя
if [[ -z "$SUDO_USER" || "$SUDO_USER" == "root" ]]; then
    SUDO_USER=$(logname 2>/dev/null || echo "$(who am i | awk '{print $1}')" || echo "student")
fi
REAL_USER="$SUDO_USER"
REAL_HOME=$(eval echo "~$REAL_USER")
HISTFILE="$REAL_HOME/.bash_history"

step() {
    local cmd="$1"
    echo ""
    echo ">>> $ $cmd"
    echo ""
    echo "Нажми Enter..."
    read -r

    # Выполняем
    eval "$cmd"

    # Пишем команду в .bash_history нужного пользователя
    echo "$cmd" >> "$HISTFILE"

    echo "[ГОТОВО]"
}

# ===== КОМАНДЫ =====

step "apt update -qq && apt upgrade -y -qq"
step "apt install -y language-pack-ru -qq"
step "locale-gen ru_RU.UTF-8"
step "timedatectl set-timezone Europe/Moscow"
step "timedatectl set-ntp true"
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
step "apt install -y openssh-server -qq"
step "systemctl enable ssh --now"
step "ip a"
step "ping -c 4 8.8.8.8"
step "apt install -y htop curl wget git vim nano net-tools screen tmux tree unzip p7zip-full sshfs build-essential python3-pip libreoffice -qq"
step "apt install -y cups cups-pdf -qq"
step "systemctl restart cups"
step "systemctl enable cups --now"
step "mkdir -p /backup/system"
step "tar -czf /backup/system/etc-backup-\$(date +%Y%m%d).tar.gz /etc"
step "apt install -y timeshift -qq"
step "groupadd developers"
step "groupadd admins"
step "usermod -aG developers $REAL_USER"
step "usermod -aG admins $REAL_USER"
step "useradd -m -G developers -s /bin/bash testuser"
step "echo testuser:testpass123 | chpasswd"
step "mkdir -p /srv/projects /srv/admin"
step "chown root:developers /srv/projects"
step "chmod 775 /srv/projects"
step "chown root:admins /srv/admin"
step "chmod 770 /srv/admin"
step "apt install -y libpam-pwquality -qq"
step "chage -M 90 $REAL_USER"
step "chage -W 7 $REAL_USER"
step "apt install -y auditd audispd-plugins -qq"
step "systemctl enable auditd --now"
step "auditctl -e 1"
step "auditctl -w /etc/passwd -p wa -k passwd_changes"

echo ""
echo "=========================================="
echo " ГОТОВО!"
echo "=========================================="
echo ""
echo "Открой НОВЫЙ терминал и проверь:"
echo "  history | tail -40"
echo ""
echo "Если не появились — выполни в НОВОМ терминале:"
echo "  history -r && history | tail -40"
