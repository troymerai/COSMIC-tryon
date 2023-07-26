from datetime import datetime, timedelta
from dotenv import load_dotenv
import os

from common import db

load_dotenv()

def get_current_seoul_time():
    return datetime.utcnow() + timedelta(hours=9)

class User(db.Model):
    __table_args__ = {'schema': os.getenv('SCHEMA_NAME')}
    __tablename__ = os.getenv('USER_TABLE_NAME')

    user_id = db.Column(db.String(255), unique=True, nullable=False, primary_key=True)
    user_pw = db.Column(db.String(255), nullable=False)
    created_at = db.Column(
        db.TIMESTAMP(timezone=True),
        default=get_current_seoul_time,
        nullable=False
    )
