from PyQt5.QtWidgets import *
from db import get_connection
from datetime import date


class LoanWindow(QWidget):
    def __init__(self, parent=None):
        super().__init__()
        self.parent = parent  
        self.setWindowTitle("Выдача книг")

        layout = QVBoxLayout()


        layout.addWidget(QLabel("Взять книгу"))

        self.reader_combo = QComboBox()
        self.book_combo = QComboBox()

        take_btn = QPushButton("Выдать книгу")
        take_btn.clicked.connect(self.take_book)

        layout.addWidget(QLabel("Читатель"))
        layout.addWidget(self.reader_combo)

        layout.addWidget(QLabel("Книга"))
        layout.addWidget(self.book_combo)

        layout.addWidget(take_btn)

  
        layout.addWidget(QLabel("Вернуть книгу"))

        self.loan_combo = QComboBox()

        return_btn = QPushButton("Вернуть книгу")
        return_btn.clicked.connect(self.return_book)

        layout.addWidget(self.loan_combo)
        layout.addWidget(return_btn)

        self.setLayout(layout)

        self.load_data()


    def load_data(self):
        conn = get_connection()
        cur = conn.cursor()


        cur.execute("SELECT reader_id, full_name FROM readers ORDER BY full_name")
        readers = cur.fetchall()

        self.reader_combo.clear()
        for r in readers:
            self.reader_combo.addItem(r[1], r[0])


        cur.execute("SELECT book_id, title FROM books ORDER BY title")
        books = cur.fetchall()

        self.book_combo.clear()
        for b in books:
            self.book_combo.addItem(b[1], b[0])


        cur.execute("""
            SELECT l.loan_id, r.full_name || ' - ' || b.title
            FROM loans l
            JOIN readers r ON l.reader_id = r.reader_id
            JOIN books b ON l.book_id = b.book_id
            WHERE l.return_date IS NULL
        """)
        loans = cur.fetchall()

        self.loan_combo.clear()
        for l in loans:
            self.loan_combo.addItem(l[1], l[0])

        conn.close()


    def take_book(self):
        reader_id = self.reader_combo.currentData()
        book_id = self.book_combo.currentData()

        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
            INSERT INTO loans (reader_id, book_id, loan_date)
            VALUES (%s, %s, %s)
        """, (reader_id, book_id, date.today()))

        conn.commit()
        conn.close()

        QMessageBox.information(self, "Успех", "Книга выдана")

        self.load_data()


        if self.parent:
            self.parent.load_data()


    def return_book(self):
        loan_id = self.loan_combo.currentData()

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

        self.load_data()

     
        if self.parent:
            self.parent.load_data()