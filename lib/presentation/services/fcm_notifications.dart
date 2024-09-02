import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationSendServices {
  static Future sendFcmNotification(groupId) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_SERVER_KEY',
    };
    var notificationUrl = 'https://fcm.googleapis.com/v1/projects/myproject-b5ae1/messages:send';

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get()
        .then((groupDetails) {

      List memebers = groupDetails.data()!['members'];
      for (var i = 0; i < memebers.length; i++) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(memebers[i])
            .get()
            .then((usrInfo) async {
          Map payload = {
            'to': usrInfo.data()!['notification_token'],
            'notification': {
              'title': "New Group Transaction Opened",
              'body': "Click Notification to Contribute",
            },
            'priority': 'high',
          };

          var response = await http.post(
            Uri.parse(notificationUrl),
            headers: headers,
            body: jsonEncode(payload),
          );

          if (response.statusCode != 200) {
            Get.snackbar('Failed', "Something went wrong");
            return;
          }
        });
      }
    });

    Get.snackbar('Notified', 'Notification sent to group memebers');
  }
}
