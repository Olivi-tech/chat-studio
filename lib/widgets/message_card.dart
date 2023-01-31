import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/helper/date_time_format.dart';

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
    return _isCurrenUser
        ? _myMessage(height: height, width: width)
        : _friendMessage(height: height, width: width);
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
}
