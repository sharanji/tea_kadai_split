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

class TransactionScreen extends StatefulWidget {
  TransactionScreen({super.key, this.groupName = "", this.groupId = "", this.transactionRefid});
  final String groupName;
  final String groupId;
  final String? transactionRefid;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  TransactionController transactionController = Get.find();
  double billAmount = 20.0;
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
                    Map transaction = ((snapshot.data!.data() as Map)['participants'] as Map);

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(transaction.length.toString()),
                            Text(snapshot.data!.data()!['payable_amount'].toString()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (transaction.entries
                            .where((MapEntry t) => t.key == FirebaseAuth.instance.currentUser!.uid)
                            .isEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 200,
                                child: TextFormField(
                                  onChanged: (value) {
                                    billAmount = double.parse(value);
                                  },
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.currency_rupee),
                                    hintText: 'Enter amount spent',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  ),
                                  initialValue: '20',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  FirebaseFirestore.instance
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .collection('transactions')
                                      .doc(widget.transactionRefid)
                                      .update({
                                    'payable_amount': FieldValue.increment(billAmount),
                                    'participants.${FirebaseAuth.instance.currentUser!.uid}':
                                        billAmount,
                                  });
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
                      ],
                    );
                  }
                  return const CupertinoActivityIndicator();
                }),
            Builder(
              builder: (context) {
                final GlobalKey<SlideActionState> _key = GlobalKey();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SlideAction(
                    key: _key,
                    height: 50,
                    sliderButtonIconSize: 10,
                    onSubmit: () async {
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(widget.groupId)
                          .collection('transactions')
                          .doc(widget.transactionRefid)
                          .update({'status': true});

                      _key.currentState!.reset();
                      Navigator.of(context).pop();
                    },
                    innerColor: Colors.black,
                    outerColor: Colors.white,
                    child: const Text('Close Bill'),
                  ),
                );
              },
            ),
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
              ((snapshot.data!.data() as Map)['participants'] as Map).entries.toList();

          return Column(
            children: [
              for (int i = 0; i < transaction.length; i++) transactionMember(transaction[i]),
            ],
          );
        });
  }

  Widget transactionMember(MapEntry transaction) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(transaction.key).get(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const CupertinoActivityIndicator();
        }

        Map userInfo = snapshot.data!.data() as Map;

        return ListTile(
          leading: CircleAvatar(
            foregroundImage: NetworkImage(userInfo['photoUrl']),
          ),
          title: Text(userInfo['name']),
          trailing: Text(
            '₹ ${transaction.value}',
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }
}
