import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/helper/date_time_format.dart';
import 'package:studio_chat/helper/show_snack_bar.dart';

import '../models/messages_model.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.messagesModel});
  final MessagesModel messagesModel;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool get _isCurrenUser {
    if (widget.messagesModel.fromId == APIs.user!.uid) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onLongPress: () {
        _openBottomSheet(context: context, height: height, width: width);
      },
      child: _isCurrenUser
          ? _myMessage(height: height, width: width)
          : _friendMessage(height: height, width: width),
    );
  }

  Widget _myMessage({required double width, required double height}) {
    return Padding(
      padding: EdgeInsets.only(
          top: height * 0.02,
          right: height * 0.02,
          left: width * 0.08,
          bottom: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.messagesModel.read.isNotEmpty)
                Icon(
                  Icons.done_all_outlined,
                  color: Colors.blue,
                ),
              SizedBox(width: 10),
              Text(DateTimeFormat.formatTime(time: widget.messagesModel.sent)),
            ],
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(
                top: height * 0.01,
                left: height * 0.01,
                right: height * 0.01,
                bottom: height * 0.01,
              ),
              margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04),
              decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15)),
                  border: Border.all(color: Colors.blue)),
              child: widget.messagesModel.type == Type.text
                  ? Text(
                      widget.messagesModel.msg,
                      style: TextStyle(fontSize: 16),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.messagesModel.msg,
                        errorWidget: (context, url, error) =>
                            Icon(Icons.image_not_supported),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendMessage({required double width, required double height}) {
    if (widget.messagesModel.read.isEmpty) {
      APIs.updateReadStatusMessage(message: widget.messagesModel);
    }
    return Padding(
      padding: EdgeInsets.only(
          top: height * 0.01,
          right: height * 0.03,
          left: width * 0.03,
          bottom: height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.only(
                top: height * 0.01,
                left: height * 0.01,
                right: height * 0.01,
                bottom: height * 0.01,
              ),
              margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04),
              decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                  border: Border.all(color: Colors.blue)),
              child: widget.messagesModel.type == Type.text
                  ? Text(
                      widget.messagesModel.msg,
                      style: TextStyle(fontSize: 16),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.messagesModel.msg,
                        errorWidget: (context, url, error) =>
                            Icon(Icons.image_not_supported, size: 50),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Row(
            children: [
              Text(DateTimeFormat.formatTime(time: widget.messagesModel.sent)),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  _openBottomSheet(
      {required BuildContext context,
      required double height,
      required double width}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      builder: (context) {
        return Container(
          child: ListView(
            shrinkWrap: true,
            children: [
              Divider(
                color: Colors.grey,
                thickness: 3,
                endIndent: width * 0.4,
                indent: width * 0.4,
              ),
              widget.messagesModel.type == Type.text
                  ? _item(
                      icon: Icon(
                        Icons.copy_all_rounded,
                        color: Colors.blue,
                      ),
                      msg: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.messagesModel.msg));
                        Navigator.pop(context);
                        SnackBarHelper.showSnack(
                            context: context, msg: 'Text Copied');
                      },
                    )
                  : _item(
                      icon: Icon(
                        Icons.download_sharp,
                        color: Colors.blue,
                      ),
                      msg: 'Download Image',
                      onTap: () {
                        try {
                          GallerySaver.saveImage(widget.messagesModel.msg,
                                  albumName: 'Studio Chat')
                              .then((value) {
                            if (value != null && value) {
                              Navigator.pop(context);
                              SnackBarHelper.showSnack(
                                  context: context,
                                  durationSeconds: 1,
                                  msg: 'Image Saved Successfully');
                            }
                          });
                        } catch (e) {
                          SnackBarHelper.showSnack(
                              context: context,
                              durationSeconds: 1,
                              msg: 'Error While Saving Image');
                        }
                      },
                    ),
              if (_isCurrenUser)
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                  endIndent: width * 0.05,
                  indent: width * 0.05,
                ),
              if (_isCurrenUser && widget.messagesModel.type == Type.text)
                _item(
                  icon: Icon(
                    Icons.mode_edit_outline_outlined,
                    color: Colors.blue,
                  ),
                  msg: 'Edit Message',
                  onTap: () {
                    Navigator.pop(context);
                    _showAlertDialog(context: context);
                  },
                ),
              if (_isCurrenUser)
                _item(
                  icon: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                  msg: widget.messagesModel.type == Type.text
                      ? 'Delete Message'
                      : 'Delete Image',
                  onTap: () async {
                    await APIs.deleteMessage(message: widget.messagesModel);
                    Navigator.pop(context);
                  },
                ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                endIndent: width * 0.05,
                indent: width * 0.05,
              ),
              _item(
                icon: Icon(
                  Icons.visibility_outlined,
                  color: Colors.blue,
                ),
                msg:
                    'Sent at: ${DateTimeFormat.getSentTime(time: widget.messagesModel.sent)}',
                onTap: () {},
              ),
              _item(
                icon: Icon(
                  Icons.visibility_outlined,
                  color: Colors.green,
                ),
                msg: widget.messagesModel.read.isEmpty
                    ? 'Read at: No seen yet'
                    : 'Read at: ${DateTimeFormat.getSentTime(time: widget.messagesModel.read)}',
                onTap: () {},
              ),
              Divider(
                color: Colors.grey,
                thickness: 3,
                endIndent: width * 0.4,
                indent: width * 0.4,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _item(
      {required Icon icon, required String msg, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 3),
        child: Row(
          children: [
            icon,
            SizedBox(
              width: 25,
            ),
            Text(
              msg,
              style: TextStyle(letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future _showAlertDialog({required BuildContext context}) {
    String updatedMsg = widget.messagesModel.msg;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          title: Row(
            children: [
              Icon(
                Icons.message_outlined,
                color: Colors.blue,
              ),
              SizedBox(
                width: 20,
              ),
              Text('Update Message')
            ],
          ),
          content: TextFormField(
            initialValue: widget.messagesModel.msg,
            onChanged: (value) => updatedMsg = value,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              onPressed: () async {
                if (updatedMsg.trim().isNotEmpty) {
                  Navigator.pop(context);
                  FocusScope.of(context).unfocus();
                  await APIs.updateMessage(
                      updatedMsg: updatedMsg.trim(),
                      message: widget.messagesModel);
                } else if (updatedMsg.trim().isEmpty) {
                  SnackBarHelper.showSnack(
                      context: context, msg: 'Message can\'t be empty');
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
