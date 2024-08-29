import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/controllers/transaction_controller.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key, this.groupName = "", this.groupId = "", this.transactionRef});
  final String groupName;
  final String groupId;
  final DocumentReference? transactionRef;
  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  TransactionController transactionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            transactionController.currentTransactions(widget.groupId, widget.transactionRef!.id),
          ],
        ),
      ),
      bottomSheet: Obx(
        () => Container(
          height: 100,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Participants :',
                  ),
                  Text(transactionController.totalParticipants.toString()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Toal Payable :',
                  ),
                  Text(transactionController.totalPayable.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
