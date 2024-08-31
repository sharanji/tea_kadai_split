import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Rx<User>? currentUser;
  RxString userName = "".obs;
  RxString photoUrl = "".obs;
  RxInt navIndex = 0.obs;
  RxMap userDetails = {}.obs;
  RxDouble totalCreditBalance = 0.0.obs;
  @override
  void onReady() {
    super.onReady();
    auth.authStateChanges().listen((user) async {
      if (user != null) {
        currentUser = user.obs;

        getUserData();
        initFirebase();
      }
    });
  }

  initFirebase() async {
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance.collection('users').doc(currentUser!.value.uid).update({
      'notificationToken': fcmToken,
    });
    // await initializeWorkManager(FirebaseAuth.instance.currentUser!.uid);

    print(fcmToken);
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> getUserData() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await fireStore.collection('users').doc(currentUser!.value.uid).get();
      userName.value = userDoc['name'];
      photoUrl.value = userDoc['photoUrl'];
      userDetails.value = userDoc.data()! as Map;
      totalCreditBalance.value = userDoc['credit_wallet'].values
      .where((value) => value is num) // Ensure the value is a number (int or double)
      .fold(0.0, (sum, value) => sum + (value as num).toDouble());
     
    }
  }
}
