import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:studio_chat/api/api.dart';
import 'package:studio_chat/auth/auth_provider.dart';
import 'package:studio_chat/helper/show_snack_bar.dart';
import 'package:studio_chat/provider/sign_in_provider.dart';


import 'home_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    animateIcon(context: context);
    final double width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0, left: 8, right: 8),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned(
              top: height * 0.1,
              left: width * 0.25,
              width: width,
              height: height * 0.1,
              child: const Text(
                'Chat Studio',
                textScaleFactor: 2,
              ),
            ),
            Consumer<SignInProvider>(
              builder: (context, value, child) {
                log('IS animating ${value.isAnimate.toString()}');
                return AnimatedPositioned(
                  top: height * 0.15,
                  width: width,
                  left: value.isAnimate ? width * 0.0 : -width * 0.7,
                  height: height * 0.6,
                  duration: const Duration(seconds: 1),
                  child: SizedBox(child: Image.asset('assets/images/icon.png')),
                );
              },
            ),
            Consumer<SignInProvider>(
              builder: (context, value, child) {
                return Positioned(
                  top: height * 0.68,
                  width: width * 0.6,
                  child: Center(
                    child: Provider.of<SignInProvider>(context).isSigningIn
                        ? const CircularProgressIndicator()
                        : const SizedBox(),
                  ),
                );
              },
            ),
            Positioned(
              top: height * 0.75,
              width: width * 0.6,
              child: SignInButton(Buttons.Google, onPressed: () async {
                Provider.of<SignInProvider>(context, listen: false)
                    .isSigningIn = true;
                final String status = await AuthProvider.signInWithGoogle();
                SnackBarHelper.showSnack(context: context, msg: status);
                Provider.of<SignInProvider>(context, listen: false)
                    .isSigningIn = false;
                if (status == 'Success') {
                  if (await APIs.userExists()) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(
                            title: 'Chat Page',
                          ),
                        ));
                  } else {
                    await APIs.createUser();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(
                            title: 'Chat Page',
                          ),
                        ));
                  }
                }
              }, text: 'Sign In with Google'),
            ),
          ],
        ),
      ),
    );
  }

  animateIcon({required BuildContext context}) {
    Future.delayed(Duration(milliseconds: 500), () {
      Provider.of<SignInProvider>(context, listen: false).isAnimate = true;
    });
  }
}
