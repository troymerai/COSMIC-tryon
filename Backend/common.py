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
    return datetime.utcnow() + timedelta(hours=9)


def get_image_format(image_data):
    """
    바이너리 이미지 데이터의 형식이 PNG/JPEG/ELSE인지 반환하는 함수
    """

    if image_data.startswith(b'\x89PNG'):
        return 'png'
    elif image_data.startswith(b'\xFF\xD8'):
        return 'jpeg'
    else:
        return None  # 알 수 없는 형식
