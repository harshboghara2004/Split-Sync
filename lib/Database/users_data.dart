import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:splitsync/Authentication/Methods/email_login.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/utils/constants.dart';

class UsersData {
  // ignore: deprecated_member_use
  DatabaseReference userListRef = FirebaseDatabase(
          databaseURL: 'https://splitsync-91f14-default-rtdb.firebaseio.com')
      .ref('users');
  final db = FirebaseFirestore.instance;

  Future<bool> isUsernameAvailable(String username) async {
    bool check = false;
    DatabaseEvent event = await userListRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (!snapshot.exists) {
      return false;
    }
    // Check if the username exists in the data
    Map<dynamic, dynamic> usersData = snapshot.value as Map<dynamic, dynamic>;
    if (usersData.isEmpty) return false;
    usersData.forEach((key, value) {
      if (value['username'] == username) {
        check = true;
        return;
      }
    });
    return check;
  }

  Future<String> addUser({
    required String username,
    required String email,
  }) async {
    DatabaseReference newUserRef = userListRef.push();
    User user = User(email: email, username: username);
    bool check = await isUsernameAvailable(username);

    if (check) {
      await AuthEmailMethod().deleteUser();
      return 'Username Already Exists!, Choose Different One.';
    }

    try {
      await newUserRef.set(user.toJson());
      String key = newUserRef.key!;
      print(key);
      print('user-added');
      await db.collection('friends').doc(key).set({
        'username': user.username,
        'friends': [],
      }, SetOptions(merge: true));
      print('friend-added');
    } catch (e) {
      print(e);
      return e.toString();
    }
    return 'Success';
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await userListRef.get();
    List<User> userList = [];
    if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;
      dataMap.forEach((key, value) {
        userList.add(
          User(
              username: value['username'],
              email: value['email'],
              friendsKey: key),
        );
      });
    }
    return userList;
  }

  Future<User?> getUserByUsername({
    required String usernameToFind,
  }) async {
    final snapshot = await userListRef.get();
    User? user;
    if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;
      dataMap.forEach((key, value) {
        if (value['username'] == usernameToFind) {
          user = User(
            username: value['username'],
            email: value['email'],
            friendsKey: key,
          );
        }
      });
    }
    return user;
  }

  Future<String> getFriendKeyByEmail({
    required String email,
  }) async {
    final userList = await getAllUsers();
    for (var element in userList) {
      if (element.email == email) {
        return element.friendsKey!;
      }
    }
    return 'Not Found';
  }

  Future<User?> getUserByKey({
    required String keyToFind,
  }) async {
    final snapshot = await userListRef.get();
    User? user;
    if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;
      dataMap.forEach((key, value) {
        if (key == keyToFind) {
          user = User(
            username: value['username'],
            email: value['email'],
            friendsKey: key,
          );
        }
      });
    }
    return user;
  }

  Future<User> getUserByEmail({
    required String emailToFind,
  }) async {
    User? user;
    try {
      final snapshot = await userListRef.get();
      if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;
        dataMap.forEach((key, value) {
          if (value['email'] == emailToFind) {
            user = User(username: value['username'], email: value['email']);
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }
    return user!;
  }

  static void setCurrentUser({
    required User user,
    required String key,
  }) {
    user.friendsKey = key;
    currentUser = user;
    print('Set-current-user-${user.username}');
  }
}
