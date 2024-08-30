import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupReports extends StatelessWidget {
  const GroupReports({super.key, this.groupName = "", this.groupId = ""});

  final String groupName;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .collection('transactions')
                    .where('status', isEqualTo: true)
                    .get(),
                builder: (ctx, snapShot) {
                  if (snapShot.hasData) {
                    Map peopletally = {};

                    return Text(snapShot.data!.docs.length.toString());
                  }
                  return const CupertinoActivityIndicator();
                })
          ],
        ),
      ),
    );
  }
}
