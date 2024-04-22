import 'package:flutter/material.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Screens/Groups/distribution_screen.dart';

// ignore: must_be_immutable
class AddGroupTransactionScreen extends StatefulWidget {
  AddGroupTransactionScreen({
    super.key,
    required this.group,
  });

  Group group;

  @override
  State<AddGroupTransactionScreen> createState() =>
      _AddGroupTransactionScreenState();
}

class _AddGroupTransactionScreenState extends State<AddGroupTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool splitPress = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Group Transaction'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(
                  flex: 2,
                  child: Text(
                    '\u{20B9}',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Flexible(
                  flex: 10,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter Amount',
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
            splitPress
                ? DistributionScreen(
                    group: widget.group,
                    total: double.parse(_amountController.text),
                    desc: _descriptionController.text,
                  )
                : const SizedBox(
                    height: 100,
                  ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              margin: const EdgeInsets.only(bottom: 15),
              child: splitPress
                  ? TextButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text(
                        'Split Again',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          splitPress = true;
                        });
                      },
                      child: const Text('Split'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
