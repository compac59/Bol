import 'package:mybody_rpg_engine/assessment.dart';
import 'package:mybody_rpg_engine/baremes.dart';

/// Petite démo : lance le test initial pour un exemple et affiche le résultat.
/// À lancer avec :  dart run example/demo.dart
void main() {
  final result = evaluate(
    bodyWeightKg: 80,
    entries: const [
      PerformanceEntry(exercise: AssessmentExercise.bench, charge: 80),
      PerformanceEntry(exercise: AssessmentExercise.squat, charge: 120),
      PerformanceEntry(exercise: AssessmentExercise.deadlift, charge: 160),
      PerformanceEntry(exercise: AssessmentExercise.overhead, charge: 50),
      PerformanceEntry(exercise: AssessmentExercise.pullups, charge: 10),
    ],
  );

  print('=== Résultat du test initial (homme 80 kg) ===\n');
  print('Rang par exercice :');
  result.perExerciseRank.forEach((ex, rank) {
    print('  - ${ex.name.padRight(10)} : rang ${rank.label}');
  });
  print('');
  print('Rang global    : ${result.globalRank.label}');
  print('Niveau départ  : ${result.startingLevel}');
  print('Stats départ   : ${result.stats}');
}
