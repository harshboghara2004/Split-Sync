import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Authentication/Screens/Welcome/welcome_screen.dart';
import 'package:splitsync/Database/transaction_data.dart';
import 'package:splitsync/Models/transaction.dart';
import 'package:splitsync/Models/user.dart';
import 'package:flutter/material.dart';
import 'package:splitsync/Screens/Friends/add_transaction_screen.dart';
import 'package:splitsync/utils/user_provider.dart';

// ignore: must_be_immutable
class FriendDetailScreen extends StatefulWidget {
  FriendDetailScreen({
    super.key,
    required this.user,
  });

  User user;
  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  double balance = 0, tmp = 0;
  User? currentUser;

  _getTransactions() async {
    if (currentUser == null) return [];
    final res = await TransactionData().getTxBwTwoUsers(
      user1: currentUser!.username,
      user2: widget.user.username,
    );
    balance = 0;
    for (var t in res) {
      // print(balance);
      if (t.from == currentUser!.username) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<UserProvider>(context).currentUser;
    if (currentUser == null) {
      return const WelcomeScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username),
      ),
      body: FutureBuilder(
        future: _getTransactions(),
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
          List<Transaction> txs = snapshot.data! as List<Transaction>;
          tmp = balance;
          // print(balance);
          // return Text('hello');
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                width: double.parse("200"),
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
                        textAlign: TextAlign.left,
                      )
                    : Text(
                        'you will give ₹${(balance).abs()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
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
                                ? const Color.fromARGB(255, 120, 200, 123)
                                : const Color.fromARGB(150, 249, 35, 60)),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                txs[index].from == currentUser!.username
                                    ? "+"
                                    : "-",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                txs[index].amount.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ), // Right side
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // you gave
            InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTranscationScreen(
                      from: currentUser!.username,
                      to: widget.user.username,
                    ),
                  ),
                );
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width / 3,
                decoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'You Gave ₹',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // you got
            InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTranscationScreen(
                      from: widget.user.username,
                      to: currentUser!.username,
                    ),
                  ),
                );
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width / 3,
                decoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'You Got ₹',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
