import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/ui/transaction/reports.dart';

class GroupOptions {
  static List<GroupOption> options = [
    GroupOption(
        title: "See Report",
        description: "See the Tally reports",
        taphandler: (groupInfo, id) {
          Get.back();

          Get.to(
            GroupReports(
              groupName: groupInfo['name'],
              groupId: id,
            ),
          );
        }),
    GroupOption(
        title: "Add People",
        description: "Invite a person to this Group",
        taphandler: (groupInfo, id) {
          Get.back();
          String userEmail = "";
          Get.defaultDialog(
            title: 'Add Email Address',
            content: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Enter email"),
                contentPadding: EdgeInsets.all(0),
              ),
              keyboardType: TextInputType.emailAddress,
              onSaved: (val) {
                userEmail = val!;
              },
            ),
            onConfirm: () {
              FirebaseFirestore.instance.collection("invites").add({
                "groupName": groupInfo["name"],
                "groupImage": groupInfo["image"],
                "invitorName": FirebaseAuth.instance.currentUser!.displayName,
                "groupId": id,
                "userEmail": userEmail,
              });
              Get.back();
            },
            onCancel: Get.back,
          );
        }),
    GroupOption(
      title: "Exit Group",
      description: "Make Sure every credit is settled",
      taphandler: (groupInfo, id) {},
    ),
  ];
}

class GroupOption {
  String title;
  String description;
  Function taphandler;

  GroupOption({
    required this.title,
    required this.description,
    required this.taphandler,
  });
}
