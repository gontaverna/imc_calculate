import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imc/domain/entities/measurement.dart';
import 'package:imc/domain/entities/patient.dart';
import 'package:imc/presentation/providers/providers.dart';
import 'package:intl/intl.dart';

class MeasurementDetailScreen extends ConsumerWidget {
  final Patient patient;
  final Measurement measurement;

  const MeasurementDetailScreen({
    super.key,
    required this.patient,
    required this.measurement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = ref.read(calculatorServiceProvider);
    final result = calculator.calculate(patient, measurement);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd MMM yyyy').format(measurement.date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Medición'),
                  content: const Text(
                    '¿Estás seguro de que deseas eliminar esta medición?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                ref
                    .read(measurementListProvider(patient.id).notifier)
                    .deleteMeasurement(measurement.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Peso',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '${measurement.weight} kg',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Altura',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '${measurement.height} cm',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Factor Act.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '${measurement.activityFactor}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results Reuse
            const Text(
              'Resultados Completos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _ResultCard(
              title: 'IMC',
              value: result.imc.toStringAsFixed(1),
              subtitle: result.imcCategory,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _ResultCard(
                    title: 'MB (Miffin)',
                    value: '${result.mbMiffin.toStringAsFixed(0)} kcal',
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ResultCard(
                    title: 'GET (Miffin)',
                    value: '${result.getMiffin.toStringAsFixed(0)} kcal',
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _ResultCard(
                    title: 'MB (Harris)',
                    value: '${result.mbHarris.toStringAsFixed(0)} kcal',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ResultCard(
                    title: 'GET (Harris)',
                    value: '${result.getHarris.toStringAsFixed(0)} kcal',
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _ResultCard(
              title: 'Objetivo Calórico',
              value: '${result.targetCalories.toStringAsFixed(0)} kcal',
              color: Colors.green,
            ),
            const SizedBox(height: 8),

            const Text(
              'Macros Sugeridos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ResultCard(
                    title: 'Proteínas',
                    value: '${result.proteinsG.toStringAsFixed(0)}g',
                    subtitle: '${result.proteinsKcal.toStringAsFixed(0)} kcal',
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ResultCard(
                    title: 'Grasas',
                    value: '${result.fatsG.toStringAsFixed(0)}g',
                    subtitle: '${result.fatsKcal.toStringAsFixed(0)} kcal',
                    color: Colors.yellow[800],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ResultCard(
                    title: 'Carbos',
                    value: '${result.carbsG.toStringAsFixed(0)}g',
                    subtitle: '${result.carbsKcal.toStringAsFixed(0)} kcal',
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ResultCard(
              title: 'Hidratación',
              value: '${result.hydration.toStringAsFixed(1)} L',
              color: Colors.lightBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;

  const _ResultCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color?.withopacity(0.1) ?? Colors.grey[100],
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color?.withopacity(0.5) ?? Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color ?? Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension ColorOp on Color {
  Color withopacity(double opacity) => withOpacity(opacity);
}
