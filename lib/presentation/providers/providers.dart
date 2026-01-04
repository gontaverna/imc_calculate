import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:imc/data/repositories/measurement_repository_firestore.dart';
import 'package:imc/data/repositories/patient_repository_firestore.dart';
import 'package:imc/domain/entities/measurement.dart';
import 'package:imc/domain/entities/patient.dart';
import 'package:imc/domain/repositories/measurement_repository.dart';
import 'package:imc/domain/repositories/patient_repository.dart';
import 'package:imc/domain/services/calculator_service.dart';

// Services
final calculatorServiceProvider = Provider<CalculatorService>((ref) {
  return CalculatorService();
});

// Firebase Auth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Repositories
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  return PatientRepositoryFirestore(user?.uid);
});

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final user = ref.watch(authStateProvider).value;
  return MeasurementRepositoryFirestore(user?.uid);
});

// State Notifiers / Controllers

// Patients List
final patientListProvider =
    StateNotifierProvider<PatientListNotifier, AsyncValue<List<Patient>>>((
      ref,
    ) {
      final repository = ref.watch(patientRepositoryProvider);
      return PatientListNotifier(repository);
    });

class PatientListNotifier extends StateNotifier<AsyncValue<List<Patient>>> {
  final PatientRepository _repository;

  PatientListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    try {
      state = const AsyncValue.loading();
      final patients = await _repository.getPatients();
      state = AsyncValue.data(patients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      await _repository.insertPatient(patient);
      await loadPatients();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      await _repository.updatePatient(patient);
      await loadPatients();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      await _repository.deletePatient(id);
      await loadPatients();
    } catch (e) {
      // Handle error
    }
  }
}

// Measurements List (Family provider by patientId)
final measurementListProvider =
    StateNotifierProvider.family<
      MeasurementListNotifier,
      AsyncValue<List<Measurement>>,
      String
    >((ref, patientId) {
      final repository = ref.watch(measurementRepositoryProvider);
      return MeasurementListNotifier(repository, patientId);
    });

class MeasurementListNotifier
    extends StateNotifier<AsyncValue<List<Measurement>>> {
  final MeasurementRepository _repository;
  final String patientId;

  MeasurementListNotifier(this._repository, this.patientId)
    : super(const AsyncValue.loading()) {
    loadMeasurements();
  }

  Future<void> loadMeasurements() async {
    try {
      state = const AsyncValue.loading();
      final measurements = await _repository.getMeasurements(patientId);
      state = AsyncValue.data(measurements);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMeasurement(Measurement measurement) async {
    try {
      await _repository.insertMeasurement(measurement);
      await loadMeasurements();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteMeasurement(String id) async {
    try {
      await _repository.deleteMeasurement(id);
      await loadMeasurements();
    } catch (e) {
      // Handle error
    }
  }
}
