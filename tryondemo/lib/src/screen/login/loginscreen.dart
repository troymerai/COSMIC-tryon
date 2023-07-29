import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tryondemo/api/api.dart';
import 'package:tryondemo/repository/user_preference.dart';
import 'package:tryondemo/repository/user_repo.dart';
import 'package:tryondemo/src/app.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /** 회원가입, 로그인 페이지 나누는 변수 */
  bool isSignupScreen = true;
  /** textediter의 값을 key값으로 제어 */
  final _formKey = GlobalKey<FormState>();

  // user정보 담아두는 변수
  String userId = '';
  String userPassword = '';

  // 각각의 textediter controller
  var userIdController = TextEditingController();
  var userPasswordController = TextEditingController();

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
  /// 회원가입 로직
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

  /** 회원가입용 아이디 유효성 검사(중복 검사) */
  // 1. post로 id 중복 검사 요청
  // 2. DB접근 문제 생기면 토스트 메세지 출력 후 프로세스 종료
  // 3. 이미 존재하는 아이디로 회원가입을 시도하는 경우 토스트 메세지 출력 후 프로세스 종료
  // 4. 성공하면 토스트 메세지 출력 후 saveInfo 함수 실행
  checkUserIdForSignup() async {
    var response = await http.post(
      Uri.parse(API.signup),
      headers: {
        // 오류때매 추가한 코드
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userIdController.text.trim(),
        'user_pw': userPasswordController.text.trim(),
      }),
    );
    // statuscode 저장하는 변수
    var statusCode = response.statusCode;
    // 반환 json값 담는 변수
    var responsebody = jsonDecode(response.body);
    var decodedResponse = utf8.decoder.convert(response.bodyBytes);
    final Map<String, dynamic> jsonData = jsonDecode(decodedResponse);
    try {
      // DB 접근 문제 발생하는 경우
      if (response.statusCode == 500) {
        Fluttertoast.showToast(msg: responsebody);
        Fluttertoast.showToast(msg: "signup status 500");
      }
      // 이미 존재하는 아이디로 회원가입을 시도하는 경우
      if (response.statusCode == 400) {
        Fluttertoast.showToast(msg: responsebody);
        Fluttertoast.showToast(msg: "signup status 400");
      }
      // 성공하는 경우
      if (response.statusCode == 201) {
        await saveInfo();
        // 로그인 화면으로 전환
        isSignupScreen = false;
        setState(() {});
        Fluttertoast.showToast(msg: response.body);
        Fluttertoast.showToast(msg: "signup status 201");
      }
      // 알 수 없는 에러 발생 시
      // 누나한테 어케처리할지 질문
      else {
        Fluttertoast.showToast(msg: responsebody);
        Fluttertoast.showToast(msg: "서버에서 반환된 데이터: ${response.body}");
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
      // 이게 문제 맞았음.. ㅅㅂ
      Fluttertoast.showToast(msg: '이게 문제임');
      Fluttertoast.showToast(msg: 'statuscode: ${statusCode}');
      // 한글 깨짐
      Fluttertoast.showToast(msg: "서버에서 반환된 데이터: ${response.body}");
      // 한글 깨짐 해결
      Fluttertoast.showToast(msg: "json 디코딩한 데이터: ${jsonData}");
    }
  }

  /** 유효성 검사 후 유저 정보 데이터베이스에 넣는 함수 */
  saveInfo() async {
    // uuid 자동 부여
    var uuid = const Uuid();
    String userUuid = uuid.v4();

    User userModel = User(
      user_id: userIdController.text.trim(),
      user_uuid: userUuid,
      //user_name: "",
      //user_gender: "",
      //user_nickname: "",
      //user_phonenumber: 0,
      //user_studentID: 0,
      //user_email: "",
      user_pw: userPasswordController.text.trim(),
      //user_age: 0,
      //user_imageUrls: "",
      //user_bio: "",
      //user_major: "",
    );

    try {
      var response = await http.post(
        Uri.parse(API.signup),
        headers: {
          // 오류때매 추가한 코드
          'Content-Type': 'application/json',
        },
        body: json.encode(userModel.toJson()),
      );
      var statusCode = response.statusCode;
      Fluttertoast.showToast(msg: "usermodel info: ${userModel.toJson()}");
      Fluttertoast.showToast(msg: "saveinfo statuscode : ${statusCode}");

      var resSignup = jsonDecode(response.body);
      // shared preference 기능으로 캐시에 유저 데이터 저장
      await UserPreferences.saveUser(
        uuid: userModel.user_uuid,
        id: userModel.user_id,
        password: userModel.user_pw,
      );
      Fluttertoast.showToast(msg: "saveinfo 통과함");

      // 회원가입 성공 동시에 로그인 시켜버려??
      setState(() {});
      // if (response.statusCode == 201) {}
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
  /// 로그인 로직
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

  /** 로그인용 유효성 검사(중복 검사) */
  // 1. post로 id, pw 중복 검사 요청
  // 2. 존재하지 않는 아이디면 토스트 메세지 출력 후 프로세스 종료
  // 3. 비번 일치하지 않으면 토스트 메세지 출력 후 프로세스 종료
  // 4. 성공하면 토스트 메세지 출력 후 로그인 완료
  checkForSignin() async {
    try {
      var res = await http.post(
        Uri.parse(API.login),
        headers: {
          // 오류때매 추가한 코드
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userIdController.text.trim(),
          'user_pw': userPasswordController.text.trim(),
        }),
      );
      // statuscode 저장하는 변수
      var statuscode = res.statusCode;
      // 반환 json값 담는 변수
      var resbody = jsonDecode(res.body);
      // 반환 json이 깨져서 utf-8로 변환하는 변수
      var decodedResponse = utf8.decoder.convert(res.bodyBytes);
      final Map<String, dynamic> jsonData = jsonDecode(decodedResponse);
      //존재하지 않는 아이디로 로그인하려는 경우
      if (statuscode == 404) {
        Fluttertoast.showToast(msg: resbody.toString());
        Fluttertoast.showToast(msg: "signin status 404");
      }
      //비밀번호가 일치하지 않는데 로그인 하려는 경우
      if (statuscode == 401) {
        Fluttertoast.showToast(msg: resbody.toString());
        Fluttertoast.showToast(msg: "signin status 401");
      }
      // 성공!
      if (statuscode == 200) {
        Fluttertoast.showToast(msg: resbody.toString());
        Fluttertoast.showToast(msg: "signin status 200");

        setState(() {});
        Get.to(App());
      }
      // 알 수 없는 에러 발생 시
      else {
        Fluttertoast.showToast(msg: resbody.toString());
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
      // Fluttertoast.showToast(msg: 'statuscode: ${statusCode}');
      // Fluttertoast.showToast(msg: "서버에서 반환된 데이터: ${res.body}");
      // Fluttertoast.showToast(msg: "json 디코딩한 데이터: ${jsonData}");
    }
  }

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
  /// 로그인 스크린 위젯
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // 스크린 저장 변수
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              //위에 공간 확보용
              Container(
                width: screenWidth,
                height: screenHeight * 0.2,
                color: Colors.black,
              ),
              //소개글 작성 공간
              Container(
                width: screenWidth,
                height: screenHeight * 0.2,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Text(
                        '안녕하세요\n피팅룸입니다',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Text(isSignupScreen
                          ? '회원가입하여 가상 피팅 서비스를 이용해보세요!'
                          : '로그인하여 가상 피팅 서비스를 이용해보세요'),
                    ),
                  ],
                ),
              ),
              //textedier 및 정보 입력 공간
              Container(
                // container 디자인 부분
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                width: screenWidth * 0.8,
                height:
                    isSignupScreen ? screenHeight * 0.35 : screenHeight * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                //textediter 부분
                child: Column(
                  children: [
                    // 로그인, 회원가입 전환 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignupScreen = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  '로그인',
                                  style: TextStyle(
                                    color: !isSignupScreen
                                        ? Colors.black
                                        : Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                if (!isSignupScreen)
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    height: 2,
                                    width: 55,
                                    color: Colors.black,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignupScreen = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  '회원가입',
                                  style: TextStyle(
                                    color: !isSignupScreen
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                if (isSignupScreen)
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    height: 2,
                                    width: 55,
                                    color: Colors.black,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // textformfield 부분
                    //// 로그인 부분
                    if (!isSignupScreen)
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //// 로그인 - userid
                              TextFormField(
                                key: ValueKey(1),
                                controller: userIdController,
                                validator: (value) {
                                  value == "" ? "아이디를 적어주세요" : null;
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    CupertinoIcons.person_circle,
                                    color: Colors.black,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35),
                                    ),
                                  ),
                                  hintText: 'ex) mingkey',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),

                              //// 로그인 - 비밀번호
                              TextFormField(
                                obscureText: true,
                                key: ValueKey(2),
                                controller: userPasswordController,
                                validator: (value) {
                                  value == "" ? "비밀번호를 적어주세요" : null;
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    CupertinoIcons.lock,
                                    color: Colors.black,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35),
                                    ),
                                  ),
                                  hintText: 'ex) 6자 이상',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),

                              //// 로그인 버튼
                              GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    checkForSignin();
                                  }
                                },
                                child: Container(
                                  width: screenWidth * 0.4,
                                  height: screenHeight * 0.05,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isSignupScreen ? '회원가입' : '로그인',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    //// 회원가입 부분
                    if (isSignupScreen)
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //// 회원가입 - userid
                              TextFormField(
                                key: ValueKey(3),
                                controller: userIdController,
                                validator: (value) {
                                  value == "" ? "아이디를 적어주세요" : null;
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    CupertinoIcons.person_circle,
                                    color: Colors.black,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35),
                                    ),
                                  ),
                                  hintText: '아이디를 적어주세요',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),

                              //// 회원가입 - 비밀번호
                              TextFormField(
                                obscureText: true,
                                key: ValueKey(4),
                                controller: userPasswordController,
                                validator: (value) {
                                  value == "" ? "비밀번호를 적어주세요" : null;
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    CupertinoIcons.lock,
                                    color: Colors.black,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35),
                                    ),
                                  ),
                                  hintText: '6자 이상',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),

                              //// 회원가입 버튼
                              GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    checkUserIdForSignup();
                                  }
                                },
                                child: Container(
                                  width: screenWidth * 0.4,
                                  height: screenHeight * 0.05,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isSignupScreen ? '회원가입' : '로그인',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
