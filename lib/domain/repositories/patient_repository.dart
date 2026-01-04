import 'package:imc/domain/entities/patient.dart';

abstract class PatientRepository {
  Stream<List<Patient>> getPatients();
  Future<void> insertPatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<void> updatePatient(Patient patient);
}
