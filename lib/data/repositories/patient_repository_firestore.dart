import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:imc/domain/entities/patient.dart';
import 'package:imc/domain/repositories/patient_repository.dart';

class PatientRepositoryFirestore implements PatientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId;

  PatientRepositoryFirestore(this.userId);

  @override
  Stream<List<Patient>> getPatients() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Future<void> insertPatient(Patient patient) async {
    await _collection.doc(patient.id).set(patient.toMap());
  }

  @override
  Future<void> deletePatient(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    await _collection.doc(patient.id).update(patient.toMap());
  }
}
