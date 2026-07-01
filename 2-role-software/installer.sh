#!/bin/bash
# ============================================================
# УСТАНОВЩИК ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ
# Квалификационный экзамен по ОС - Этап 2
# Все 29 билетов (веб-сервисы, мобилки, игры, девопс и т.д.)
#
# Использование: sudo bash installer.sh
# ============================================================

# ---- Цвета ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
GRAY='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'

# ---- Директория лога установки ----
INSTALL_DIR="/tmp/oc-installer"
mkdir -p "$INSTALL_DIR"
INSTALLED_FILE="$INSTALL_DIR/installed.txt"
CHECK_CACHE="$INSTALL_DIR/cache.txt"
touch "$INSTALLED_FILE"

# ---- Проверка root ----
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Ошибка: Запусти от sudo!${NC}"
    echo -e "  ${GRAY}sudo bash installer.sh${NC}"
    exit 1
fi

# ---- Определяем пакетный менеджер ----
if command -v apt &>/dev/null; then
    PM="apt"
elif command -v dnf &>/dev/null; then
    PM="dnf"
elif command -v yum &>/dev/null; then
    PM="yum"
else
    echo -e "${RED}Не найден пакетный менеджер (apt/dnf/yum)${NC}"
    exit 1
fi

# -----------------------------------------------------------
# СТРУКТУРА ДАННЫХ
# Для каждой категории: массивы PKG_NAME, PKG_CHECK, PKG_INSTALL, PKG_DESC
# -----------------------------------------------------------

CAT_NAMES=()
CAT_COUNT=0

