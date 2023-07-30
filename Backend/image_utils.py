from PIL import Image
import os
import shutil
import io

from ACGPN.U_2_Net import u2net_load, u2net_run
from ACGPN.predict_pose import generate_pose_keypoints

u2net = u2net_load.model(model_name='u2netp')


def get_image_format(image_data):
    """
    바이너리 이미지 데이터의 형식이 PNG/JPEG/ELSE인지 반환하는 함수
    """
    if image_data.startswith(b'\x89PNG'):
        return 'png'
    elif image_data.startswith(b'\xFF\xD8'):
        return 'jpeg'
    else:
        return None


def delete_files_in_directory(directory):
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        if os.path.isfile(file_path):
            os.remove(file_path)


def clean_files():
    directories_to_clean = [
        "ACGPN/Data_preprocessing/test_color/",
        "ACGPN/Data_preprocessing/test_colormask/",
        "ACGPN/Data_preprocessing/test_edge/",
        "ACGPN/Data_preprocessing/test_img/",
        "ACGPN/Data_preprocessing/test_label/",
        "ACGPN/Data_preprocessing/test_mask/",
        "ACGPN/Data_preprocessing/test_pose/",
        "ACGPN/inputs/cloth/",
        "ACGPN/inputs/img/",
        "ACGPN/results/test/refined_cloth/",
        "ACGPN/results/test/warped_cloth/",
        "Real-ESRGAN/upload/",
        "Real-ESRGAN/results/",
    ]

    for directory in directories_to_clean:
        delete_files_in_directory(directory)


def merge_images(body_img_data, clothes_img_data, image_id):
    """
    body image + clothes image -(모델)-> 합성된 사진 반환하는 함수
    """
    
    cloth_name = f'cloth_{image_id}.png'
    cloth_path = f'ACGPN/inputs/cloth/{cloth_name}'

    with open(cloth_path, "wb") as f:
        f.write(clothes_img_data)
    
    cloth = Image.open(cloth_path)
    cloth = cloth.resize((192, 256), Image.BICUBIC).convert('RGB')

    cloth.save(os.path.join('ACGPN/Data_preprocessing/test_color', cloth_name))
    u2net_run.infer(u2net, 'ACGPN/Data_preprocessing/test_color', 'ACGPN/Data_preprocessing/test_edge')


    img_name = f'img_{image_id}.png'
    img_path = f'ACGPN/inputs/img/{img_name}'

    with open(img_path, "wb") as f:
        f.write(body_img_data)

    img = Image.open(img_path)
    img = img.resize((192,256), Image.BICUBIC)

    img_path = os.path.join('ACGPN/Data_preprocessing/test_img', img_name)
    img.save(img_path)

    os.system("python3 ACGPN/Self-Correction-Human-Parsing-for-ACGPN/simple_extractor.py --dataset 'lip' --model-restore 'ACGPN/lip_final.pth' --input-dir 'ACGPN/Data_preprocessing/test_img' --output-dir 'ACGPN/Data_preprocessing/test_label'")


    pose_path = os.path.join('ACGPN/Data_preprocessing/test_pose', img_name.replace('.png', '_keypoints.json'))

    generate_pose_keypoints(img_path, pose_path)

    test_pairs_file_path = 'ACGPN/Data_preprocessing/test_pairs.txt'

    try:
        os.remove(test_pairs_file_path)
    except Exception as e:
        raise e

    with open(test_pairs_file_path, 'w') as f:
        f.write(f'{img_name} {cloth_name}')

    os.system("python ACGPN/test.py")

    file_path = f"ACGPN/results/test/try-on/{img_name}"
    upload_folder = 'Real-ESRGAN/upload'

    shutil.move(file_path, upload_folder)

    os.system("python Real-ESRGAN/inference_realesrgan.py -n RealESRGAN_x4plus -i upload --outscale 3.5 --face_enhance")

    uploaded = Image.open(os.path.join(upload_folder, img_name))

    img_byte_array = io.BytesIO()
    uploaded.save(img_byte_array, format="PNG")
    img_data = img_byte_array.getvalue()

    clean_files()

    return img_data
