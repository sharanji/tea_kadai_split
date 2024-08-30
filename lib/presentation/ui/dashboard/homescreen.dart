
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/components/bottom_bar.dart';
import 'package:tea_kadai_split/presentation/services/transaction_reports.dart';
import 'package:tea_kadai_split/presentation/ui/transaction/reports.dart';
import 'package:tea_kadai_split/presentation/ui/transaction/transaction_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Pending Transactions',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            pendingtransactions(),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Your Groups',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            myGroups(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomBar(),
    );
  }

  Widget myGroups() {
    return StreamBuilder(
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
                    onTap: () {
                      Get.to(
                        () => GroupReports(
                          groupName: groupInfo['name'],
                          groupId: g.id,
                        ),
                      );
                    },
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
                    trailing: GestureDetector(
                     
                      onTap: () async {
                       await TransactionReports.openNewTransAction(g.id,groupInfo);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add),
                             Text(
                              'Open New',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        });
  }

  Widget pendingtransactions() {
    return StreamBuilder(
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
              for (int i = 0; i < groups.length; i++)
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('groups')
                        .doc(groups[i].id)
                        .collection('transactions')
                        .where('status', isEqualTo: false)
                        .snapshots(),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            ...snapshot.data!.docs.map((transaction) {
                              if (transaction.data().containsKey('timestamp') &&
                                  transaction.data()['timestamp'].runtimeType == Timestamp) {
                                DateTime currentdatetime =
                                    (transaction.data()['timestamp'] as Timestamp).toDate();

                                return ListTile(
                                  title: Text((groups[i].data()! as Map)['name']),
                                  subtitle: Text(timeago.format(currentdatetime)),
                                  trailing: TextButton(
                                    onPressed: () async {
                                      Get.to(
                                        () => TransactionScreen(
                                          groupName: (groups[i].data()! as Map)['name'],
                                          groupId: groups[i].id,
                                          transactionRefid: transaction.id,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Open',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                );
                              }
                              return const CupertinoActivityIndicator();
                            }),
                          ],
                        );
                      }
                      return const CupertinoActivityIndicator();
                    }),
            ],
          );
        });
  }
}
