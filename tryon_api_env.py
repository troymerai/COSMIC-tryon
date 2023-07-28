
####### 서버에서 한번만 작업하면 되는 것

#ACGPN 모델 폴더 다운로드
!git clone https://github.com/kairess/ACGPN.git
#얘는 필요 c++ 빌드 관련 모시기라고 함
!pip install ninja -qq

import numpy as np
from PIL import Image
import IPython
import os
import sys
import time
# lip_final.pth 파일이랑 ACGPN_checkpoint 때매 넣음.. gdown 말고 리눅스에서 쓸 수 있는 코드 찾아야 함
import gdown


%cd ACGPN

from predict_pose import generate_pose_keypoints


#ACGPN 모델을 돌리기 위한 폴더 준비
!mkdir Data_preprocessing/test_color
!mkdir Data_preprocessing/test_colormask
!mkdir Data_preprocessing/test_edge
!mkdir Data_preprocessing/test_img
!mkdir Data_preprocessing/test_label
!mkdir Data_preprocessing/test_mask
!mkdir Data_preprocessing/test_pose
!mkdir inputs
!mkdir inputs/img
!mkdir inputs/cloth

#휴먼 세그멘테이션 모델 파일 다운로드
!git clone https://github.com/levindabhi/Self-Correction-Human-Parsing-for-ACGPN.git
#옷 마스킹 모델 파일 다운로드
!git clone https://github.com/levindabhi/U-2-Net.git

#리눅스 다운 코드로 변환해야 함
!gdown --id 11dRA_iLSJFFsOWXuadmH7Apqukc2F_Vf -O pose/pose_iter_440000.caffemodel

gdown.download('https://drive.google.com/uc?id=1k4dllHpu0bdx38J7H28rVVLpU-kOHmnH', 'lip_final.pth', quiet=False)

#U-2-Net 모델을 돌릴 때 필요한 파일 준비를 위해 해당 모델 폴더로 이동
%cd U-2-Net

#U-2-Net 모델에 필요한 폴더 생성
!mkdir saved_models
!mkdir saved_models/u2net
!mkdir saved_models/u2netp

#사전 학습된 U-2-Net 모델 다운로드
!gdown 1rbSTGKAE-MTxBYHd-51l2hMOQPT_7EPy -O saved_models/u2netp/u2netp.pth
!gdown 1ao1ovG1Qtx4b7EoskHXmi2E9rp5CHLcZ -O saved_models/u2net/u2net.pth

import u2net_load
import u2net_run

#로드하려면 쿠다 필요 (위치 확인용)
u2net = u2net_load.model(model_name='u2netp')

#U-2-Net 모델을 위한 파일 준비가 끝나면 부모 폴더로 이동
%cd ..

#ACGPN 모델에 필요한 폴더 생성
!mkdir checkpoints


#사전 학습된 ACGPN 모델 다운로드
gdown.download('https://drive.google.com/uc?id=1UWT6esQIU_d4tUm8cjxDKMhB8joQbrFx', output='checkpoints/ACGPN_checkpoints.zip', quiet=False)

#압축된 모델 파일 풀어서 전에 만든 폴더위치에 넣어줌
!unzip checkpoints/ACGPN_checkpoints.zip -d checkpoints

# 부모 폴더로 이동
%cd ..

# Clone Real-ESRGAN and enter the Real-ESRGAN
!git clone https://github.com/xinntao/Real-ESRGAN.git
%cd Real-ESRGAN
# Set up the environment
!pip install basicsr
!pip install facexlib
!pip install gfpgan
!pip install -r requirements.txt
!python setup.py develop

import shutil

upload_folder = 'upload'
result_folder = 'results'

if os.path.isdir(upload_folder):
    shutil.rmtree(upload_folder)
if os.path.isdir(result_folder):
    shutil.rmtree(result_folder)
os.mkdir(upload_folder)
os.mkdir(result_folder)

%cd ..

from pathlib import Path

CURRENT_DIR = Path()
q = CURRENT_DIR / 'Real-ESRGAN' / 'upload'
#d = CURRENT_DIR / 'ACGPN' / 'results' / 'test' / 'try-on' / f"{img_name}"


!pwd