import 'package:mybody_rpg_engine/assessment.dart';
import 'package:mybody_rpg_engine/baremes.dart';
import 'package:mybody_rpg_engine/xp.dart';

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

  // --- Exemple de gain d'XP pour une séance ---
  print('\n=== Exemple : gain d\'XP d\'une séance ===\n');
  final xp = computeWorkoutXp(
    sets: const [
      WorkoutSet(reps: 10, charge: 60), // développé couché
      WorkoutSet(reps: 10, charge: 60),
      WorkoutSet(reps: 8, charge: 80), // squat
      WorkoutSet(reps: 8, charge: 80),
    ],
    streakJours: 3,
    nbRecords: 1,
  );
  print('Détail : ${xp}');
  print('XP gagné : ${xp.total.round()}');

  // --- Où ça mène en termes de niveau ---
  const totalXp = 500;
  final prog = levelFromTotalXp(totalXp);
  print('\nAvec $totalXp XP total -> niveau ${prog.level} '
      '(${prog.xpDansNiveau}/${prog.xpPourNiveauSuivant} XP, '
      '${(prog.fraction * 100).round()}% du niveau)');
}
