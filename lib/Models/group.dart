class Group {
  
  String? key;
  final String name;
  final String creator;
  final String description;
  final List<String> members;
  final List<String> admin;
  final date;
  bool? reduce;

  Group({ 
    this.key,
    required this.name,
    required this.creator,
    required this.description,
    required this.members,
    required this.admin,
    this.date,
    this.reduce = false,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    List<dynamic> dl = json['admin'];
    List<String> sl = dl.cast<String>();
    json['admin'] = sl;
    dl = json['members'];
    sl = dl.cast<String>();
    json['members'] = sl;
    return Group(
      key: json['key'],
      name: json['name'],
      creator: json['creator'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      members: (json['members'] as List<String>),
      admin: (json['admin'] as List<String>),
      reduce: json['reduce'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'creator': creator,
      'description': description,
      'date': DateTime.now().toIso8601String(), // Set date to current time
      'members': members,
      'admin': admin,
      'reduce': reduce,
    };
  }
}
  