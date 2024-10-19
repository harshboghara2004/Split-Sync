import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Database/friends_data.dart';
import 'package:splitsync/Database/transaction_data.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Widgets/user_card_friend.dart';
import 'package:splitsync/utils/user_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  User? currentUser;

  _getAllFriends() async {
    final currentUserFriendsKey = currentUser!.friendsKey;
    final friendKeysList = await FriendsData()
        .getFriendListOfKeys(friendsKey: currentUserFriendsKey!);
    List<User> friendList = [];
    List<double> balance = [];

    for (var key in friendKeysList) {
      var user = await UsersData().getUserByKey(keyToFind: key);
      if (user != null) {
        final bal = await _getBalance(
            user1: currentUser!.username, user2: user.username);
        if (bal != 0.0) {
          friendList.add(user);
          balance.add(bal);
        }
      }
    }

    return [friendList, balance];
  }

  Future<double> _getBalance({
    required String user1,
    required String user2,
  }) async {
    // print(user1);print(user2);
    final res = await TransactionData().getTxBwTwoUsers(
      user1: user1,
      user2: user2,
    );
    // print(res);
    double balance = 0.0;
    for (var t in res) {
      if (t.from == user1) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<UserProvider>(context).currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Friends'),
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
            itemBuilder: (context, index) {
              return UserCardFriend(
                user: friends[index],
                balance: bal[index],
              );
            }
          );
        },
      ),
    );
  }
}
