import 'package:imc/domain/entities/patient.dart';
import 'package:imc/domain/entities/measurement.dart';

class HealthResult {
  final double imc;
  final String imcCategory;
  final double mbMiffin;
  final double mbHarris;
  final double getMiffin;
  final double getHarris;
  // Calorias objetivo (Average of GETs or specific choice? Usually GET + Goal. Assuming Maintenance for now if not specified)
  final double targetCalories;
  final double proteinsG;
  final double proteinsKcal;
  final double fatsG;
  final double fatsKcal;
  final double carbsG;
  final double carbsKcal;
  final double totalCaloric; // Same as target?
  final double hydration; // Liters

  HealthResult({
    required this.imc,
    required this.imcCategory,
    required this.mbMiffin,
    required this.mbHarris,
    required this.getMiffin,
    required this.getHarris,
    required this.targetCalories,
    required this.proteinsG,
    required this.proteinsKcal,
    required this.fatsG,
    required this.fatsKcal,
    required this.carbsG,
    required this.carbsKcal,
    required this.totalCaloric,
    required this.hydration,
  });
}

class CalculatorService {
  HealthResult calculate(Patient patient, Measurement measurement) {
    int age = patient.age;
    bool isMale = patient.gender.toLowerCase() == 'male';
    double weight = measurement.weight;
    double height = measurement.height; // cm

    // 1. IMC
    // IMC = weight (kg) / height (m)^2
    double heightM = height / 100.0;
    double imc = weight / (heightM * heightM);
    String imcCategory = _getImcCategory(imc);

    // 2. MB (Metabolismo Basal)

    // Miffin-St Jeor
    // Men: (10 × weight) + (6.25 × height) - (5 × age) + 5
    // Women: (10 × weight) + (6.25 × height) - (5 × age) - 161
    double mbMiffin = (10 * weight) + (6.25 * height) - (5 * age);
    mbMiffin += isMale ? 5 : -161;

    // Harris-Benedict (Revised)
    // Men: 88.362 + (13.397 × weight) + (4.799 × height) - (5.677 × age)
    // Women: 447.593 + (9.247 × weight) + (3.098 × height) - (4.330 × age)
    double mbHarris;
    if (isMale) {
      mbHarris = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      mbHarris = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    // 3. GET (Gasto Energético Total) = MB * ActivityFactor
    double getMiffin = mbMiffin * measurement.activityFactor;
    double getHarris = mbHarris * measurement.activityFactor;

    // Using Miffin as primary for Target Calories as it's generally considered more accurate for modern populations
    double targetCals = getMiffin; // TODO: Add goal adjustment (lose/gain)

    // 4. Macros (Standard distribution: 30% P / 35% F / 35% C or 40/30/30 - let's use standard balanced 30P/30F/40C or similar.
    // Actually, protein is often based on body weight (e.g. 2g/kg).
    // Let's use a standard percentage split for now: 25% P, 25% F, 50% C is USDA?
    // Fitness standard: 2g/kg Protein?
    // Let's stick to percentages for simplicity unless specified: 30% Protein, 30% Fat, 40% Carbs.

    double pRatio = 0.30;
    double fRatio = 0.30;
    double cRatio = 0.40;

    double proteinsKcal = targetCals * pRatio;
    double fatsKcal = targetCals * fRatio;
    double carbsKcal = targetCals * cRatio;

    double proteinsG = proteinsKcal / 4;
    double fatsG = fatsKcal / 9;
    double carbsG = carbsKcal / 4;

    // 5. Hydration (35ml per kg)
    double hydration = weight * 0.035;

    return HealthResult(
      imc: imc,
      imcCategory: imcCategory,
      mbMiffin: mbMiffin,
      mbHarris: mbHarris,
      getMiffin: getMiffin,
      getHarris: getHarris,
      targetCalories: targetCals,
      proteinsG: proteinsG,
      proteinsKcal: proteinsKcal,
      fatsG: fatsG,
      fatsKcal: fatsKcal,
      carbsG: carbsG,
      carbsKcal: carbsKcal,
      totalCaloric: targetCals,
      hydration: hydration,
    );
  }

  String _getImcCategory(double imc) {
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 24.9) return 'Peso normal';
    if (imc < 29.9) return 'Sobrepeso';
    return 'Obesidad';
  }
}
