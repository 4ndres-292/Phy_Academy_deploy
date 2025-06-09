from flask import Flask
from backend.app.core.database import iniciar_base_datos
from backend.app.core.extensions import db
from flask_migrate import upgrade
import os

print("🔍 DATABASE_URL (en migrate.py):", os.getenv("DATABASE_URL"))

app = Flask(__name__)
iniciar_base_datos(app)

with app.app_context():
    upgrade()
    print("✅ Migraciones aplicadas correctamente")
