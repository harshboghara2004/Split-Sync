import 'package:flutter/material.dart';
import 'package:splitsync/Database/group_data.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Screens/Groups/add_group_screen.dart';
import 'package:splitsync/Widgets/group_card.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  _getGroups() async {
    final groups = await GroupData().getAllGroups();
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: FutureBuilder(
        future: _getGroups(),
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
              child: Text('No Groups'),
            );
          }
          final groups = snapshot.data as List<Group>;
           if (groups.isEmpty) {
            return const Center(
              child: Text('No Groups'),
            );
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) => GroupCard(
              group: groups[index],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final group = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGroupScreen(),
            ),
          );
          final res = await GroupData().addGroup(group: group);
          setState(() {});
          print(res);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
