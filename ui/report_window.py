from PyQt5.QtWidgets import *
from db import get_connection


class ReportWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Отчёты")
        self.resize(450, 550)

        main_layout = QVBoxLayout()

        self.combo = QComboBox()
        self.combo.addItems([
            "Популярные книги",
            "Текущие выдачи",
            "Книги по библиотекам",
            "Выданные книги"
        ])

        self.field_combo = QComboBox()
        self.value_list = QListWidget()
        self.value_list.setSelectionMode(QAbstractItemView.MultiSelection)

        self.sort_combo = QComboBox()

        self.sort_order = QComboBox()
        self.sort_order.addItems(["По возрастанию", "По убыванию"])


        form = QFormLayout()
        form.addRow("Отчёт:", self.combo)
        form.addRow("Фильтр по:", self.field_combo)
        form.addRow("Значения:", self.value_list)
        form.addRow("Сортировка:", self.sort_combo)
        form.addRow("Порядок:", self.sort_order)

        self.table = QTableWidget()

        self.table.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.table.horizontalHeader().setStretchLastSection(True)
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)

        btn = QPushButton("Сформировать")
        btn.clicked.connect(self.load_report)

        main_layout.addLayout(form)
        main_layout.addWidget(self.table)
        main_layout.addWidget(btn)

        self.setLayout(main_layout)


        self.combo.currentIndexChanged.connect(self.update_ui)
        self.field_combo.currentIndexChanged.connect(self.on_field_changed)

        self.update_ui()

    def update_ui(self):
        report = self.combo.currentText()

        self.field_combo.clear()
        self.sort_combo.clear()

        if report == "Популярные книги":
            self.field_combo.addItems(["Название книги"])
            self.sort_combo.addItems(["По названию", "По количеству"])

        elif report == "Текущие выдачи":
            self.field_combo.addItems(["Имя читателя"])
            self.sort_combo.addItems(["По имени", "По количеству"])

        elif report == "Книги по библиотекам":
            self.field_combo.addItems(["Название библиотеки"])
            self.sort_combo.addItems(["По названию", "По количеству"])

        elif report == "Выданные книги":
            self.field_combo.addItems(["Имя читателя", "Название книги"])
            self.update_sort_for_loans()

        self.load_filter_values()
        self.table.clear()
        self.table.setRowCount(0)
        self.table.setColumnCount(0)

    def update_sort_for_loans(self):
        field = self.field_combo.currentText()

        self.sort_combo.clear()

        if field == "Имя читателя":
            self.sort_combo.addItems(["По дате выдачи"])

        elif field == "Название книги":
            self.sort_combo.addItems(["По дате выдачи", "По читателю"])

        else:
            self.sort_combo.addItems(["По дате выдачи"])

    def on_field_changed(self):
        report = self.combo.currentText()

        if report == "Выданные книги":
            self.update_sort_for_loans()

        self.load_filter_values()

    def load_filter_values(self):
        conn = get_connection()
        cur = conn.cursor()

        report = self.combo.currentText()

        if report == "Популярные книги":
            cur.execute("SELECT DISTINCT title FROM books ORDER BY title")

        elif report == "Текущие выдачи":
            cur.execute("SELECT DISTINCT full_name FROM readers ORDER BY full_name")

        elif report == "Книги по библиотекам":
            cur.execute("SELECT DISTINCT name FROM libraries ORDER BY name")

        elif report == "Выданные книги":
            field = self.field_combo.currentText()

            if field == "Имя читателя":
                cur.execute("SELECT DISTINCT full_name FROM readers ORDER BY full_name")
            else:
                cur.execute("SELECT DISTINCT title FROM books ORDER BY title")

        values = [str(v[0]) for v in cur.fetchall()]

        self.value_list.clear()
        for v in values:
            item = QListWidgetItem(v)
            self.value_list.addItem(item)

        conn.close()

    def load_report(self):
        conn = get_connection()
        cur = conn.cursor()

        report = self.combo.currentText()
        selected_items = self.value_list.selectedItems()
        selected_values = [item.text() for item in selected_items]

        sort_ui = self.sort_combo.currentText()
        field_ui = self.field_combo.currentText()

        sort_order_ui = self.sort_order.currentText()

        if sort_order_ui == "По возрастанию":
            sort_order = "ASC"
        else:
            sort_order = "DESC"

        if report == "Популярные книги":
            base_query = """
                SELECT b.title, COUNT(l.loan_id) AS total
                FROM books b
                LEFT JOIN loans l ON b.book_id = l.book_id
                GROUP BY b.title
            """
            headers = ["Название книги", "Количество"]
            field_map = {"Название книги": "title"}
            sort_map = {
                "По названию": "title",
                "По количеству": "total"
            }

        elif report == "Текущие выдачи":
            base_query = """
                SELECT r.full_name, COUNT(l.loan_id) AS total
                FROM readers r
                JOIN loans l ON r.reader_id = l.reader_id
                WHERE l.return_date IS NULL
                GROUP BY r.full_name
            """
            headers = ["Читатель", "Количество"]
            field_map = {"Имя читателя": "full_name"}
            sort_map = {
                "По имени": "full_name",
                "По количеству": "total"
            }

        elif report == "Книги по библиотекам":
            base_query = """
                SELECT lib.name, SUM(b.quantity) AS total_books
                FROM libraries lib
                JOIN books b ON lib.library_id = b.library_id
                GROUP BY lib.name
            """
            headers = ["Библиотека", "Остаток книг"]
            field_map = {"Название библиотеки": "name"}
            sort_map = {
                "По названию": "name",
                "По количеству": "total_books"
            }

        elif report == "Выданные книги":
            base_query = """
                SELECT r.full_name, b.title, l.loan_date, l.return_date
                FROM loans l
                JOIN readers r ON l.reader_id = r.reader_id
                JOIN books b ON l.book_id = b.book_id
            """
            headers = ["Читатель", "Книга", "Дата выдачи", "Дата возврата"]

            field_map = {
                "Имя читателя": "full_name",
                "Название книги": "title"
            }

            sort_map = {
                "По дате выдачи": "loan_date",
                "По читателю": "full_name"
            }

        field = field_map[field_ui]
        sort = sort_map[sort_ui]

        order = f"ORDER BY {sort} {sort_order}"

        conditions = []
        params = []

        if selected_values:
            placeholders = ", ".join(["%s"] * len(selected_values))
            conditions.append(f"{field} IN ({placeholders})")
            params.extend(selected_values)

        if conditions:
            where = "WHERE " + " AND ".join(conditions)
            query = f"""
                SELECT * FROM ({base_query}) AS sub
                {where}
                {order}
            """
            cur.execute(query, params)
        else:
            query = base_query + f" {order}"
            cur.execute(query)

        rows = cur.fetchall()

        self.table.setRowCount(len(rows))
        self.table.setColumnCount(len(headers))
        self.table.setHorizontalHeaderLabels(headers)

        for i, row in enumerate(rows):
            for j, val in enumerate(row):
                if val is None:
                    val = "Не возвращена"
                self.table.setItem(i, j, QTableWidgetItem(str(val)))

        if report != "Выданные книги" and rows:
            total_sum = sum(row[1] for row in rows)
            QMessageBox.information(self, "Итог", f"Общий итог: {total_sum}")

        conn.close()