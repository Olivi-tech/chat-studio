import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/helper/show_snack_bar.dart';
import 'package:studio_chat/models/chatting_users_model.dart';
import 'package:studio_chat/models/messages_model.dart';
import 'package:studio_chat/provider/emoji_provider.dart';
import 'package:studio_chat/provider/progress_provider.dart';
import 'package:studio_chat/screens/view_profile.dart';
import 'package:studio_chat/widgets/message_card.dart';

class ChattingScreen extends StatelessWidget {
  const ChattingScreen({super.key, required this.user});
  final ChattingUsersModel user;
  static List<MessagesModel> _list = [];
  static final TextEditingController _msgController = TextEditingController();
  // static late bool ;
  @override
  Widget build(BuildContext context) {
    // _isDisplayingEmoji =
    //     Provider.of<EmojiProvider>(context, listen: false).isShowingEmoji;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        log('_isDisplayingEmoji : ${Provider.of<EmojiProvider>(context, listen: false).isShowingEmoji}');
        if (Provider.of<EmojiProvider>(context, listen: false).isShowingEmoji) {
          Provider.of<EmojiProvider>(context, listen: false).isShowingEmoji =
              !Provider.of<EmojiProvider>(context, listen: false)
                  .isShowingEmoji;
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(width, 56),
              child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: ViewProfile(
                          user: user,
                        ),
                      )),
                  child:
                      _appBar(context: context, height: height, width: width)),
            ),
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
                          reverse: true,
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
              Consumer<ProgressProvider>(
                builder: (context, value, child) => value.isUploading
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: width * 0.15, bottom: height * 0.01),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : SizedBox(),
              ),
              _inPut(context: context),
              Consumer<EmojiProvider>(
                  builder: (BuildContext context, value, child) =>
                      value.isShowingEmoji
                          ? SizedBox(
                              height: height * 0.35,
                              child: EmojiPicker(
                                textEditingController: _msgController,
                                config: Config(
                                    columns: 8,
                                    bgColor: Colors.white,
                                    emojiSizeMax: 30),
                              ),
                            )
                          : SizedBox(width: 0, height: 0)),
            ]),
          ),
        ),
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
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(height * 0.1),
            child: CachedNetworkImage(
              imageUrl: user.image,
              fit: BoxFit.cover,
              width: height * 0.055,
              height: height * 0.055,
              errorWidget: (context, url, error) =>
                  Icon(Icons.person_2_outlined),
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
            ),
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

  Widget _inPut({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 1),
      child: Row(children: [
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    // log('Before _isDisplayingEmoji : ${Provider.of<EmojiProvider>(context, listen: false).isShowingEmoji}');
                    Provider.of<EmojiProvider>(context, listen: false)
                            .isShowingEmoji =
                        !Provider.of<EmojiProvider>(context, listen: false)
                            .isShowingEmoji;
                    // log('after _isDisplayingEmoji : ${Provider.of<EmojiProvider>(context, listen: false).isShowingEmoji}');
                  },
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                ),
                Expanded(
                  child: TextField(
                      onTap: () {
                        if (Provider.of<EmojiProvider>(context, listen: false)
                                .isShowingEmoji ==
                            true)
                          Provider.of<EmojiProvider>(context, listen: false)
                              .isShowingEmoji = !Provider.of<EmojiProvider>(
                                  context,
                                  listen: false)
                              .isShowingEmoji;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: _msgController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Type message ')),
                ),
                IconButton(
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    // Pick an multiple images
                    final List<XFile?> images = await _picker.pickMultiImage();

                    if (images.isNotEmpty) {
                      for (var i in images) {
                        Provider.of<ProgressProvider>(context, listen: false)
                            .isUploading = true;
                        await APIs.sendChatImage(
                            file: File(i!.path), user: user, context: context);
                        Provider.of<ProgressProvider>(context, listen: false)
                            .isUploading = false;
                      }
                    }
                    SnackBarHelper.showSnack(
                        context: context, msg: 'No Image Selected');
                  },
                  icon: Icon(
                    Icons.image,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    // Pick an image
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (image != null) {
                      Provider.of<ProgressProvider>(context, listen: false)
                          .isUploading = true;
                      await APIs.sendChatImage(
                          file: File(image.path), user: user, context: context);
                      Provider.of<ProgressProvider>(context, listen: false)
                          .isUploading = false;
                    } else {
                      SnackBarHelper.showSnack(
                          context: context, msg: 'Image Not Selected');
                    }
                  },
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
                  msg: _msgController.text.trim(),
                  usersModel: user,
                  type: Type.text);
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
