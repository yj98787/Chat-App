import 'dart:developer';

import 'package:chatapp/main.dart';
import 'package:chatapp/models/chatRoomModel.dart';
import 'package:chatapp/models/messageModel.dart';
import 'package:chatapp/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatroomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatroomPage({super.key, required this.targetUser, required this.chatroom, required this.userModel, required this.firebaseUser});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {

  TextEditingController messagingController = TextEditingController();

  void sendMessage() async {
    String msg = messagingController.text.trim();
    messagingController.clear();

    if(msg != ""){
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        text: msg,
        createdon: Timestamp.fromDate(DateTime.now()),
        seen: false,
      );

      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").
      doc(newMessage.messageid).set(newMessage.toMap());

      log("message sent!");

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.targetUser.profilepic!),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(widget.targetUser.fullname.toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Container(
            child: Column(
              children: [
                Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).
                          collection("messages").orderBy("createdon", descending: true).snapshots(),
                          builder: (context,snapshot){
                            if(snapshot.connectionState == ConnectionState.active){
                              if(snapshot.hasData){
                                QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                                return ListView.builder(
                                  reverse: true,
                                    itemCount: dataSnapshot.docs.length,
                                    itemBuilder: (context,index){
                                      MessageModel currentMessage = MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String,dynamic>);

                                      return Row(
                                        mainAxisAlignment: (currentMessage.sender == widget.userModel.uid)?
                                        MainAxisAlignment.end : MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(vertical: 2),
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: (currentMessage.sender == widget.userModel.uid)?
                                                Colors.grey : Theme.of(context).colorScheme.primary,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                  currentMessage.text.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                          ),
                                        ],
                                      );
                                    }
                                );
                              }else if(snapshot.hasError){
                                return Center(
                                  child: Text("An error occured!, Please check your internet connection"),
                                );
                              }else{
                                return Center(
                                  child: Text("Say Hi👋 to your new friend"),
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
                Container(
                  color: Colors.grey[200],
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                          child: TextField(
                            controller: messagingController,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Message",
                            ),
                          ),
                      ),
                      IconButton(
                          onPressed: (){
                            sendMessage();
                          },
                          icon: Icon(Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
