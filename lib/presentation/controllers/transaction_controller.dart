import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:tea_kadai_split/presentation/services/transaction_reports.dart';

class TransactionController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // FirebaseMessaging.instance
    //     .requestPermission(provisional: true)
    //     .then((value) async {
    //   final token = await FirebaseMessaging.instance.getToken();
    //   FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .update({'notification_token': token});
    // });
  }

  Future<List<Map>> getGroupTransactions(grpId) async {
    var members = await FirebaseFirestore.instance
        .collection('users')
        .where('credit_wallet.$grpId', isNull: false)
        .get()
        .then((value) => value.docs);

    List<Map> tallyTransactions =
        TransactionReports.getUsertallys(members, grpId);
    return tallyTransactions;
  }
}
