import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tea_kadai_split/presentation/ui/dashboard/homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              await signInWithGoogle();
              if (FirebaseAuth.instance.currentUser != null) {
                // await FirebaseMessaging.instance.requestPermission();
                var usercred = FirebaseAuth.instance.currentUser;
                // var notificationtoken  =FirebaseMessaging.instance.getToken();
                FirebaseFirestore.instance.collection('users').doc(usercred!.uid).set({
                  'name': usercred.displayName,
                  'email': usercred.email,
                  'photoUrl': usercred.photoURL,
                  // 'notification_token':notificationtoken,
                }).then((value) {
                  Get.toEnd(() => const HomeScreen());
                });
              }
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Google Login',
                style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      Get.snackbar(
        'Authentication Success',
        'Login Successfull',
      );
    } catch (e) {
      print("error at login :" + e.toString());
    }
  }
}
