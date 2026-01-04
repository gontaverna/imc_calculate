import 'package:imc/domain/entities/measurement.dart';

abstract class MeasurementRepository {
  Stream<List<Measurement>> getMeasurements(String patientId);
  Future<void> insertMeasurement(Measurement measurement);
  Future<void> deleteMeasurement(String id);
}
