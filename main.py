import sys
from PyQt5.QtWidgets import QApplication
from ui.window import Window

app = QApplication(sys.argv)

window = Window()
window.show()

sys.exit(app.exec_())