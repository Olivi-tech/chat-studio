import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:provider/provider.dart';
import 'package:studio_chat/provider/emoji_provider.dart';
import 'package:studio_chat/provider/is_searching.dart';
import 'package:studio_chat/provider/progress_provider.dart';
import 'package:studio_chat/provider/sign_in_provider.dart';
import 'package:studio_chat/screens/status_page.dart';
import 'firebase_options.dart';

late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'for showing message notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log('result: $result');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SignInProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => IsSearching(),
        ),
        ChangeNotifierProvider(
          create: (context) => EmojiProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProgressProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              centerTitle: true,
              foregroundColor: Colors.black,
            )),
        home: const StatusPage(),
      ),
    );
  }
}
