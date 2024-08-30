import 'package:flutter/material.dart';

class UserListSelectable extends StatefulWidget {
  const UserListSelectable(
      {super.key, required this.userInfo, required this.personTransact});
  final Map userInfo;
  final dynamic personTransact;

  @override
  State<UserListSelectable> createState() => _UserListSelectableState();
}

class _UserListSelectableState extends State<UserListSelectable> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      leading: CircleAvatar(
        foregroundImage: NetworkImage(widget.userInfo['photoUrl']),
      ),
      title: Text(widget.userInfo['name']),
      subtitle: Text('₹ ${widget.personTransact.value.toStringAsFixed(2)}'),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.transparent,
            border: Border.all(color: Colors.red)),
      ),
    );
  }
}
