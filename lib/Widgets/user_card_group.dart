import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Screens/Friends/friend_detail_screen.dart';
import 'package:splitsync/Screens/Groups/group_user_tx_screen.dart';
import 'package:splitsync/utils/user_provider.dart';

// ignore: must_be_immutable
class UserCard extends StatelessWidget {
  final User user;
  final dynamic balance;
  final bool inGroup;
  Group? group;

  UserCard({
    super.key,
    required this.user,
    required this.balance,
    required this.inGroup,
    this.group,
  });
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // print(currentUser.username);
    User? currentUser = Provider.of<UserProvider>(context).currentUser;

    return InkWell(
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
      child: Container(
        margin: screenWidth > 800
            ? const EdgeInsets.symmetric(horizontal: 400)
            : const EdgeInsets.all(0),
        child: Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
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
                : group != null && group!.admin.contains(user.username)
                    ? const Text('Admin')
                    : const Text(''),
          ),
        ),
      ),
    );
  }
}
