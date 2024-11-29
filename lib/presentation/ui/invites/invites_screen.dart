import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_navigation/src/routes/get_transition_mixin.dart';
import 'package:hexcolor/hexcolor.dart';

class GroupInvites extends StatefulWidget {
  const GroupInvites({super.key});

  @override
  State<GroupInvites> createState() => _GroupInvitesState();
}

class _GroupInvitesState extends State<GroupInvites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text("Group Invites"),
                  backgroundColor: Colors.transparent,
                ),
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("invites")
                        .where("userEmail", isEqualTo: FirebaseAuth.instance.currentUser!.email)
                        .get(),
                    builder: (ctx, snapShot) {
                      if (snapShot.connectionState != ConnectionState.done) {
                        return const CupertinoActivityIndicator();
                      }
                      List<QueryDocumentSnapshot> invites = snapShot.data!.docs;
                      if (invites.isEmpty) {
                        return const ListTile(
                          leading: Icon(Icons.error),
                          title: Text(
                            'No Group Invites',
                          ),
                          subtitle: Text('Ask Group Admin to Invite'),
                        );
                      }
                      return Column(
                          children: invites.map((QueryDocumentSnapshot invite) {
                        return ListTile(
                          leading: CircleAvatar(
                            foregroundImage: NetworkImage(invite['groupImage'] ?? ''),
                          ),
                          title: Text(invite['groupName']),
                          subtitle: Text("Invited By : ${invite['invitorName'] ?? ''}"),
                          trailing: SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    removeInvite(invite.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: HexColor('#ff967a'),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(invite['groupId'])
                                        .update({
                                      "members": FieldValue.arrayUnion([
                                        FirebaseAuth.instance.currentUser!.uid,
                                      ])
                                    });
                                    removeInvite(invite.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: HexColor('#ff967a'),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList());
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future removeInvite(String inviteId) async {
    await FirebaseFirestore.instance.collection('invites').doc(inviteId).delete();
    setState(() {});
  }
}
