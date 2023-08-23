import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryondemo/api/api.dart';
import 'package:tryondemo/repository/user_preference.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tryondemo/src/screen/tryon/imagefromserver.dart';

class ImagePickingScreen extends StatefulWidget {
  const ImagePickingScreen({super.key});

  @override
  State<ImagePickingScreen> createState() => _ImagePickingScreenState();
}

class _ImagePickingScreenState extends State<ImagePickingScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _bodyImageFile;
  XFile? _clothesImageFile;
  bool isUploaded = false;
  int? imageId;
  String token = UserPreferences.getUserToken();
  //bool isUploading = false;
  int clickCount = 0;

  String getExtensionFromPath(String path) {
    return extension(path).replaceFirst('.', '');
  }

  Future<void> _pickBodyImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 30,
    );
    setState(() {
      _bodyImageFile = pickedFile;
    });
  }

  Future<void> _pickClothesImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 30,
    );
    setState(() {
      _clothesImageFile = pickedFile;
    });
  }

  Future<void> _uploadImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = UserPreferences.getUserId();
    var uri = Uri.parse(API.imageupload);

    if (_bodyImageFile == null || _clothesImageFile == null) {
      Fluttertoast.showToast(msg: '이미지를 선택해주세요');
      return;
    }

    try {
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = '$token';
      request.fields['user_id'] = userId;

      request.files.add(
        http.MultipartFile.fromBytes(
          'body_image',
          File(_bodyImageFile!.path).readAsBytesSync(),
          contentType:
              MediaType('image', getExtensionFromPath(_bodyImageFile!.path)),
          filename:
              '${userId}body${getExtensionFromPath(_bodyImageFile!.path)}',
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'clothes_image',
          File(_clothesImageFile!.path).readAsBytesSync(),
          contentType:
              MediaType('image', getExtensionFromPath(_clothesImageFile!.path)),
          filename:
              '${userId}cloth${getExtensionFromPath(_bodyImageFile!.path)}',
        ),
      );

      final streamedResponse = await request.send();

      // if (isUploading == true) {
      //   Fluttertoast.showToast(msg: '실행 중입니다. 잠시만 기다려주세요');
      // }
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        isUploaded = true;
        // isUploading = false;

        Fluttertoast.showToast(msg: '이미지 업로드가 완료되었습니다');
        // JSON 파싱 및 image_id를 저장
        final parsedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        imageId = parsedResponse['image_id'];
        //isUploaded = true;
      } else {
        Fluttertoast.showToast(msg: '에러가 발생했습니다 다시 시도하세요');
        Fluttertoast.showToast(msg: '에러코드 ${response.statusCode}');
        Fluttertoast.showToast(msg: '에러 메시지: ${response.body}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '에러: $e');
    }
  }

  Widget _displayImage(XFile? imageFile) {
    if (imageFile == null) {
      return Text("선택된 이미지가 없습니다");
    } else {
      return Image.file(File(imageFile.path), fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('이미지 선택하기')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('모델 이미지:'),
          ),
          _displayImage(_bodyImageFile),
          TextButton(
            onPressed: _pickBodyImage,
            child: Text('여기를 눌러서 모델 이미지를 선택해주세요'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('옷 이미지:'),
          ),
          _displayImage(_clothesImageFile),
          TextButton(
            onPressed: _pickClothesImage,
            child: Text('여기를 눌러서 옷 이미지를 선택해주세요'),
          ),
          if (clickCount == 0)
            ElevatedButton(
              onPressed: () async {
                clickCount++;
                setState(() {});
                Fluttertoast.showToast(msg: "업로드 중입니다. 잠시만 기다려주세요");
                // isUploading = true;
                await _uploadImages();
                if (isUploaded == true) {
                  Get.to(() => ImageFromServer(imageId: imageId!));
                  isUploaded = false;
                  clickCount = 0;
                }
              },
              child: Text('이미지 업로드'),
            ),
        ],
      ),
    );
  }
}
