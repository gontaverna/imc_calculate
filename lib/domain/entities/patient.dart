import 'package:hive/hive.dart';

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String lastName;
  @HiveField(3)
  final String gender; // 'male' or 'female'
  @HiveField(4)
  final DateTime birthDate;
  @HiveField(5)
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    required this.createdAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
