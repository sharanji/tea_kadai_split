import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/components/bottom_bar.dart';
import 'package:tea_kadai_split/presentation/ui/transaction/transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              child: Icon(Icons.add)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Your Groups',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return const CupertinoActivityIndicator();
                }
                List<QueryDocumentSnapshot> groups = snapshot.data!.docs;
                return Column(
                  children: [
                    ...groups.map(
                      (g) {
                        Map<dynamic, dynamic> groupInfo = g.data() as Map;
                        return ListTile(
                          leading: CircleAvatar(
                            foregroundImage: NetworkImage(groupInfo['image']),
                          ),
                          title: Text(
                            groupInfo['name'],
                            // style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            groupInfo['description'],
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              var transactionId = await FirebaseFirestore.instance
                                  .collection('groups')
                                  .doc(g.id)
                                  .collection('transactions')
                                  .add({
                                'timestamp': FieldValue.serverTimestamp(),
                                'status': false,
                                'initaited': FirebaseAuth.instance.currentUser!.uid,
                                'participants': [
                                  {'user_id': FirebaseAuth.instance.currentUser!.uid, 'amount': 20},
                                ],
                              });
                              Get.to(() => TransactionScreen(
                                  groupName: groupInfo['name'],
                                  groupId: g.id,
                                  transactionRef: transactionId));
                            },
                            child: const Text(
                              'Open',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              })
        ],
      ),
      bottomNavigationBar: const AppBottomBar(),
    );
  }
}
