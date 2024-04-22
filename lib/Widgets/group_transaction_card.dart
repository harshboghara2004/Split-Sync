import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitsync/Models/group_transaction.dart';

// ignore: must_be_immutable
class GroupTransactionCard extends StatefulWidget {
  GroupTransactionCard({super.key, required this.gtx});

  GroupTransaction gtx;

  @override
  State<GroupTransactionCard> createState() => _GroupTransactionCardState();
}

class _GroupTransactionCardState extends State<GroupTransactionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created by: ${widget.gtx.creator}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat(
                    'dd/MM HH:mm',
                  ).format(widget.gtx.date ?? DateTime.now()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total amount: ${widget.gtx.amount}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Distribution:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.gtx.distribution.entries.map((entry) {
                    return Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 14),
                    );
                  }).toList(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
