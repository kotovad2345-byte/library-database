from PyQt5.QtWidgets import *
from db import get_connection


class AddDialog(QDialog):
    def __init__(self, table):
        super().__init__()
        self.table = table
        self.setWindowTitle("Добавить запись")

        layout = QVBoxLayout()
        self.inputs = {}

        labels = {
            "author": "Автор",
            "title": "Название",
            "publisher": "Издательство",
            "publish_year": "Год издания",
            "library_id": "Библиотека",
            "genre_id": "Жанр",
            "quantity": "Количество",
            "full_name": "ФИО",
            "address": "Адрес",
            "phone": "Телефон",
            "name": "Название",
            "genre_name": "Жанр",

            "reader_id": "Читатель",
            "book_id": "Книга",
            "loan_date": "Дата выдачи"
        }

        fields = {
            "books": [
                "author",
                "title",
                "publisher",
                "publish_year",
                "library_id",
                "genre_id",
                "quantity"
            ],
            "readers": [
                "full_name",
                "address",
                "phone"
            ],



            "libraries": ["name", "address", "phone"],

            "genres": ["genre_name"],
            "loans": ["reader_id", "book_id", "loan_date"]
        }

        for field in fields.get(table, []):
            layout.addWidget(QLabel(labels.get(field, field)))

            if field == "library_id":
                combo = QComboBox()
                self.load_libraries(combo)
                layout.addWidget(combo)
                self.inputs[field] = combo

            elif field == "genre_id":
                combo = QComboBox()
                self.load_genres(combo)
                layout.addWidget(combo)
                self.inputs[field] = combo

            elif field == "reader_id":
                combo = QComboBox()
                self.load_readers(combo)
                layout.addWidget(combo)
                self.inputs[field] = combo

            elif field == "book_id":
                combo = QComboBox()
                self.load_books(combo)
                layout.addWidget(combo)
                self.inputs[field] = combo

            else:
                inp = QLineEdit()
                layout.addWidget(inp)
                self.inputs[field] = inp

        btn = QPushButton("Сохранить")
        btn.clicked.connect(self.save)

        layout.addWidget(btn)
        self.setLayout(layout)

    def load_libraries(self, combo):
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT library_id, name FROM libraries ORDER BY name")

        for row in cur.fetchall():
            combo.addItem(row[1], row[0])

        conn.close()

    def load_genres(self, combo):
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT genre_id, genre_name FROM genres ORDER BY genre_name")

        for row in cur.fetchall():
            combo.addItem(row[1], row[0])

        conn.close()

    def load_readers(self, combo):
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT reader_id, full_name FROM readers")

        for r in cur.fetchall():
            combo.addItem(r[1], r[0])

        conn.close()

    def load_books(self, combo):
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT book_id, title FROM books")

        for b in cur.fetchall():
            combo.addItem(b[1], b[0])

        conn.close()

    def save(self):
        conn = get_connection()
        cur = conn.cursor()

        data = {}

        for k, widget in self.inputs.items():
            if isinstance(widget, QComboBox):
                data[k] = widget.currentData()
            else:
                data[k] = widget.text()

        if self.table == "books":
            try:
                year = int(data["publish_year"])
                if year < 1500 or year > 2100:
                    raise ValueError
            except:
                QMessageBox.warning(self, "Ошибка", "Введите корректный год")
                return


        if self.table == "libraries":
            if not data["name"]:
                QMessageBox.warning(self, "Ошибка", "Введите название")
                return

        if self.table == "books":
            cur.execute("""
                INSERT INTO books 
                (author, title, publisher, publish_year, library_id, genre_id, quantity)
                VALUES (%s,%s,%s,%s,%s,%s,%s)
            """, (
                data["author"],
                data["title"],
                data["publisher"],
                int(data["publish_year"]),
                data["library_id"],
                data["genre_id"],
                data["quantity"]
            ))

        elif self.table == "readers":
            cur.execute("""
                INSERT INTO readers (full_name, address, phone, registration_date)
                VALUES (%s,%s,%s,CURRENT_DATE)
            """, (
                data["full_name"],
                data["address"],
                data["phone"]
            ))


        elif self.table == "libraries":
            cur.execute(
                "INSERT INTO libraries (name, address, phone) VALUES (%s,%s,%s)",
                (data["name"], data["address"], data["phone"])
            )

        elif self.table == "genres":
            cur.execute(
                "INSERT INTO genres (genre_name) VALUES (%s)",
                (data["genre_name"],)
            )

        elif self.table == "loans":
            cur.execute("""
                INSERT INTO loans (reader_id, book_id, loan_date)
                VALUES (%s,%s,%s)
            """, (
                data["reader_id"],
                data["book_id"],
                data["loan_date"]
            ))

        conn.commit()
        conn.close()

        QMessageBox.information(self, "Успех", "Запись добавлена")
        self.accept()