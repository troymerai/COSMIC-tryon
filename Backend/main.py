from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)

db_uri = os.getenv('SQLALCHEMY_DATABASE_URI')
app.config['SQLALCHEMY_DATABASE_URI'] = db_uri

db = SQLAlchemy(app)


class User(db.Model):
    table_name = os.getenv('USER_TABLE_NAME')

    __tablename__ = table_name
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.String(255), unique=True, nullable=False) # varchar?
    user_pw = db.Column(db.String(255), nullable=False)


@app.route('/signup', methods=['POST'])
def sign_up():
    data = request.get_json()
    user_id = data.get('user_id')
    user_pw = data.get('user_pw')

    existing_user = User.query.filter_by(user_id=user_id).first()
    if existing_user:
        return jsonify(message='User id already exists'), 400

    new_user = User(user_id=user_id, user_pw=user_pw)
    db.session.add(new_user)
    db.session.commit()

    return jsonify(message='User created successfully'), 201


@app.route('/signin', methods=['POST'])
def sign_in():
    data = request.get_json()
    user_id = data.get('user_id')
    user_pw = data.get('user_pw') # string 타입으로 DB 테이블에 저장되어 있음.

    user = User.query.filter_by(user_id=user_id).first()
    if not user:
        return jsonify(message='User not found'), 404

    if user.user_pw != user_pw:
        return jsonify(message='Incorrect password'), 401

    return jsonify(message='Sign in successful'), 200


if __name__ == '__main__':
    app.run(debug=True)
