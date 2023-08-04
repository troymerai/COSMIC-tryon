from flask import request, jsonify, Response
from dotenv import load_dotenv
import jwt
import os

from common import app, db
from image_utils import get_image_format, merge_images
from model.user import User
from model.before_image import BeforeImage
from model.after_image import AfterImage

load_dotenv()


def generate_token(user_id):
    """
    API 보안을 위한 개인 token 생성하는 함수
    """
    payload = { 'user_id': user_id }

    secret_key = os.getenv('SECRET_KEY')
    token = jwt.encode(payload, secret_key, algorithm='HS256')
    
    return token


def verify_token(token):
    """
    개인 token이 유효 상태인지 검사하는 함수
    """
    secret_key = os.getenv('SECRET_KEY')

    try:
        payload = jwt.decode(token, secret_key, algorithms=['HS256'])
        return payload
    except jwt.InvalidTokenError:
        return None


@app.route('/signup', methods=['POST'])
def sign_up():
    """
    회원가입 API
    JSON 형식으로 user_id (str), user_pw(str) 넘기기
    """
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

    token = generate_token(user_id)

    return jsonify({"message": "회원가입이 완료되었습니다.", "token": token}), 201


@app.route('/signin', methods=['POST'])
def sign_in():
    """
    로그인 API
    JSON 형식으로 user_id (str), user_pw(str) 넘기기
    """
    token = request.headers.get('Authorization')
    payload = verify_token(token)
    if not payload:
        return jsonify(message='올바르지 않은 접근입니다. 관리자에게 문의하세요.'), 401

    data = request.get_json()
    user_id = data.get('user_id')
    user_pw = data.get('user_pw') # string 타입으로 DB 테이블에 저장되어 있음.

    user = User.query.filter_by(user_id=user_id).first()
    if not user:
        return jsonify(message='아이디가 존재하지 않습니다.'), 404

    if user.user_pw != user_pw:
        return jsonify(message='비밀번호가 일치하지 않습니다.'), 401

    return jsonify(message='로그인 되었습니다.'), 200


@app.route('/upload_images', methods=['POST'])
def upload_images():
    """
    Before 2장의 이미지 DB에 업로드 -> 모델 돌리기 -> 최종 결과 이미지 DB에 업로드
    -> After 이미지 테이블 id 반환
    """
    token = request.headers.get('Authorization')
    payload = verify_token(token)
    if not payload:
        return jsonify(message='올바르지 않은 접근입니다. 관리자에게 문의하세요.'), 401
    
    user_id = request.form.get('user_id')

    user = User.query.filter_by(user_id=user_id).first()

    if user.is_making:
        return '실행 중입니다. 잠시만 기다려주세요.', 400

    else:
        user.is_making = True

        body_img_file = request.files.get('body_image')
        clothes_img_file = request.files.get('clothes_image')

        if not body_img_file or not clothes_img_file:
            return '상체 이미지 1장과 옷 이미지 1장을 모두 업로드 해주세요.', 400

        body_img_data = body_img_file.read()
        clothes_img_data = clothes_img_file.read()

        new_record = BeforeImage(
            user_id=user_id,
            body_img_data=body_img_data,
            clothes_img_data=clothes_img_data
        )

        db.session.add(new_record)
        
        try:
            db.session.commit()
            image_id = new_record.id

        except:
            db.session.rollback()
            return jsonify(message='업로드하신 이미지 저장 도중 에러가 발생했습니다. 다시 시도해주세요.'), 500
        
        merged_image = merge_images(body_img_data, clothes_img_data, image_id)

        new_record = AfterImage(
            id=image_id,
            user_id=user_id,
            img_data=merged_image
        )

        db.session.add(new_record)
        
        user.is_making = False

        try:
            db.session.commit()

        except Exception as e:
            print(e)
            db.session.rollback()
            return jsonify(message='합성된 이미지 저장 도중 에러가 발생했습니다. 다시 시도해주세요.'), 500

    return jsonify({"image_id": image_id, "message": "이미지 처리가 완료되었습니다."}), 200


@app.route('/get_result_image/<image_id>', methods=['GET'])
def get_image(image_id):
    """
    After 이미지 테이블 id 기반으로, 최종 결과 이미지 DB에서 GET
    """
    token = request.headers.get('Authorization')
    payload = verify_token(token)
    if not payload:
        return jsonify(message='올바르지 않은 접근입니다. 관리자에게 문의하세요.'), 401

    data = AfterImage.query.filter_by(id=image_id).first()

    if not data:
        return '이미지를 찾을 수 없습니다.', 404
    else:
        if data.user_id != payload['user_id']:
            return jsonify(message='본인이 올린 이미지만 확인할 수 있습니다.'), 403

    img_data = data.img_data
    img_format = get_image_format(img_data)

    return Response(img_data, content_type=f'image/{img_format}')


if __name__ == '__main__':
    app.run(debug=False)
