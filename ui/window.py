from PyQt5.QtWidgets import *
from db import get_connection


class Window(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Библиотека")

        layout = QVBoxLayout()

        self.combo = QComboBox()
        self.combo.addItems(["books", "readers", "loans", "libraries", "genres", "librarians"])

        self.filter_field = QComboBox()
        self.search_field = QComboBox()

        self.filter_op = QComboBox()
        self.filter_op.addItems(["=", ">", "<", ">=", "<=", "LIKE"])

        self.filter_value = QLineEdit()
        self.filter_value.setPlaceholderText("Фильтр...")

        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Поиск...")

        self.sort_combo = QComboBox()

        self.sort_order = QComboBox()
        self.sort_order.addItems(["По возрастанию", "По убыванию"])

        self.add_btn = QPushButton("Добавить")
        self.edit_btn = QPushButton("Изменить")
        self.delete_btn = QPushButton("Удалить")

        self.rel_btn = QPushButton("Читатели и книги")
        self.rep_btn = QPushButton("Отчёты")

        self.table = QTableWidget()
        self.table.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.table.horizontalHeader().setStretchLastSection(True)
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)

        self.combo.currentIndexChanged.connect(self.load_data)
        self.search_input.textChanged.connect(self.load_data)
        self.sort_combo.currentIndexChanged.connect(self.sort_data)


        self.sort_order.currentIndexChanged.connect(self.sort_data)

        self.filter_value.textChanged.connect(self.load_data)
        self.filter_op.currentIndexChanged.connect(self.load_data)

        self.delete_btn.clicked.connect(self.delete_record)
        self.add_btn.clicked.connect(self.add_record)
        self.edit_btn.clicked.connect(self.edit_record)

        self.rel_btn.clicked.connect(self.open_relation)
        self.rep_btn.clicked.connect(self.open_reports)

  
        table_group = QGroupBox("Таблица")
        table_layout = QFormLayout()
        table_layout.addRow("Таблица:", self.combo)
        table_group.setLayout(table_layout)


        filter_group = QGroupBox("Фильтр")
        filter_layout = QFormLayout()
        filter_layout.addRow("Поле:", self.filter_field)
        filter_layout.addRow("Условие:", self.filter_op)
        filter_layout.addRow("Значение:", self.filter_value)
        filter_group.setLayout(filter_layout)


        search_group = QGroupBox("Поиск")
        search_layout = QFormLayout()
        search_layout.addRow("Поле:", self.search_field)
        search_layout.addRow("Значение:", self.search_input)
        search_group.setLayout(search_layout)


        sort_group = QGroupBox("Сортировка")
        sort_layout = QFormLayout()
        sort_layout.addRow("Поле:", self.sort_combo)


        sort_layout.addRow("Порядок:", self.sort_order)

        sort_group.setLayout(sort_layout)


        layout.addWidget(table_group)
        layout.addWidget(filter_group)
        layout.addWidget(search_group)
        layout.addWidget(sort_group)

        layout.addWidget(self.table, 1)

        crud = QHBoxLayout()
        crud.addWidget(self.add_btn)
        crud.addWidget(self.edit_btn)
        crud.addWidget(self.delete_btn)
        layout.addLayout(crud)

        layout.addWidget(self.rel_btn)
        layout.addWidget(self.rep_btn)

        self.setLayout(layout)

        self.load_data()

    def load_data(self):
        table = self.combo.currentText()

        text = self.search_input.text()
        filter_val = self.filter_value.text()
        filter_op = self.filter_op.currentText()

        conn = get_connection()
        cur = conn.cursor()

        cols = self.get_columns(table)

        current_filter = self.filter_field.currentText()
        current_search = self.search_field.currentText()
        current_sort = self.sort_combo.currentText()

        self.filter_field.blockSignals(True)
        self.search_field.blockSignals(True)
        self.sort_combo.blockSignals(True)

        self.filter_field.clear()
        self.search_field.clear()
        self.sort_combo.clear()

        self.filter_field.addItems(cols)
        self.search_field.addItems(cols)
        self.sort_combo.addItems(cols)

        if current_filter in cols:
            self.filter_field.setCurrentText(current_filter)

        if current_search in cols:
            self.search_field.setCurrentText(current_search)

        if current_sort in cols:
            self.sort_combo.setCurrentText(current_sort)

        self.filter_field.blockSignals(False)
        self.search_field.blockSignals(False)
        self.sort_combo.blockSignals(False)

        query = f"SELECT * FROM {table}"
        params = []
        conditions = []

        if filter_val:
            field = self.filter_field.currentText()

            if filter_op == "LIKE":
                conditions.append(f"{field}::TEXT ILIKE %s")
                params.append(f"%{filter_val}%")
            else:
                conditions.append(f"{field} {filter_op} %s")
                params.append(filter_val)

        if text:
            field = self.search_field.currentText()
            conditions.append(f"{field}::TEXT ILIKE %s")
            params.append(f"%{text}%")

        if conditions:
            query += " WHERE " + " AND ".join(conditions)

        cur.execute(query, params)

        rows = cur.fetchall()

        self.fill_table(rows, cur)
        conn.close()

    def sort_data(self):
        table = self.combo.currentText()
        col = self.sort_combo.currentText()

        if not col:
            return

        conn = get_connection()
        cur = conn.cursor()

        order_ui = self.sort_order.currentText()
        if order_ui == "По возрастанию":
            order = "ASC"
        else:
            order = "DESC"

        query = f"SELECT * FROM {table} ORDER BY {col} {order}"
        cur.execute(query)

        rows = cur.fetchall()

        self.fill_table(rows, cur)
        conn.close()

    def delete_record(self):
        row = self.table.currentRow()
        if row == -1:
            QMessageBox.warning(self, "Ошибка", "Выберите строку")
            return

        table = self.combo.currentText()
        record_id = self.table.item(row, 0).text()

        conn = get_connection()
        cur = conn.cursor()

        id_map = {
            "books": "book_id",
            "readers": "reader_id",
            "loans": "loan_id",
            "libraries": "library_id",
            "genres": "genre_id",
            "librarians": "librarian_id"
    }

        try:
            if table == "books":
                cur.execute("DELETE FROM loans WHERE book_id=%s", (record_id,))
            elif table == "readers":
                cur.execute("DELETE FROM loans WHERE reader_id=%s", (record_id,))

            cur.execute(
                f"DELETE FROM {table} WHERE {id_map[table]}=%s",
                (record_id,)
            )

            conn.commit()
            QMessageBox.information(self, "Успех", "Запись удалена")

        except Exception as e:
            QMessageBox.critical(self, "Ошибка", str(e))

        finally:
            conn.close()

        self.load_data()

    def add_record(self):
        from ui.add_dialog import AddDialog

        table = self.combo.currentText()
        dialog = AddDialog(table)

        if dialog.exec_():
            self.load_data()

    def edit_record(self):
        row = self.table.currentRow()
        col = self.table.currentColumn()

        if row == -1 or col == -1:
            QMessageBox.warning(self, "Ошибка", "Выберите ячейку")
            return

        table = self.combo.currentText()

        column_name = self.table.horizontalHeaderItem(col).text()
        record_id = self.table.item(row, 0).text()
        current_value = self.table.item(row, col).text()

        if col == 0:
            QMessageBox.warning(self, "Ошибка", "Нельзя изменять ID")
            return

        new_val, ok = QInputDialog.getText(
            self,
            "Изменить",
            f"{column_name}:",
            text=current_value
        )

        if not ok or new_val == current_value:
            return

        conn = get_connection()
        cur = conn.cursor()

        id_map = {
            "books": "book_id",
            "readers": "reader_id",
            "loans": "loan_id",
            "libraries": "library_id",
            "genres": "genre_id"
        }

        try:
            cur.execute(
                f"UPDATE {table} SET {column_name}=%s WHERE {id_map[table]}=%s",
                (new_val, record_id)
            )
            conn.commit()
            QMessageBox.information(self, "Успех", "Запись обновлена")

        except Exception as e:
            QMessageBox.critical(self, "Ошибка", str(e))

        finally:
            conn.close()

        self.load_data()

    def fill_table(self, rows, cur):
        self.table.setRowCount(len(rows))
        self.table.setColumnCount(len(rows[0]) if rows else 0)

        colnames = [desc[0] for desc in cur.description]
        self.table.setHorizontalHeaderLabels(colnames)

        for i, row in enumerate(rows):
            for j, val in enumerate(row):
                self.table.setItem(i, j, QTableWidgetItem(str(val)))

    def get_columns(self, table):
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = %s
        """, (table,))

        cols = [c[0] for c in cur.fetchall()]
        conn.close()
        return cols

    def open_relation(self):
        from ui.relation_window import RelationWindow
        self.rel = RelationWindow()
        self.rel.show()
        self.rel.destroyed.connect(self.load_data)

    def open_reports(self):
        from ui.report_window import ReportWindow
        self.rep = ReportWindow()
        self.rep.show()