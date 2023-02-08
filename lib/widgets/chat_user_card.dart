import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/helper/date_time_format.dart';
import 'package:studio_chat/main.dart';
import 'package:studio_chat/models/chat_user.dart';
import 'package:studio_chat/models/messages_model.dart';
import 'package:studio_chat/screens/chatting_screen.dart';
import 'package:studio_chat/widgets/profile_dialog.dart';

class ChatUserCard extends StatelessWidget {
  const ChatUserCard({super.key, required this.user});
  final ChatUser user;
  static MessagesModel? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(
        left: mq.width * 0.03,
        right: mq.width * 0.03,
        top: mq.height * 0.015,
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
            leading: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (context) => ProfileDialog(user: user),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.1),
                child: CachedNetworkImage(
                  imageUrl: user.image,
                  fit: BoxFit.cover,
                  width: mq.height <= 740 ? mq.height * 0.07 : mq.height * 0.06,
                  height:
                      mq.height <= 740 ? mq.height * 0.07 : mq.height * 0.06,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.person_2_outlined),
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            subtitle: Text(
              _message != null
                  ? _message!.type == Type.text
                      ? _message!.msg
                      : 'image'
                  : user.about,
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
