from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv
from datetime import datetime, timedelta
import os

load_dotenv()

app = Flask(__name__)

db_uri = os.getenv('SQLALCHEMY_DATABASE_URI')
app.config['SQLALCHEMY_DATABASE_URI'] = db_uri

db = SQLAlchemy(app)

def get_current_seoul_time():
    """
    utc에 9를 더하여 서울 시간 반환하는 함수
    """
    return datetime.utcnow() + timedelta(hours=9)
