import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:imc/domain/entities/measurement.dart';
import 'package:imc/domain/repositories/measurement_repository.dart';

class MeasurementRepositoryFirestore implements MeasurementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId;

  MeasurementRepositoryFirestore(this.userId);

  CollectionReference get _collection => _firestore
      .collection('users')
      .doc(userId ?? 'global')
      .collection('measurements');

  @override
  Future<List<Measurement>> getMeasurements(String patientId) async {
    final snapshot = await _collection
        .where('patientId', isEqualTo: patientId)
        .get();
    return snapshot.docs
        .map((doc) => Measurement.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> insertMeasurement(Measurement measurement) async {
    await _collection.doc(measurement.id).set(measurement.toMap());
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    await _collection.doc(id).delete();
  }
}
