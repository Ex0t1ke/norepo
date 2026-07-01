#!/usr/bin/env python3
"""
Генератор шаблона «Руководство пользователя» в формате .odt
по ГОСТ Р 59795-2021 (раздел 6.4) + ГОСТ 24.301 (оформление)

Использование:
    python3 generate-template.py [название ПО] [--output файл.odt]

Зависимости:
    pip install odfpy
"""

import sys
import os
from odf import style, text, table, draw, teletype
from odf.opendocument import OpenDocumentText
from odf.style import (
    Style, TextProperties, ParagraphProperties, PageLayout,
    PageLayoutProperties, MasterPage, HeaderStyle, HeaderFooterProperties,
    FooterStyle
)
from odf.number import DateStyle, NumberStyle

# ---- Parameters ----
APP_NAME = sys.argv[1] if len(sys.argv) > 1 else "[Название ПО]"
OUTPUT_FILE = sys.argv[2] if len(sys.argv) > 2 else "user-guide-template.odt"

# ---- Create document ----
doc = OpenDocumentText()

# ======== STYLES ========

# ---- Page layout (GOST 24.301 margins) ----
page_layout = PageLayout(name="GostPage")
page_layout.addElement(PageLayoutProperties(
    pagewidth="210mm",
    pageheight="297mm",
    marginleft="30mm",
    marginright="10mm",
    margintop="20mm",
    marginbottom="20mm",
))
doc.automaticstyles.addElement(page_layout)

# Master page
master_page = MasterPage(name="Standard", pagelayoutname="GostPage")
doc.masterstyles.addElement(master_page)

# ---- Default paragraph style (body text) ----
body_style = Style(name="BodyText", family="paragraph")
body_style.addElement(ParagraphProperties(
    lineheight="150%",
))
body_style.addElement(TextProperties(
    fontsize="14pt",
    fontname="Times New Roman",
    language="ru",
    country="RU",
))
doc.styles.addElement(body_style)

# ---- Title style ----
title_style = Style(name="TitleMain", family="paragraph")
title_style.addElement(ParagraphProperties(
    textalign="center",
))
title_style.addElement(TextProperties(
    fontsize="16pt",
    fontname="Times New Roman",
    fontweight="bold",
))
doc.automaticstyles.addElement(title_style)

# ---- Section heading (1, 2, 3...) ----
h1_style = Style(name="Heading1", family="paragraph", parentstylename="Heading")
h1_style.addElement(ParagraphProperties(
    textalign="left",
))
h1_style.addElement(TextProperties(
    fontsize="14pt",
    fontname="Times New Roman",
    fontweight="bold",
))
doc.automaticstyles.addElement(h1_style)

# ---- Subsection heading (1.1, 1.2...) ----
h2_style = Style(name="Heading2", family="paragraph", parentstylename="Heading")
h2_style.addElement(ParagraphProperties(
    textalign="left",
))
h2_style.addElement(TextProperties(
    fontsize="14pt",
    fontname="Times New Roman",
    fontweight="bold",
    fontstyle="italic",
))
doc.automaticstyles.addElement(h2_style)

# ---- Sub-subsection (4.2, 4.3...) ----
h3_style = Style(name="Heading3", family="paragraph", parentstylename="Heading")
h3_style.addElement(ParagraphProperties(
    textalign="left",
))
h3_style.addElement(TextProperties(
    fontsize="14pt",
    fontname="Times New Roman",
    fontweight="bold",
))
doc.automaticstyles.addElement(h3_style)

# ---- Code block style ----
code_style = Style(name="CodeBlock", family="paragraph")
code_style.addElement(ParagraphProperties(
    marginleft="10mm",
))
code_style.addElement(TextProperties(
    fontsize="11pt",
    fontname="Courier New",
))
doc.automaticstyles.addElement(code_style)

# ---- List item style ----
list_style = Style(name="ListItem", family="paragraph")
list_style.addElement(ParagraphProperties(
    marginleft="10mm",
))
list_style.addElement(TextProperties(
    fontsize="14pt",
    fontname="Times New Roman",
))
doc.automaticstyles.addElement(list_style)


# ---- Bold inline span style ----
bold_span_style = Style(name="BoldSpan", family="text")
bold_span_style.addElement(TextProperties(fontweight="bold"))
doc.automaticstyles.addElement(bold_span_style)

# ======== HELPER FUNCTIONS ========

def add_title(txt, style_name="TitleMain"):
    p = text.P(stylename=style_name)
    p.addText(txt)
    doc.text.addElement(p)

