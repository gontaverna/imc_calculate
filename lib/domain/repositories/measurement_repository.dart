import 'package:imc/domain/entities/measurement.dart';

abstract class MeasurementRepository {
  Future<List<Measurement>> getMeasurements(String patientId);
  Future<void> insertMeasurement(Measurement measurement);
  Future<void> deleteMeasurement(String id);
}
