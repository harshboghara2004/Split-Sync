
class GroupTransaction {

  String? key;
  final double amount;
  final String creator;
  final String description;
  final Map<String,double> distribution;
  final date;
  final String groupKey;

  GroupTransaction({
    this.key,
    required this.amount,
    required this.creator,
    required this.description,
    required this.distribution,
    required this.groupKey,
    this.date,
  });

  factory GroupTransaction.fromJson(Map<String, dynamic> json) {
    return GroupTransaction(
      groupKey: json['groupKey'],
      amount: json['amount'],
      creator: json['creator'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      distribution: json['distribution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupKey': groupKey,
      'amount': amount,
      'creator': creator,
      'description': description,
      'date': DateTime.now().toIso8601String(), // Set date to current time
      'distribution': distribution,
    };
  }
}
