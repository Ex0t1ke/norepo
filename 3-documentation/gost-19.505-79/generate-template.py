#!/usr/bin/env python3
"""
Генератор шаблона «Руководство оператора» в формате .odt
по ГОСТ 19.505-79 «ЕСПД. Руководство оператора. Требования к содержанию и оформлению»

Структура документа (согласно п. 1.2 ГОСТ 19.505-79):
    1. Назначение программы
    2. Условия выполнения программы
    3. Выполнение программы
    4. Сообщения оператору
    + Приложения (п. 2.6)

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
# Parse arguments: python3 script.py [name] [output.odt]
# Also supports: python3 script.py [name] --output [output.odt]
APP_NAME = "[Название ПО]"
OUTPUT_FILE = "user-guide-template.odt"

if len(sys.argv) > 1:
    if sys.argv[1] != "--output":
        APP_NAME = sys.argv[1]

if "--output" in sys.argv:
    idx = sys.argv.index("--output")
    if idx + 1 < len(sys.argv):
        OUTPUT_FILE = sys.argv[idx + 1]
elif len(sys.argv) > 2 and sys.argv[1] != "--output":
    OUTPUT_FILE = sys.argv[2]

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

# ---- Sub-subsection (3.3.2, 3.3.3...) ----
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

add_title("РУКОВОДСТВО ОПЕРАТОРА")
add_empty()
add_empty()
add_empty()
add_empty()
add_empty()

# Title block - centered
p = text.P(stylename=title_style)
bold = text.Span(stylename="BoldSpan")
bold.addText(f"Программа: {APP_NAME}")
p.addElement(bold)
doc.text.addElement(p)

add_empty()

p = text.P(stylename="BodyText")
p.addText("Операционная система: Linux (Ubuntu 22.04+) / Windows 10+")
doc.text.addElement(p)

p = text.P(stylename="BodyText")
p.addText("Дата составления: _______________")
doc.text.addElement(p)

# Page break — multiple blank lines
for _ in range(3):
    add_empty()

# ============================================================
# Раздел 1. НАЗНАЧЕНИЕ ПРОГРАММЫ (п. 2.1 ГОСТ 19.505-79)
# ============================================================
add_heading("1. Назначение программы")
add_empty()

add_heading("1.1 Назначение средства автоматизации", 2)
add_para("«" + APP_NAME + "» — это _______________________________________________________________________, предназначенный для __________________________________________________________________.")
add_para("Программа обеспечивает выполнение следующих основных функций:")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_empty()

add_heading("1.2 Краткое описание возможностей", 2)
add_para("Основные возможности программы:")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_bullet("______________________________________________________________________")
add_bullet("поддержка операционных систем Linux и Windows")
add_empty()

add_heading("1.3 Сведения, достаточные для понимания функций программы", 2)
add_para("Для понимания функций программы пользователь должен обладать базовыми навыками работы в операционной системе (терминал Linux / командная строка Windows), а также понимать основные принципы ________________________________________")
add_para("Программа работает в следующих режимах:")
add_bullet("интерактивный режим — пользователь взаимодействует через графический интерфейс или командную строку")
add_bullet("пакетный режим (при наличии) — автоматическое выполнение набора операций без участия оператора")
add_empty()

# ============================================================
# Раздел 2. УСЛОВИЯ ВЫПОЛНЕНИЯ ПРОГРАММЫ (п. 2.2 ГОСТ 19.505-79)
# ============================================================
add_heading("2. Условия выполнения программы")
add_empty()

add_heading("2.1 Требования к техническим средствам", 2)
add_para("Linux (Ubuntu 22.04+):")
add_bullet("Процессор: не ниже 2-ядерного, 2 ГГц")
add_bullet("ОЗУ: не менее 4 ГБ (рекомендуется 8 ГБ)")
add_bullet("Свободное место на диске: не менее 1 ГБ")
add_bullet("ОС: Ubuntu 22.04 LTS или выше")
add_bullet("Периферийные устройства: клавиатура, мышь, монитор 1024×768")
add_bullet("Зависимости: ________________________________________________")
add_empty()
add_para("Windows 10+:")
add_bullet("Процессор: не ниже 2-ядерного, 2 ГГц")
add_bullet("ОЗУ: не менее 4 ГБ (рекомендуется 8 ГБ)")
add_bullet("Свободное место на диске: не менее 1 ГБ")
add_bullet("ОС: Windows 10 Pro 64-bit или выше")
add_bullet("Периферийные устройства: клавиатура, мышь, монитор 1024×768")
add_bullet("Зависимости: ________________________________________________")
add_empty()

add_heading("2.2 Требования к программным средствам", 2)
add_para("Минимальный состав программного окружения:")
add_bullet("Операционная система согласно п. 2.1")
add_bullet("Среда выполнения: ___________________________________________")
add_bullet("Дополнительные компоненты:")
add_bullet("________________________________________")
add_bullet("________________________________________")
add_bullet("Наличие подключения к локальной сети / интернету (для функций, требующих сетевого доступа)")
add_empty()
add_para("Рекомендуемое программное обеспечение:")
add_bullet("________________________________________")
add_bullet("________________________________________")
add_empty()

add_heading("2.3 Требования к подготовке оператора", 2)
add_para("Пользователь (оператор) должен:")
add_bullet("иметь базовые навыки работы в операционной системе (Linux / Windows)")
add_bullet("понимать основные принципы ________________________________")
add_bullet("пройти инструктаж по работе с программой (ознакомиться с настоящим руководством)")
add_empty()

# ============================================================
# Раздел 3. ВЫПОЛНЕНИЕ ПРОГРАММЫ (п. 2.3 ГОСТ 19.505-79)
# ============================================================
add_heading("3. Выполнение программы")
add_empty()

add_heading("3.1 Загрузка программы", 2)
add_para("3.1.1 Установка в Linux (Ubuntu)")
add_code("    # Способ 1 — из репозитория\n    echo \"deb [репозиторий]\" | sudo tee /etc/apt/sources.list.d/[файл].list\n    wget -qO- [ключ] | sudo apt-key add -\n    sudo apt update\n    sudo apt install [пакет]\n\n    # Способ 2 — из .deb пакета\n    sudo dpkg -i [файл].deb\n    sudo apt --fix-broken install")
add_empty()
add_para("3.1.2 Установка в Windows")
add_numbered(1, "Скачать установочный файл с официального сайта.")
add_numbered(2, "Запустить [файл].exe / [файл].msi от имени администратора.")
add_numbered(3, "Следовать инструкциям мастера установки.")
add_empty()

add_para("3.1.3 Проверка загрузки (установки)")
add_para("Linux:")
add_code("    [команда] --version\n    [команда запуска]")
add_para("Windows:")
add_code("    [команда] --version\n    [команда запуска]")
add_para("Если программа запустилась и отображает основной интерфейс — установка выполнена успешно.")
add_empty()

add_heading("3.2 Запуск программы", 2)
add_para("Linux:")
add_bullet("Из терминала: [команда запуска]")
add_bullet("Из графического меню: «Приложения» → [категория] → «" + APP_NAME + "»")
add_empty()
add_para("Windows:")
add_bullet("Из командной строки: [команда запуска]")
add_bullet("Из меню «Пуск»: [категория] → «" + APP_NAME + "»")
add_empty()
add_para("При запуске программа отображает главное окно (интерфейс), готовое к выполнению операций.")
add_empty()

add_heading("3.3 Взаимодействие оператора с программой", 2)
add_empty()

add_heading("3.3.1 Описание команд и форматов", 3)
add_para("Управление программой осуществляется с помощью графического интерфейса (пункты меню, кнопки, поля ввода), а также командной строки (если применимо):")
add_empty()

# Add commands table template
cmd_tbl = table.Table()
cmd_tbl.addElement(table.TableColumn())
cmd_tbl.addElement(table.TableColumn())
cmd_tbl.addElement(table.TableColumn())

# Header
hdr = table.TableRow()
for cell_text in ["Команда / действие", "Назначение", "Формат"]:
    cell = table.TableCell()
    p = text.P()
    p.addText(cell_text)
    cell.addElement(p)
    hdr.addElement(cell)
cmd_tbl.addElement(hdr)

# Data rows
for row_data in [
    ["[команда 1]", "[назначение]", "[формат]"],
    ["[команда 2]", "[назначение]", "[формат]"],
    ["[команда 3]", "[назначение]", "[формат]"],
]:
    row = table.TableRow()
    for cell_text in row_data:
        cell = table.TableCell()
        p = text.P()
        p.addText(cell_text)
        cell.addElement(p)
        row.addElement(cell)
    cmd_tbl.addElement(row)

doc.text.addElement(cmd_tbl)
add_empty()

# Operation template for GOST 19.505-79
def add_operation(num, name):
    add_heading(f"3.3.{num} Операция: {name}", 3)
    add_empty()
    add_bold_line("Наименование:")
    add_para(name)
    add_empty()
    add_bold_line("Условия выполнения:")
    add_bullet("программа должна быть установлена и запущена (см. п. 3.1, 3.2)")
    add_bullet("________________________________________")
    add_empty()
    add_bold_line("Подготовительные действия:")
    add_numbered(1, "Запустить программу (см. п. 3.2).")
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
    add_bold_line("Ответ программы на команды:")
    add_bullet("при успешном выполнении: ________________________________")
    add_bullet("при ошибке: ______________________________________________")
    add_empty()

add_operation(2, "[Название операции 1]")
add_operation(3, "[Название операции 2]")

add_heading("3.3.4 [Дополнительные операции — при необходимости]", 3)
add_para("При необходимости в данный раздел добавляются другие операции, предусмотренные функциональностью программы.")
add_empty()

add_heading("3.4 Завершение программы", 2)
add_para("Нормальное завершение:")
add_para("Linux:")
add_bullet("Нажать кнопку «Закрыть» в главном окне программы")
add_bullet("или нажать Ctrl+Q (Ctrl+C в терминале)")
add_bullet("или выполнить: [команда] --exit")
add_empty()
add_para("Windows:")
add_bullet("Нажать кнопку «Закрыть» в правом верхнем углу окна")
add_bullet("или нажать Alt+F4")
add_bullet("или выполнить: [команда] --exit")
add_empty()

# ============================================================
# Раздел 4. СООБЩЕНИЯ ОПЕРАТОРУ (п. 2.4 ГОСТ 19.505-79)
# ============================================================
add_heading("4. Сообщения оператору")
add_empty()

add_heading("4.1 Информационные сообщения", 2)
add_para("В процессе выполнения программы оператору могут выдаваться следующие информационные сообщения:")
add_empty()

# Messages table
msg_tbl = table.Table()
msg_tbl.addElement(table.TableColumn())
msg_tbl.addElement(table.TableColumn())
msg_tbl.addElement(table.TableColumn())

hdr2 = table.TableRow()
for cell_text in ["Сообщение", "Описание содержания", "Действия оператора"]:
    cell = table.TableCell()
    p = text.P()
    p.addText(cell_text)
    cell.addElement(p)
    hdr2.addElement(cell)
msg_tbl.addElement(hdr2)

for row_data in [
    ["[текст сообщения 1]", "[описание]", "[действия]"],
    ["[текст сообщения 2]", "[описание]", "[действия]"],
    ["[текст сообщения 3]", "[описание]", "[действия]"],
]:
    row = table.TableRow()
    for cell_text in row_data:
        cell = table.TableCell()
        p = text.P()
        p.addText(cell_text)
        cell.addElement(p)
        row.addElement(cell)
    msg_tbl.addElement(row)

doc.text.addElement(msg_tbl)
add_empty()

add_heading("4.2 Сообщения об ошибках", 2)
add_para("При возникновении ошибок программа выдаёт следующие сообщения:")
add_empty()

err_tbl = table.Table()
err_tbl.addElement(table.TableColumn())
err_tbl.addElement(table.TableColumn())
err_tbl.addElement(table.TableColumn())

hdr3 = table.TableRow()
for cell_text in ["Сообщение", "Описание содержания", "Действия оператора"]:
    cell = table.TableCell()
    p = text.P()
    p.addText(cell_text)
    cell.addElement(p)
    hdr3.addElement(cell)
err_tbl.addElement(hdr3)

for row_data in [
    ["[текст ошибки 1]", "[описание]", "[действия]"],
    ["[текст ошибки 2]", "[описание]", "[действия]"],
    ["[текст ошибки 3]", "[описание]", "[действия]"],
]:
    row = table.TableRow()
    for cell_text in row_data:
        cell = table.TableCell()
        p = text.P()
        p.addText(cell_text)
        cell.addElement(p)
        row.addElement(cell)
    err_tbl.addElement(row)

doc.text.addElement(err_tbl)
add_empty()

add_heading("4.3 Действия оператора при сбоях", 2)
add_para("При возникновении сбоя в процессе выполнения программы необходимо:")
add_numbered(1, "Зафиксировать текст сообщения об ошибке.")
add_numbered(2, "Проверить сетевое подключение (если требуется).")
add_numbered(3, "Убедиться, что сервер (если требуется) доступен и работает.")
add_para("Проверка системных журналов:")
add_bullet("Linux: journalctl -xe или tail -f /var/log/syslog")
add_bullet("Windows: eventvwr.msc (Журнал событий)")
add_empty()

add_heading("4.4 Восстановление программы после сбоя", 2)
add_para("После устранения причины сбоя необходимо:")
add_numbered(1, "Закрыть программу (см. п. 3.4).")
add_numbered(2, "Проверить целостность данных:")
add_bullet("Linux: cp -r ~/.config/[программа] ~/backup/")
add_bullet("Windows: копировать папку %APPDATA%\\[программа] в резервную папку")
add_numbered(3, "Запустить программу повторно (см. п. 3.2).")
add_numbered(4, "Если программа не запускается — переустановить её (см. п. 3.1).")
add_numbered(5, "Восстановить данные из резервной копии.")
add_empty()

add_heading("4.5 Возможность повторного запуска программы", 2)
add_para("После устранения сбоя программа может быть запущена повторно в обычном режиме (см. п. 3.2). Если сбой был вызван ошибками в данных, необходимо восстановить данные из резервной копии перед запуском.")
add_empty()
add_para("При обнаружении признаков несанкционированного доступа:")
add_numbered(1, "Немедленно завершить работу программы.")
add_numbered(2, "Сменить пароль учётной записи.")
add_numbered(3, "Проверить журнал доступа (логи).")
add_numbered(4, "Сообщить администратору системы.")
add_empty()
add_empty()

# ============================================================
# ПРИЛОЖЕНИЕ А. Лист регистрации изменений
# ============================================================
add_heading("Приложение А. Лист регистрации изменений", 1)
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
add_empty()
add_empty()

# Приложение Б — необязательное (по п. 2.6 ГОСТ)
add_heading("Приложение Б. Дополнительные материалы", 1)
add_para("[При необходимости: дополнительные сведения, которые нецелесообразно включать в основные разделы руководства — схемы, графики, подробные примеры, справочные данные.]")
add_empty()
add_empty()
add_empty()

# ---- GOST info ----
p = text.P(stylename="BodyText")
p.addText("Документ составлен в соответствии с требованиями ГОСТ 19.505-79 «ЕСПД. Руководство оператора. Требования к содержанию и оформлению».")
doc.text.addElement(p)

# ---- Save ----
doc.save(OUTPUT_FILE)
print("[OK] Shablon sozdan:", OUTPUT_FILE)
print("  Put:", os.path.abspath(OUTPUT_FILE))
print("  Razmer:", os.path.getsize(OUTPUT_FILE), "bayt")
print()
print("  Otkryt v LibreOffice:")
print(f"  libreoffice '{OUTPUT_FILE}'")
