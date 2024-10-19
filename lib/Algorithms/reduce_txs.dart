import 'package:collection/collection.dart';
import 'package:splitsync/Database/group_data.dart';
import 'package:splitsync/Database/group_transaction.dart';

class ReduceTxs {
  getData({
    required String groupKey,
  }) async {
    final txs =
        await GroupTxsData().getAllGroupTransactions(groupKey: groupKey);
    Map<String, int> nodes =
        await GroupData().getAllUsersNum(groupKey: groupKey);
    Map<String, dynamic> graph = {};
    graph['nodes'] = nodes;
    List<Map<String, dynamic>> edges = [];

    for (var t in txs) {
      t.distribution.forEach((key, value) {
        if (t.creator != key) {
          Map<String, dynamic> mp = {};
          mp['from'] = nodes[t.creator] as int;
          mp['to'] = nodes[key] as int;
          mp['amt'] = value.toString();
          edges.add(mp);
        }
      });
    }
    graph['edges'] = edges;
    return graph;
  }

  Map<String, dynamic> solveData({required Map<String, dynamic> graphData}) {
    Map<String, dynamic> data = Map<String, dynamic>.from(graphData);
    int sz = data['nodes'].length;
    List<double> vals = List<double>.filled(sz, 0);

    // Calculating net balance of each person
    for (int i = 0; i < data['edges'].length; i++) {
      Map<String, dynamic> edge = data['edges'][i];
      vals[edge['to'] - 1] += double.parse(edge['amt']); 
      vals[edge['from'] - 1] -= double.parse(edge['amt']); 
    }

    // print(vals);

    HeapPriorityQueue<List<double>> posHeap = HeapPriorityQueue<List<double>>(
        (a, b) =>
            b[0].compareTo(a[0])); // Max heap for positive values (givers)
    HeapPriorityQueue<List<double>> negHeap = HeapPriorityQueue<List<double>>(
        (a, b) =>
            b[0].compareTo(a[0])); // Min heap for negative values (receivers)

    for (int i = 0; i < vals.length; i++) {
      if (vals[i] > 0) {
        posHeap.add(
            [vals[i], double.parse(i.toString())]); // All givers in one subset
      } else if (vals[i] < 0) {
        negHeap.add([
          -vals[i],
          double.parse(i.toString())
        ]); // All receivers in another subset
        vals[i] *= -1;
      }
    }

    List<Map<String, dynamic>> newEdges = [];
    while (posHeap.isNotEmpty && negHeap.isNotEmpty) {
      List<double> mx = posHeap.removeFirst();
      List<double> mn = negHeap.removeFirst();
      double amt = mx[0].compareTo(mn[0]) > 0 ? mn[0] : mx[0];
      int to = mx[1].toInt();
      int from = mn[1].toInt();

      // print(mx);
      // print(mn);
      // print('neext');

      if (amt != 0.0) {
        newEdges.add({
          'from': from + 1,
          'to': to + 1,
          'amt': amt.abs().toString(),
        });
      }

      vals[to] -= amt;
      vals[from] -= amt;

      if (mx[0] > mn[0]) {
        posHeap.add([vals[to], to.toDouble()]);
      } else if (mx[0] < mn[0]) {
        negHeap.add([-vals[from], from.toDouble()]);
      }
    }

    Map<int, String> nds = {};
    data['nodes'].forEach((key, value) {
      nds[value] = key;
    });
    data = {'nodes': nds, 'edges': newEdges};
    return data;
  }
}
