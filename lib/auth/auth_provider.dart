import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider {
  static Future<String> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      return 'Success';
    } catch (e) {
      return 'Failed to login, Check Internet';
    }
  }

  static Future<String> logOut() async {
    try {
      await GoogleSignIn().disconnect().whenComplete(
        () async {
          await FirebaseAuth.instance.signOut();
        },
      );
      return 'Logged Out';
    } catch (e) {
      return 'Couldn\'t Logout, Check Internet';
    }
  }
}
