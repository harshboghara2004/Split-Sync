import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitsync/Database/group_transaction.dart';
import 'package:splitsync/Models/transaction.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/utils/constants.dart';

class GroupUserTxScreen extends StatefulWidget {
  const GroupUserTxScreen({
    super.key,
    required this.user,
  });

  final User user;

  @override
  State<GroupUserTxScreen> createState() => _GroupUserTxScreenState();
}

class _GroupUserTxScreenState extends State<GroupUserTxScreen> {
  double balance = 0, tmp = 0;

  _fetchData() async {
    List<Transaction> txs =
        await GroupTxsData().getAllGroupTransactionsOfTwoUser(
      groupKey: currentGroup!.key!,
      user1: currentUser!.username,
      user2: widget.user.username,
    );
    balance = 0;
    for (var t in txs) {
      // print(balance);
      if (t.from == currentUser!.username) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return txs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${currentUser!.username}(You) & ${widget.user.username} in ${currentGroup!.name}'),
      ),
      body: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            if (!snapshot.hasData || (snapshot.data as dynamic).isEmpty) {
              return const Center(
                child: Text('No Transactions.'),
              );
            }
            final txs = snapshot.data as List<Transaction>;
            tmp = balance;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                    color: balance >= 0.0 ? Colors.green : Colors.red,
                  ),
                  child: balance >= 0.0
                      ? Text(
                          'you will get ₹$balance',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          'you will give ₹${(balance).abs()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: txs.length,
                      itemBuilder: (context, index) {
                        if (index > 0) {
                          if (txs[index - 1].from == currentUser!.username) {
                            tmp -= txs[index - 1].amount;
                          } else {
                            tmp += txs[index - 1].amount;
                          }
                        }
                        return Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(16),
                            color: txs[index].from == currentUser!.username
                                ? Colors.green
                                : Colors.red,
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      txs[index].description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      'Bal: $tmp',
                                    )
                                  ],
                                ),
                                Text(DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(txs[index].date!)),
                              ],
                            ),
                            trailing: Text(
                              txs[index].amount.toString(),
                            ), // Right side
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
