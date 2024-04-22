import 'package:flutter/material.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Screens/Friends/friend_detail_screen.dart';
import 'package:splitsync/Screens/Groups/group_user_tx_screen.dart';
import 'package:splitsync/utils/constants.dart';

class UserCard extends StatelessWidget {
  final User user;
  final balance;
  final bool inGroup;

  const UserCard(
      {required this.user, required this.balance, required this.inGroup});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        onTap: () {
          if (user.email != currentUser!.email) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => inGroup
                    ? GroupUserTxScreen(user: user)
                    : FriendDetailScreen(user: user),
              ),
            );
          }
        },
        title: Text(user.username),
        subtitle: Text(user.email),
        trailing: (balance != 'Group')
            ? balance > 0.0
                ? Text(
                    'You will get $balance',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Text(
                    'You will give ${balance.abs()}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  )
            : const Text('Admin'),
      ),
    );
  }
}
