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

  @HiveField(6)
  final int? ageAtMeasurement;
  @HiveField(7)
  final String? genderAtMeasurement;

  Measurement({
    required this.id,
    required this.patientId,
    required this.date,
    required this.weight,
    required this.height,
    required this.activityFactor,
    this.ageAtMeasurement,
    this.genderAtMeasurement,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'date': date.toIso8601String(),
      'weight': weight,
      'height': height,
      'activityFactor': activityFactor,
      'ageAtMeasurement': ageAtMeasurement,
      'genderAtMeasurement': genderAtMeasurement,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      weight: (map['weight'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      activityFactor: (map['activityFactor'] ?? 1.2).toDouble(),
      ageAtMeasurement: map['ageAtMeasurement'],
      genderAtMeasurement: map['genderAtMeasurement'],
    );
  }
}
