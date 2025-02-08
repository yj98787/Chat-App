import 'dart:developer';
import 'dart:io';
import 'package:chatapp/Pages/homePage.dart';
import 'package:chatapp/models/ui_helper.dart';
import 'package:chatapp/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({super.key,required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if(pickedFile!=null){
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 25,
    );

    if(croppedImage!=null){
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOption(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
      title: Text("Upload Profile Picture"),
  content: Column(
    mainAxisSize: MainAxisSize.min,
  children: [
    ListTile(
      onTap: (){
        Navigator.pop(context);
        selectImage(ImageSource.gallery);
      },
      leading: Icon(Icons.photo_album),
      title: Text("Select from Gallery"),
    ),
    
    ListTile(
      onTap: (){
        Navigator.pop(context);
        selectImage(ImageSource.camera);
      },
      leading: Icon(Icons.camera_alt),
      title: Text("Capture Image"),
    )
  ],
  ),
      );
  });
}

  void checkValues(){
    String fullname = fullNameController.text.trim();

    if(fullname == ""||imageFile==null){
      UiHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields!");
      print("Please fill all the fields");
    }
    else{
      log("uploading data...");
      uploadData();
    }
  }

  void uploadData() async{
    UiHelper.showLoadingDialogs(context, "Uploading Image...");
    UploadTask uploadTask = FirebaseStorage.instance.ref("ProfilePictures").child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullNameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance.collection("User").doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value){
      log("Data uploaded");
      print("Data Uploaded");
      Navigator.popUntil(context, (route)=>route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Homepage(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: Text("Complete Profile",
        style: TextStyle(
          color: Colors.white,
        ),
        ),
      ),
      body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: ListView(
              children: [
                SizedBox(height: 20,),
                CupertinoButton(
                  onPressed: (){
                    showPhotoOption();
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: (imageFile!=null)?FileImage(imageFile!):null,
                    child: (imageFile == null)?Icon(Icons.person, size: 60):null,
                  ),
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: "Full Name"
                  ),
                ),
                SizedBox(height: 20,),
                CupertinoButton(
                    child: Text("Submit",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    ),
                    onPressed: (){
                      checkValues();
                    },
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          )
      ),
    );
  }
}
