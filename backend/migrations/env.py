import os
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context

# Importa app y db
from backend.app.main import app
from backend.app.core.extensions import db

config = context.config
fileConfig(config.config_file_name)

# Lee la URI desde variable de entorno
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise Exception("DATABASE_URL no está definida")

config.set_main_option("sqlalchemy.url", DATABASE_URL)

target_metadata = db.metadata

def run_migrations_offline():
    context.configure(
        url=DATABASE_URL, target_metadata=target_metadata,
        literal_binds=True, dialect_opts={"paramstyle": "named"}
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online():
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
