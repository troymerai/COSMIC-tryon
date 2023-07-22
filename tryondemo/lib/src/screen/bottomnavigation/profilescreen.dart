import 'package:flutter/material.dart';

import '../../../repository/user_preference.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void showUserData() {
    // print('User ID: $userId');
    // print('User Name: $userName');
  }

  @override
  Widget build(BuildContext context) {
    int userId = UserPreferences.getUserId();
    String userName = UserPreferences.getUserName();

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
              child: Text('프로필 페이지'),
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.blue,
              child: Text(userId.toString()),
            ),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.green,
              child: Text(userName),
            ),
          ],
        ),
      ),
    );
  }
}
