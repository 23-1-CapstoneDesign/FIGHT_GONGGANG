import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/*
자주 사용할 위젯양식들을 모아둔 코드




 */
  class FGTextField extends StatelessWidget{

  final TextEditingController controller;
  final String text;
  final bool obscureText;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const FGTextField({super.key, required this.text,required this.controller,this.onChanged,this.obscureText=false,this.focusNode,this.onTap});

  @override
  Widget build(BuildContext context) {


    return TextField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      onChanged: onChanged,
      onTap:onTap,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // 원하는 패딩 설정
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // 원하는 테두리 모서리 조정
        ),
        labelText: text,
      ),
    );
  }
}



class FGRoundButton extends StatelessWidget{

  final String text;

  final void Function() onPressed;
  final TextStyle? textStyle;
  const FGRoundButton({super.key,required this.text,required this.onPressed,this.textStyle});

  @override
  Widget build(BuildContext context) {

    return RawMaterialButton(
      constraints: BoxConstraints(
        // maxWidth:200

        minWidth: 30,
        minHeight: 30,

      ),
      elevation: 2.0,
      fillColor: Colors.green,
      shape: CircleBorder(),
      onPressed: (){
  onPressed();
      },
      child: Text(text,
      style: textStyle,

      ),
    );

  }
}

class FGRoundTextField extends StatelessWidget{
  final String text;
  final double height;
  const FGRoundTextField({super.key,required this.text,this.height=35.0});


  @override
  Widget build(BuildContext context) {

    return Container(
      alignment: Alignment.centerLeft,
      width: 200,
      height: this.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black, // 윤곽선 색상
          width: 0.1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
