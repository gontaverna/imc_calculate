import 'package:hive_flutter/hive_flutter.dart';
import 'package:imc/domain/entities/patient.dart';
import 'package:imc/domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final Box<Patient> box;

  PatientRepositoryImpl(this.box);

  @override
  Future<List<Patient>> getPatients() async {
    return box.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> insertPatient(Patient patient) async {
    await box.put(patient.id, patient);
  }

  @override
  Future<void> deletePatient(String id) async {
    await box.delete(id);
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    await box.put(patient.id, patient);
  }
}
