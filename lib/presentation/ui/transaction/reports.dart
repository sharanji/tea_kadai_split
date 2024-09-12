import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tea_kadai_split/presentation/components/user_list_selectable.dart';
import 'package:tea_kadai_split/presentation/controllers/transaction_controller.dart';

class GroupReports extends StatefulWidget {
  const GroupReports({super.key, this.groupName = "", this.groupId = ""});

  final String groupName;
  final String groupId;

  @override
  State<GroupReports> createState() => _GroupReportsState();
}

class _GroupReportsState extends State<GroupReports> {
  TransactionController transactionController = Get.find();
  bool isSelectAll = false;
  List transactions = [];
  List selectableTrans = [];
  List selectedTrans = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor('#fe8953'),
        title: Text(widget.groupName),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // HexColor('#fd784c'),
                  HexColor('#fe8953'),
                  HexColor('#fd9957'),
                  HexColor('#fcc364'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (selectableTrans.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: toggleSelectAll,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: isSelectAll ? Colors.black : null,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: toggleSelectAll,
                            child: const Text(
                              'Select All',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                          if (selectedTrans.isNotEmpty)
                            isLoading
                                ? const CupertinoActivityIndicator()
                                : GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      for (var i = 0; i < selectedTrans.length; i++) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(selectedTrans[i]['receiver_id'])
                                            .update({
                                          'credit_wallet.${widget.groupId}':
                                              FieldValue.increment(selectedTrans[i]['amount'])
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(selectedTrans[i]['payer_id'])
                                            .update({
                                          'credit_wallet.${widget.groupId}':
                                              FieldValue.increment(-selectedTrans[i]['amount'])
                                        });
                                      }

                                      fetchTransactions();
                                    },
                                    child: const Text(
                                      'Mark as Received',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                        ],
                      ),
                    ),
                  userListing(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userListing() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    // List userTransations =
    //     transactions.where((t) => t['recevier_id'] == userId || t['payer_id'] == userId).toList();

    // if (userTransations.isEmpty) {
    //   return Container(
    //     alignment: Alignment.center,
    //     width: double.infinity,
    //     height: 300,
    //     child: const Text(
    //       'No Settlements found',
    //       style: TextStyle(
    //         color: Colors.white,
    //       ),
    //     ),
    //   );
    // }

    return Column(
      children: [
        ...transactions.map(
          (t) {
            return UserListSelectable(
              transact: t,
              isSelected: selectedTrans.contains(t),
              onSelect: selectTransact,
            );
          },
        ),
      ],
    );
  }

  void toggleSelectAll() {
    if (isSelectAll) {
      selectedTrans = [];
    } else {
      selectedTrans = selectableTrans;
    }

    setState(() {
      isSelectAll = !isSelectAll;
    });
  }

  void selectTransact(isRemove, trans) {
    print(trans);
    if (isRemove) {
      selectedTrans.remove(trans);
    } else {
      selectedTrans.add(trans);
    }
    if (selectedTrans.length == selectableTrans.length) {
      isSelectAll = true;
    } else {
      isSelectAll = false;
    }

    setState(() {});
  }

  void fetchTransactions() {
    transactionController.getGroupTransactions(widget.groupId).then((value) {
      setState(() {
        transactions = value;
        selectableTrans = transactions
            .where((t) => t['receiver_id'] == FirebaseAuth.instance.currentUser!.uid)
            .toList();
        selectedTrans = [];
        isLoading = false;
      });
    });
  }
}
