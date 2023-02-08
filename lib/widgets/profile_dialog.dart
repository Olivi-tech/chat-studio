import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studio_chat/main.dart';
import 'package:studio_chat/models/chat_user.dart';

import '../screens/view_profile.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SizedBox(
        width: mq.width * 0.4,
        height: mq.height * 0.45,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Text(
                  user.name,
                ),
              ),
              IconButton(
                padding: EdgeInsets.only(left: mq.width * 0.2),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ViewProfile(
                            user: user,
                          )));
                },
                splashColor: Colors.white,
                splashRadius: 10,
                icon: Icon(Icons.info_outline),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              imageUrl: user.image,
              fit: BoxFit.cover,
              width: mq.height * 0.3,
              height: mq.height * 0.3,
              errorWidget: (context, url, error) =>
                  Icon(Icons.person_2_outlined),
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(mq.width * 0.03, 10),
                  shape: StadiumBorder(),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
