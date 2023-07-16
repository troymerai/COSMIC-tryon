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
    user_id = db.Column(db.String(255), unique=True, nullable=False)
    user_pw = db.Column(db.String(255), nullable=False)


@app.route('/signup', methods=['POST'])
def sign_up():
    data = request.get_json()
    user_id = data.get('user_id')
    user_pw = data.get('user_pw')

    existing_user = User.query.filter_by(user_id=user_id).first()
    if existing_user:
        return jsonify(message='이미 존재하는 아이디입니다.'), 400

    new_user = User(user_id=user_id, user_pw=user_pw)
    db.session.add(new_user)
    
    try:
        db.session.commit()
    except:
        db.session.rollback()
        return jsonify(message='에러가 발생했습니다. 다시 시도해주세요.'), 500

    return jsonify(message='회원가입이 완료되었습니다.'), 201


@app.route('/signin', methods=['POST'])
def sign_in():
    data = request.get_json()
    user_id = data.get('user_id')
    user_pw = data.get('user_pw') # string 타입으로 DB 테이블에 저장되어 있음.

    user = User.query.filter_by(user_id=user_id).first()
    if not user:
        return jsonify(message='아이디가 존재하지 않습니다.'), 404

    if user.user_pw != user_pw:
        return jsonify(message='비밀번호가 일치하지 않습니다.'), 401

    return jsonify(message='로그인 되었습니다.'), 200


if __name__ == '__main__':
    app.run(debug=True)
