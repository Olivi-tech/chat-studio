import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:studio_chat/helper/date_time_format.dart';
import 'package:studio_chat/models/chat_user.dart';

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: width * 0.2, right: width * 0.2, top: height * 0.05),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height * 0.2),
                child: CachedNetworkImage(
                  imageUrl: user.image,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error_outline_sharp),
                  fit: BoxFit.cover,
                  width: height * 0.2,
                  height: height * 0.2,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
            Text(user.email),
            SizedBox(height: height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'About: ',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                Text(
                  user.about,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Joined: ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          Text(
            DateTimeFormat.getLastMessageTime(user.createdAt),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
