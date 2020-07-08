import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {

  final IconData iconData;
  final String hint;
  final bool obscure;
  //parametro para receber a Stream que vai estar com o retorno do validator
  final Stream<String> stream;
  final Function(String) onChanged;
  InputField({this.iconData,this.hint,this.obscure,this.stream,this.onChanged});

  @override
  Widget build(BuildContext context) {
    //refazendo a tela sempre que entrar dados na variavél "stream"
    //feito com o StreamBuilder
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        return TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            icon: Icon(iconData,color: Colors.white,),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.pinkAccent
              )
            ),
            errorText: snapshot.hasError ? snapshot.error : null,
            contentPadding: EdgeInsets.only(
              left: 5,
              right: 30,
              bottom: 30,
              top: 30
            )
          ),
          style: TextStyle(
            color: Colors.white,
          ),
          obscureText: obscure,
        );
      }
    );
  }
}
