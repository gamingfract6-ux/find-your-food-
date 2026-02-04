//


class User {
  final int id;
  final String email;
  final String name;
  final String? profilePic;
  final int? age;
  final double? height;
  final double? weight;
  final String? gender;
  final String? fitnessGoal;
  final String? dietaryPreference;
  final List<String>? allergies;
  final String? region;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePic,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.fitnessGoal,
    this.dietaryPreference,
    this.allergies,
    this.region,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profilePic: json['profile_pic'],
      age: json['age'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      gender: json['gender'],
      fitnessGoal: json['fitness_goal'],
      dietaryPreference: json['dietary_preference'],
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies'])
          : null,
      region: json['region'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_pic': profilePic,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'fitness_goal': fitnessGoal,
      'dietary_preference': dietaryPreference,
      'allergies': allergies,
      'region': region,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
