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
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Your Groups'),
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
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'start new',
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
