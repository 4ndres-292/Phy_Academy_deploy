FROM python:3.10-slim

# Crear usuario no root
RUN useradd -ms /bin/bash sandboxuser

# Establecer directorio de trabajo
WORKDIR /home/sandboxuser

# Copiar el archivo main.py desde la carpeta correcta
COPY ./container/main.py ./main.py

# Dar permisos de ejecución
RUN chmod +x main.py

# Instalar Flask versión 3.1.0
RUN pip install flask==3.1.0

# Cambiar al usuario seguro
USER sandboxuser

# Comando que inicia el servidor Flask
CMD [ "python", "main.py" ]
