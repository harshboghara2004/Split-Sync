import 'package:flutter/material.dart';
import 'package:splitsync/Database/group_transaction.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Models/transaction.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Widgets/user_card.dart';
import 'package:splitsync/utils/constants.dart';

// ignore: must_be_immutable
class YourTransaction extends StatefulWidget {
  YourTransaction({
    super.key,
    required this.group,
  });

  Group group;
  @override
  State<YourTransaction> createState() => _YourTransactionState();
}

class _YourTransactionState extends State<YourTransaction> {
  _fetchData() async {
    List<String> members = widget.group.members;
    List<User> groupMembers = [];
    List<double> bal = [];

    for (var member in members) {
      if (member == currentUser!.username) continue;
      final user =
          await UsersData().getUserByUsername(usernameToFind: member) as User;
      List<Transaction> txs =
          await GroupTxsData().getAllGroupTransactionsOfTwoUser(
        groupKey: currentGroup!.key!,
        user1: currentUser!.username,
        user2: member,
      );
      var balance = 0.0;
      for (var t in txs) {
        if (t.from == currentUser!.username) {
          balance += t.amount;
        } else {
          balance -= t.amount;
        }
      }
      if (txs.isNotEmpty) {
        groupMembers.add(user);
        bal.add(balance);
      }
    }

    return [groupMembers, bal];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${currentUser!.username}\'s Transaction in ${widget.group.name}'),
      ),
      body: FutureBuilder(
        future: _fetchData(),
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
              child: Text('No Transactions'),
            );
          }
          final data = snapshot.data as List<dynamic>;
          final groupMembers = data[0];
          final bal = data[1];
          // print(groupMembers);
          // print(bal);
          // return const Center(
          //   child: Text('Transactions'),
          // );
          return ListView.builder(
            itemCount: groupMembers.length,
            itemBuilder: (context, index) => UserCard(
              user: groupMembers[index],
              balance: bal[index],
              inGroup: true,
            ),
          );
        },
      ),
    );
  }
}
