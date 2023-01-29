import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:studio_chat/models/chatting_users_model.dart';
import 'package:studio_chat/models/messages_model.dart';

class APIs {
  static User? get user => FirebaseAuth.instance.currentUser;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static late ChattingUsersModel me;
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
    final chatUser = ChattingUsersModel(
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
        me = ChattingUsersModel.fromJson(user.data()!);
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
      {required ChattingUsersModel usersModel}) {
    return FirebaseFirestore.instance
        .collection('chats/${getChatId(usersModel.id)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(
      {required ChattingUsersModel usersModel, required String msg}) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    MessagesModel msgModel = MessagesModel(
        fromId: user!.uid,
        toId: usersModel.id,
        msg: msg,
        read: '',
        sent: time,
        type: Type.text);
    final ref = FirebaseFirestore.instance
        .collection('chats/${getChatId(usersModel.id)}/messages/');
    await ref.doc(time).set(msgModel.toJson());
  }

  static Future<void> updateReadStatusMessage(
      {required MessagesModel message}) async {
    FirebaseFirestore.instance
        .collection('chats/${getChatId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      {required ChattingUsersModel user}) {
    return FirebaseFirestore.instance
        .collection('chats/${getChatId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
