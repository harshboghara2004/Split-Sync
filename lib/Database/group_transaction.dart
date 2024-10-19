import 'package:firebase_database/firebase_database.dart';
import 'package:splitsync/Models/group_transaction.dart';
import 'package:splitsync/Models/transaction.dart' as trans;

class GroupTxsData {
  // ignore: deprecated_member_use
  DatabaseReference groupTxsList = FirebaseDatabase(
          databaseURL: 'https://splitsync-91f14-default-rtdb.firebaseio.com')
      .ref('group_transactions');

  Future<Map<String, double>> createDistribution({
    required List<String> selectedMembers,
    required double amount,
  }) async {
    Map<String, double> data = {};
    final def = (amount / selectedMembers.length);
    for (var mem in selectedMembers) {
      data[mem] = def;
    }
    return data;
  }

  Future<Map<String, double>> addMemberToDistribution({
    required List<String> selectedMembers,
    required List<String> editedMembers,
    required double total,
    required String member,
    required Map<String, double> dist,
  }) async {
    Map<String, double> newDist = {};

    var ndSum = 0.0;
    var ctn = 0;

    for (var key in selectedMembers) {
      if (editedMembers.contains(key)) {
        ndSum += dist[key] as double;
      } else {
        ctn++;
      }
    }

    final newVal = ((total - ndSum) / (ctn + 1));
    final newDef = double.parse(newVal.toStringAsFixed(2));
    // print(newDef);

    for (var key in selectedMembers) {
      if (!editedMembers.contains(key)) {
        newDist[key] = newDef;
      } else {
        newDist[key] = dist[key] as double;
      }
    }

    newDist[member] = newDef;
    return newDist;
  }

  Future<Map<String, double>> removeMemberToDistribution({
    required List<String> selectedMembers,
    required List<String> editedMembers,
    required double total,
    required String member,
    required Map<String, double> dist,
  }) async {
    if (selectedMembers.length == 1) {
      print('sum-will-be-less-than-$total');
      return dist;
    }

    Map<String, double> newDist = {};

    var ndSum = 0.0;
    var ctn = 0;

    for (var key in selectedMembers) {
      if (editedMembers.contains(key)) {
        ndSum += dist[key] as double;
      } else {
        ctn++;
      }
    }

    if (ctn == 0) {
      print('sum-will-be-less-than-$total');
      return dist;
    }

    if (ctn == 1 && !editedMembers.contains(member)) {
      print('sum-will-be-less-than-$total');
      return dist;
    }

    final newVal = !editedMembers.contains(member)
        ? (total - ndSum) / (ctn - 1)
        : (total - ndSum) / (ctn);
    final newDef = double.parse(newVal.toStringAsFixed(2));

    for (var key in selectedMembers) {
      if (key == member) continue;
      if (!editedMembers.contains(key)) {
        newDist[key] = newDef;
      } else {
        newDist[key] = dist[key] as double;
      }
    }

    return newDist;
  }

  Future<Map<String, double>> changeAmountOfMember({
    required List<String> selectedMembers,
    required List<String> editedMembers,
    required Map<String, double> dist,
    required String memKey,
    required double total,
    required double newAmt,
  }) async {
    if (selectedMembers.length == 1) {
      print('Only-one-member-is-selected');
      return dist;
    }
    Map<String, double> newDist = {};

    var ctnDef = 0;
    var nonDef = 0.0;
    for (var key in selectedMembers) {
      if (editedMembers.contains(key)) {
        nonDef += dist[key] as double;
      } else {
        ctnDef++;
      }
    }

    if (!editedMembers.contains(memKey) && ctnDef == 1) {
      print('value-can-be-changed-total-sum-has-to-be-$total');
      return dist;
    }

    final newVal = (!editedMembers.contains(memKey))
        ? (total - nonDef - newAmt) / (ctnDef - 1)
        : (total - nonDef - newAmt) / (ctnDef);
    double newDef = double.parse(newVal.toStringAsFixed(2));
    // print(newDef);
    if (newDef < 0) {
      print('amount-is-greater-than-$total');
      return dist;
    }
    for (var key in selectedMembers) {
      if (!editedMembers.contains(key)) {
        newDist[key] = newDef;
      } else {
        newDist[key] = dist[key] as double;
      }
    }
    newDist[memKey] = newAmt;

    // print(newDist);
    return newDist;
  }

  Future<String> addGroupTransaction({
    required GroupTransaction gtx,
  }) async {
    DatabaseReference newGtx = groupTxsList.child(gtx.groupKey).push();
    try {
      await newGtx.set(gtx.toJson());
      final key = newGtx.key!;
      await newGtx.update({
        'key': key,
      });
      // print(newGtx.key!);
      print('gtx-added');
    } catch (e) {
      return e.toString();
    }
    return 'Success';
  }

  Future<List<GroupTransaction>> getAllGroupTransactions({
    required String groupKey,
  }) async {
    final snapshot = await groupTxsList.child(groupKey).get();
    List<GroupTransaction> txsList = [];
    if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;
      final dataList = dataMap.entries.toList();
      dataList.sort((a, b) => DateTime.parse(b.value['date'])
          .compareTo(DateTime.parse(a.value['date'])));

      for (var entry in dataList) {
        try {
          Map<String, double> convertedMap = {};
          // print(entry.value['distribution']);
          if (entry.value['distribution'] != null) {
            entry.value['distribution'].forEach((key, value) async {
              convertedMap[key] = (value as num).toDouble();
            });
          }
          // print(convertedMap);
          final gt = GroupTransaction(
            key: entry.key,
            groupKey: entry.value['groupKey'],
            amount: entry.value['amount'].toDouble(),
            creator: entry.value['creator'],
            description: entry.value['description'],
            distribution: convertedMap,
            date: DateTime.parse(entry.value['date']),
          );
          txsList.add(gt);
        } on Exception catch (e) {
          print(e.toString());
        }
      }

      dataMap.forEach((key, value) async {});
    }
    return txsList;
  }

  Future<List<trans.Transaction>> getAllGroupTransactionsOfTwoUser({
    required String groupKey,
    required String user1,
    required String user2,
  }) async {
    List<GroupTransaction> txs =
        await getAllGroupTransactions(groupKey: groupKey);
    List<trans.Transaction> res = [];

    for (var t in txs) {
      if (t.creator == user1 && t.distribution[user2] != null) {
        final tx = trans.Transaction(
          description: t.description,
          amount: t.distribution[user2] as double,
          from: user1,
          to: user2,
          date: t.date,
        );
        res.add(tx);
      }
      if (t.creator == user2 && t.distribution[user1] != null) {
        final tx = trans.Transaction(
          description: t.description,
          amount: t.distribution[user1] as double,
          from: user2,
          to: user1,
          date: t.date,
        );
        res.add(tx);
      }
    }

    return res;
  }

  Future<void> deleteAllGroupTransaction({
    required String groupKey,
  }) async {
    await groupTxsList.child(groupKey).remove().then((_) {
      print("Data with key $groupKey deleted successfully");
    }).catchError((error) {
      print("Error deleting data: $error");
    });
  }

  Future<void> deleteTransaction({
    required String key,
    required String groupKey,
  }) async {
    await groupTxsList.child(groupKey).child(key).remove().then((_) {
      print("Data with key $key deleted successfully");
    }).catchError((error) {
      print("Error deleting data: $error");
    });
  }
}
