import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tea_kadai_split/presentation/controllers/transaction_controller.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:tea_kadai_split/presentation/services/transaction_reports.dart';

class TransactionScreen extends StatefulWidget {
  TransactionScreen(
      {super.key,
      this.groupName = "",
      this.groupId = "",
      this.transactionRefid});
  final String groupName;
  final String groupId;
  final String? transactionRefid;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  TransactionController transactionController = Get.find();
  double billAmount = 20.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            currentTransactions(widget.groupId, widget.transactionRefid!),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        child: Wrap(
          // height: 100,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               const  Text('Bill opened by : '),
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.groupId)
                        .collection('transactions')
                        .doc(widget.transactionRefid)
                        .get(),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasData) {
                        return FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(snapshot.data!.data()!['initaited'])
                                .get(),
                            builder: (ctx, snapshot) {
                              if (snapshot.hasData) {
                                return Text(snapshot.data!.data()!['name']);
                              }
                              return const CupertinoActivityIndicator();
                            });
                      }
                      return const CupertinoActivityIndicator();
                    }),
              ],
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Participants'),
                Text('Amount'),
              ],
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupId)
                    .collection('transactions')
                    .doc(widget.transactionRefid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map transaction =
                        ((snapshot.data!.data() as Map)['participants'] as Map);

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(transaction.length.toString()),
                            Text((snapshot.data!.data()!['payable_amount'])
                                .toStringAsFixed(2)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (!snapshot.data!.data()!['status'] &&
                            transaction.entries
                                .where((MapEntry t) =>
                                    t.key ==
                                    FirebaseAuth.instance.currentUser!.uid)
                                .isEmpty)
                          Form(
                            key: _formKey,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextFormField(
                                    validator: (value) {
                                      try {
                                        double dVal = double.parse(value!);
                                        if (dVal < 0) {
                                          return "Invalid Amount";
                                        }
                                      } catch (e) {
                                        return "Invalid Amount";
                                      }

                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.currency_rupee),
                                      hintText: 'Enter amount spent',
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 10),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSaved: (value) {
                                      billAmount = double.parse(value!);
                                    },
                                    initialValue: '20',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      TransactionReports.addMyBill(
                                          widget.groupId,
                                          widget.transactionRefid,
                                          billAmount);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(),
                                    ),
                                    child: const Text('Add Bill'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!snapshot.data!.data()!['status'] &&
                            snapshot.data!.data()!['initaited'] ==
                                FirebaseAuth.instance.currentUser!.uid &&
                            transaction.entries
                                .where((MapEntry t) =>
                                    t.key ==
                                    FirebaseAuth.instance.currentUser!.uid)
                                .isNotEmpty)
                          Builder(
                            builder: (context) {
                              final GlobalKey<SlideActionState> _key =
                                  GlobalKey();
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SlideAction(
                                  key: _key,
                                  height: 50,
                                  sliderButtonIconSize: 10,
                                  onSubmit: () async {
                                    TransactionReports.closeBill(
                                      widget.groupId,
                                      widget.transactionRefid,
                                    );
                                  },
                                  innerColor: Colors.black,
                                  outerColor: Colors.white,
                                  child: const Text('Swipe to Close Bill'),
                                ),
                              );
                            },
                          ),
                        if (snapshot.data!.data()!['initaited'] !=
                                FirebaseAuth.instance.currentUser!.uid ||
                            snapshot.data!.data()!['status'])
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              snapshot.data!.data()!['status']
                                  ? 'This Bill Has Been Closed'
                                  : 'Waiting for Bill Close',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const CupertinoActivityIndicator();
                }),
          ],
        ),
      ),
    );
  }

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
          List<dynamic> transaction =
              ((snapshot.data!.data() as Map)['participants'] as Map)
                  .entries
                  .toList();

          return Column(
            children: [
              for (int i = 0; i < transaction.length; i++)
                transactionMember(transaction[i]),
            ],
          );
        });
  }

  Widget transactionMember(MapEntry transaction) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(transaction.key)
          .get(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const CupertinoActivityIndicator();
        }

        Map userInfo = snapshot.data!.data() as Map;

        return Dismissible(
          key: Key(transaction.key),
          direction: FirebaseAuth.instance.currentUser!.uid == transaction.key
              ? DismissDirection.endToStart
              : DismissDirection.none,
          onDismissed: (DismissDirection direction) async {
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupId)
                .collection('transactions')
                .doc(widget.transactionRefid)
                .update({
              'payable_amount': FieldValue.increment(-transaction.value),
              'participants.${transaction.key}': FieldValue.delete()
            });
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(13),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              foregroundImage: NetworkImage(userInfo['photoUrl']),
            ),
            title: Text(userInfo['name']),
            trailing: Text(
              '₹ ${transaction.value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      },
    );
  }
}
