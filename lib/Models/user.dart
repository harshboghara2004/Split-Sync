class User {
  
  String username;
  String email;
  String? friendsKey;

  User({required this.username, required this.email , this.friendsKey});
 
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      friendsKey: json['friendsKey'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['email'] = email;
    data['friendsKey'] = friendsKey;
    return data;
  }
}
