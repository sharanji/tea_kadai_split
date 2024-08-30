import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:tea_kadai_split/presentation/components/user_list_selectable.dart';
import 'package:tea_kadai_split/presentation/services/transaction_reports.dart';
import 'package:timeago/timeago.dart';
import 'package:intl/intl.dart';

class GroupReports extends StatelessWidget {
  const GroupReports({super.key, this.groupName = "", this.groupId = ""});

  final String groupName;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            reports(),
          ],
        ),
      ),
      bottomSheet: Wrap(
        children: [
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
                    
                    },
                    innerColor: Colors.black,
                    outerColor: Colors.white,
                    child: const Text('Close Report'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget reports() {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('transactions')
            .where('status', isEqualTo: true)
            .get(),
        builder: (ctx, snapShot) {
          if (snapShot.hasData) {
            List tallyReports =
                TransactionReports.monthlyGroupTally(snapShot.data!.docs);
            Map<dynamic, dynamic> peopletally = tallyReports.first;
            DateTime startTime = tallyReports[1];
            DateTime endTime = tallyReports.last;

            return userListing(peopletally, startTime, endTime);
          }
          return const CupertinoActivityIndicator();
        });
  }

  Widget userListing(Map peopletally, startTime, endTime) {
    DateTime now = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('From: '),
                  Text(DateFormat('dd-MM-y').format(startTime)),
                ],
              ),
              Row(
                children: [
                  const Text('To: '),
                  Text(DateFormat('dd-MM-y').format(endTime)),
                ],
              )
            ],
          ),
        ),
        ...peopletally.entries.map(
          (personTransact) => FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(personTransact.key)
                .get(),
            builder: (ctx, snapShot) {
              if (!snapShot.hasData) {
                return const CupertinoActivityIndicator();
              }
              Map? userInfo = snapShot.data!.data();
              return UserListSelectable(
                  userInfo: userInfo!, personTransact: personTransact);
            },
          ),
        ),
      ],
    );
  }
}
