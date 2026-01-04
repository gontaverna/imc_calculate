import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imc/domain/entities/patient.dart';
import 'package:imc/presentation/providers/providers.dart';
import 'package:imc/presentation/screens/calculator_screen.dart';
import 'package:imc/presentation/screens/measurement_detail_screen.dart';
import 'package:imc/presentation/screens/edit_patient_screen.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends ConsumerWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  void _deletePatient(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Paciente'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este paciente y todas sus mediciones?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(patientListProvider.notifier).deletePatient(patient.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(measurementListProvider(patient.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.name} ${patient.lastName}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPatientScreen(patient: patient),
                  ),
                );
              } else if (value == 'delete') {
                _deletePatient(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoItem(label: 'Edad', value: '${patient.age}'),
                _InfoItem(
                  label: 'Género',
                  value: patient.gender == 'male' ? 'M' : 'F',
                ),
                _InfoItem(
                  label: 'Registro',
                  value: DateFormat('dd/MM/yy').format(patient.createdAt),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Progress List
          Expanded(
            child: measurementsAsync.when(
              data: (measurements) {
                if (measurements.isEmpty) {
                  return const Center(
                    child: Text('No hay mediciones registradas.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: measurements.length,
                  itemBuilder: (context, index) {
                    final measurement = measurements[index];
                    // Get calculated results for display (brief)
                    final calcService = ref.read(calculatorServiceProvider);
                    final healthResult = calcService.calculate(
                      patient,
                      measurement,
                    );

                    return Dismissible(
                      key: Key(measurement.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar Medición'),
                                content: const Text(
                                  '¿Deseas eliminar esta medición?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (direction) {
                        ref
                            .read(measurementListProvider(patient.id).notifier)
                            .deleteMeasurement(measurement.id);
                      },
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MeasurementDetailScreen(
                                patient: patient,
                                measurement: measurement,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(measurement.date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getImcColor(healthResult.imc),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'IMC ${healthResult.imc.toStringAsFixed(1)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _MeasurementItem(
                                      label: 'Peso',
                                      value: '${measurement.weight} kg',
                                    ),
                                    _MeasurementItem(
                                      label: 'Grasa',
                                      value:
                                          '${healthResult.fatsG.toStringAsFixed(0)} g',
                                    ), // Example metric
                                    _MeasurementItem(
                                      label: 'Kcal',
                                      value: healthResult.targetCalories
                                          .toStringAsFixed(0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalculatorScreen(patient: patient),
            ),
          );
        },
        label: const Text('Nueva Medición'),
        icon: const Icon(Icons.add_chart),
      ),
    );
  }

  Color _getImcColor(double imc) {
    if (imc < 18.5) return Colors.blue;
    if (imc < 24.9) return Colors.green;
    if (imc < 29.9) return Colors.orange;
    return Colors.red;
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _MeasurementItem extends StatelessWidget {
  final String label;
  final String value;
  const _MeasurementItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
