import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:studio_chat/models/chat_user.dart';
import 'package:studio_chat/models/messages_model.dart';
import 'package:http/http.dart';

class APIs {
  static User? get user => FirebaseAuth.instance.currentUser;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static final FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  static late ChatUser me;
  static Future<bool> userExists() async {
    return (await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get())
        .exists;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', isNotEqualTo: user!.uid)
        .snapshots();
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        email: user!.email!,
        name: user!.displayName!,
        about: 'I am about',
        createdAt: time,
        image: user!.photoURL!,
        id: user!.uid,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set(chatUser.toJson());
  }

  static Future<void> getSelfInfo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        updateLastActive(isOnline: true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> updateUser() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePic({required File file}) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('ProfilePics/${user!.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
      (p0) {
        log('Data Transferred = ${p0.bytesTransferred / 1000} bytes');
      },
    );
    me.image = await ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'image': me.image});
  }

  static String getChatId(String friendId) {
    return user!.uid.hashCode <= friendId.hashCode
        ? '${user!.uid}_$friendId'
        : '${friendId}_${user!.uid}';
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      {required ChatUser usersModel}) {
    return FirebaseFirestore.instance
        .collection('chats/${getChatId(usersModel.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      {required ChatUser usersModel,
      required String msg,
      required Type type}) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    MessagesModel msgModel = MessagesModel(
        fromId: user!.uid,
        toId: usersModel.id,
        msg: msg,
        read: '',
        sent: time,
        type: type);
    final ref = FirebaseFirestore.instance
        .collection('chats/${getChatId(usersModel.id)}/messages/');
    await ref.doc(time).set(msgModel.toJson()).then((value) async =>
        await sendPushNotification(
            user: usersModel, msg: type == Type.text ? msg : 'image'));
  }

  static Future<void> updateReadStatusMessage(
      {required MessagesModel message}) async {
    FirebaseFirestore.instance
        .collection('chats/${getChatId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      {required ChatUser user}) {
    return FirebaseFirestore.instance
        .collection('chats/${getChatId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(
      {required File file,
      required ChatUser user,
      required BuildContext context}) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getChatId(user.id)}${DateTime.now().millisecondsSinceEpoch}.$ext');
    // SnackBarHelper.showSnack(context: context, msg: 'Uploading Image');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    final imgUrl = await ref.getDownloadURL();
    await sendMessage(msg: imgUrl, usersModel: user, type: Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      {required ChatUser chatUser}) {
    log(chatUser.toString());
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateLastActive({required bool isOnline}) async {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      ChatUser.keyIsOnline: isOnline,
      ChatUser.keyLastActive: DateTime.now().millisecondsSinceEpoch.toString(),
      ChatUser.keyPushToken: me.pushToken,
    });
  }

  static Future<void> getFirebaseMessagingToken() async {
    final status = await fMessaging.requestPermission();
    log('request status : ${status.authorizationStatus.toString()}');
    await fMessaging.getToken().then(
      (t) {
        if (t != null) {
          me.pushToken = t;
        }
      },
    );
    log('push token: ${me.pushToken}');
  }

  static Future<void> sendPushNotification(
      {required ChatUser user, required String msg}) async {
    try {
      final url = 'https://fcm.googleapis.com/fcm/send';
      final body = {
        'to': user.pushToken,
        'notification': {
          'title': user.name,
          'body': msg,
          'android_channel_id': 'chats',
          'data': {
            'user data': 'user data: ${me.id}',
          },
        }
      };
      // Response res =
      await post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'key=AAAAcw1ACAQ:APA91bEIRezFQsc-SQupbSDjYD3lTfz1aSu807jq5RuwjBnXssnTzTbtMZphTvJga0Vo2Ib17PSO_Wa21_Ru2zPY8i7Uutgsczi9W7ZSb-iz71blB3oNzY9V2yYbpOmRx_LyuLpjusYq'
        },
      );
      // log('${res.statusCode}');
      // log('push notification sent');
    } catch (e) {
      log('$e');
    }
  }
}
