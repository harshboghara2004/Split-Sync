import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Authentication/Screens/Welcome/welcome_screen.dart';
import 'package:splitsync/Database/group_data.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Screens/Groups/group_screen.dart';
import 'package:splitsync/Screens/Search/search_screen.dart';
import 'package:splitsync/Widgets/user_card_group.dart';
import 'package:splitsync/utils/user_provider.dart';

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
  bool isAdmin = false;

  _getData() async {
    final members = await GroupData().getAllMembers(key: widget.group.key!);
    final admins = await GroupData().getAllAdmins(key: widget.group.key!);
    reduce = await GroupData().getReduceValue(key: widget.group.key!);
    return [members, admins];
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;
    if (currentUser == null) {
      return const WelcomeScreen();
    }

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
          final [members, admins] = snapshot.data as List<List<User>>;
          for (var admin in admins) {
            if (admin.username == currentUser.username) {
              isAdmin = true;
              break;
            }
          }
          // print(isAdmin);
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isAdmin
                      ? Expanded(
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
                        )
                      : const Text(''),
                  currentUser.username == widget.group.creator
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
                    group: widget.group,
                  ),
                ),
              ),
              widget.group.admin.contains(currentUser.username)
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      margin: const EdgeInsets.symmetric(vertical: 50),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final res = await GroupData()
                              .toggleReduce(key: widget.group.key!);
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
                    )
                  : const SizedBox(),
            ],
          );
        },
      ),
    );
  }
}
