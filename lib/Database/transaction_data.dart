import 'package:firebase_database/firebase_database.dart';
import 'package:splitsync/Models/transaction.dart' as model;

class TransactionData {
  DatabaseReference transactionsListRef = FirebaseDatabase(
          databaseURL: 'https://splitsync-91f14-default-rtdb.firebaseio.com')
      .ref('transactions');

  Future<String> createTransaction({
    required model.Transaction t,
  }) async {
    DatabaseReference newTransactionRef = transactionsListRef.push();
    try {
      await newTransactionRef.set(t.toJson());
      print(newTransactionRef.key);
      print('transaction-made-success');
    } catch (e) {
      return (e.toString());
    }
    return 'Success';
  }

  Future<List<model.Transaction>> getAllTxs() async {

    final snapshot = await transactionsListRef.get();
    List<model.Transaction> txList = [];
    if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {

      Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;
      final dataList = dataMap.entries.toList();
      dataList.sort((a, b) => DateTime.parse(b.value['date']).compareTo(DateTime.parse(a.value['date'])));
      // print(dataList);
      for (var entry in dataList) {
        try {
        final tx = model.Transaction(
              key: entry.key,
              description: entry.value['description'],
              amount: entry.value['amount'].toDouble(),
              from: entry.value['from'],
              to: entry.value['to'],
              date: DateTime.parse(entry.value['date']),
            );
        txList.add(tx);
        } on Exception catch (e) {
          print(e.toString());
        }
      }

    }

    return txList;
  }

  Future<List<model.Transaction>> getTxBwTwoUsers({
    required String user1,
    required String user2,
  }) async {

    List<model.Transaction> res = [];                   
    List<model.Transaction> txs = await getAllTxs();

    for(var tx in txs) {
      if ((tx.from == user1 && tx.to == user2) || (tx.from == user2 && tx.to == user1)) {
        res.add(tx);
      }
    }
    return res;
  }


}