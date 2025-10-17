import '../services/database_helper.dart';

/// Contact model class representing a contact in the database
class Contact {
  final int? id;
  final String name;
  final int age;

  Contact({
    this.id,
    required this.name,
    required this.age,
  });

  // Convert Contact to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnAge: age,
    };
  }

  // Create a Contact from a Map (database query result)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map[DatabaseHelper.columnId] as int?,
      name: map[DatabaseHelper.columnName] as String,
      age: map[DatabaseHelper.columnAge] as int,
    );
  }

  // Create a copy of Contact with optional field updates
  Contact copyWith({
    int? id,
    String? name,
    int? age,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, age: $age}';
  }
}