import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';

class TransactionController extends GetxController {
  RxInt totalPayable = 0.obs;
  RxInt totalParticipants = 0.obs;

  Widget currentTransactions(groupId, transactionRefId) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('transactions')
            .doc(transactionRefId)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const CupertinoActivityIndicator();
          }
          List<dynamic> transaction = (snapshot.data!.data() as Map)['participants'];
          totalParticipants += 1;
          return Column(
            children: [
              for (int i = 0; i < transaction.length; i++) transactionMember(transaction[i]),
            ],
          );
        });
  }

  Widget transactionMember(transaction) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(transaction['user_id']).get(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const CupertinoActivityIndicator();
        }

        Map userInfo = snapshot.data!.data() as Map;
        totalPayable += int.parse(transaction['amount'].toString());

        return ListTile(
          leading: CircleAvatar(
            foregroundImage: NetworkImage(userInfo['photoUrl']),
          ),
          title: Text(userInfo['name']),
          trailing: Text(
            '₹ ${transaction['amount']}',
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }
}
