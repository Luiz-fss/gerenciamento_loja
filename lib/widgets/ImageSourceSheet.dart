import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {

  Function(File) onImageSelected;

  ImageSourceSheet({this.onImageSelected});

  @override
  Widget build(BuildContext context) {

    void imageSelected(File image)async{
      if(image!=null){
       File cropedImage = await ImageCropper.cropImage(
           sourcePath: image.path,
       );
       onImageSelected(cropedImage);
      }
    }

    return BottomSheet(
      onClosing: (){},
      builder: (context)=> Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton(
            child: Text("camera"),
            onPressed: ()async{
             File image = await ImagePicker.pickImage(source: ImageSource.camera);
             imageSelected(image);
            },
          ),
          FlatButton(
            child: Text("galeria"),
            onPressed: ()async{
              File image = await  ImagePicker.pickImage(source: ImageSource.gallery);
              imageSelected(image);
            },
          )
        ],
      ),
    );
  }
}