import 'dart:async';
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
  final user = ref.watch(authStateProvider).asData?.value;
  return PatientRepositoryFirestore(user?.uid);
});

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
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
  StreamSubscription? _subscription;

  PatientListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPatients();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void loadPatients() {
    _subscription?.cancel();
    _subscription = _repository.getPatients().listen(
      (patients) {
        state = AsyncValue.data(patients);
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );
  }

  Future<void> addPatient(Patient patient) async {
    await _repository.insertPatient(patient);
  }

  Future<void> updatePatient(Patient patient) async {
    await _repository.updatePatient(patient);
  }

  Future<void> deletePatient(String id) async {
    await _repository.deletePatient(id);
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
  StreamSubscription? _subscription;

  MeasurementListNotifier(this._repository, this.patientId)
    : super(const AsyncValue.loading()) {
    loadMeasurements();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void loadMeasurements() {
    _subscription?.cancel();
    _subscription = _repository
        .getMeasurements(patientId)
        .listen(
          (measurements) {
            state = AsyncValue.data(measurements);
          },
          onError: (e, st) {
            state = AsyncValue.error(e, st);
          },
        );
  }

  Future<void> addMeasurement(Measurement measurement) async {
    await _repository.insertMeasurement(measurement);
  }

  Future<void> deleteMeasurement(String id) async {
    await _repository.deleteMeasurement(id);
  }
}
