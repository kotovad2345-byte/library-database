from PyQt5.QtWidgets import *
from db import get_connection
from datetime import date


class RelationWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Читатели и книги")

        main_layout = QHBoxLayout()


        self.readers = QListWidget()
        self.readers.itemClicked.connect(self.load_books)

        right_layout = QVBoxLayout()


        self.books = QTableWidget()

        self.books.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.books.horizontalHeader().setStretchLastSection(True)
        self.books.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)


        self.book_combo = QComboBox()


        self.add_reader_btn = QPushButton("Добавить читателя")
        self.add_reader_btn.clicked.connect(self.add_reader)


        self.take_btn = QPushButton("Выдать книгу")
        self.return_btn = QPushButton("Вернуть книгу")

        self.take_btn.clicked.connect(self.take_book)
        self.return_btn.clicked.connect(self.return_book)

        right_layout.addWidget(QLabel("Книги читателя"))
        right_layout.addWidget(self.books)

        right_layout.addWidget(self.add_reader_btn)  

        right_layout.addWidget(QLabel("Выбрать книгу"))
        right_layout.addWidget(self.book_combo)

        right_layout.addWidget(self.take_btn)
        right_layout.addWidget(self.return_btn)

        main_layout.addWidget(self.readers)
        main_layout.addLayout(right_layout)

        main_layout.setStretch(0, 1)
        main_layout.setStretch(1, 2)

        self.setLayout(main_layout)

        self.load_readers()
        self.load_books_list()


    def add_reader(self):
        from ui.add_dialog import AddDialog

        dialog = AddDialog("readers")

        if dialog.exec_():
            self.load_readers()

    def load_readers(self):
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT reader_id, full_name FROM readers")

        self.readers.clear()
        for r in cur.fetchall():
            self.readers.addItem(f"{r[0]} - {r[1]}")

        conn.close()

    def load_books_list(self):
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT book_id, title FROM books ORDER BY title")

        self.book_combo.clear()
        for b in cur.fetchall():
            self.book_combo.addItem(b[1], b[0])

        conn.close()

    def load_books(self, item):
        reader_id = item.text().split(" - ")[0]

        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
        SELECT l.loan_id, b.title, l.loan_date, l.return_date
        FROM loans l
        JOIN books b ON l.book_id=b.book_id
        WHERE l.reader_id=%s
        ORDER BY l.loan_id
        """, (reader_id,))

        rows = cur.fetchall()

        self.books.setRowCount(len(rows))
        self.books.setColumnCount(4)
        self.books.setHorizontalHeaderLabels(["ID","Книга","Дата","Возврат"])

        for i, row in enumerate(rows):
            for j, val in enumerate(row):
                if val is None:
                    val = "Не возвращена"
                self.books.setItem(i, j, QTableWidgetItem(str(val)))

        self.books.setColumnHidden(0, True)
        self.books.clearSelection()

        conn.close()

    def take_book(self):
        selected = self.readers.currentItem()
        if not selected:
            QMessageBox.warning(self, "Ошибка", "Выберите читателя")
            return

        reader_id = selected.text().split(" - ")[0]
        book_id = self.book_combo.currentData()

        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT quantity FROM books WHERE book_id=%s", (book_id,))
        quantity = cur.fetchone()[0]

        if quantity <= 0:
            QMessageBox.warning(self, "Ошибка", "Нет доступных экземпляров")
            conn.close()
            return

        cur.execute("""
            INSERT INTO loans (reader_id, book_id, loan_date)
            VALUES (%s,%s,%s)
        """, (reader_id, book_id, date.today()))

        conn.commit()
        conn.close()

        QMessageBox.information(self, "Успех", "Книга выдана")

        self.load_books(selected)
        self.load_books_list()

    def return_book(self):
        selected_items = self.books.selectedItems()

        if not selected_items:
            QMessageBox.warning(self, "Ошибка", "Выберите строку с книгой")
            return

        row = selected_items[0].row()
        loan_id = self.books.item(row, 0).text()

        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
            UPDATE loans
            SET return_date = %s
            WHERE loan_id = %s
        """, (date.today(), loan_id))

        conn.commit()
        conn.close()

        QMessageBox.information(self, "Успех", "Книга возвращена")

        selected = self.readers.currentItem()
        if selected:
            self.load_books(selected)
            self.load_books_list()