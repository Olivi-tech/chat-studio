import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/auth/auth_provider.dart';
import 'package:studio_chat/helper/show_snack_bar.dart';
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

class _HomePageState extends State<HomePage> {
  late final TextEditingController _searchController;
  List<ChatUser> _usersList = [];
  List<ChatUser> _searchList = [];
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshots;

  @override
  void initState() {
    super.initState();
    snapshots = APIs.getUsers();
    APIs.updateLastActive(isOnline: true);
    SystemChannels.lifecycle.setMessageHandler(
      (message) {
        if (message!.contains('resumed')) {
          APIs.updateLastActive(
            isOnline: true,
          );
        } else
          APIs.updateLastActive(isOnline: false);
        return Future.value(message);
      },
    );
    APIs.getSelfInfo();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    bool _searchingProvider =
        Provider.of<IsSearching>(context, listen: false).isSearching;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_searchingProvider) {
            Provider.of<IsSearching>(context, listen: false).isSearching =
                !Provider.of<IsSearching>(context, listen: false).isSearching;
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
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              i.email
                                  .toUpperCase()
                                  .contains(value.toLowerCase())) {
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
                          hintText: 'Search name',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          constraints: BoxConstraints(maxHeight: height * 0.06),
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
                    value.isSearching = !value.isSearching;
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
                      // log('user at home page ${_usersList.toString()}');
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
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final String status = await AuthProvider.logOut();
              SnackBarHelper.showSnack(context: context, msg: status);
            },
            child: const Icon(Icons.chat_outlined),
          ),
        ),
      ),
    );
  }
}
