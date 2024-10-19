import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Algorithms/reduce_txs.dart';
import 'package:splitsync/Authentication/Screens/Welcome/welcome_screen.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Widgets/user_card_group.dart';
import 'package:splitsync/utils/user_provider.dart';

class ReducedTransaction extends StatefulWidget {
  const ReducedTransaction({super.key, required this.group});

  final Group group;

  @override
  State<ReducedTransaction> createState() => _ReducedTransactionState();
}

class _ReducedTransactionState extends State<ReducedTransaction> {
  User? currentUser;

  getData() async {
    final graph = await ReduceTxs().getData(groupKey: widget.group.key!);
    // print(graph);
    final reduced = ReduceTxs().solveData(graphData: graph);
    // print(reduced);
    print('i am here');
    var id = 0;
    (reduced['nodes'] as Map<int, String>).forEach((key, value) {
      if (value == currentUser!.username) {
        id = key;
      }
    });

    List<Map<String, dynamic>> dataList = [];

    for (var t in reduced['edges']) {
      if (t['from'] == id) {
        Map<String, dynamic> mp = {};
        final user = await UsersData()
            .getUserByUsername(usernameToFind: reduced['nodes'][t['to']]);
        mp['user'] = user;
        mp['balance'] = t['amt'];
        dataList.add(mp);
      } else if (t['to'] == id) {
        Map<String, dynamic> mp = {};
        final user = await UsersData()
            .getUserByUsername(usernameToFind: reduced['nodes'][t['from']]);
        double amt = double.parse(t['amt']);
        amt *= (-1);
        mp['user'] = user;
        mp['balance'] = amt;
        dataList.add(mp);
      }
    }

    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<UserProvider>(context).currentUser;
    if (currentUser == null) {
      return const WelcomeScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Transactions'),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.50,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Data'),
            );
          }
          final data = snapshot.data as List<Map<String, dynamic>>;
          // print(data);
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => UserCard(
              user: data[index]['user'],
              balance: double.parse(data[index]['balance']),
              inGroup: true,
            ),
          );
        },
      ),
    );
  }
}
