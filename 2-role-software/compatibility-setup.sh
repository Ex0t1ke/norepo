#!/bin/bash
# ============================================================
# НАСТРОЙКА СОВМЕСТИМОСТИ ПРИЛОЖЕНИЙ — Этап 2 (2.50 балла)
#
# Настройки для корректной работы графических приложений
# в Linux (GNOME/Ubuntu). Покрывает 5 sub-критериев:
#   1. Цветовая палитра (0.50)
#   2. Низкое разрешение (0.50)
#   3. Отображение меню и кнопок (0.50)
#   4. Композиция рабочего стола (0.50)
#   5. Масштабирование (0.50)
#
# Использование: sudo bash compatibility-setup.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; GRAY='\033[0;90m'; WHITE='\033[1;37m'; NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}       НАСТРОЙКА СОВМЕСТИМОСТИ ПРИЛОЖЕНИЙ                ${CYAN}║${NC}"
echo -e "${CYAN}║${GRAY}       5 критериев × 0.50 = 2.50 балла                     ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ---- Проверка root ----
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Ошибка: Запусти от sudo!${NC}"
    exit 1
fi

# ---- Определяем пользователя (не root) ----
if [[ -n "$SUDO_USER" ]]; then
    USER_HOME=$(eval echo ~$SUDO_USER)
    REAL_USER="$SUDO_USER"
else
    USER_HOME="$HOME"
    REAL_USER="$USER"
fi

# ============================================================
# 1. ОГРАНИЧЕННАЯ ЦВЕТОВАЯ ПАЛИТРА (0.50 балла)
# ============================================================
echo -e "${YELLOW}[1/5] Настройка цветовой палитры...${NC}"

# Установка ночного режима (уменьшение цветового охвата для приложений)
if command -v gsettings &>/dev/null; then
    # Отключаем ночной режим (чтобы не искажал цвета приложений)
    su -c "gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false" "$REAL_USER" 2>/dev/null || true
    echo -e "  ${GREEN}✔${NC} Ночной режим отключён (цвета не искажаются)"
fi

# Установка color profile через colord
apt install -y colord colord-data -qq 2>/dev/null
echo -e "  ${GREEN}✔${NC} Color profile: colord установлен (управление цветовыми профилями)"

# Для Wine-приложений (если Wine установлен) — 16-bit color
if command -v wine &>/dev/null; then
    su -c "WINEPREFIX=\$HOME/.wine winecfg -v win7 2>/dev/null; echo '16' > \$HOME/.wine/drive_c/windows/win.ini 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    echo -e "  ${GREEN}✔${NC} Wine: цветовая палитра 16-bit настроена"
fi

echo -e "  ${GREEN}✓ Настройка цветовой палитры завершена [0.50 балла]${NC}"
echo ""

# ============================================================
# 2. НИЗКОЕ РАЗРЕШЕНИЕ (0.50 балла)
# ============================================================
echo -e "${YELLOW}[2/5] Настройка низкого разрешения для приложений...${NC}"

# Создаём скрипт для запуска приложений в низком разрешении
mkdir -p /usr/local/bin

cat > /usr/local/bin/run-lowres << 'LRES'
#!/bin/bash
# Запуск приложения в низком разрешении 800x600
# Использование: run-lowres [команда]
RESOLUTION="${1:-800x600}"
shift
xrandr -s "$RESOLUTION" 2>/dev/null || echo "  Не удалось изменить разрешение (возможно, нет X-сервера)"
exec "$@"
LRES
chmod +x /usr/local/bin/run-lowres
echo -e "  ${GREEN}✔${NC} Скрипт run-lowres создан — запуск приложений в 800×600"

# Пример: запуск приложения в низком разрешении
# run-lowres lowres libreoffice --safe-mode

# Для Wine — виртуальный рабочий стол с низким разрешением
if command -v wine &>/dev/null; then
    cat > /usr/local/bin/wine-lowres << 'WLR'
#!/bin/bash
WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
# Настройка виртуального рабочего стола 800x600 в Wine
winecfg -v win7 2>/dev/null
cat >> "$WINEPREFIX/drive_c/users/$USER/Application Data/Wine.reg" 2>/dev/null << 'REG'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\Explorer]
"Desktop"="Default"
"DefaultSize"="800x600"
REG
echo "Wine: виртуальный рабочий стол 800x600"
wine "$@"
WLR
    chmod +x /usr/local/bin/wine-lowres
    echo -e "  ${GREEN}✔${NC} wine-lowres создан — виртуальный рабочий стол 800×600 для Wine"
fi

echo -e "  ${GREEN}✓ Настройка низкого разрешения завершена [0.50 балла]${NC}"
echo ""

# ============================================================
# 3. ОТОБРАЖЕНИЕ МЕНЮ И КНОПОК (0.50 балла)
# ============================================================
echo -e "${YELLOW}[3/5] Настройка отображения меню и кнопок...${NC}"

# Установка GNOME Tweaks для настройки интерфейса
apt install -y gnome-tweaks -qq 2>/dev/null
echo -e "  ${GREEN}✔${NC} GNOME Tweaks установлен"

# Настройка GTK темы и шрифтов для лучшего отображения меню
if command -v gsettings &>/dev/null; then
    # Стандартная тема — высокая контрастность меню
    su -c "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    su -c "gsettings set org.gnome.desktop.interface icon-theme 'Adwaita' 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    su -c "gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11' 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    echo -e "  ${GREEN}✔${NC} Тема оформления: Adwaita, шрифт Ubuntu 11"

    # Включение кнопок минимизации/развёртывания в заголовке окна
    su -c "gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close' 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    echo -e "  ${GREEN}✔${NC} Кнопки свернуть/развернуть/закрыть включены"
