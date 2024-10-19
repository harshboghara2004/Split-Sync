import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Authentication/Screens/Welcome/welcome_screen.dart';
import 'package:splitsync/Database/friends_data.dart';
import 'package:splitsync/Database/group_data.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Models/user.dart';
import 'dart:core';

import 'package:splitsync/utils/constants.dart';
import 'package:splitsync/utils/user_provider.dart';

// ignore: must_be_immutable
class UserDetailScreen extends StatefulWidget {
  UserDetailScreen({super.key, required this.user, required this.isInGroup});

  User user;
  bool isInGroup;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? currentUser;
//
  _fetchFriensList({
    required String friendsKey,
  }) async {
    final List<User> friendList = [];
    final dataKeys = await FriendsData()
        .getFriendListOfKeys(friendsKey: widget.user.friendsKey!);
    final userList = await UsersData().getAllUsers();

    for (var element in userList) {
      if (dataKeys.contains(element.friendsKey)) {
        friendList.add(element);
      }
    }
    // print(friendList);
    return friendList;
  }

  _check() async {
    if (widget.isInGroup) {
      final res = await _checkInGroup();
      return res;
    } else {
      final res = await _checkFriends();
      return res;
    }
  }

  _checkFriends() async {
    if (currentUser == null) {
      print('user-not-sign-in');
    } else {
      // print(widget.user);
      final res = await FriendsData().checkFriends(
        key1: currentUser!.friendsKey!,
        key2: widget.user.friendsKey!,
      );
      if (res) {
        return 'Already Friends';
      } else {
        return 'Add Friend';
      }
    }
  }

  _checkInGroup() async {
    final res = await GroupData().checkInGroup(
      groupKey: currentGroup!.key!,
      user: widget.user.username,
    );
    if (res) {
      return 'Already In Group';
    } else {
      return 'Add to Group';
    }
  }

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<UserProvider>(context).currentUser;
    if (currentUser == null) {
      return const WelcomeScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username),
      ),
      body: FutureBuilder(
        future: _check(),
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
          String txt = snapshot.data as String;
          // print(txt);
          return widget.isInGroup == false
              ? TextButton(
                  onPressed: () async {
                    final res = await FriendsData().makeFriends(
                      key1: widget.user.friendsKey!,
                      key2: currentUser!.friendsKey!,
                    );
                    if (res) {
                      print('Friend-${widget.user.username}-added');
                      Navigator.pop(context);
                    }
                  },
                  child: Text(txt),
                )
              : TextButton(
                  onPressed: () async {
                    final res = await GroupData().addMemberToGroup(
                      groupKey: currentGroup!.key!,
                      userKey: widget.user.username,
                    );
                    if (res) {
                      print('${widget.user.username}-added-into-group');
                      Navigator.pop(context);
                    }
                  },
                  child: Text(txt),
                );
        },
      ),
    );
  }
}
