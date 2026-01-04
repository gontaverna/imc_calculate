import 'package:hive/hive.dart';

part 'measurement.g.dart';

@HiveType(typeId: 1)
class Measurement {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String patientId;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final double weight; // kg
  @HiveField(4)
  final double height; // cm
  @HiveField(5)
  final double activityFactor; // 1.2, 1.375, etc.

  Measurement({
    required this.id,
    required this.patientId,
    required this.date,
    required this.weight,
    required this.height,
    required this.activityFactor,
  });
}
