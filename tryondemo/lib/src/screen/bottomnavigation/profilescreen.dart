import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tryondemo/src/screen/login/loginscreen.dart';

import '../../../repository/user_preference.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  logout() async {
    // 사용자의 uid, 아이디, 비밀번호 저장
    final String savedUid = await UserPreferences.getUserUid();
    final String savedId = await UserPreferences.getUserId();
    final String savedPassword = await UserPreferences.getUserPassword();

    /** 사용자를 정보 삭제 */
    await UserPreferences.clear(
        keepUid: true, keepId: true, keepPassword: true, keepToken: true);

    setState(() {
      // 로그인 상태를 나타내는 변수나 클래스 초기화
    });

    Fluttertoast.showToast(msg: "로그아웃 되었습니다.");

    // 로그아웃 프로세스 후 로그인 페이지로 이동
    Get.to(() => LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    String userUid = UserPreferences.getUserUid();
    String userId = UserPreferences.getUserId();
    String userPassword = UserPreferences.getUserPassword();

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.amber,
              child: const Text('프로필 페이지'),
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.blue,
              child: Center(child: Text(userUid)),
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.green,
              child: Center(child: Text(userId)),
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.red,
              child: Center(child: Text(userPassword)),
            ),
            GestureDetector(
              onTap: () {
                logout();
              },
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.purple,
                child: const Center(child: Text('로그아웃 버튼')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
