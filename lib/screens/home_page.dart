import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/main.dart';
import 'package:studio_chat/models/chat_user.dart';
import 'package:studio_chat/provider/is_searching.dart';
import 'package:studio_chat/screens/profile_screen.dart';
import 'package:studio_chat/widgets/chat_user_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final TextEditingController _searchController;
  List<ChatUser> _usersList = [];
  List<ChatUser> _searchList = [];
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshots;
  // late bool _hasNewItemProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    APIs.getSelfInfo();
    snapshots = APIs.getUsers();
    _searchController = TextEditingController();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        await APIs.updateLastActive(
          isOnline: false,
        );
        break;
      case AppLifecycleState.resumed:
        await APIs.updateLastActive(
          isOnline: true,
        );
        break;
      case AppLifecycleState.inactive:
        await APIs.updateLastActive(
          isOnline: false,
        );
        break;
      case AppLifecycleState.detached:
        await APIs.updateLastActive(
          isOnline: false,
        );
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _searchingProvider =
        Provider.of<IsSearching>(context, listen: false).isSearching;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_searchingProvider) {
            Provider.of<IsSearching>(context, listen: false).isSearching =
                false;
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 1,
            title: Consumer<IsSearching>(
              builder: (context, value, child) => value.isSearching
                  ? TextFormField(
                      autofocus: true,
                      onChanged: (value) {
                        _searchList.clear();
                        for (var i in _usersList) {
                          if (i.name
                                  .trim()
                                  .toLowerCase()
                                  .contains(value.trim().toLowerCase()) ||
                              i.email
                                  .trim()
                                  .toLowerCase()
                                  .contains(value.trim().toLowerCase())) {
                            _searchList.add(i);
                          }
                        }

                        setState(() {});
                      },
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          hintText: 'By Fname or email',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          constraints:
                              BoxConstraints(maxHeight: mq.height * 0.06),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    )
                  : Text(widget.title),
            ),
            leading: const Icon(Icons.home_outlined),
            shadowColor: Colors.black,
            actions: [
              Consumer<IsSearching>(
                builder: (context, value, child) => IconButton(
                  icon: Icon(
                      value.isSearching ? Icons.cancel_outlined : Icons.search),
                  onPressed: () {
                    log('before tap : ${value.isSearching}');
                    value.isSearching = !value.isSearching;
                    log('after tap : ${value.isSearching}');
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_outlined),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfile(),
                      ));
                },
              ),
            ],
          ),
          body: StreamBuilder(
            stream: snapshots,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!.docs;
                _usersList =
                    data.map((e) => ChatUser.fromJson(e.data())).toList();
                if (_usersList.isNotEmpty) {
                  return ListView.builder(
                    itemCount: _searchingProvider
                        ? _searchList.length
                        : _usersList.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      log('_searchingProvider: $_searchingProvider');
                      log('users list : ${_usersList.length}');
                      log('_search list : ${_searchList.length}');
                      return ChatUserCard(
                        user: _searchingProvider
                            ? _searchList[index]
                            : _usersList[index],
                      );
                    },
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError) {
                return Center(child: CircularProgressIndicator());
              } else if (_usersList.isEmpty) {
                return Center(
                  child: Text('Converstion is not Initiated yet'),
                );
              }
              return SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
