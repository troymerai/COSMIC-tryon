import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final int index;
  final List<XFile>? imageFiles;
  final ValueChanged<int> onChanged;

  ImagePickerWidget(
      {required this.index, required this.imageFiles, required this.onChanged});

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  ImagePicker _picker = ImagePicker();

  void _getImage() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: 1024,
      imageQuality: 30,
    );

    if (image != null) {
      setState(() {
        widget.imageFiles![widget.index] = image;
      });
      widget.onChanged(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.imageFiles![widget.index] != null
              ? Image.file(
                  File(widget.imageFiles![widget.index].path),
                  fit: BoxFit.fill,
                )
              : SizedBox(
                  width: 300,
                  height: 300,
                  child: Icon(Icons.camera_alt_outlined, size: 100),
                ),
        ),
        TextButton(
          onPressed: _getImage,
          child: Text("이미지 변경"),
        ),
      ],
    );
  }
}
