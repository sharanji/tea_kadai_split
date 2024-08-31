import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/controllers/transaction_controller.dart';

// ignore: must_be_immutable
class UserListSelectable extends StatefulWidget {
  UserListSelectable(
      {super.key,
      required this.transact,
      this.isSelected = false,
      this.onSelect});

  final Map transact;
  bool isSelected;
  final Function? onSelect;

  @override
  State<UserListSelectable> createState() => _UserListSelectableState();
}

class _UserListSelectableState extends State<UserListSelectable> {
  TransactionController transactionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.onSelect != null
          ? () {
              widget.onSelect!(widget.isSelected, widget.transact);
            }
          : null,
      leading: (widget.transact['recevier_id'] !=
              FirebaseAuth.instance.currentUser!.uid)
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color:
                    widget.isSelected  
                        ? Colors.black
                        : null,
                border: Border.all(color: Colors.black),
              ),
            )
          : null,
      title: Row(
        children: [
          Text(
            widget.transact['pays'],
            style: const TextStyle(color: Colors.red),
          ),
          const Icon(Icons.arrow_right),
          Text(
            widget.transact['recevies'],
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ),
      subtitle: Text(
        widget.transact['desc'],
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
