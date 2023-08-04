from dotenv import load_dotenv
from sqlalchemy import Boolean
import os

from common import db, get_current_seoul_time

load_dotenv()


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
    is_making = db.Column(Boolean, default=False, nullable=False)
