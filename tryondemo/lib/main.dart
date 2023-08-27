import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryondemo/repository/user_preference.dart';
import 'package:tryondemo/src/binding/init_bindings.dart';
import 'package:tryondemo/src/screen/login/loginscreen.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tryon Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black),
        ),
      ),
      initialBinding: InitBinding(),
      home: UserPreferences.isLoggedIn() ? App() : LoginScreen(),
    );
  }
}
