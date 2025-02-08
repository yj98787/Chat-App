import 'package:chatapp/Pages/createProfile.dart';
import 'package:chatapp/models/ui_helper.dart';
import 'package:chatapp/models/userModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if(email==""||password==""||cPassword==""){
      UiHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields!");
      print("Please fill all the fields!");
    }
    else if(password != cPassword){
      UiHelper.showAlertDialog(context, "Password Mismatched", "The password you have entered do not match!");
      print("Password does not match!");
    }
    else{
      print("Sign Up successful!");
      signUp(email, password);
    }
  }

  void signUp(String email,String password) async {
    UserCredential? credential;

    UiHelper.showLoadingDialogs(context, "Creating new Account...");

    try{
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UiHelper.showAlertDialog(context, "An error occured", ex.code.toString());
      print(ex.code.toString());
    }

    if(credential!= null){
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );

      await FirebaseFirestore.instance.collection("User").doc(uid).set(newUser.toMap());
      print("New user Created!");
      Navigator.popUntil(context, (route)=>route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CompleteProfile(userModel: newUser, firebaseUser: credential!.user!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Chat App",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                      ),
                    ),

                    SizedBox(height: 10,),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                      ),
                    ),

                    SizedBox(height: 10,),

                    TextField(
                      controller: cPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                      ),
                    ),

                    SizedBox(height: 20,),
                    CupertinoButton(
                      onPressed: (){
                        checkValues();
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>CompleteProfile()));
                      },
                      child: Text("Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      ),
                      color: Theme.of(context).colorScheme.primary,
                    )
                  ],
                ),
              ),
            ),
          )
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have an account?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            CupertinoButton(child: Text("Log In"), onPressed: (){
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }
}
