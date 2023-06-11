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
  final String email;

  const ImageUploadPopup(this.email, {super.key});

  @override
  ImageUploadPopupState createState() => ImageUploadPopupState();
}

class ImageUploadPopupState extends State<ImageUploadPopup> {
  File? _imageFile;
  String? _encodedImage;
  bool reset = false;
  static final dbUrl = dotenv.env["MONGODB_URL"].toString();

  bool run=true;


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
    updateMongo();
  }

  void encodeImage(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    setState(() {
      _encodedImage = base64Encode(imageBytes);
    });
  }

  void updateMongo() async {


    if (_encodedImage != null||reset) {
if(mounted) {
        setState(() {
          run = false;
        });

      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      mongo.Db conn = await mongo.Db.create(dbUrl);
      await conn.open();
      mongo.DbCollection collection = conn.collection('users');
      var modifier = mongo.ModifierBuilder().set('profile',_encodedImage);

      if(reset){
        modifier = mongo.ModifierBuilder().unset('profile');

      }

      var result = await collection.updateOne(
          {'email': widget.email}, modifier);


      if (result.isSuccess) {
        if(_encodedImage!=null) {

          prefs.setString("profile", _encodedImage.toString());
        }
        else{
          prefs.remove("profile");
        }
        conn.close();
        if(!mounted)return;
        Navigator.pop(context, _encodedImage);
      } else {
        if(mounted) {
          setState(() {
            run = true;
          });

        }
        Fluttertoast.showToast(
          msg: "이미지가 업로드 되지 않았습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      conn.close();
    } else {
      if(mounted) {
        setState(() {
          run = true;
        });

      }
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
        const Text("업로드 방식"),
        FGRoundButton(
            text: "x",
            onPressed: () {
              Navigator.pop(context);
            },
            textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                child: const Text("앨범"),
              ),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Text("카메라"),
              ),
            ],
          ),
          if (_imageFile != null) const Text('업로드 된 이미지', style: TextStyle()),
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
        if(run)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () => setBasic(),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.greenAccent)),
              child: const Text("기본 이미지"),
            ),
            const SizedBox(width: 10,),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.greenAccent), // 원하는 배경색으로 설정합니다.
              ),
              onPressed: () {
                updateMongo();
              },
              child: const Text('업로드'),
            ),
          ],
        ),
        if(!run)const Align(child:Text("업로드중...") )
      ],
    );
  }
}
