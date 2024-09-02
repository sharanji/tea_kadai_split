import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/components/app_logo_header.dart';
import 'package:tea_kadai_split/presentation/components/creditBalanceWidget.dart';
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
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLogo(),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Container(
                        //   width: 60, // Adjust the size as needed
                        //   height: 60,
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     border: Border.all(
                        //       color: Colors.blue, // Border color
                        //       width: .0, // Border width
                        //     ),
                        //   ),
                        //   child: ClipOval(
                        //     child: Image.network(
                        //       authController.photoUrl.value,
                        //       fit: BoxFit.cover,
                        //       errorBuilder: (context, error, stackTrace) =>
                        //           const Icon(Icons
                        //               .error), // Handles image loading errors
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   width: 7,
                        // ),
                        Text(
                          'Hello, ${authController.userName.value}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasData) {
                      Map userDoc = snapshot.data!.data() as Map;
                      print(userDoc);
                      double totalCreditBalance = (userDoc['credit_wallet'] as Map).entries.fold(0.0, (previousValue, element) => previousValue+element.value);
                          
                      return CreditBalanceWidget(
                          totalCreditBalance: totalCreditBalance);
                    }
                    return const CupertinoActivityIndicator();
                  }),
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
      ),
    );
  }

  Widget myGroups() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('members',
                arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: const CupertinoActivityIndicator());
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
                        await TransactionReports.openNewTransAction(
                            g.id, groupInfo);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
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
            .where('members',
                arrayContains: FirebaseAuth.instance.currentUser!.uid)
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
                      final hasPendingTransactions = transactions.any(
                          (transaction) =>
                              transaction.data().containsKey('timestamp') &&
                              transaction.data()['timestamp'].runtimeType ==
                                  Timestamp);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show the heading only if there are pending transactions
                          if (hasPendingTransactions)
                            const Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                              child: Text(
                                'Pending Transactions',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ...transactions.map((transaction) {
                            if (transaction.data().containsKey('timestamp') &&
                                transaction.data()['timestamp'].runtimeType ==
                                    Timestamp) {
                              DateTime currentdatetime =
                                  (transaction.data()['timestamp'] as Timestamp)
                                      .toDate();

                              return ListTile(
                                title: Text((groups[i].data()! as Map)['name']),
                                subtitle: Text(timeago.format(currentdatetime)),
                                trailing: TextButton(
                                  onPressed: () async {
                                    Get.to(
                                      () => TransactionScreen(
                                        groupName:
                                            (groups[i].data()! as Map)['name'],
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
}