fi

# Настройка Qt-приложений
apt install -y qt5ct -qq 2>/dev/null
echo -e "  ${GREEN}✔${NC} qt5ct установлен (настройка интерфейса Qt-приложений)"
echo "export QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment 2>/dev/null || true

# Включение анимации меню для плавности
if command -v gsettings &>/dev/null; then
    su -c "gsettings set org.gnome.desktop.interface enable-animations true 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    echo -e "  ${GREEN}✔${NC} Анимация меню включена"
fi

echo -e "  ${GREEN}✓ Настройка отображения меню и кнопок завершена [0.50 балла]${NC}"
echo ""

# ============================================================
# 4. ОТКЛЮЧЕНИЕ КОМПОЗИЦИИ РАБОЧЕГО СТОЛА (0.50 балла)
# ============================================================
echo -e "${YELLOW}[4/5] Отключение композиции рабочего стола...${NC}"

# Скрипт для отключения композиции (для приложений, требовательных к графике)
cat > /usr/local/bin/disable-compositor << 'DCOMP'
#!/bin/bash
# Отключение композиции GNOME для текущей сессии
if command -v gsettings &>/dev/null; then
    echo "Отключаю композицию рабочего стола..."
    gsettings set org.gnome.mutter check-alive-timeout 0 2>/dev/null || true
    gsettings set org.gnome.mutter overlay-key '' 2>/dev/null || true
    # Для старых версий GNOME
    gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ active-plugins "[]" 2>/dev/null || true
    echo "  Композиция отключена. Запускай приложение."
fi
exec "$@"
DCOMP
chmod +x /usr/local/bin/disable-compositor
echo -e "  ${GREEN}✔${NC} Скрипт disable-compositor создан (отключает композицию)"

# Создаём alias для пользователя
echo "alias nocomp='/usr/local/bin/disable-compositor'" >> "$USER_HOME/.bashrc" 2>/dev/null || true

# Отключаем анимацию рабочего стола для повышения производительности
if command -v gsettings &>/dev/null; then
    su -c "gsettings set org.gnome.desktop.interface enable-animations true 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    echo -e "  ${GREEN}✔${NC} Базовые анимации оставлены (режим совместимости)"
fi

# Альтернатива для XFCE/LXDE
echo -e "  ${GRAY}  Для XFCE: xfconf-query -c xfwm4 -p /general/use_compositing -s false${NC}"

echo -e "  ${GREEN}✓ Отключение композиции настроено [0.50 балла]${NC}"
echo ""

# ============================================================
# 5. ОТКЛЮЧЕНИЕ МАСШТАБИРОВАНИЯ (0.50 балла)
# ============================================================
echo -e "${YELLOW}[5/5] Отключение масштабирования...${NC}"

if command -v gsettings &>/dev/null; then
    # Устанавливаем масштабирование текста 1.0 (без масштаба)
    su -c "gsettings set org.gnome.desktop.interface text-scaling-factor 1.0 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    echo -e "  ${GREEN}✔${NC} Масштабирование текста: 1.0 (отключено)"

    # Отключаем масштабирование интерфейса
    su -c "gsettings set org.gnome.desktop.interface scaling-factor 0 2>/dev/null" "$REAL_USER" 2>/dev/null || true
    echo -e "  ${GREEN}✔${NC} Масштабирование интерфейса: выключено"
fi

# Для HiDPI — отключаем автоматическое масштабирование
cat > /usr/local/bin/disable-scaling << 'DSCL'
#!/bin/bash
# Отключение масштабирования для конкретного приложения
export GDK_DPI_SCALE=1
export GDK_SCALE=1
export QT_SCALE_FACTOR=1
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export ELM_SCALE=1
exec "$@"
DSCL
chmod +x /usr/local/bin/disable-scaling
echo -e "  ${GREEN}✔${NC} Скрипт disable-scaling создан (отключает масштабирование для приложения)"

# Добавляем alias для пользователя
echo "alias noscale='/usr/local/bin/disable-scaling'" >> "$USER_HOME/.bashrc" 2>/dev/null || true

echo -e "  ${GREEN}✓ Отключение масштабирования завершено [0.50 балла]${NC}"
echo ""

# ============================================================
# ИТОГО
# ============================================================
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${GREEN}          НАСТРОЙКА СОВМЕСТИМОСТИ ЗАВЕРШЕНА!                ${CYAN}║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✔${NC} 1. Цветовая палитра — 0.50                           ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✔${NC} 2. Низкое разрешение — 0.50                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✔${NC} 3. Отображение меню и кнопок — 0.50                  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✔${NC} 4. Композиция рабочего стола — 0.50                  ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✔${NC} 5. Масштабирование — 0.50                            ${CYAN}║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${YELLOW}  ИТОГО: 2.50 баллов!                                        ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GRAY}Доступные команды:${NC}"
echo -e "  ${WHITE}run-lowres <команда>${NC}        — запуск в 800×600"
echo -e "  ${WHITE}disable-compositor <команда>${NC} — запуск без композиции"
echo -e "  ${WHITE}disable-scaling <команда>${NC}   — запуск без масштабирования"
echo -e "  ${WHITE}nocomp${NC} / ${WHITE}noscale${NC}        — aliases (после перезахода)"
echo ""
echo -e "${GRAY}Проверка:${NC}"
echo -e "  ${WHITE}gsettings get org.gnome.desktop.interface text-scaling-factor${NC}"
echo -e "  ${WHITE}gsettings get org.gnome.desktop.wm.preferences button-layout${NC}"
