import os
#from dotenv import load_dotenv
#from pathlib import Path

#env_path = Path(__file__).resolve().parent.parent.parent / '.env'
#load_dotenv(dotenv_path=env_path)

class Config:
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")
    SQLALCHEMY_TRACK_MODIFICATIONS = False