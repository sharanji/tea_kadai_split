class TransactionReports {
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
