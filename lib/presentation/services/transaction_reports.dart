import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tea_kadai_split/presentation/ui/transaction/transaction_screen.dart';

class TransactionReports {
  static Future openNewTransAction(groupId, groupInfo) async {
    // check for pending transactions
    var pendings =await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(groupId)
                        .collection('transactions')
                        .where('status', isEqualTo: false)
                        .get();

    if (pendings.docs.isNotEmpty) {
      Get.snackbar('Transaction Running', "Your Group have a pending transaction");
      return;
    }

    var transactionId = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('transactions')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'status': false,
      'initaited': FirebaseAuth.instance.currentUser!.uid,
      'payable_amount': 0,
      'participants': {}
    });

    Get.to(
      () => TransactionScreen(
          groupName: groupInfo['name'],
          groupId: groupId,
          transactionRefid: transactionId.id),
    );
  }

  static List monthlyGroupTally(List docs) {
    Map tally = {};
    docs.sort((a, b) {
      DateTime aTime = a.data()['timestamp'].toDate();
      DateTime bTime = b.data()['timestamp'].toDate();

      return aTime.compareTo(bTime);
    });
    DateTime startTime = docs[0].data()['timestamp'].toDate();
    DateTime endTime = docs.last.data()['timestamp'].toDate();

    for (int i = 0; i < docs.length; i++) {
      Map transactionData = docs[i].data();
      List<MapEntry> participants =
          (transactionData['participants'] as Map).entries.toList();

      for (var j = 0; j < participants.length; j++) {
        if (tally.containsKey(participants[j].key)) {
          tally[participants[j].key] += participants[j].value;
        } else {
          tally[participants[j].key] = participants[j].value;
        }
      }
      if (tally.containsKey(transactionData['initaited'])) {
        tally[transactionData['initaited']] -=
            transactionData['payable_amount'];
      }
    }

    return [tally, startTime, endTime];
  }
}
