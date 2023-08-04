import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tryondemo/api/api.dart';
import 'package:tryondemo/src/app.dart';

import '../../../repository/user_preference.dart';

class ImageFromServer extends StatefulWidget {
  final int imageId;
  const ImageFromServer({Key? key, required this.imageId}) : super(key: key);

  @override
  _ImageFromServerState createState() => _ImageFromServerState();
}

class _ImageFromServerState extends State<ImageFromServer> {
  late Uri uri;

  @override
  void initState() {
    super.initState();
    uri = Uri.parse('${API.getimage}${widget.imageId}');
  }

  Uint8List? _imageBytes;

  // Future<Uint8List> _getImageBytes() async {
  //   try {
  //     final response = await http.get(uri);

  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> jsonResponse = jsonDecode(response.body);

  //       // Extract and decode the image data from jsonResponse
  //       String base64ImageData = jsonResponse['image_data'];
  //       Uint8List imageBytes = base64Decode(base64ImageData);

  //       return imageBytes;
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Error fetching image: $e');
  //     rethrow;
  //   }
  // }
  Future<Uint8List> _getImageBytes() async {
    String token = UserPreferences.getUserToken();

    try {
      final response = await http.get(uri, headers: {
        'Content-Type': 'image/jpeg',
        'Authorization': '$token',
      });

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '에러: $e');
      rethrow;
    }
  }

  Future<void> _saveImage() async {
    if (_imageBytes == null) {
      Fluttertoast.showToast(msg: "이미지 다운로드에 실패했습니다");
      return;
    }

    final status = await Permission.storage.request();
    if (status.isGranted) {
      final extDir = await getExternalStorageDirectory();
      final picturesDir = Directory('${extDir!.path}/Pictures');
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }
      final filePath = '${picturesDir.path}/downloaded_image.jpg';
      final file = File(filePath);
      await file.writeAsBytes(_imageBytes!);
      Fluttertoast.showToast(msg: "갤러리에 이미지가 저장되었습니다");
    } else {
      Fluttertoast.showToast(msg: "Storage permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('JSON Server Image'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: _getImageBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _imageBytes = snapshot.data!;
              return Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.memory(snapshot.data!),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => App());
                        },
                        child: Container(
                          color: Colors.black,
                          width: 100,
                          height: 50,
                          child: Center(
                              child: Text(
                            '홈으로 돌아가기',
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            // 여기에 다른 페이지 클래스를 넣어서 로딩 화면을 지루?하지 않게 만들 수 있음
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveImage,
        child: Icon(Icons.download),
        tooltip: 'Download Image',
      ),
    );
  }
}
