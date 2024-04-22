import 'package:flutter/material.dart';
import 'package:splitsync/Database/transaction_data.dart';
import 'package:splitsync/Models/transaction.dart';

// ignore: must_be_immutable
class AddTranscationScreen extends StatefulWidget {
  AddTranscationScreen({
    super.key,
    required this.from,
    required this.to,
  });

  String from;
  String to;

  @override
  State<AddTranscationScreen> createState() => _AddTranscationScreenState();
}

class _AddTranscationScreenState extends State<AddTranscationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
  }

  _addTransaction() async {

    Transaction tx = Transaction(
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      from: widget.from,
      to: widget.to,
    );

    try {

      final res = await TransactionData().createTransaction(t: tx);
      return res;

    } catch (e) {
      return e.toString();
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split-Snyc'),
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
          ],
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () async {
          final res = await _addTransaction();
          if (res == 'Success') {
            Navigator.pop(context);
          } else {
            print(res);
          }
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
