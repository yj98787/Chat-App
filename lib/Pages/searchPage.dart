import 'dart:developer';

import 'package:chatapp/Pages/chatRoomPage.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chatRoomModel.dart';
import 'package:chatapp/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";
  @override
  Widget build(BuildContext context) {

    TextEditingController searchController = TextEditingController();

    Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async{
      ChatRoomModel? chatroom;
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}",isEqualTo: true).
      where("participants.${targetUser.uid}",isEqualTo: true).get();

      if(snapshot.docs.length>0){
        //Chatroom already exist
        var docData = snapshot.docs[0].data();
        ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String,dynamic>);
        chatroom = existingChatroom;
        log("Chatroom already exist");
      }else{
        //create new one
        ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          createdon: Timestamp.fromDate(DateTime.now()),
          participants: {
            widget.userModel.uid.toString():true,
            targetUser.uid.toString():true,
          }
        );
        await FirebaseFirestore.instance.collection("chatrooms").doc(newChatroom.chatroomid).set(newChatroom.toMap());
        log("chatroom created");
        chatroom = newChatroom;
      }
      return chatroom;
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Search",
        style: TextStyle(
          color: Colors.white,
        ),
        ),
      ),
      body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    hintText: "flutteruser11@gmail.com",
                  ),
                ),
                SizedBox(height: 20.0,),
                CupertinoButton(
                  onPressed: (){
                    setState(() {
                      searchQuery = searchController.text.trim().toLowerCase();
                    });
                  },
                    child: Text("Search",
                    style: TextStyle(
                      color: Colors.white
                    ),
                    ),
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 20.0,),

                StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("User").where("email", isEqualTo: searchQuery).where("email",isNotEqualTo: widget.userModel.email).snapshots(),
                    builder: (context,snapshot){
                      if(snapshot.connectionState == ConnectionState.active){
                        if(snapshot.hasData){
                          QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                          log("Active Connection");
                          log(dataSnapshot.docs.length.toString());

                          if(dataSnapshot.docs.length > 0){
                            Map<String,dynamic> userMap = dataSnapshot.docs[0].data() as Map<String,dynamic>;

                            UserModel searchedUser = UserModel.fromMap(userMap);
                            log("Length greater than 0");

                            return ListTile(
                              onTap: ()async{
                               ChatRoomModel? chatroomModel = await getChatroomModel(searchedUser);
                               if(chatroomModel!=null){
                                 Navigator.pop(context);
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatroomPage(
                                     targetUser: searchedUser,
                                     chatroom: chatroomModel,
                                     userModel: widget.userModel,
                                     firebaseUser: widget.firebaseUser)));
                               }
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(searchedUser.profilepic!),
                              ),
                              title: Text(searchedUser.fullname!),
                              subtitle: Text(searchedUser.email!),
                              trailing: Icon(Icons.keyboard_arrow_right),
                            );
                          }else{
                            log("gdk");
                            return Text("No Data Found!");
                          }

                        }else if(snapshot.hasError){
                          return Text("An error occured!");
                        }else{
                          return Text("No Data Found!");
                        }
                      }else{
                        return CircularProgressIndicator();
                      }
                    },
                ),
              ],
            ),
          ),
      ),
    );
  }
}
