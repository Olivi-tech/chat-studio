import 'package:flutter/material.dart';
import 'package:studio_chat/api/api.dart';

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
              Icon(
                Icons.done_all_outlined,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text(widget.messagesModel.read),
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
              child: Text(
                widget.messagesModel.msg,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendMessage({required double width, required double height}) {
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
              child: Text(
                widget.messagesModel.msg,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Row(
            children: [
              Text(widget.messagesModel.read),
              SizedBox(width: 10),
              Icon(
                Icons.done_all_outlined,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