# Добавление категории
add_cat() {
    CAT_NAMES+=("$1")
    CAT_COUNT=${#CAT_NAMES[@]}
}

# ===================== КАТЕГОРИИ =====================

# --- 1. IDE и редакторы кода ---
add_cat "IDE и редакторы кода"
cat1_name=(); cat1_check=(); cat1_install=(); cat1_desc=()
pkg_ide() { cat1_name+=("$1"); cat1_check+=("$2"); cat1_install+=("$3"); cat1_desc+=("$4"); }
pkg_ide "VS Code"           "command -v code"                              "wget -qO /tmp/code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' && dpkg -i /tmp/code.deb 2>/dev/null; $PM install -f -y -qq" "Универсальная IDE (JS, Python, Go, Rust...)"
pkg_ide "PyCharm Community" "command -v /opt/pycharm-community/bin/pycharm.sh 2>/dev/null || snap list pycharm-community 2>/dev/null"      "snap install pycharm-community --classic 2>/dev/null || (echo '  Snap не сработал, качаю с JetBrains...' && wget -qO /tmp/pycharm.tar.gz 'https://download.jetbrains.com/python/pycharm-community-2024.2.tar.gz' && tar -xzf /tmp/pycharm.tar.gz -C /opt/ && ln -sf /opt/pycharm-community-*/bin/pycharm.sh /usr/local/bin/pycharm-community 2>/dev/null && ln -sf /opt/pycharm-community-* /opt/pycharm-community 2>/dev/null && rm -f /tmp/pycharm.tar.gz)" "IDE для Python и Django"
pkg_ide "IntelliJ IDEA"     "snap list intellij-idea-community 2>/dev/null || command -v idea 2>/dev/null" "snap install intellij-idea-community --classic 2>/dev/null || (echo '  Snap не сработал, качаю с JetBrains...' && wget -qO /tmp/idea.tar.gz 'https://data.services.jetbrains.com/products/download?platform=linux&code=IIC' && tar -xzf /tmp/idea.tar.gz -C /opt/ && ln -sf /opt/idea-IC-*/bin/idea.sh /usr/local/bin/idea 2>/dev/null && rm -f /tmp/idea.tar.gz)" "IDE для Java, Kotlin"
pkg_ide "Eclipse IDE"       "command -v eclipse 2>/dev/null"               "$PM install -y eclipse 2>/dev/null || snap install eclipse --classic" "IDE для Java, C/C++, PHP"
pkg_ide "Android Studio"    "command -v android-studio 2>/dev/null"        "snap install android-studio --classic" "Разработка Android-приложений"
pkg_ide "Code::Blocks"      "command -v codeblocks 2>/dev/null"            "$PM install -y codeblocks -qq 2>/dev/null || snap install codeblocks --classic" "IDE для C/C++"
pkg_ide "Arduino IDE"       "command -v arduino 2>/dev/null"               "$PM install -y arduino -qq 2>/dev/null || snap install arduino" "Разработка для Arduino/MCU"
pkg_ide "Jupyter Lab"       "command -v jupyter-lab 2>/dev/null || command -v jupyter-lab-desktop 2>/dev/null || snap list jupyterlab-desktop 2>/dev/null"           "snap install jupyterlab-desktop --classic 2>/dev/null || pip3 install jupyterlab -q" "Интерактивная среда для Data Science"
pkg_ide "Qt Creator"        "command -v qtcreator 2>/dev/null"             "$PM install -y qtcreator -qq 2>/dev/null || snap install qtcreator --classic" "IDE для C++/Qt приложений"
pkg_ide "NetBeans"          "command -v netbeans 2>/dev/null"              "$PM install -y netbeans -qq 2>/dev/null || snap install netbeans --classic" "IDE для Java, PHP, C/C++"
pkg_ide "MonoDevelop"       "command -v monodevelop 2>/dev/null || command -v dotnet 2>/dev/null"           "$PM install -y monodevelop -qq 2>/dev/null || snap install monodevelop --classic 2>/dev/null || echo '  MonoDevelop не поддерживается, используй VS Code (C# плагины) или .NET SDK (категория 2)'" "IDE для .NET/C# под Linux"
pkg_ide "CLion"             "snap list clion 2>/dev/null || command -v clion 2>/dev/null"               "snap install clion --classic 2>/dev/null || (echo '  Snap не сработал, качаю с JetBrains...' && wget -qO /tmp/clion.tar.gz 'https://data.services.jetbrains.com/products/download?platform=linux&code=CL' && tar -xzf /tmp/clion.tar.gz -C /opt/ && ln -sf /opt/clion-*/bin/clion.sh /usr/local/bin/clion 2>/dev/null && rm -f /tmp/clion.tar.gz)" "IDE для C/C++ от JetBrains"
pkg_ide "WebStorm"          "snap list webstorm 2>/dev/null || command -v webstorm 2>/dev/null"           "snap install webstorm --classic 2>/dev/null || (echo '  Snap не сработал, качаю с JetBrains...' && wget -qO /tmp/ws.tar.gz 'https://data.services.jetbrains.com/products/download?platform=linux&code=WS' && tar -xzf /tmp/ws.tar.gz -C /opt/ && ln -sf /opt/WebStorm-*/bin/webstorm.sh /usr/local/bin/webstorm 2>/dev/null && rm -f /tmp/ws.tar.gz)" "IDE для JS/TS от JetBrains"

# --- 2. Языки программирования и SDK ---
add_cat "Языки и SDK"
cat2_name=(); cat2_check=(); cat2_install=(); cat2_desc=()
pkg_lang() { cat2_name+=("$1"); cat2_check+=("$2"); cat2_install+=("$3"); cat2_desc+=("$4"); }
pkg_lang "Python 3 + pip"   "command -v python3 && command -v pip3"        "$PM install -y python3-pip python3-venv python3-dev -qq" "Базовый язык для многих билетов"
pkg_lang "Node.js (LTS)"    "command -v node && node -v | grep -q 'v20\|v22'" "curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && $PM install -y nodejs -qq" "Среда для JS/TS, веб-сервисы, SPA"
pkg_lang "OpenJDK 17"       "java -version 2>&1 | grep -q 'openjdk.*17' || dpkg -l openjdk-17-jdk 2>/dev/null | grep -q '^ii'"   "$PM install -y openjdk-17-jdk -qq" "Java SE (банк, финансы, корп.ПО)"
pkg_lang "OpenJDK 8"        "java -version 2>&1 | grep -q 'openjdk.*1.8' || dpkg -l openjdk-8-jdk 2>/dev/null | grep -q '^ii'"  "$PM install -y openjdk-8-jdk -qq" "Java 8 (совместимость со старым ПО)"
pkg_lang "Go (Golang)"      "command -v go"                                "$PM install -y golang -qq" "Go для DevOps/CLI утилит"
pkg_lang "Rust"             "command -v rustc 2>/dev/null || ls /home/*/.cargo/bin/rustc 2>/dev/null"                             "su -c 'curl --proto \"=https\" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y' \$SUDO_USER" "Rust для системного ПО"
pkg_lang ".NET SDK"          "command -v dotnet && dotnet --list-sdks | grep -q '8\|9'" "wget -qO /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && dpkg -i /tmp/packages-microsoft-prod.deb && $PM update -qq && $PM install -y dotnet-sdk-8.0 -qq" "C#, ASP.NET (билет 9)"
pkg_lang "Flutter SDK"      "command -v flutter"                           "snap install flutter --classic" "Кроссплатформенная мобильная разработка"
pkg_lang "GCC (build-essential)" "command -v gcc && command -v make"       "$PM install -y build-essential -qq" "Компилятор C/C++, make, libc"

# --- 3. СУБД и базы данных ---
add_cat "СУБД и базы данных"
cat3_name=(); cat3_check=(); cat3_install=(); cat3_desc=()
pkg_db() { cat3_name+=("$1"); cat3_check+=("$2"); cat3_install+=("$3"); cat3_desc+=("$4"); }
pkg_db "PostgreSQL"          "command -v psql"                              "$PM install -y postgresql postgresql-contrib -qq" "Реляционная СУБД (почти все билеты)"
pkg_db "MySQL Server"        "command -v mysql"                             "$PM install -y mysql-server -qq" "Реляционная СУБД (веб, финансы)"
pkg_db "SQLite"              "command -v sqlite3"                           "$PM install -y sqlite3 -qq" "Лёгкая встраиваемая БД"
pkg_db "MariaDB"             "command -v mariadb 2>/dev/null"               "$PM install -y mariadb-server -qq" "Форк MySQL (тестирование, .NET)"
pkg_db "MongoDB"             "command -v mongod 2>/dev/null"                "wget -qO /tmp/mongo.asc 'https://www.mongodb.org/static/pgp/server-7.0.asc' && gpg --dearmor -o /usr/share/keyrings/mongodb.gpg /tmp/mongo.asc 2>/dev/null; echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse' > /etc/apt/sources.list.d/mongodb.list && $PM update -qq && $PM install -y mongodb-org -qq" "NoSQL (SPA, веб-сервисы)"
pkg_db "Redis"               "command -v redis-server"                      "$PM install -y redis -qq" "Кэш/Broker (чат-боты, онлайн-игры)"
pkg_db "phpMyAdmin"          "dpkg -l phpmyadmin 2>/dev/null | grep -q ^ii" "$PM install -y phpmyadmin -qq" "Веб-админка для MySQL"
pkg_db "InfluxDB"            "command -v influxd 2>/dev/null"               "wget -qO /tmp/influxdb.deb 'https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.11-linux-amd64.deb' 2>/dev/null && (dpkg -i /tmp/influxdb.deb 2>/dev/null || true) && $PM install -f -y -qq; command -v influxd 2>/dev/null || snap install influxdb --channel=beta 2>/dev/null || echo '  Установи InfluxDB вручную: snap install influxdb --channel=beta'" "Time-series БД для телеметрии"

# --- 4. Графические редакторы ---
add_cat "Графические редакторы"
cat4_name=(); cat4_check=(); cat4_install=(); cat4_desc=()
pkg_gfx() { cat4_name+=("$1"); cat4_check+=("$2"); cat4_install+=("$3"); cat4_desc+=("$4"); }
pkg_gfx "GIMP"               "command -v gimp"                              "$PM install -y gimp -qq" "Растровый редактор (аналог Photoshop)"
pkg_gfx "Inkscape"           "command -v inkscape"                          "$PM install -y inkscape -qq" "Векторный редактор (аналог Illustrator)"
pkg_gfx "Blender"            "command -v blender"                           "snap install blender --classic" "3D-моделирование и анимация"
pkg_gfx "Krita"              "command -v krita"                             "$PM install -y krita -qq" "Цифровой рисунок и текстуры"

# --- 5. Веб-фреймворки ---
add_cat "Веб-фреймворки"
cat5_name=(); cat5_check=(); cat5_install=(); cat5_desc=()
pkg_web() { cat5_name+=("$1"); cat5_check+=("$2"); cat5_install+=("$3"); cat5_desc+=("$4"); }
pkg_web "Django"             "python3 -c 'import django' 2>/dev/null"       "pip3 install django -q" "Python веб-фреймворк"
pkg_web "Flask"              "python3 -c 'import flask' 2>/dev/null"        "pip3 install flask -q" "Python микро-фреймворк"
pkg_web "Express.js"         "npm list -g express-generator 2>/dev/null"    "npm install -g express-generator -s 2>/dev/null" "Node.js веб-фреймворк"
pkg_web "Angular CLI"        "command -v ng"                                "npm install -g @angular/cli -s 2>/dev/null" "SPA фреймворк от Google"
pkg_web "React CLI"          "command -v create-react-app 2>/dev/null"      "npm install -g create-react-app -s 2>/dev/null" "SPA библиотека от Facebook"
pkg_web "Vue CLI"            "command -v vue"                               "npm install -g @vue/cli -s 2>/dev/null" "SPA фреймворк"
pkg_web "Electron"           "npm list -g electron 2>/dev/null"             "npm install -g electron -s 2>/dev/null" "Десктопные приложения из JS/TS"

# --- 6. ML/AI и Data Science ---
add_cat "ML/AI и Data Science"
cat6_name=(); cat6_check=(); cat6_install=(); cat6_desc=()
pkg_ml() { cat6_name+=("$1"); cat6_check+=("$2"); cat6_install+=("$3"); cat6_desc+=("$4"); }
pkg_ml "TensorFlow"          "python3 -c 'import tensorflow' 2>/dev/null"   "pip3 install tensorflow -q" "Глубокое обучение (нейросети)"
pkg_ml "PyTorch"             "python3 -c 'import torch' 2>/dev/null"        "pip3 install torch torchvision -q" "Глубокое обучение (динамические графы)"
pkg_ml "scikit-learn"        "python3 -c 'import sklearn' 2>/dev/null"      "pip3 install scikit-learn -q" "Классическое ML (классиф., регрессия)"
pkg_ml "OpenCV"              "python3 -c 'import cv2' 2>/dev/null"          "pip3 install opencv-python -q" "Компьютерное зрение"
pkg_ml "Pandas / NumPy"      "python3 -c 'import pandas' 2>/dev/null"       "pip3 install pandas numpy -q" "Анализ данных и вычисления"
pkg_ml "Matplotlib / Seaborn""python3 -c 'import matplotlib' 2>/dev/null"   "pip3 install matplotlib seaborn -q" "Визуализация данных и графики"
pkg_ml "NLTK"                "python3 -c 'import nltk' 2>/dev/null"         "pip3 install nltk -q" "Natural Language Toolkit"
pkg_ml "spaCy"               "python3 -c 'import spacy' 2>/dev/null"        "pip3 install spacy -q" "NLP библиотека"
pkg_ml "HuggingFace Transformers" "python3 -c 'import transformers' 2>/dev/null" "pip3 install transformers -q" "Трансформеры и предобученные модели"
pkg_ml "Ultralytics (YOLO)"  "python3 -c 'import ultralytics' 2>/dev/null"  "pip3 install ultralytics -q" "Обнаружение объектов YOLO"
pkg_ml "Librosa"             "python3 -c 'import librosa' 2>/dev/null"      "pip3 install librosa -q" "Аудио-обработка и анализ"
pkg_ml "GeoPandas"           "python3 -c 'import geopandas' 2>/dev/null"    "pip3 install geopandas -q" "Геоданные и картография"

# --- 7. Тестирование и API ---
add_cat "Тестирование и API"
cat7_name=(); cat7_check=(); cat7_install=(); cat7_desc=()
pkg_test() { cat7_name+=("$1"); cat7_check+=("$2"); cat7_install+=("$3"); cat7_desc+=("$4"); }
pkg_test "Postman"            "snap list postman 2>/dev/null"                "snap install postman" "GUI клиент для тестирования API"
pkg_test "Insomnia"           "command -v insomnia 2>/dev/null"              "snap install insomnia && sleep 2" "REST/GraphQL клиент (документация!)"
pkg_test "Selenium"           "python3 -c 'import selenium' 2>/dev/null"    "pip3 install selenium -q" "Автоматизация браузера"
pkg_test "JMeter"             "command -v jmeter"                            "$PM install -y jmeter -qq" "Нагрузочное тестирование"
pkg_test "k6"                 "command -v k6"                                "$PM install -y k6 -qq 2>/dev/null || (curl -fsSL https://dl.k6.io/key.gpg | gpg --dearmor -o /usr/share/keyrings/k6.gpg 2>/dev/null && echo 'deb [signed-by=/usr/share/keyrings/k6.gpg] https://dl.k6.io/deb stable main' > /etc/apt/sources.list.d/k6.list && $PM update -qq && $PM install -y k6 -qq)" "Нагрузочное тестирование API"
pkg_test "Locust"             "python3 -c 'import locust' 2>/dev/null"       "pip3 install locust -q" "Нагрузочное тестирование на Python"
pkg_test "OWASP ZAP"          "command -v zaproxy 2>/dev/null"               "snap install zaproxy --classic" "Поиск уязвимостей в веб-приложениях"
pkg_test "Newman"             "command -v newman"                            "npm install -g newman -s 2>/dev/null" "CLI для Postman-коллекций"
pkg_test "Swagger CLI"        "command -v swagger-cli 2>/dev/null"           "npm install -g swagger-cli -s 2>/dev/null" "OpenAPI/Swagger инструменты"

# --- 8. Контейнеризация и виртуализация ---
add_cat "Контейнеризация и виртуализация"
cat8_name=(); cat8_check=(); cat8_install=(); cat8_desc=()
pkg_cont() { cat8_name+=("$1"); cat8_check+=("$2"); cat8_install+=("$3"); cat8_desc+=("$4"); }
pkg_cont "Docker"             "command -v docker"                            "$PM install -y docker.io -qq && systemctl enable docker --now" "Контейнеризация приложений"
pkg_cont "Docker Compose"     "command -v docker-compose 2>/dev/null"        "$PM install -y docker-compose -qq" "Оркестрация нескольких контейнеров"
pkg_cont "VirtualBox"         "command -v virtualbox 2>/dev/null"            "$PM install -y virtualbox -qq" "Виртуализация рабочей станции"
pkg_cont "Vagrant"            "command -v vagrant"                           "$PM install -y vagrant -qq 2>/dev/null || snap install vagrant 2>/dev/null || (echo '  Snap не сработал, качаю с HashiCorp...' && wget -qO /tmp/vagrant.deb 'https://releases.hashicorp.com/vagrant/2.4.1/vagrant_2.4.1-1_amd64.deb' && dpkg -i /tmp/vagrant.deb 2>/dev/null && $PM install -f -y -qq)" "Инфраструктура как код (VMs)"
pkg_cont "Minikube"           "command -v minikube"                          "wget -qO /tmp/minikube.deb 'https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb' && dpkg -i /tmp/minikube.deb 2>/dev/null; $PM install -f -y -qq" "Локальный Kubernetes"
pkg_cont "kubectl"            "command -v kubectl"                           "snap install kubectl --classic" "Управление Kubernetes"
pkg_cont "KVM/libvirt"        "command -v virsh 2>/dev/null"                 "$PM install -y virt-manager libvirt-daemon-system -qq" "Виртуализация уровня ядра"
pkg_cont "QEMU"               "command -v qemu-system-x86_64 2>/dev/null"    "$PM install -y qemu-system-x86 qemu-utils -qq" "Эмуляция железa"

# --- 9. Мониторинг и CI/CD ---
add_cat "Мониторинг и CI/CD"
cat9_name=(); cat9_check=(); cat9_install=(); cat9_desc=()
pkg_mon() { cat9_name+=("$1"); cat9_check+=("$2"); cat9_install+=("$3"); cat9_desc+=("$4"); }
pkg_mon "Grafana"             "command -v grafana-server 2>/dev/null"        "wget -qO /tmp/grafana.deb 'https://dl.grafana.com/oss/release/grafana_11.3.0_amd64.deb' && dpkg -i /tmp/grafana.deb 2>/dev/null; $PM install -f -y -qq" "Визуализация метрик и дашборды"
pkg_mon "Prometheus"          "command -v prometheus 2>/dev/null"            "wget -qO /tmp/prometheus.tar.gz 'https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz' && tar -xzf /tmp/prometheus.tar.gz -C /opt/ 2>/dev/null; ln -sf /opt/prometheus-*/prometheus /usr/local/bin/prometheus 2>/dev/null" "Сбор метрик и алертинг"
pkg_mon "Netdata"             "command -v netdata 2>/dev/null"               "$PM install -y netdata -qq 2>/dev/null || (wget -qO /tmp/netdata-kickstart.sh 'https://my-netdata.io/kickstart.sh' && bash /tmp/netdata-kickstart.sh -y 2>/dev/null; rm -f /tmp/netdata-kickstart.sh)" "Мониторинг системы в реальном времени"
pkg_mon "Jenkins"             "command -v jenkins 2>/dev/null"               "wget -qO /tmp/jenkins.deb 'https://get.jenkins.io/debian-stable/jenkins_2.479.3_all.deb' && dpkg -i /tmp/jenkins.deb 2>/dev/null; $PM install -f -y -qq" "CI/CD сервер"
pkg_mon "HAProxy"             "command -v haproxy"                           "$PM install -y haproxy -qq" "Балансировщик нагрузки"
pkg_mon "Elasticsearch"       "dpkg -l elasticsearch 2>/dev/null | grep -q '^ii' || test -d /usr/share/elasticsearch 2>/dev/null"         "wget -qO /tmp/es-key.asc 'https://artifacts.elastic.co/GPG-KEY-elasticsearch' && gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg /tmp/es-key.asc 2>/dev/null; echo 'deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main' > /etc/apt/sources.list.d/elastic-8.x.list && $PM update -qq 2>/dev/null && $PM install -y elasticsearch -qq 2>/dev/null || wget -qO /tmp/es.deb 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.17.2-amd64.deb' && (dpkg -i /tmp/es.deb 2>/dev/null || true) && $PM install -f -y -qq" "Поисковая БД (логи, телеметрия)"

# --- 10. Безопасность ---
add_cat "Безопасность"
cat10_name=(); cat10_check=(); cat10_install=(); cat10_desc=()
pkg_sec() { cat10_name+=("$1"); cat10_check+=("$2"); cat10_install+=("$3"); cat10_desc+=("$4"); }
pkg_sec "ufw"                 "command -v ufw"                               "$PM install -y ufw -qq" "Межсетевой экран (защита от несанкц. доступа)"
pkg_sec "Fail2ban"            "command -v fail2ban-client 2>/dev/null"       "$PM install -y fail2ban -qq" "Защита от брутфорса"
pkg_sec "ClamAV"              "command -v clamscan"                          "$PM install -y clamav clamav-daemon -qq" "Антивирус (проверка на вредоносное ПО)"
pkg_sec "WireGuard"           "command -v wg"                                "$PM install -y wireguard -qq" "VPN-туннель (защита соединений)"
pkg_sec "OpenVPN"             "command -v openvpn"                           "$PM install -y openvpn -qq" "VPN клиент/сервер"
pkg_sec "Wireshark"           "command -v wireshark"                         "$PM install -y wireshark -qq" "Анализ сетевого трафика"
pkg_sec "nmap"                "command -v nmap"                              "$PM install -y nmap -qq" "Сканирование сети и портов"
pkg_sec "auditd"              "command -v auditctl"                          "$PM install -y auditd audispd-plugins -qq" "Система аудита (журнал событий безопасности)"
pkg_sec "OpenSSL"             "command -v openssl"                           "$PM install -y openssl -qq" "Шифрование и сертификаты"
pkg_sec "SonarQube Scanner"   "command -v sonar-scanner 2>/dev/null"         "wget -qO /tmp/sonar.zip 'https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.2.1.4610-linux-x64.zip' && unzip -qo /tmp/sonar.zip -d /opt/ 2>/dev/null; ln -sf /opt/sonar-scanner-*/bin/sonar-scanner /usr/local/bin/ 2>/dev/null" "Статический анализ кода (SAST)"
pkg_sec "Trivy"               "command -v trivy 2>/dev/null"                 "wget -qO /tmp/trivy.deb 'https://github.com/aquasecurity/trivy/releases/download/v0.58.2/trivy_0.58.2_Linux-64bit.deb' && (dpkg -i /tmp/trivy.deb 2>/dev/null || true) && $PM install -f -y -qq; command -v trivy 2>/dev/null || snap install trivy" "Сканирование уязвимостей"

# --- 11. Утилиты ---
add_cat "Утилиты и базовое ПО"
cat11_name=(); cat11_check=(); cat11_install=(); cat11_desc=()
pkg_util() { cat11_name+=("$1"); cat11_check+=("$2"); cat11_install+=("$3"); cat11_desc+=("$4"); }
pkg_util "Git"                "command -v git"                               "$PM install -y git -qq && git config --global init.defaultBranch main" "Система контроля версий"
pkg_util "htop"               "command -v htop"                              "$PM install -y htop -qq" "Мониторинг процессов"
pkg_util "curl + wget"        "command -v curl && command -v wget"           "$PM install -y curl wget -qq" "Скачивание файлов и запросы"
pkg_util "screen + tmux"      "command -v screen && command -v tmux"         "$PM install -y screen tmux -qq" "Мультиплексирование терминала"
pkg_util "Vim + Nano"         "command -v vim && command -v nano"            "$PM install -y vim nano -qq" "Текстовые редакторы"
pkg_util "7-Zip (p7zip)"      "command -v 7z"                                "$PM install -y p7zip-full -qq" "Архиватор"
pkg_util "tree"               "command -v tree"                              "$PM install -y tree -qq" "Дерево директорий"
pkg_util "net-tools"          "command -v ifconfig"                          "$PM install -y net-tools -qq" "Сетевые утилиты (ifconfig, netstat)"
pkg_util "CUPS + cups-pdf"    "command -v lpinfo"                            "$PM install -y cups cups-pdf -qq && systemctl enable cups --now 2>/dev/null" "Виртуальный PDF-принтер"
pkg_util "Timeshift"          "command -v timeshift"                          "$PM install -y timeshift -qq" "Точки восстановления системы"
pkg_util "build-essential"    "command -v gcc && command -v make"            "$PM install -y build-essential -qq" "GCC, make, библиотеки для компиляции"
pkg_util "FFmpeg"             "command -v ffmpeg"                            "$PM install -y ffmpeg -qq" "Обработка видео и аудио"
pkg_util "hardinfo (CPU-Z)"   "command -v hardinfo"                          "$PM install -y hardinfo -qq" "Информация о системе (CPU-Z аналог)"
pkg_util "lm-sensors"         "command -v sensors"                           "$PM install -y lm-sensors psensor -qq" "Мониторинг температуры"
pkg_util "LibreOffice"        "command -v libreoffice"                       "$PM install -y libreoffice -qq" "Офисный пакет (документация)"

# --- 12. Специализированное ПО ---
add_cat "Специализированное ПО"
cat12_name=(); cat12_check=(); cat12_install=(); cat12_desc=()
pkg_spec() { cat12_name+=("$1"); cat12_check+=("$2"); cat12_install+=("$3"); cat12_desc+=("$4"); }
pkg_spec "Mosquitto (MQTT)"   "command -v mosquitto"                         "$PM install -y mosquitto mosquitto-clients -qq" "Брокер MQTT (IoT, умный дом)"
pkg_spec "Ansible"            "command -v ansible"                           "$PM install -y ansible -qq" "Управление конфигурацией (DevOps)"
pkg_spec "R + RStudio"        "command -v R 2>/dev/null"                     "$PM install -y r-base -qq" "Статистический анализ данных"
pkg_spec "OpenOCD"            "command -v openocd 2>/dev/null"               "$PM install -y openocd -qq" "Программатор микроконтроллеров"
pkg_spec "can-utils"          "command -v candump 2>/dev/null"               "$PM install -y can-utils -qq" "CAN-шина (автомобильные системы)"
pkg_spec "GStreamer"          "command -v gst-launch-1.0 2>/dev/null"        "$PM install -y gstreamer1.0-tools gstreamer1.0-plugins-good -qq" "Мультимедиа фреймворк (CV, видео)"
pkg_spec "Rasa"               "python3 -c 'import rasa' 2>/dev/null"         "$PM install -y build-essential python3-dev -qq 2>/dev/null; pip3 install --upgrade setuptools wheel -q 2>/dev/null; pip3 install rasa -q" "Чат-боты и диалоговый AI"
pkg_spec "Open3D"             "python3 -c 'import open3d' 2>/dev/null"       "$PM install -y libgl1 -qq 2>/dev/null; pip3 install open3d -q" "3D-обработка (AR/VR, игры)"
pkg_spec "sshfs"              "command -v sshfs"                             "$PM install -y sshfs -qq" "Монтирование удалённых папок по SSH"

# ===================== ЯДРО ИНТЕРФЕЙСА =====================

# Сброс выбора для текущей категории
PKG_NAMES=(); PKG_CHECKS=(); PKG_INSTALLS=(); PKG_DESCS=()
PKG_SELECTED=()

# Загрузка категории по номеру
load_category() {
    local n=$1
    local -n names="cat${n}_name"
    local -n checks="cat${n}_check"
    local -n installs="cat${n}_install"
    local -n descs="cat${n}_desc"
    PKG_NAMES=("${names[@]}")
    PKG_CHECKS=("${checks[@]}")
    PKG_INSTALLS=("${installs[@]}")
    PKG_DESCS=("${descs[@]}")
    # Инициализируем выбор
    PKG_SELECTED=()
    for ((i=0; i<${#PKG_NAMES[@]}; i++)); do
        PKG_SELECTED[i]=0
    done
}

# Проверка установлен ли пакет
is_installed() {
    local idx=$1
    local check_cmd="${PKG_CHECKS[$idx]}"
    if [[ -z "$check_cmd" ]]; then
        # Нет проверки - считаем что не установлен
        return 1
    fi
    eval "$check_cmd" &>/dev/null && return 0
    return 1
}

# Очистка экрана
clear_screen() {
    printf "\033[2J\033[H"
}

# Заголовок
print_header() {
    local title="$1"
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}          УСТАНОВЩИК ПО — Квалификационный экзамен ОС      ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRAY}          Этап 2: Установка ПО по роли                      ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
    if [[ -n "$title" ]]; then
        # Вычисляем отступы для центрирования
        local len=${#title}
        local pad=$(( (50 - len) / 2 ))
        printf "${CYAN}║${NC}%*s${WHITE}%s${NC}%*s${CYAN}║${NC}\n" $pad "" "$title" $((50 - len - pad)) ""
        echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
    fi
}

print_footer() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
}

# ===================== ГЛАВНОЕ МЕНЮ =====================

show_main_menu() {
    while true; do
        clear_screen
        print_header "ГЛАВНОЕ МЕНЮ"
        echo ""
        for ((i=0; i<CAT_COUNT; i++)); do
            local num=$((i+1))
            printf "${WHITE}%3d)${NC}  %s\n" $num "${CAT_NAMES[$i]}"
        done
        echo ""
        echo -e "${GRAY}────────────────────────────────────────────${NC}"
        printf "${WHITE}  c)${NC}  Настройка совместимости (2.50 балла)\n"
        printf "${WHITE}  0)${NC}  Выход\n"
        echo ""
        printf "${YELLOW}Выбери категорию [0-%d, c]:${NC} " $CAT_COUNT
        read -r choice
        if [[ "$choice" == "0" ]]; then
            echo -e "${GREEN}Пока!${NC}"
            exit 0
        fi
        if [[ "$choice" == "c" || "$choice" == "C" ]]; then
            echo ""
            echo -e "${YELLOW}Запускаю настройку совместимости...${NC}"
            # Ищем скрипт compatibility-setup.sh рядом
            SCRIPT_DIR="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")"
            if [[ -f "$SCRIPT_DIR/compatibility-setup.sh" ]]; then
                bash "$SCRIPT_DIR/compatibility-setup.sh"
            elif [[ -f "./compatibility-setup.sh" ]]; then
                bash "./compatibility-setup.sh"
            else
                echo -e "${RED}Файл compatibility-setup.sh не найден!${NC}"
                echo -e "${YELLOW}Загрузи его или запусти вручную:${NC}"
                echo -e "  ${WHITE}wget -qO compatibility-setup.sh <url> && sudo bash compatibility-setup.sh${NC}"
                echo -e "${YELLOW}Либо создай и выполни настройки из раздела 'Настройка совместимости' в guides/manual-install.md${NC}"
            fi
            echo ""
            printf "${GRAY}Нажми Enter чтобы продолжить...${NC}"
            read -r
            continue
        fi
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= CAT_COUNT )); then
            load_category "$choice"
            show_category "$choice"
        else
            echo -e "${RED}Неверный выбор!${NC}"
            sleep 1
        fi
    done
}

