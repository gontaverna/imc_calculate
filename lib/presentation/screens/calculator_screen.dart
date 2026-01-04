import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imc/domain/entities/patient.dart';
import 'package:imc/domain/entities/measurement.dart';
import 'package:imc/presentation/providers/providers.dart';
import 'package:uuid/uuid.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  final Patient patient;

  const CalculatorScreen({super.key, required this.patient});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController(); // kg
  final _heightController = TextEditingController(); // cm
  double _activityFactor = 1.375; // Poco ejercicio

  // Activity Factors mapping
  final Map<double, String> _activityFactors = {
    1.2: 'Sedentario (Poco o nada ejercicio)',
    1.375: 'Ligero (Ejercicio 1-3 días/sem)',
    1.55: 'Moderado (Ejercicio 3-5 días/sem)',
    1.725: 'Fuerte (Ejercicio 6-7 días/sem)',
    1.9: 'Muy fuerte (2 veces al día)',
  };

  void _saveMeasurement() {
    if (_formKey.currentState!.validate()) {
      final measurement = Measurement(
        id: const Uuid().v4(),
        patientId: widget.patient.id,
        date: DateTime.now(),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        activityFactor: _activityFactor,
      );

      ref
          .read(measurementListProvider(widget.patient.id).notifier)
          .addMeasurement(measurement);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Live Calculation
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    // Use a temp measurement object for calculation (id/date doesn't matter for calc)
    final tempMeasurement = Measurement(
      id: '',
      patientId: widget.patient.id,
      date: DateTime.now(),
      weight: weight,
      height: height,
      activityFactor: _activityFactor,
    );

    final calculator = ref.read(calculatorServiceProvider);

    // Only calculate if valid inputs
    final result = (weight > 0 && height > 0)
        ? calculator.calculate(widget.patient, tempMeasurement)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Medición'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: result != null ? _saveMeasurement : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Form
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() {}), // Rebuild for live calc
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0
                            ? null
                            : 'Requerido',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Altura (cm)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0
                            ? null
                            : 'Requerido',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<double>(
                        value: _activityFactor,
                        decoration: const InputDecoration(
                          labelText: 'Factor de Actividad',
                          border: OutlineInputBorder(),
                        ),
                        items: _activityFactors.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _activityFactor = v ?? 1.2),
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Live Results
            if (result != null) ...[
              const Text(
                'Resultados',
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
                      subtitle:
                          '${result.proteinsKcal.toStringAsFixed(0)} kcal',
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
      color:
          color?.withOpacity(0.1) ??
          Colors.grey[100], // Updated for Flutter 3.22+
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color?.withOpacity(0.5) ?? Colors.grey),
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
