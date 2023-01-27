import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studio_chat/models/chatting_users_model.dart';
import 'package:studio_chat/screens/chatting_screen.dart';


class ChatUserCard extends StatelessWidget {
  const ChatUserCard({super.key, required this.currentUserMap});

  final ChattingUsersModel currentUserMap;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // log('building card');
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
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ChattingScreen(
                    user: currentUserMap,
                  )));
        },
        title: Text(currentUserMap.name),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(currentUserMap.image),
          radius: 30,
        ),
        subtitle: Text(currentUserMap.about, maxLines: 1),
        trailing: Text(currentUserMap.createdAt),
      ),
    );
  }
}
