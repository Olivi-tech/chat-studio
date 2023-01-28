import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/models/chatting_users_model.dart';
import 'package:studio_chat/models/messages_model.dart';
import 'package:studio_chat/widgets/message_card.dart';

class ChattingScreen extends StatelessWidget {
  const ChattingScreen({super.key, required this.user});
  final ChattingUsersModel user;
  static List<MessagesModel> _list = [];
  static final TextEditingController _msgController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // log(user.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context: context, height: height, width: width),
        body: Column(children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: APIs.getMessages(usersModel: user),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
                      snapshot.data!.docs;
                  _list = data.map((e) {
                    return MessagesModel.fromJson(e.data());
                  }).toList();
                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      itemCount: _list.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return MessageCard(
                          messagesModel: _list[index],
                        );
                      },
                    );
                  } else if (_list.isEmpty) {
                    return Center(
                      child: Text('Say Hi 👋'),
                    );
                  }
                } else if (snapshot.connectionState ==
                        ConnectionState.waiting ||
                    snapshot.hasError) {
                  log('waiting for data');
                  return Center(child: CircularProgressIndicator());
                }
                return SizedBox();
              },
            ),
          ),
          _inPut(),
        ]),
      ),
    );
  }

  AppBar _appBar(
      {required BuildContext context,
      required double height,
      required double width}) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: height * 0.035,
            backgroundImage: NetworkImage(user.image),
          ),
          SizedBox(width: width * 0.03),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text('1:45 PM'),
            ],
          )
        ],
      ),
    );
  }

  Widget _inPut() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(children: [
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                ),
                Expanded(
                  child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: _msgController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Type message ')),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.image,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
        MaterialButton(
          minWidth: 0,
          padding: EdgeInsets.only(top: 10, left: 10, right: 5, bottom: 10),
          shape: CircleBorder(),
          color: Colors.blue,
          onPressed: () {
            if (_msgController.text.isNotEmpty) {
              APIs.sendMessage(
                  msg: _msgController.text.trim(), usersModel: user);
              _msgController.clear();
            }
          },
          child: Icon(
            Icons.send,
            color: Colors.white,
            size: 28,
          ),
        ),
      ]),
    );
  }
}
