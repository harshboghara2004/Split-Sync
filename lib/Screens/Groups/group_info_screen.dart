import 'package:flutter/material.dart';
import 'package:splitsync/Database/group_data.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Screens/Groups/group_screen.dart';
import 'package:splitsync/Screens/Search/search_screen.dart';
import 'package:splitsync/Widgets/user_card.dart';
import 'package:splitsync/utils/constants.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({
    super.key,
    required this.group,
  });

  final Group group;

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  bool reduce = false;

  _getData() async {
    final res = await GroupData().getAllMembers(key: widget.group.key!);
    reduce = await GroupData().getReduceValue(key: widget.group.key!);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: FutureBuilder(
        future: _getData(),
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
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Data'),
            );
          }
          List<User> members = snapshot.data as List<User>;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          GroupData.setCurrentGroup(group: widget.group);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchScreen(
                                isInGroup: true,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.add_circle),
                        label: const Text('Add Member'),
                      ),
                    ),
                  ),
                  currentUser!.username == widget.group.creator
                      ? Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await GroupData()
                                    .deleteGroup(groupKey: widget.group.key!);
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const GroupScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete Group'),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) => UserCard(
                    user: members[index],
                    balance: 'Group',
                    inGroup: true,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                margin: const EdgeInsets.symmetric(vertical: 50),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final res =
                        await GroupData().toggleReduce(key: widget.group.key!);
                    setState(() {
                      reduce = res;
                    });
                  },
                  icon: (reduce) == false
                      ? const Icon(Icons.add)
                      : const Icon(Icons.task_alt_rounded),
                  label: (reduce) == false
                      ? const Text('Enable Transaction Reduction')
                      : const Text('Transaction Reduction Enabled'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
