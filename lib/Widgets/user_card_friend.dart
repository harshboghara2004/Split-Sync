import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Screens/Friends/friend_detail_screen.dart';
import 'package:splitsync/utils/user_provider.dart';

class UserCardFriend extends StatelessWidget {
  final User user;
  final dynamic balance;

  const UserCardFriend({
    super.key,
    required this.user,
    required this.balance,
  });
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // print(currentUser.username);
    User? currentUser = Provider.of<UserProvider>(context).currentUser;
    return Card(
      margin: screenWidth > 800
          ? const EdgeInsets.symmetric(horizontal: 400, vertical: 200)
          : const EdgeInsets.all(4),
      child: ListTile(
        onTap: () {
          if (user.email != currentUser!.email) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendDetailScreen(user: user),
              ),
            );
          }
        },
        title: Text(user.email),
        subtitle: Text(user.email),
        trailing: SizedBox(
          width: screenWidth * 0.35,
          child: Text(
            balance > 0.0
                ? 'You will get $balance'
                : 'You will give ${balance.abs()}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
