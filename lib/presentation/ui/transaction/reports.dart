import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    transactionController.getGroupTransactions(widget.groupId).then((value) {
      setState(() {
        transactions = value;
        selectableTrans = transactions
            .where((t) =>
                t['recevier_id'] == FirebaseAuth.instance.currentUser!.uid)
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await transactionController
            .getGroupTransactions(widget.groupId)
            .then((value) {
          setState(() {
            transactions = value;
            selectableTrans = transactions
                .where((t) =>
                    t['recevier_id'] == FirebaseAuth.instance.currentUser!.uid)
                .toList();
          });
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.groupName),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (selectableTrans.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: toggleSelectAll,
                        child: Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: isSelectAll ? Colors.black : null,
                          ),
                        ),
                      ),
                      const Text('Select All'),
                      const Spacer(),
                      if (selectedTrans.isNotEmpty)
                        isLoading
                            ? const CupertinoActivityIndicator()
                            : GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  for (var i = 0;
                                      i < selectedTrans.length;
                                      i++) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(selectedTrans[i]['recevier_id'])
                                        .update({
                                      'credit_wallet.${widget.groupId}':
                                          FieldValue.increment(
                                              selectedTrans[i]['amount'])
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(selectedTrans[i]['payer_id'])
                                        .update({
                                      'credit_wallet.${widget.groupId}':
                                          FieldValue.increment(
                                              -selectedTrans[i]['amount'])
                                    });

                                    transactionController
                                        .getGroupTransactions(widget.groupId)
                                        .then((value) {
                                      setState(() {
                                        transactions = value;
                                        selectableTrans = transactions
                                            .where((t) =>
                                                t['recevier_id'] !=
                                                FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            .toList();
                                        isLoading = false;
                                      });
                                    });
                                  }
                                },
                                child: Text(
                                  'Mark as Received',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
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
    );
  }

  Widget userListing() {
    return Column(
      children: [
        ...transactions.map((t) => UserListSelectable(
              transact: t,
              isSelected: selectedTrans.contains(t),
              onSelect: selectTransact,
            )),
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
}