def add_heading(txt, level=1):
    if level == 1:
        st = h1_style
    elif level == 2:
        st = h2_style
    else:
        st = h3_style
    p = text.P(stylename=st)
    p.addText(txt)
    doc.text.addElement(p)

def add_para(txt, st="BodyText"):
    p = text.P(stylename=st)
    p.addText(txt)
    doc.text.addElement(p)

def add_empty():
    p = text.P(stylename="BodyText")
    doc.text.addElement(p)

def add_code(lines):
    """Add code block (multi-line)"""
    for line in lines.split('\n'):
        add_para(line, "CodeBlock")

def add_bullet(txt):
    """Add list item"""
    p = text.P(stylename="ListItem")
    p.addText("•  " + txt)
    doc.text.addElement(p)

def add_numbered(number, txt):
    """Add numbered item"""
    p = text.P(stylename="ListItem")
    p.addText(f"{number}. {txt}")
    doc.text.addElement(p)

def add_bold_line(txt):
    p = text.P(stylename="BodyText")
    span = text.Span(stylename="BoldSpan")
    span.addText(txt)
    p.addElement(span)
    doc.text.addElement(p)


# ======== DOCUMENT CONTENT ========

# ---- Title page ----
add_empty()
add_empty()
add_empty()
add_empty()
add_empty()

add_title("РУКОВОДСТВО ПОЛЬЗОВАТЕЛЯ")
add_empty()
add_empty()
add_empty()
add_empty()
add_empty()

# Title block - centered
p = text.P(stylename=title_style)
bold = text.Span(stylename="BoldSpan")
bold.addText(f"Средство автоматизации: {APP_NAME}")
p.addElement(bold)
doc.text.addElement(p)

add_empty()

p = text.P(stylename="BodyText")
p.addText("Операционная система: Linux (Ubuntu 22.04+) / Windows 10+")
doc.text.addElement(p)

p = text.P(stylename="BodyText")
p.addText("Дата составления: _______________")
doc.text.addElement(p)

# Page break
# Page break — multiple blank lines
for _ in range(3):
    add_empty()

# ---- Section 1: Introduction ----
add_heading("1. Введение")
add_empty()

add_heading("1.1 Область применения", 2)
add_para("Настоящий документ является руководством пользователя для работы со средством автоматизации «" + APP_NAME + "».")
add_para("Данное программное обеспечение предназначено для __________________________________________________________________")
add_para("Руководство предназначено для пользователей, выполняющих _____________________________________________________")
add_empty()

add_heading("1.2 Уровень подготовки пользователя", 2)
add_para("Пользователь должен обладать базовыми навыками работы в операционной системе (терминал Linux / командная строка Windows), а также понимать основные принципы ________________________________________")
add_para("Для работы в Linux требуется уверенное использование терминала и пакетного менеджера. Для работы в Windows — умение устанавливать приложения и работать с проводником.")
add_empty()

add_heading("1.3 Перечень эксплуатационной документации", 2)
add_para("Для успешного использования средства автоматизации рекомендуется ознакомиться со следующей документацией:")
add_bullet("официальная документация «" + APP_NAME + "» (доступна на сайте разработчика)")
add_bullet("системные требования и инструкция по установке")
add_bullet("настоящий документ")
add_empty()

# ---- Section 2: Purpose and conditions ----
add_heading("2. Назначение и условия применения")
add_empty()

add_heading("2.1 Назначение средства автоматизации", 2)
add_para("«" + APP_NAME + "» — это _______________________________________________________________________, который позволяет пользователю автоматизировать следующие виды деятельности:")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_empty()

add_heading("2.2 Краткое описание возможностей", 2)
add_para("Основные возможности средства автоматизации:")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_bullet("поддержка операционных систем Linux и Windows")
add_empty()

add_heading("2.3 Конфигурация технических средств", 2)
add_para("Linux (Ubuntu 22.04+):")
add_bullet("Процессор: не ниже 2-ядерного, 2 ГГц")
add_bullet("ОЗУ: не менее 4 ГБ (рекомендуется 8 ГБ)")
add_bullet("Свободное место на диске: не менее 1 ГБ")
add_bullet("ОС: Ubuntu 22.04 LTS или выше")
add_bullet("Зависимости: ________________________________________________")
add_empty()
add_para("Windows 10+:")
add_bullet("Процессор: не ниже 2-ядерного, 2 ГГц")
add_bullet("ОЗУ: не менее 4 ГБ (рекомендуется 8 ГБ)")
add_bullet("Свободное место на диске: не менее 1 ГБ")
add_bullet("ОС: Windows 10 Pro 64-bit или выше")
add_bullet("Зависимости: ________________________________________________")
add_empty()

