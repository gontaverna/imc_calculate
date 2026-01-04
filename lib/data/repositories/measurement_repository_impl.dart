import 'package:hive_flutter/hive_flutter.dart';
import 'package:imc/domain/entities/measurement.dart';
import 'package:imc/domain/repositories/measurement_repository.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final Box<Measurement> box;

  MeasurementRepositoryImpl(this.box);

  @override
  Future<List<Measurement>> getMeasurements(String patientId) async {
    return box.values.where((m) => m.patientId == patientId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> insertMeasurement(Measurement measurement) async {
    await box.put(measurement.id, measurement);
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    await box.delete(id);
  }
}
