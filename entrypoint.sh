#!/bin/sh

# Ir al directorio del backend
#cd backend

# Establecer FLASK_APP (ajusta si tu estructura es diferente)
#export FLASK_APP=app.main:app
#export FLASK_ENV=production

# Ejecutar migraciones
echo "Ejecutando migraciones..."
flask db upgrade

# Ejecutar Gunicorn
echo "Iniciando Gunicorn..."
exec gunicorn --bind 0.0.0.0:${PORT} app.main:app