# ===================== МЕНЮ КАТЕГОРИИ =====================

show_category() {
    local cat_num=$1
    local cat_name="${CAT_NAMES[$((cat_num-1))]}"
    local total=${#PKG_NAMES[@]}

    while true; do
        clear_screen
        print_header "$cat_name"
        echo -e "${GRAY}  №  Статус  Программа                    Описание${NC}"
        echo -e "${GRAY}  ──────────────────────────────────────────────────────────────${NC}"

        for ((i=0; i<total; i++)); do
            local num=$((i+1))
            local name="${PKG_NAMES[$i]}"
            local desc="${PKG_DESCS[$i]}"

            # Статус установки
            if is_installed "$i"; then
                local status="${GREEN}✔${NC}"
            else
                local status="${GRAY}·${NC}"
            fi

            # Выбран ли
            if [[ ${PKG_SELECTED[$i]} -eq 1 ]]; then
                local marker="${GREEN}►${NC}"
            else
                local marker=" "
            fi

            # Обрезаем имя до 30 символов
            printf "  ${WHITE}%2d)${NC} ${marker}${status} %-30s ${GRAY}%s${NC}\n" "$num" "$name" "$desc"
        done

        echo ""
        echo -e "${GRAY}────────────────────────────────────────────${NC}"
        echo -e "  ${WHITE}i${NC}) Установить выбранное"
        echo -e "  ${WHITE}a${NC}) Выбрать всё"
        echo -e "  ${WHITE}c${NC}) Снять всё"
        echo -e "  ${WHITE}b${NC}) Назад в меню"
        echo ""
        printf "${YELLOW}Выбери номер пакета (или i/a/c/b):${NC} "
        read -r cmd

        if [[ "$cmd" == "b" ]]; then
            return
        elif [[ "$cmd" == "i" ]]; then
            install_selected
            sleep 2
        elif [[ "$cmd" == "a" ]]; then
            for ((i=0; i<total; i++)); do
                if ! is_installed "$i"; then
                    PKG_SELECTED[$i]=1
                else
                    PKG_SELECTED[$i]=0
                fi
            done
        elif [[ "$cmd" == "c" ]]; then
            for ((i=0; i<total; i++)); do
                PKG_SELECTED[$i]=0
            done
        elif [[ "$cmd" =~ ^[0-9]+$ ]] && (( cmd >= 1 && cmd <= total )); then
            local idx=$((cmd-1))
            if is_installed "$idx"; then
                echo -e "  ${YELLOW}Уже установлено. Снять выбор?${NC}"
                PKG_SELECTED[$idx]=0
            else
                if [[ ${PKG_SELECTED[$idx]} -eq 1 ]]; then
                    PKG_SELECTED[$idx]=0
                else
                    PKG_SELECTED[$idx]=1
                fi
            fi
            sleep 0.3
        else
            echo -e "${RED}Неверный ввод${NC}"
            sleep 0.5
        fi
    done
}

# ===================== УСТАНОВКА =====================

install_selected() {
    local total=${#PKG_NAMES[@]}
    local to_install=()
    for ((i=0; i<total; i++)); do
        if [[ ${PKG_SELECTED[$i]} -eq 1 ]]; then
            to_install+=("$i")
        fi
    done

    if [[ ${#to_install[@]} -eq 0 ]]; then
        echo -e "${YELLOW}Ничего не выбрано для установки.${NC}"
        sleep 1
        return
    fi

    echo ""
    echo -e "${YELLOW}Будут установлены:${NC}"
    for idx in "${to_install[@]}"; do
        echo -e "  ${GREEN}•${NC} ${PKG_NAMES[$idx]} — ${PKG_DESCS[$idx]}"
    done
    echo ""
    printf "${YELLOW}Продолжить? [Y/n]:${NC} "
    read -r confirm
    if [[ "$confirm" =~ ^[Nn] ]]; then
        echo -e "  ${GRAY}Отменено${NC}"
        sleep 1
        return
    fi

    # Обновление репозиториев
    echo -e "${BLUE}Обновляю список пакетов...${NC}"
    $PM update -qq 2>/dev/null

    # ---- Апгрейд pip и системные зависимости для pip-пакетов ----
    local has_pip=0
    for idx in "${to_install[@]}"; do
        if [[ "${PKG_INSTALLS[$idx]}" == pip3* ]]; then
            has_pip=1
            break
        fi
    done
    if [[ $has_pip -eq 1 ]]; then
        echo -e "${BLUE}  Обновляю pip и системные зависимости Python...${NC}"
        pip3 install --upgrade pip -q 2>/dev/null || true
        export PIP_BREAK_SYSTEM_PACKAGES=1
        # Прямой флаг для pip >= 23 (на всякий случай, если env var не подхватится)
        local pip_extra=""
        if pip3 install --help 2>/dev/null | grep -q break-system-packages; then
            pip_extra="--break-system-packages"
        fi
        $PM install -y python3-dev build-essential libgdal-dev -qq 2>/dev/null || true
    fi

    # ---- Проверка npm для npm-пакетов (Node.js должен быть установлен) ----
    local has_npm=0
    for idx in "${to_install[@]}"; do
        if [[ "${PKG_INSTALLS[$idx]}" == npm* ]]; then
            has_npm=1
            break
        fi
    done
    if [[ $has_npm -eq 1 ]] && ! command -v npm &>/dev/null; then
        echo -e "${YELLOW}  ⚠ npm не найден! npm-пакеты не установятся без Node.js.${NC}"
        echo -e "  ${YELLOW}  Сначала установи Node.js из категории 2 (Языки и SDK).${NC}"
        echo -e "  ${GRAY}  После установки Node.js можно доустановить npm-пакеты.${NC}"
    fi

    for idx in "${to_install[@]}"; do
        local name="${PKG_NAMES[$idx]}"
        local install_cmd="${PKG_INSTALLS[$idx]}"

        echo ""
        echo -e "${YELLOW}═══ Устанавливаю: $name ═══${NC}"

        if is_installed "$idx"; then
            echo -e "${GREEN}  ✔ Уже установлено!${NC}"
            continue
        fi

        # Пытаемся установить
        if [[ "$install_cmd" == pip3* ]] && [[ -n "$pip_extra" ]]; then
            eval "$install_cmd $pip_extra" >> "$INSTALL_DIR/install.log" 2>&1
        else
            eval "$install_cmd" >> "$INSTALL_DIR/install.log" 2>&1
        fi
        local exit_code=$?

        if [[ $exit_code -eq 0 ]]; then
            # Проверяем успешность
            sleep 1
            if is_installed "$idx"; then
                echo -e "  ${GREEN}✔ Успешно установлено: $name${NC}"
            else
                echo -e "  ${YELLOW}⚠ Установка завершена, но проверка не пройдена. Возможно, нужен рестарт.${NC}"
            fi
        else
            echo -e "  ${RED}✘ Ошибка при установке $name (exit: $exit_code)${NC}"
            echo -e "  ${GRAY}   Подробнее: tail -20 $INSTALL_DIR/install.log${NC}"
        fi
    done

    echo ""
    echo -e "${GREEN}═══ Установка завершена ═══${NC}"
    echo -e "  ${GRAY}Лог: $INSTALL_DIR/install.log${NC}"

    # ---- Post-install: interface & data exchange config ----
    if [[ ${#to_install[@]} -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}═══ Пост-установочная настройка ═══${NC}"
        echo -e "${GRAY}  Хочешь настроить интерфейс и обмен данными?${NC}"
        printf "${YELLOW}  Настроить? [Y/n]:${NC} "
        read -r config_confirm
        if [[ ! "$config_confirm" =~ ^[Nn] ]]; then
            echo -e "  ${BLUE}→ Настройка интерфейса...${NC}"

            # Настройка Git, если установлен
            if command -v git &>/dev/null; then
                git config --global init.defaultBranch main 2>/dev/null
                # Создаём тестовый репозиторий
                su -c "
                    mkdir -p \$HOME/projects/myapp
                    cd \$HOME/projects/myapp
                    git init 2>/dev/null
                    echo '# MyApp' > README.md
                    git add README.md 2>/dev/null
                    git commit -m 'Initial commit' 2>/dev/null
                " "$SUDO_USER" 2>/dev/null || true
                echo -e "  ${GREEN}✔${NC} Git: репозиторий ~/projects/myapp инициализирован"
            fi

            # Настройка VS Code, если установлен
            if command -v code &>/dev/null; then
                # Базовая конфигурация VS Code
                su -c "
                    mkdir -p \$HOME/.config/Code/User
                    cat > \$HOME/.config/Code/User/settings.json << 'EOF'
{
    \"editor.fontSize\": 14,
    \"files.autoSave\": \"onFocusChange\",
    \"workbench.colorTheme\": \"Default Dark+\",
    \"editor.minimap.enabled\": true
}
EOF
                " "$SUDO_USER" 2>/dev/null || true
                echo -e "  ${GREEN}✔${NC} VS Code: настройки интерфейса применены"
            fi

            # Запуск служб БД, если установлены
            if command -v psql &>/dev/null; then
                systemctl enable postgresql --now 2>/dev/null || true
                su -c "psql -c 'SELECT version();' 2>/dev/null" postgres 2>/dev/null || true
                echo -e "  ${GREEN}✔${NC} PostgreSQL: служба запущена"
            fi
            if command -v mysql &>/dev/null; then
                systemctl enable mysql --now 2>/dev/null || true
                echo -e "  ${GREEN}✔${NC} MySQL: служба запущена"
            fi

            # Каталоги для импорта/экспорта
            su -c "
                mkdir -p \$HOME/data/import \$HOME/data/export
                echo 'id,name,value' > \$HOME/data/import/sample.csv
                echo '1,test,100' >> \$HOME/data/import/sample.csv
            " "$SUDO_USER" 2>/dev/null || true
            echo -e "  ${GREEN}✔${NC} Data: каталоги импорта/экспорта созданы"

            echo -e "  ${GREEN}✓ Пост-установочная настройка завершена${NC}"
            echo -e "  ${GRAY}   Вклад в баллы: стартовая настройка (2.0) + обмен данными (2.0)${NC}"
        fi
    fi
}

# ===================== START =====================

# Первичная настройка
echo -e "${GRAY}Инициализация...${NC}"

# ---- Debconf пресеты (чтобы установка не зависла) ----
echo "wireshark-common wireshark-common/install-setuid boolean false" | debconf-set-selections 2>/dev/null || true
echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections 2>/dev/null || true
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections 2>/dev/null || true

# ---- Реальный пользователь (работает даже из sudo -i) ----
if [[ -z "$SUDO_USER" ]]; then
    SUDO_USER=$(logname 2>/dev/null || echo "root")
fi
# Включаем universe репозиторий (там много IDE)
$PM install -y software-properties-common -qq &>/dev/null
add-apt-repository -y universe &>/dev/null || true
$PM update -qq 2>/dev/null
# Настраиваем Git если ещё нет
if command -v git &>/dev/null; then
    git config --global user.name "Student" &>/dev/null
    git config --global user.email "student@example.com" &>/dev/null
    git config --global init.defaultBranch main &>/dev/null
fi
# Убеждаемся что pip3 есть
if ! command -v pip3 &>/dev/null; then
    $PM install -y python3-pip -qq &>/dev/null
fi
# Убеждаемся что snap есть
if ! command -v snap &>/dev/null; then
    $PM install -y snapd -qq &>/dev/null
fi
# Добавляем snap/bin в PATH для sudo
if [[ ":$PATH:" != *":/snap/bin:"* ]]; then
    export PATH="$PATH:/snap/bin:/var/lib/snapd/snap/bin"
fi
# Добавляем snap/bin в системный PATH для всех пользователей
if ! grep -q "snap/bin" /etc/bash.bashrc 2>/dev/null; then
    echo 'export PATH="$PATH:/snap/bin:/var/lib/snapd/snap/bin"' >> /etc/bash.bashrc 2>/dev/null || true
fi
# Ждём инициализацию snap (на свежей системе без этого snap install падает)
if command -v snap &>/dev/null; then
    timeout 120 snap wait system seed.loaded 2>/dev/null || true
fi

clear_screen
print_header
echo -e "${GREEN}  Готов к работе!${NC}"
echo -e "${GRAY}  Выбирай категорию → выбирай ПО → устанавливай${NC}"
echo -e "${GRAY}  Каждый пакет можно объяснить на защите!${NC}"
print_footer
sleep 1

show_main_menu
