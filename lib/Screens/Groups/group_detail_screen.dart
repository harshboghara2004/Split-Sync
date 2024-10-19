import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Authentication/Screens/Welcome/welcome_screen.dart';
import 'package:splitsync/Database/group_data.dart';
import 'package:splitsync/Database/group_transaction.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Models/group_transaction.dart';
import 'package:splitsync/Screens/Groups/add_group_transaction_screen.dart';
import 'package:splitsync/Screens/Groups/group_info_screen.dart';
import 'package:splitsync/Screens/Groups/reduced_transaction.dart';
import 'package:splitsync/Screens/Groups/your_transaction.dart';
import 'package:splitsync/Widgets/group_transaction_card.dart';
import 'package:splitsync/utils/user_provider.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, required this.group});

  final Group group;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;
    if (currentUser == null) {
      return const WelcomeScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupInfoScreen(
                    group: widget.group,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.info),
            label: const Text('Info'),
          ),
        ],
      ),
      body: FutureBuilder(
        future:
            GroupTxsData().getAllGroupTransactions(groupKey: widget.group.key!),
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
          final txs = snapshot.data as List<GroupTransaction>;
          if (txs.isEmpty) {
            return const Center(
              child: Text('No Transactions'),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    // print(txs[index].distribution);
                    if (txs[index].creator == currentUser.username) {
                      return Dismissible(
                        key: Key(txs[index].toString()),
                        onDismissed: (direction) async {
                          await GroupTxsData().deleteTransaction(
                            groupKey: widget.group.key!,
                            key: txs[index].key!,
                          );
                          setState(() {
                            txs.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item dismissed')),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: GroupTransactionCard(
                          gtx: txs[index],
                        ),
                      );
                    }
                    return GroupTransactionCard(
                      gtx: txs[index],
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    final reduce = await GroupData()
                        .getReduceValue(key: widget.group.key!);
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => reduce
                            ? ReducedTransaction(group: widget.group)
                            : YourTransaction(group: widget.group),
                      ),
                    );
                  },
                  child: const Text('See Your Transcations.'),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGroupTransactionScreen(
                group: widget.group,
              ),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
