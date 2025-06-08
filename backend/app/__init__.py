# En tu archivo app/__init__.py o similar
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def create_app():
    app = Flask(__name__)
    app.config.from_object("config")  # asegúrate de tener la DB URL aquí
    db.init_app(app)

    with app.app_context():
        db.create_all()  # ⚠️ Crea todas las tablas declaradas con SQLAlchemy

    return app