add_heading("2.4 Условия применения", 2)
add_para("Программа применяется при наличии установленной операционной системы (Linux или Windows), соответствующей указанным выше требованиям. Для работы необходимо:")
add_bullet("подключение к локальной сети / интернету (для функций, требующих сетевого доступа)")
add_bullet("наличие учётной записи (для некоторых функций)")
add_bullet("______________________________________________________________________")
add_empty()

# ---- Section 3: Preparation ----
add_heading("3. Подготовка к работе")
add_empty()

add_heading("3.1 Состав дистрибутива", 2)
add_para("Дистрибутив включает:")
add_bullet("установочный файл / пакет (____________________________________)")
add_bullet("файлы конфигурации (при необходимости)")
add_bullet("документацию")
add_empty()

add_heading("3.2.1 Установка в Linux (Ubuntu)", 2)
add_para("Способ 1 — установка из репозитория:")
add_code("    # Добавление репозитория (если требуется)\n    echo \"deb [репозиторий]\" | sudo tee /etc/apt/sources.list.d/[файл].list\n    # Импорт ключа GPG\n    wget -qO- [ключ] | sudo apt-key add -\n    # Установка\n    sudo apt update\n    sudo apt install [пакет]")
add_para("Способ 2 — установка из скачанного пакета:")
add_code("    # Для .deb\n    sudo dpkg -i [файл].deb\n    sudo apt --fix-broken install\n\n    # Для .AppImage\n    chmod +x [файл].AppImage\n    ./[файл].AppImage")
add_empty()

add_heading("3.2.2 Установка в Windows", 2)
add_para("Способ 1 — установка через установщик:")
add_numbered(1, "Скачать установочный файл с официального сайта.")
add_numbered(2, "Запустить [файл].exe / [файл].msi от имени администратора.")
add_numbered(3, "Следовать инструкциям мастера установки.")
add_para("Способ 2 — установка через менеджер пакетов (winget):")
add_code("    winget install [пакет]")
add_empty()

add_heading("3.3 Проверка работоспособности", 2)
add_para("После установки необходимо проверить, что программа запускается корректно.")
add_para("Linux:")
add_code("    # Проверка версии\n    [команда] --version\n\n    # Запуск программы\n    [команда запуска]")
add_para("Windows:")
add_code("    :: Проверка версии\n    [команда] --version\n\n    :: Запуск из командной строки\n    [команда запуска]")
add_para("Если программа запустилась и отображает основной интерфейс — установка выполнена успешно.")
add_empty()

# ---- Section 4: Operations ----
add_heading("4. Описание операций")
add_empty()

add_heading("4.1 Общее описание", 2)
add_para("В данном разделе приведены основные операции, выполняемые пользователем при работе со средством автоматизации «" + APP_NAME + "».")
add_empty()

# Operation template
def add_operation(num, name):
    add_heading(f"4.{num} Операция: {name}", 2)
    add_empty()
    add_bold_line("Наименование:")
    add_para(name)
    add_empty()
    add_bold_line("Условия выполнения:")
    add_bullet("программа должна быть установлена и запущена")
    add_bullet("________________________________________")
    add_empty()
    add_bold_line("Подготовительные действия:")
    add_numbered(1, "Запустить программу.")
    add_numbered(2, "__________________________________")
    add_empty()
    add_bold_line("Основные действия:")
    add_numbered(1, "В главном меню выбрать «_____________».")
    add_numbered(2, "В открывшемся окне указать параметры.")
    add_numbered(3, "Нажать кнопку «______________________».")
    add_numbered(4, "Дождаться завершения операции.")
    add_empty()
    add_bold_line("Заключительные действия:")
    add_bullet("Убедиться, что результат корректен.")
    add_bullet("При необходимости сохранить результат.")
    add_empty()
    add_bold_line("Ресурсы, расходуемые на операцию:")
    add_bullet("время выполнения: __________________")
    add_bullet("оперативная память: ________________")
    add_bullet("дисковое пространство: ______________")
    add_empty()

add_operation(2, "[Название операции 1]")
add_operation(3, "[Название операции 2]")

add_heading("4.4 [Дополнительные операции — при необходимости]", 2)
add_para("При необходимости в данный раздел добавляются другие операции, предусмотренные функциональностью средства автоматизации.")
add_empty()

# ---- Section 5: Emergency ----
add_heading("5. Аварийные ситуации")
add_empty()

