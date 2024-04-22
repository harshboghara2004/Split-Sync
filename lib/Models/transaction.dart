class Transaction {
  
  String? key;
  final String description;
  final double amount;
  DateTime? date;
  final String from;
  final String to;

  Transaction({
    this.key,
    required this.description,
    required this.amount,
    required this.from,
    required this.to,
    this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      description: json['description'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      from: json['from'],
      to: json['to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'date': DateTime.now().toIso8601String(), // Set date to current time
      'from': from,
      'to': to,
    };
  }
}
