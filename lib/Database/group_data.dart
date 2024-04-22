import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitsync/Database/group_transaction.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/utils/constants.dart';
import 'package:uuid/uuid.dart';

class GroupData {
  final dbGroup = FirebaseFirestore.instance.collection('groups');
  final uuid = const Uuid();

  static setCurrentGroup({
    required Group group,
  }) {
    currentGroup = group;
  }

  Future<String> addGroup({
    required Group group,
  }) async {
    try {
      final docRef = await dbGroup.add(group.toJson());
      await dbGroup.doc(docRef.id).update({
        'key': docRef.id,
      });
      return 'Success';
    } catch (e) {
      return (e.toString());
    }
  }

  Future<List<Group>> getAllGroups() async {
    List<Group> groups = [];
    try {
      final snap = await dbGroup.get();
      for (var g in snap.docs) {
        final group = Group.fromJson(g.data());
        groups.add(group);
      }
    } catch (e) {
      print(e.toString());
    }
    return groups;
  }

  Future<List<User>> getAllMembers({
    required String key,
  }) async {
    List<User> res = [];
    try {
      final data = await dbGroup.doc(key).get();
      final members = data['members'];
      for (var member in members) {
        final user =
            await UsersData().getUserByUsername(usernameToFind: member);
        if (user != null) {
          res.add(user);
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return res;
  }

  Future<bool> checkInGroup({
    required String groupKey,
    required String user,
  }) async {
    final data = await dbGroup.doc(groupKey).get();
    final members = data['members'];
    final c1 = members.contains(user);
    if (c1) return true;
    return false;
  }

  Future<bool> addMemberToGroup({
    required String groupKey,
    required String userKey,
  }) async {
    try {
      await dbGroup.doc(groupKey).update({
        'members': FieldValue.arrayUnion([userKey]),
      });
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<bool> toggleReduce({
    required String key,
  }) async {
    final snapshot = await dbGroup.doc(key).get();
    final data = snapshot.data() as Map<String, dynamic>;
    await dbGroup.doc(key).update({
      'reduce': !data['reduce'],
    });
    final res = await getReduceValue(key: key);
    print('set-reduce-to-${res}');
    return res;
  }

  Future<bool> getReduceValue({
    required String key,
  }) async {
    final snapshot = await dbGroup.doc(key).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return data['reduce'];
  }

  Future<Map<String, int>> getAllUsersNum({
    required String groupKey,
  }) async {
    Map<String, int> data = {};
    final mem = await getAllMembers(key: groupKey);
    var ctn = 1;
    for (var st in mem) {
      data[st.username] = ctn;
      ctn++;
    }
    return data;
  }

  Future<void> deleteGroup({
    required String groupKey,
  }) async {
    try {
      DocumentReference docRef = dbGroup.doc(groupKey);
      await docRef.delete();
      await GroupTxsData().deleteAllGroupTransaction(groupKey: groupKey);
      print('group-deleted');
    } catch (e) {
      print(e.toString());
    }
  }
}
