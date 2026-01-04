import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:imc/domain/entities/measurement.dart';
import 'package:imc/domain/entities/patient.dart';
import 'package:imc/presentation/screens/patient_list_screen.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(MeasurementAdapter());

  await Hive.openBox<Patient>('patients');
  await Hive.openBox<Measurement>('measurements');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persona Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const PatientListScreen(),
    );
  }
}
