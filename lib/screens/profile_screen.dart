import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/auth/auth_provider.dart';
import 'package:studio_chat/helper/show_snack_bar.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  static final _formKey = GlobalKey<FormState>();
  static String? _image;
  @override
  Widget build(BuildContext context) {
    log(_image == null ? 'null' : 'image is not null');
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    log('width: $width. height: $height');
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          _image = null;
          return Future.value(true);
        },
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 30),
            child: SingleChildScrollView(
              child: SizedBox(
                height: height,
                width: width,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(height),
                                child: Image.file(
                                  File(_image!),
                                  width: height * 0.28,
                                  height: height * 0.28,
                                  fit: BoxFit.cover,
                                ))
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(height * 0.1),
                                child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(APIs.me.image),
                                    radius: 100),
                              ),
                        Positioned(
                          top: height > 750 ? height * 0.15 : height * 0.2,
                          left: width * 0.3,
                          child: MaterialButton(
                              color: Colors.white,
                              elevation: 2,
                              shape: CircleBorder(),
                              child: Icon(Icons.edit_sharp),
                              onPressed: () => _showBottomSheet(
                                  context: context,
                                  height: height,
                                  width: width)),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Text(
                      APIs.me.email,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: height * 0.03),
                    Container(
                        height: height * 0.2,
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: APIs.me.name,
                                  onSaved: (newValue) =>
                                      APIs.me.name = newValue!,
                                  // onChanged: (value) => widget.name = value,
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'Required Field',
                                  decoration: InputDecoration(
                                      hintText: 'Name',
                                      labelText: 'Your Name',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                                SizedBox(height: 15),
                                TextFormField(
                                  initialValue: APIs.me.about,
                                  onSaved: (newValue) =>
                                      APIs.me.about = newValue!,
                                  // onChanged: (value) => about = value,
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'Required Field',
                                  decoration: InputDecoration(
                                      hintText: 'About',
                                      labelText: 'Your About',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                )
                              ],
                            ))),
                    Container(
                        height: height * 0.1,
                        child: SizedBox(
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  minimumSize: Size(
                                    width * 0.5,
                                    height * 0.06,
                                  )),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  await APIs.updateUser().then(
                                    (value) {
                                      SnackBarHelper.showSnack(
                                          context: context,
                                          msg: 'User Updated Successfully');
                                    },
                                  );
                                }
                              },
                              child: Text('Update'),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: Text('LogOut'),
            backgroundColor: Colors.redAccent.shade200,
            icon: Icon(Icons.login_outlined),
            onPressed: () async {
              final status = await AuthProvider.logOut();
              SnackBarHelper.showSnack(context: context, msg: status);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  _showBottomSheet(
      {required double height,
      required double width,
      required BuildContext context}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (BuildContext context) => ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.03, horizontal: width * 0.02),
              children: [
                Text(
                  'Select image',
                  textAlign: TextAlign.center,
                  textScaleFactor: 2,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      shape: CircleBorder(),
                      elevation: 2,
                      color: Colors.white,
                      child: IconButton(
                        iconSize: 50,
                        icon: Icon(Icons.file_present),
                        onPressed: () async {
                          final ImagePicker _picker = ImagePicker();
                          // Pick an image
                          final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          if (image != null) {
                            log(image.path);
                            _image = image.path;
                            Navigator.pop(context);
                            SnackBarHelper.showSnack(
                                context: context, msg: 'Image Being updated');
                            await APIs.updateProfilePic(file: File(_image!));
                            setState(() {});
                          } else {
                            SnackBarHelper.showSnack(
                                context: context, msg: 'No Image found');
                          }
                        },
                        color: Colors.blueAccent,
                        alignment: Alignment.center,
                      ),
                    ),
                    Card(
                      shape: CircleBorder(),
                      elevation: 2,
                      color: Colors.white,
                      child: IconButton(
                        iconSize: 50,
                        icon: Icon(Icons.photo_camera),
                        onPressed: () async {
                          final ImagePicker _picker = ImagePicker();
                          // Pick an image
                          final XFile? image = await _picker.pickImage(
                              source: ImageSource.camera, imageQuality: 80);
                          if (image != null) {
                            log(image.path);
                            _image = image.path;
                            Navigator.pop(context);
                            SnackBarHelper.showSnack(
                                context: context, msg: 'Image Being updated');
                            await APIs.updateProfilePic(file: File(_image!));
                            setState(() {});
                          } else {
                            SnackBarHelper.showSnack(
                                context: context, msg: 'Image Not Clicked');
                          }
                        },
                        color: Colors.blueAccent,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                )
              ],
            ));
  }
}
