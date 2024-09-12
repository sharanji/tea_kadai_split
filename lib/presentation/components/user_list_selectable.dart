import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/controllers/transaction_controller.dart';

// ignore: must_be_immutable
class UserListSelectable extends StatefulWidget {
  UserListSelectable({super.key, required this.transact, this.isSelected = false, this.onSelect});

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
    return GestureDetector(
      onTap: (widget.transact['receiver_id'] == FirebaseAuth.instance.currentUser!.uid)
          ? () {
              widget.onSelect!(widget.isSelected, widget.transact);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.transact['receiver_id'] == FirebaseAuth.instance.currentUser!.uid)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: widget.isSelected ? Colors.black : null,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                Text(
                  widget.transact['pays'],
                  style: TextStyle(
                    color: (widget.transact['payer_id'] == FirebaseAuth.instance.currentUser!.uid)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColorLight,
                  ),
                ),
                Icon(
                  Icons.arrow_right,
                  color: Theme.of(context).primaryColorLight,
                ),
                Text(
                  widget.transact['receives'],
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            Text(
              widget.transact['desc'],
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
