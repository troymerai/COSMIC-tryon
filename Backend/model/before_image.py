from dotenv import load_dotenv
import os

from common import db, get_current_seoul_time

load_dotenv()


class BeforeImage(db.Model):
    __table_args__ = {'schema': os.getenv('SCHEMA_NAME')}
    __tablename__ = os.getenv('BEFORE_TABLE_NAME')

    id = db.Column(db.Integer, primary_key=True, autoincrement=True, nullable=False)
    user_id = db.Column(db.String(255), nullable=False)
    body_img_data = db.Column(db.LargeBinary, nullable=False)
    clothes_img_data = db.Column(db.LargeBinary, nullable=False)
    created_at = db.Column(
        db.TIMESTAMP(timezone=True),
        default=get_current_seoul_time,
        nullable=False
    )
