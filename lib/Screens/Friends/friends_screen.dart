import 'package:flutter/material.dart';
import 'package:splitsync/Authentication/Methods/email_login.dart';
import 'package:splitsync/Database/friends_data.dart';
import 'package:splitsync/Database/transaction_data.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Widgets/user_card.dart';
import 'package:splitsync/utils/constants.dart';

class FriendsScreen extends StatefulWidget {

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  

  _getAllFriends() async {
    final currentUserEmail = await AuthEmailMethod().getCurrentUserEmail();
    final currentUserFriendsKey =
        await UsersData().getFriendKeyByEmail(email: currentUserEmail!);
    final friendKeysList = await FriendsData()
        .getFriendListOfKeys(friendsKey: currentUserFriendsKey);
    List<User> friendList = [];
    List<double> balance = [];

    for (var key in friendKeysList) {
      var user = await UsersData().getUserByKey(keyToFind: key);
      if (user != null) {
        final bal = await _getBalance(username: user.username);
        if (bal != 0.0) {
          friendList.add(user);
          balance.add(bal);
        }
      }
    }
    return [friendList, balance];
  }

  Future<double> _getBalance({
    required String username,
  }) async {

    final res = await TransactionData().getTxBwTwoUsers(
      user1: currentUser!.username,
      user2: username,
    );
    double balance = 0.0;
    for (var t in res) {
      // print(balance);
      if (t.from == currentUser!.username) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: FutureBuilder(
        future: _getAllFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error!.toString()),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Friends. Add Some One.'),
            );
          }
          final data = snapshot.data as List<List<dynamic>>;
          final friends = data[0];
          final bal = data[1];

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) => UserCard(
              user: friends[index],
              balance: bal[index],
              inGroup: false,
            ),
          );
        },
      ),
    );
  }
}
