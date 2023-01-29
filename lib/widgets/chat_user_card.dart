import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/helper/date_time_format.dart';
import 'package:studio_chat/models/chatting_users_model.dart';
import 'package:studio_chat/models/messages_model.dart';
import 'package:studio_chat/screens/chatting_screen.dart';

class ChatUserCard extends StatelessWidget {
  const ChatUserCard({super.key, required this.user});
  final ChattingUsersModel user;
  static MessagesModel? _message;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(
        left: width * 0.03,
        right: width * 0.03,
        top: height * 0.015,
        // bottom: height * 0.01,
      ),
      color: Colors.blueGrey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: StreamBuilder(
        stream: APIs.getLastMessage(user: user),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => MessagesModel.fromJson(e.data())).toList() ?? [];
          if (list.isNotEmpty) _message = list[0];

          return ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: ChattingScreen(
                        user: user,
                      )));
            },
            title: Text(user.name),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.image),
              radius: 30,
            ),
            subtitle: Text(
              _message != null ? _message!.msg : user.about,
              maxLines: 1,
            ),
            trailing: _message == null
                ? null
                : _message!.read.isEmpty && _message!.fromId != APIs.user!.uid
                    ? Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadiusDirectional.circular(10)),
                      )
                    : Text(DateTimeFormat.getLastMessageTime(_message!.sent)),
          );
        },
      ),
    );
  }
}
