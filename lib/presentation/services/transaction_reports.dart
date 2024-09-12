import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/ui/transaction/transaction_screen.dart';

import 'dart:math';

class TransactionReports {
  static int sortCoparator(a, b) => ((b['credit'] * 1.0) - (a['credit'] * 1.0)).toInt();

  static Future openNewTransAction(groupId, groupInfo) async {
    // check for pending transactions
    var pendings = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('transactions')
        .where('status', isEqualTo: false)
        .get();

    if (pendings.docs.isNotEmpty) {
      Get.snackbar(
        'Transaction Running',
        "Your Group have a pending transaction",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    var transactionId = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('transactions')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'status': false,
      'initaited': FirebaseAuth.instance.currentUser!.uid,
      'payable_amount': 0,
      'participants': {}
    });

    Get.back();
    Get.to(
      () => TransactionScreen(
          groupName: groupInfo['name'], groupId: groupId, transactionRefid: transactionId.id),
    );
  }

  static List monthlyGroupTally(List docs) {
    Map tally = {};
    docs.sort((a, b) {
      DateTime aTime = a.data()['timestamp'].toDate();
      DateTime bTime = b.data()['timestamp'].toDate();

      return aTime.compareTo(bTime);
    });
    DateTime startTime = docs[0].data()['timestamp'].toDate();
    DateTime endTime = docs.last.data()['timestamp'].toDate();

    for (int i = 0; i < docs.length; i++) {
      Map transactionData = docs[i].data();
      List<MapEntry> participants = (transactionData['participants'] as Map).entries.toList();

      for (var j = 0; j < participants.length; j++) {
        if (tally.containsKey(participants[j].key)) {
          tally[participants[j].key] += participants[j].value;
        } else {
          tally[participants[j].key] = participants[j].value;
        }
      }
      if (tally.containsKey(transactionData['initaited'])) {
        tally[transactionData['initaited']] -= transactionData['payable_amount'];
      }
    }

    return [tally, startTime, endTime];
  }

  static addMyBill(groupId, transactionRefid, double billAmount) async {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('transactions')
        .doc(transactionRefid)
        .update({
      'payable_amount': FieldValue.increment(billAmount),
      'participants.${FirebaseAuth.instance.currentUser!.uid}': billAmount,
    });
  }

  static closeBill(groupId, transactionRefid) async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('transactions')
        .doc(transactionRefid)
        .update({'status': true});

    var transactions = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('transactions')
        .doc(transactionRefid)
        .get();
    List<MapEntry> participants = transactions.data()!['participants']!.entries.toList();
    String initedUserId = transactions.data()!['initaited'];

    for (var i = 0; i < participants.length; i++) {
      if (participants[i].key == initedUserId) {
        FirebaseFirestore.instance.collection('users').doc(participants[i].key).update(
          {
            'credit_wallet.$groupId': FieldValue.increment(
                -(transactions.data()!['payable_amount'] - participants[i].value)),
          },
        );
        continue;
      }

      FirebaseFirestore.instance.collection('users').doc(participants[i].key).update(
        {
          'credit_wallet.$groupId': FieldValue.increment(participants[i].value),
        },
      );
    }
  }

  static List<Map> getUserTallys(List<QueryDocumentSnapshot> creditWallets, String groupId) {
    List<Map> credits = [];
    List<Map> debits = [];

    for (var doc in creditWallets) {
      Map currentUser = doc.data() as Map;
      double creditAmount = currentUser['credit_wallet'][groupId] * 1.0;

      if (creditAmount != 0) {
        Map transactionMap = {
          "id": doc.id,
          "name": currentUser['name'],
          "credit": creditAmount,
        };
        (creditAmount > 0 ? credits : debits).add(transactionMap);
      }
    }

    credits.sort((a, b) => b['credit'].compareTo(a['credit']));
    debits.sort((a, b) => a['credit'].compareTo(b['credit']));

    int i = 0;
    int j = 0;
    List<Map> transactions = [];

    while (i < credits.length && j < debits.length) {
      double credit = credits[i]['credit'];
      double debit = debits[j]['credit'];
      double amount = min(credit.abs(), debit.abs());

      transactions.add({
        'pays': credits[i]['name'],
        'receives': debits[j]['name'],
        'receiver_id': debits[j]['id'],
        'amount': amount,
        'payer_id': credits[i]['id'],
        'desc': '${credits[i]['name']} pays ₹ $amount to ${debits[j]['name']}',
      });

      credits[i]['credit'] -= amount;
      debits[j]['credit'] += amount;

      if (credits[i]['credit'] == 0) i++;
      if (debits[j]['credit'] == 0) j++;
    }

    print(credits);
    print(debits);

    return transactions;
  }
}
