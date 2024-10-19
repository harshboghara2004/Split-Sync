import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsData {

  final db = FirebaseFirestore.instance;

  Future<List> getFriendListOfKeys({
    required String friendsKey,
  }) async {
    try {
      final res = await db
        .collection('friends')
        .doc(friendsKey)
        .get();

      final data = res.data()!['friends'];
      return data;
    } catch(e) {
      print(e.toString());
    } 
    return [];
  }

  Future<bool> checkFriends({
    required String key1,
    required String key2,
  }) async {
    try {
      final data = await getFriendListOfKeys(friendsKey: key1);
      if (data.contains(key2)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<bool> makeFriends({
    required String key1,
    required String key2,
  }) async {
    try {
      // print(key1);
      // print(key2);
      await db.collection('friends').doc(key1).update({
        'friends': FieldValue.arrayUnion([key2])
      });
      await db.collection('friends').doc(key2).update({
        'friends': FieldValue.arrayUnion([key1])
      });
      print('Make Friends Successfully');
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

}