import 'package:flutter/material.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/utils/constants.dart';

// ignore: must_be_immutable
class AddGroupScreen extends StatefulWidget {
  AddGroupScreen({
    super.key,
  });

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _groupNameController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split-Sync'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(flex: 2, child: Icon(Icons.group)),
                Flexible(
                  flex: 10,
                  child: TextField(
                    controller: _groupNameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Enter Group Name',
                    ),
                    autocorrect: false,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: TextField(
                controller: _descriptionController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Enter Description',
                ),
                autocorrect: false,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          Navigator.pop(context,
            Group(
              name: _groupNameController.text,
              creator: currentUser!.username,
              description: _descriptionController.text,
              members: [currentUser!.username],
              admin: [currentUser!.username],
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 10,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 50),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
