import 'package:chatapp/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper{
  
  static Future<UserModel?> getUserModelById(String uid) async{
    UserModel? userModel;
    
    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection("User").doc(uid).get();

    if(docSnap.data() != null){
      userModel = UserModel.fromMap(docSnap.data() as Map<String,dynamic>);
    }
    return userModel;
  }
  
}