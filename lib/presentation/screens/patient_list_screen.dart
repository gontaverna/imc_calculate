import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imc/presentation/providers/providers.dart';
import 'package:imc/presentation/screens/add_patient_screen.dart';
import 'package:imc/presentation/screens/patient_detail_screen.dart';

class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes'), centerTitle: true),
      body: patientsAsync.when(
        data: (patients) {
          if (patients.isEmpty) {
            return const Center(
              child: Text(
                'No hay pacientes registrados.\nAgrega uno para comenzar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: patients.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(child: Text(patient.name[0])),
                  title: Text('${patient.name} ${patient.lastName}'),
                  subtitle: Text(
                    '${patient.age} años • ${patient.gender == 'male' ? 'Masculino' : 'Femenino'}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientDetailScreen(patient: patient),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPatientScreen()),
          );
        },
        label: const Text('Nuevo Paciente'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}
