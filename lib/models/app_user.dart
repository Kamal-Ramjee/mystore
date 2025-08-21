class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "phone": phone,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
    );
  }
}
