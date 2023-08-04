import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryondemo/api/api.dart';
import 'package:tryondemo/repository/user_preference.dart';
import 'package:tryondemo/src/components/image_data.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tryondemo/src/screen/tryon/imagefromserver.dart';

import '../../components/imagepick_widget.dart';

// class ImagePickingScreen extends StatefulWidget {
//   const ImagePickingScreen({Key? key}) : super(key: key);

//   @override
//   State<ImagePickingScreen> createState() => _ImagePickingScreenState();
// }

// class _ImagePickingScreenState extends State<ImagePickingScreen> {
//   // imagepicker용 변수
//   final ImagePicker _picker = ImagePicker();
//   // 여러 이미지 리스트 형식으로 담는 변수
//   List<XFile>? _multipleImages;

//   /** 이미지 접근 권한 및 이미지 선택 기능 */
//   Future<void> _pickImages() async {
//     final pickedImages = await _picker.pickMultiImage(
//       maxWidth: 1024,
//       maxHeight: 1024,
//       imageQuality: 10,
//     );
//     if (pickedImages != null) {
//       setState(() {
//         _multipleImages = pickedImages;
//       });
//     }
//   }

//   /** 권한 확인 관련 모달창 기능 */
//   void _showPermissionErrorDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('알림'),
//           content:
//               const Text('권한이 없으면 이미지를 선택할 수 없습니다. 설정에서 사진 접근 권한을 허용해주세요.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('설정으로 이동'),
//               onPressed: () async {
//                 await openAppSettings();
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('취소'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /** 선택한 이미지 보여주는 위젯 */
//   Widget _buildImageGrid() {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 1,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       // 이거로 하면 max item count 값을 2로 제한 둬야 함 => 코드 수정 해야함 렌더링 오류 있음
//       itemCount: 2 ?? 0,
//       itemBuilder: (BuildContext context, int index) {
//         return Image.file(File(_multipleImages![index].path));
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('이미지 선택 예제'),
//       ),
//       body: _multipleImages != null && _multipleImages!.isNotEmpty
//           ? _buildImageGrid()
//           : const Center(child: Text('이미지를 선택해 주세요')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _pickImages();
//         },
//         child: const Icon(Icons.add_photo_alternate),
//       ),
//     );
//   }
// }

/*

1. 옷 이미지 선택 위젯 (이미지 변경 버튼 포함)
2. 모델 이미지 선택 위젯 (이미지 변경 버튼 포함)
3. 이미지 확정 버튼

>> 1, 2는 class 하나 파서 매개변수로 해보기
1,2는 List<XFile>? 타입의 변수에 이미지를 담으며, 각각 지정된 Index를 관할하여 이미지 변경도 가능하게


*/

// 아이폰에서도 돌아갈라면 나중에 갤러리 사용자 권한 받아야함

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/// 벙커에서 한거

// class ImagePickingScreen extends StatefulWidget {
//   const ImagePickingScreen({super.key});

//   @override
//   State<ImagePickingScreen> createState() => _ImagePickingScreenState();
// }

// class _ImagePickingScreenState extends State<ImagePickingScreen> {
//   /** 이미지 저장하는 리스트 */
//   List<XFile>? _images =
//       List.filled(2, XFile(IconsPath.imageSelectAlert), growable: false);

//   /** 이미지 바꿀 때 state 변경용 */
//   void _onImageChanged(int index) {
//     setState(() {});
//   }

//   /** userId, 이미지 업로드 기능 */
//   void uploadImages(List<XFile> images) async {
//     var uri = Uri.parse(API.imageupload);

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userId = UserPreferences.getUserId();

//     try {
//       var request = http.MultipartRequest('POST', uri);

//       Fluttertoast.showToast(msg: '이유모르는 실패: 1');

//       //userId 추가하는 기능
//       request.fields['user_id'] = userId ?? '';

//       Fluttertoast.showToast(msg: '이유모르는 실패: 2');

//       //이미지 파일 설정 -> xfile 타입을 string으로 형변환한거라서 작동 안할수도있음
//       File clothImageFile = File(_images![0].path);
//       Fluttertoast.showToast(msg: '이유모르는 실패: 3');
//       Fluttertoast.showToast(msg: 'cloth 담긴거 : ${clothImageFile}');

//       File bodyImageFile = File(_images![1].path);
//       Fluttertoast.showToast(msg: 'body 담긴거 : ${bodyImageFile}');
//       Fluttertoast.showToast(msg: '이유모르는 실패: 4');

//       // >> 여기까지는 성공

//       //이미지 파일 추가
//       request.files.add(
//         http.MultipartFile(
//           'clothes_image',
//           clothImageFile.readAsBytes().asStream(),
//           clothImageFile.lengthSync(),
//           contentType: MediaType('image', 'jpg'),
//         ),
//       );
//       Fluttertoast.showToast(msg: '이유모르는 실패: 5');

//       request.files.add(
//         http.MultipartFile(
//           'body_image',
//           bodyImageFile.readAsBytes().asStream(),
//           bodyImageFile.lengthSync(),
//           contentType: MediaType('image', 'jpg'),
//         ),
//       );

//       /*
//       // 이미지 파일 설정 수정
//       File clothImageFile = File.fromUri(Uri.parse(_images![0].path));
//       File bodyImageFile = File.fromUri(Uri.parse(_images![1].path));

//       // 이미지 파일 추가 수정
//       request.files.add(
//         await http.MultipartFile.fromPath('clothes_image', clothImageFile.path),
//       );
//       request.files.add(
//         await http.MultipartFile.fromPath('body_image', bodyImageFile.path),
//       );
//       */

//       Fluttertoast.showToast(msg: '이유모르는 실패: 6');

//       // JSON 데이터 생성
//       var jsonData = {
//         'user_id': userId,
//       };

//       Fluttertoast.showToast(msg: '이유모르는 실패: 여기');

//       // JSON 데이터를 문자열로 변환하여 추가
//       request.fields['json_data'] = jsonEncode(jsonData);

//       Fluttertoast.showToast(msg: '이유모르는 실패: 7');

//       // 요청 보내기
//       //final response = await request.send();

//       //print(response);

//       final response = await request.send().timeout(const Duration(seconds: 30),
//           onTimeout: () {
//         throw TimeoutException("서버에 연결할 수 없습니다. 다시 시도해주세요.");
//       });

//       Fluttertoast.showToast(msg: '이유모르는 실패: 8');
//       Fluttertoast.showToast(msg: 'request 내용: ${response}');

//       var statuscode = response.statusCode;
//       Fluttertoast.showToast(msg: 'response statuscode는 ${statuscode}');

//       if (response.statusCode == 200) {
//         print('업로드 성공: ${response.reasonPhrase}');
//         final responseStream = await response.stream.bytesToString();
//         Fluttertoast.showToast(msg: '서버 응답: $responseStream');
//       } else {
//         Fluttertoast.showToast(msg: '업로드 실패: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: '이유모르는 실패: ${e}');
//       Fluttertoast.showToast(msg: '이유모르는 실패: 9');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("옷 이미지 & 모델 이미지 선택 위젯"),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('옷 이미지 선택 하는 곳'),
//               ImagePickerWidget(
//                 index: 0,
//                 imageFiles: _images,
//                 onChanged: _onImageChanged,
//               ),
//               SizedBox(height: 16),
//               Text('모델 이미지 선택 하는 곳'),
//               ImagePickerWidget(
//                 index: 1,
//                 imageFiles: _images,
//                 onChanged: _onImageChanged,
//               ),
//               SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   // 이미지 확정 버튼 클릭 시 작업
//                   uploadImages(_images!);
//                 },
//                 child: Text('이미지 확정'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

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
        // Fluttertoast.showToast(msg: '에러코드 ${response.statusCode}');
        // Fluttertoast.showToast(msg: '에러 메시지: ${response.body}');
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
