import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tryon/imagepickscreen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: Colors.lightBlue,
            child: Center(
              child: Column(
                children: const [
                  Text('메인 페이지'),
                  Text('UI 적용 안 해서 조잡한 거 맞습니다~ (오류 아님)'),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          GestureDetector(
            onTap: () {
              //이미지 선택 페이지로 이동
              Get.to(() => ImagePickingScreen());
            },
            child: Container(
              width: 100,
              height: 100,
              color: Colors.amber,
              child: const Center(
                child: Text('이미지 선택하러 가기'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
