import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tryon/imagepickscreen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 300,
          height: 50,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  '메인 페이지',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[300]!,
                          offset: Offset(4, 4),
                          blurRadius: 2,
                          spreadRadius: 1),
                      BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4, -4),
                          blurRadius: 2,
                          spreadRadius: 1)
                    ]),
                child: const Center(child: Text('이미지 선택하러 가기'))))
      ])),
    );
  }
}
