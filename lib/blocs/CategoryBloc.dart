import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc extends BlocBase{


  final _titleController = BehaviorSubject<String>();
  final _imageController = BehaviorSubject();
  final _deleteController = BehaviorSubject<bool>();

  File image;
  String title;

  Stream<String> get outTitle => _titleController.stream.transform(
    StreamTransformer<String, String>.fromHandlers(
      handleData: (title,sink){
        if(title.isEmpty){
          sink.addError("Insira um titulo");
        }else{
          sink.add(title);
        }
      }
    )
  );
  Stream get outImage => _imageController.stream;
  Stream<bool> get outDelete => _deleteController.stream;
  Stream<bool> get submitValid => Observable.combineLatest2(
      outTitle, outImage, (a,b)=>true);


  void saveData()async{
    if(image==null && category != null && title==category.data["title"]){
      return;
    }else{
      Map<String,dynamic> dataToUpdate={};
      if(image!=null){
        StorageUploadTask task = FirebaseStorage.instance.ref().child("icons")
            .child(title).putFile(image);
        StorageTaskSnapshot snap = await task.onComplete;
        dataToUpdate["icon"] = await snap.ref.getDownloadURL();
      }
      if(category==null || title != category.data["title"]){
        dataToUpdate["title"] = title;
      }
      if(category==null){
        await Firestore.instance.collection("products").document(title.toLowerCase());
      }else{
        await category.reference.updateData(dataToUpdate);
      }
    }
  }

  void delete(){
    category.reference.delete();
  }

  void setImage(File file){
    image = file;
    _imageController.add(file);
  }
  void setTitle(String title){
    this.title = title;
    _titleController.add(title);
  }

  DocumentSnapshot category;
  CategoryBloc(this.category){
    title = category.data["title"];
    if(category!=null){
      _titleController.add(category.data["title"]);
      _imageController.add(category.data["icon"]);
      _deleteController.add(true);

    }else{
      _deleteController.add(false);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _deleteController.close();
    _imageController.close();
    _deleteController.close();
  }

}