import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



  class FGTextField extends StatelessWidget{

  final TextEditingController controller;
  final String text;
  final bool obscureText;
  const FGTextField({super.key, required this.controller,required this.text,this.obscureText=false});

  @override
  Widget build(BuildContext context) {


    return TextField(
      controller: controller,
      obscureText: obscureText,
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




class FGButton extends StatelessWidget{

  final String text;

  final void Function() onPressed;

  const FGButton({super.key,required this.text,required this.onPressed,});

  @override
  Widget build(BuildContext context) {

    return RawMaterialButton(
      constraints: BoxConstraints(
        // maxWidth:200

        minWidth: 30,
        minHeight: 30,

      ),
      elevation: 2.0,
      fillColor: Colors.yellow,
      shape: CircleBorder(),
      onPressed: (){
  onPressed();
      },
      child: Text(text,
          style: TextStyle(
            fontSize: 15,
            fontFamily: GoogleFonts.lato(
              fontWeight: FontWeight.w100,
              fontStyle: FontStyle.italic,
            ).fontFamily,
          )),
    );

  }
}