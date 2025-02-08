import 'dart:developer';

import 'package:chatapp/Pages/createProfile.dart';
import 'package:chatapp/Pages/homePage.dart';
import 'package:chatapp/Pages/loginPage.dart';
import 'package:chatapp/Pages/signUpPage.dart';
import 'package:chatapp/models/firebase_helper.dart';
import 'package:chatapp/models/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;

  if(currentUser!=null){
    log("data Fetched");
    //Already Logged IN

    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel!=null){
      log("data Fetched....");
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }else{
      log("data Fetched????????");
      runApp(MyApp());
    }

  }else{
    log("data not Fetched");
    //Login Page
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loginpage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
