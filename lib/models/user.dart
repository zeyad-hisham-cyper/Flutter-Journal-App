/*
 * File Name   : user.dart
 * Description : User profile data model with authentication credentials.
 * Author      : Zeyad Hisham
 * Date        : January 2026
 */

class User {
  int? id;
  String email;
  String password;
  String name;
  String createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
  });

  /*
   * Convert User to Map for database storage
   * Returns: Map containing user data
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'createdAt': createdAt,
    };
  }

  /*
   * Create User from database Map
   * Parameters: map - Database row data
   * Returns: User object
   */
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      createdAt: map['createdAt'],
    );
  }

  /*
   * Create a copy of User with updated fields
   * Returns: New User with modified values
   */
  User copyWith({
    int? id,
    String? email,
    String? password,
    String? name,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