add_heading("5.1 Действия при сбоях выполнения операций", 2)
add_para("При возникновении ошибки в процессе выполнения операции необходимо:")
add_numbered(1, "Зафиксировать текст сообщения об ошибке.")
add_numbered(2, "Проверить сетевое подключение (если требуется).")
add_numbered(3, "Убедиться, что сервер (если требуется) доступен и работает.")
add_para("Linux: проверить системные журналы")
add_code("    journalctl -xe\n    tail -f /var/log/syslog")
add_para("Windows: проверить Журнал событий")
add_code("    eventvwr.msc")
add_empty()

add_heading("5.2 Восстановление программ и/или данных", 2)
add_para("При отказе носителей данных или обнаружении ошибок в данных:")
add_numbered(1, "Закрыть программу.")
add_numbered(2, "Создать резервную копию рабочей директории:")
add_bullet("Linux: cp -r ~/.config/[программа] ~/backup/")
add_bullet("Windows: копировать папку %APPDATA%\\[программа] в резервную папку")
add_numbered(3, "Переустановить программу (см. раздел 3.2).")
add_numbered(4, "Восстановить данные из резервной копии.")
add_empty()

add_heading("5.3 Действия при несанкционированном доступе", 2)
add_para("При обнаружении признаков несанкционированного доступа:")
add_numbered(1, "Немедленно завершить работу программы.")
add_numbered(2, "Сменить пароль учётной записи.")
add_numbered(3, "Проверить журнал доступа (логи).")
add_numbered(4, "Сообщить администратору системы.")
add_empty()

add_heading("5.4 Действия в других аварийных ситуациях", 2)
add_para("При зависании программы:")
add_para("Linux:")
add_code("    # Найти PID процесса\n    ps aux | grep [программа]\n    # Принудительно завершить\n    kill -9 [PID]")
add_para("Windows:")
add_code("    :: Завершить через диспетчер задач\n    taskkill /f /im [процесс].exe")
add_empty()

# ---- Section 6: Recommendations ----
add_heading("6. Рекомендации по освоению")
add_empty()

add_heading("6.1 Контрольный пример", 2)
add_para("Для освоения работы со средством автоматизации рекомендуется выполнить следующий контрольный пример.")
add_para("Цель: проверить основные функции программы.")
add_para("Исходные данные:")
add_bullet("________________________________________")
add_bullet("________________________________________")
add_empty()

add_heading("6.2 Порядок выполнения контрольного примера", 2)
add_numbered(1, "Установить программу (см. раздел 3.2).")
add_numbered(2, "Запустить программу (см. раздел 3.3).")
add_numbered(3, "Выполнить операцию 4.2 с параметрами: ___________________")
add_numbered(4, "Проверить, что получен ожидаемый результат: ______________")
add_numbered(5, "Выполнить операцию 4.3 с параметрами: ___________________")
add_numbered(6, "Проверить, что получен ожидаемый результат: ______________")
add_numbered(7, "Сохранить результаты работы.")
add_empty()

add_bold_line("Признаки успешного выполнения:")
add_bullet("программа работает без ошибок")
add_bullet("все операции завершаются корректно")
add_bullet("результаты операций соответствуют ожидаемым")
add_empty()
add_empty()

# ---- Revision table ----
add_heading("Лист регистрации изменений", 1)
add_empty()

tbl = table.Table()
tbl.addElement(table.TableColumn())
tbl.addElement(table.TableColumn())
tbl.addElement(table.TableColumn())
tbl.addElement(table.TableColumn())

# Header row
hdr1 = table.TableRow()
for cell_text in ["Версия", "Дата", "Изменение", "Исполнитель"]:
    cell = table.TableCell()
    p = text.P()
    p.addText(cell_text)
    cell.addElement(p)
    hdr1.addElement(cell)
tbl.addElement(hdr1)

# Data row
row1 = table.TableRow()
for cell_text in ["1.0", "[дата]", "Первоначальная версия", "[ФИО]"]:
    cell = table.TableCell()
    p = text.P()
    p.addText(cell_text)
    cell.addElement(p)
    row1.addElement(cell)
tbl.addElement(row1)

doc.text.addElement(tbl)

# ---- Save ----
doc.save(OUTPUT_FILE)
print("[OK] Shablon sozdan:", OUTPUT_FILE)
print("  Put:", os.path.abspath(OUTPUT_FILE))
print("  Razmer:", os.path.getsize(OUTPUT_FILE), "bayt")
print()
print("  Otkryt v LibreOffice:")
print(f"  libreoffice '{OUTPUT_FILE}'")
