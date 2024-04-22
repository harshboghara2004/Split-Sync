import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Screens/Search/user_detail_screen.dart';

// ignore: must_be_immutable
class SearchScreen extends StatefulWidget {
  SearchScreen({super.key, required this.isInGroup});
  bool isInGroup;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void search(String query) {
    // ignore: deprecated_member_use
    DatabaseReference usersRef = FirebaseDatabase(
            databaseURL: 'https://splitsync-91f14-default-rtdb.firebaseio.com')
        .ref('users');

    usersRef.once().then((DatabaseEvent event) {
      setState(() {
        _searchResults.clear();
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

        users.forEach((key, value) {
          if (value['username'].toString().contains(query) ||
              value['email'].toString().contains(query)) {
            _searchResults.add({
              'key': key,
              'username': value['username'],
              'email': value['email'],
            });
          }
        });
      });
    });

    print(_searchResults);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Friend'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              search(value);
            },
            decoration: const InputDecoration(
              hintText: 'Search by username or email',
              border: InputBorder.none,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // onTap: () => ,
                  title: Text(
                    _searchResults[index]['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(_searchResults[index]['email']),
                  trailing: TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailScreen(
                            isInGroup: widget.isInGroup,
                            user: User(
                              username: _searchResults[index]['username'],
                              email: _searchResults[index]['email'],
                              friendsKey: _searchResults[index]['key'],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text('View'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
