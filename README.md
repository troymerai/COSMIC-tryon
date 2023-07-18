# COSMIC-tryon
2023 공개 SW 개발자 대회 가상피팅 프로젝트

## Usage

- Back-end

    ```bash
    # venv 설치
    $ python3.8.10 -m venv myenv

    # venv 활성화
    $ source myenv/bin/activate

    # 의존성 설치
    (myenv) $ pip install -r requirements.txt

    # exampleapp.service 참고하여 tryonapp.service 작성
    # ...

    # tryonapp.service를 복사
    $ sudo cp tryonapp.service /etc/systemd/system/

    # tryonapp systemctl 실행
    $ sudo systemctl daemon-reload
    $ sudo systemctl start tryonapp

    # tryonapp 서비스를 시스템 재부팅 시에도 자동 실행되도록 설정
    $ sudo systemctl enable tryonapp
    ```
