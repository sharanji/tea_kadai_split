import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tea_kadai_split/firebase_options.dart';
import 'package:tea_kadai_split/presentation/controllers/auth_controller.dart';
import 'package:tea_kadai_split/presentation/controllers/transaction_controller.dart';
import 'package:tea_kadai_split/presentation/ui/auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/ui/dashboard/homescreen.dart';
import 'package:tea_kadai_split/theme/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tea Kadai Split',
      theme: MyTheme('KumbhSans').lightTheme,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            Get.put(TransactionController());
            Get.put(AuthController());
            if (snapshot.hasData && snapshot.data!.email != null) {
              return const HomeScreen();
            }
            return const LoginScreen();
          }),
    );
  }
}
