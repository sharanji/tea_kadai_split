import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:tea_kadai_split/presentation/services/transaction_reports.dart';

class TransactionController extends GetxController {
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
