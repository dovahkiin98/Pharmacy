import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  static FromFirestore<User> fromFirestore = (snapshot, _) {
    final data = snapshot.data() as Map<String, dynamic>;

    return User(
      id: snapshot.id,
      name: data['name'] ?? '',
    );
  };

  static ToFirestore<User> toFirestore = (category, _) => category.toJson();

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
