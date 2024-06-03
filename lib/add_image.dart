

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
 // final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late CollectionReference imgRef;
  bool uploading =false;
  double val =0;
  String? userId;
  final List<File> _image =[];
  final List<String> _url=[];
  final picker = ImagePicker();
  late var snapshot;

  chooseImage() async{
    final pickerFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickerFile!.path));
    });
  }
  Future downloadFile() async{
    int i=1;
    for(var img in _image) {
      setState(() {
        val = i/_image.length;
      });
      //upload image ot Firebase Storage
      snapshot = await FirebaseStorage.instance
          .ref()
          .child('image_gallery')
          .child(img.path)
          .putFile(img);
      //Get image download url
      String downloadUrl = await snapshot.ref.getDownloadURL();
        print(downloadUrl.toString());
        _url.add(downloadUrl);
      i++;
    }
    uploadFile();
  }
  Future<void>uploadFile() async{
    for(var url in _url ){
      await FirebaseFirestore.instance
          .collection('images')
          .doc(userId)
          .set({'imageUrl':url});
      await FirebaseFirestore.instance
          .collection('images')
          .doc(userId)
          .get();
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Image'),
        actions: [
          TextButton(
              onPressed: (){
                setState(() {
                  uploading=true;
                });
                downloadFile().whenComplete(() => Navigator.of(context).pop());
          }, child: const Text('Upload'))
        ],

      ),
      body: Stack(
        children:[
          GridView.builder(
              itemCount: _image.length+1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context,index){
                return index == 0?Center(child: IconButton(
                  onPressed: () =>!uploading ? chooseImage(): null,icon: const Icon(Icons.add),))
                    :Container(margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(_image[index-1]),fit: BoxFit.cover)),
                );
              }),
          uploading?Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [const Text('uploading..',style: TextStyle(fontSize: 20),),
         const SizedBox(height: 10,),
          CircularProgressIndicator(value: val,valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),)
          ],

          )):Container()
    ]));


  }


    }


