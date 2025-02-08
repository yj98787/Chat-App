import 'package:chatapp/Pages/chatRoomPage.dart';
import 'package:chatapp/Pages/loginPage.dart';
import 'package:chatapp/Pages/searchPage.dart';
import 'package:chatapp/models/chatRoomModel.dart';
import 'package:chatapp/models/firebase_helper.dart';
import 'package:chatapp/models/ui_helper.dart';
import 'package:chatapp/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const Homepage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: ()async{
             await FirebaseAuth.instance.signOut();
             Navigator.popUntil(context, (route)=>route.isFirst);
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Loginpage()));
            },
              icon: Icon(Icons.exit_to_app),
            color: Colors.white,
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Chat App",
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
          child: Container(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).
                snapshots(),
                builder: (context,snapshot){
                  if(snapshot.connectionState == ConnectionState.active){
                    if(snapshot.hasData){
                      QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                      return ListView.builder(
                          itemCount: chatRoomSnapshot.docs.length,
                          itemBuilder: (context,index){

                            ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatRoomSnapshot.docs[index].data()
                            as Map<String,dynamic>);

                            Map<String,dynamic> participants = chatRoomModel.participants!;

                            List<String> participantsKeys = participants.keys.toList();
                            participantsKeys.remove(widget.userModel.uid);

                            return FutureBuilder(
                              future: FirebaseHelper.getUserModelById(participantsKeys[0]),
                              builder: (context,userData){
                                if(userData.connectionState == ConnectionState.done){
                                  if(userData.data != null){
                                    UserModel targetUser = userData.data as UserModel;

                                    return ListTile(
                                      onTap: (){
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context)=>ChatroomPage(
                                                targetUser: targetUser,
                                                chatroom: chatRoomModel,
                                                userModel: widget.userModel,
                                                firebaseUser: widget.firebaseUser,
                                            ))
                                        );
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(targetUser.profilepic!),
                                      ),
                                      title: Text(targetUser.fullname.toString()),
                                      subtitle: (chatRoomModel.lastMessage.toString()!="")?Text(chatRoomModel.lastMessage.toString()):
                                      Text("Say hi to your new friend!",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      ),
                                    );
                                  }else{
                                    return Container();
                                  }
                                }
                                else{
                                  return Container();
                                }
                              },
                            );
                          },
                      );
                    }
                    else if(snapshot.hasError){
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }else{
                      return Center(
                        child: Text("No Data Found!"),
                      );
                    }
                  }
                  else{
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
        },
        child: Icon(Icons.search,
        color: Colors.white,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
