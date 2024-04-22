import 'package:flutter/material.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Screens/Groups/group_detail_screen.dart';
import 'package:splitsync/utils/constants.dart';

class GroupCard extends StatelessWidget {
  final Group group;

  const GroupCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () {
          currentGroup = group;
          print('you-are-in-group-${currentGroup!.name}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsScreen(
                group: group,
              ),
            ),
          );
        },
        title: Text(group.name),
        // You can add more widgets here to display other information
      ),
    );
  }
}
