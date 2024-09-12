import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_transition_mixin.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tea_kadai_split/presentation/components/app_logo_header.dart';
import 'package:tea_kadai_split/presentation/components/creditBalanceWidget.dart';
import 'package:tea_kadai_split/presentation/components/navigation_bar.dart';
import 'package:tea_kadai_split/presentation/controllers/auth_controller.dart';
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
  AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: HexColor('#fe8953'),
        title: const Text('Tea Kadai Split'),
        actions: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: HexColor('#ff967a'),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          CircleAvatar(
            radius: 12,
            foregroundImage: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
          ),
          const SizedBox(width: 15),
        ],
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
                  ////HexColor('#fd784c'),
                  HexColor('#fe8953'),
                  HexColor('#fd9957'),
                  HexColor('#fcc364'),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasData) {
                        Map userDoc = snapshot.data!.data() as Map;
                        double yourCredit = 0;
                        double yourDebit = 0;

                        List<MapEntry> userWallets =
                            (userDoc['credit_wallet'] ?? {}).entries.toList();

                        for (MapEntry wallet in userWallets) {
                          if (wallet.value > 0) {
                            yourCredit += wallet.value;
                          } else {
                            yourDebit -= wallet.value;
                          }
                        }

                        return Container(
                          // width: 300,
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // height: 100,
                                width: 150,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rs $yourDebit',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    const Text(
                                      'You Get Back',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                // height: 100,
                                width: 150,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rs $yourCredit',
                                      style: const TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    const Text(
                                      'You Give Back',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const CupertinoActivityIndicator();
                    }),
                pendingtransactions(),
                myGroups(),
                recentTransactions(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(),
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
            return const Center(child: CupertinoActivityIndicator());
          }
          List<QueryDocumentSnapshot> groups = snapshot.data!.docs;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Your Groups',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    // color: Colors
                  ),
                ),
              ),
              ...groups.map(
                (g) {
                  Map<dynamic, dynamic> groupInfo = g.data() as Map;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: HexColor('#2c2c2c'),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  groupInfo['name'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                ),
                                Text(
                                  groupInfo['description'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                Get.to(
                                  () => GroupReports(
                                    groupName: groupInfo['name'],
                                    groupId: g.id,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Reports',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                    content: const Text('Do You want to Pay Bill ?'),
                                    textConfirm: 'Yes, Pay',
                                    textCancel: 'Sorry',
                                    onConfirm: () async {
                                      await TransactionReports.openNewTransAction(g.id, groupInfo);
                                    });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Pay Bill',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      final transactions = snapshot.data!.docs;

                      // Check if there are any pending transactions
                      final hasPendingTransactions = transactions.any((transaction) =>
                          transaction.data().containsKey('timestamp') &&
                          transaction.data()['timestamp'].runtimeType == Timestamp);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show the heading only if there are pending transactions
                          if (hasPendingTransactions && i == 0)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(10.0, 0.0, 16.0, 0.0),
                              child: Text(
                                'Pending Transactions',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ...transactions.map((transaction) {
                            if (transaction.data().containsKey('timestamp') &&
                                transaction.data()['timestamp'].runtimeType == Timestamp) {
                              DateTime transactionTime =
                                  (transaction.data()['timestamp'] as Timestamp).toDate();
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (groups[i].data()! as Map)['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColorLight,
                                          ),
                                        ),
                                        Text(
                                          timeago.format(transactionTime),
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColorLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 70),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => TransactionScreen(
                                            groupName: (groups[i].data()! as Map)['name'],
                                            groupId: groups[i].id,
                                            transactionRefid: transaction.id,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Add Bill',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context).primaryColorLight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const CupertinoActivityIndicator();
                          }).toList(),
                        ],
                      );
                    }
                    return const CupertinoActivityIndicator();
                  },
                ),
            ],
          );
        });
  }

  Widget recentTransactions() {
    return Container();
  }
}
