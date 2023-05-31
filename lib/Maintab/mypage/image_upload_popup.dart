import 'dart:convert';
import 'dart:io';

import 'package:fighting_gonggang/Layout/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploadPopup extends StatefulWidget {
  String email;

  ImageUploadPopup(this.email);

  @override
  ImageUploadPopupState createState() => ImageUploadPopupState();
}

class ImageUploadPopupState extends State<ImageUploadPopup> {
  File? _imageFile;
  String? _encodedImage;
  bool reset = false;
  static final dburl = dotenv.env["MONGO_URL"].toString();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
        encodeImage(_imageFile!);
      }
    });
  }

  void setBasic() {
    setState(() {
      reset = true;
    });
  }

  void encodeImage(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    setState(() {
      _encodedImage = base64Encode(imageBytes);
    });
  }

  void updateMongo() async {
    if (_encodedImage != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      mongo.Db conn = await mongo.Db.create(dburl);
      await conn.open();
      mongo.DbCollection collection = conn.collection('users');

      var result = await collection.updateOne(
          {'email': widget.email}, mongo.modify.set('profile', _encodedImage));

      if (result.isSuccess) {
        Navigator.pop(context, _encodedImage);
      } else {
        Fluttertoast.showToast(
          msg: "이미지가 업로드 되지 않았습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "이미지가 업로드 되지 않았습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("업로드 방식"),
        FGRoundButton(text: "x", onPressed: () {Navigator.pop(context);},textStyle: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text("앨범"),
              ),

              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: Text("카메라"),
              ),

            ],
          ),      ElevatedButton(
            onPressed: () => _pickImage(ImageSource.camera),
            child: Text("기본 이미지"),
          ),
          if (_imageFile != null) Text('업로드 된 이미지', style: TextStyle()),
          if (_imageFile != null)
            Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_imageFile!),
                    fit: BoxFit.cover,
                  )
                  // 기본 아이콘
                  ),
            ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.greenAccent), // 원하는 배경색으로 설정합니다.
              ),
              onPressed: () {
                updateMongo();
              },
              child: const Text('업로드'),
            ),
          ],
        ),
      ],
    );
  }
}
