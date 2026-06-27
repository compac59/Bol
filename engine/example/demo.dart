import 'package:mybody_rpg_engine/assessment.dart';
import 'package:mybody_rpg_engine/baremes.dart';
import 'package:mybody_rpg_engine/catalog.dart';
import 'package:mybody_rpg_engine/decay.dart';
import 'package:mybody_rpg_engine/progression.dart';
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

  // Exemple ciblé : homme 80 kg qui ne renseigne que le bench à 65 kg.
  final benchSeul = evaluate(
    bodyWeightKg: 80,
    entries: const [
      PerformanceEntry(exercise: AssessmentExercise.bench, charge: 65),
    ],
  );
  print('\nHomme 80 kg, bench 65 kg (ratio 0.81) -> '
      'rang ${benchSeul.globalRank.label}, niveau ${benchSeul.startingLevel} '
      '(et non niveau 10 = tout début du rang D)');

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

  // --- Double progression sur le développé couché (objectif : prise de masse) ---
  print('\n=== Progression : développé couché (objectif prise de masse) ===\n');
  const goal = TrainingGoal.masse; // 8-12 reps
  const group = MuscleGroup.pectoraux; // +5 kg par palier
  var state = const ProgressionState(weightKg: 60, targetReps: 11);

  // On simule 4 séances où le joueur réussit son objectif à chaque fois.
  for (var seance = 1; seance <= 4; seance++) {
    final reps = List.filled(3, state.targetReps); // 3 séries réussies
    final res = applySession(
      state: state,
      repsPerSet: reps,
      goal: goal,
      group: group,
    );
    print('Séance $seance : ${state.weightKg.toStringAsFixed(0)} kg × '
        '${state.targetReps} reps -> ${res.message}');
    state = res.next;
  }

  // --- Perte d'XP par inactivité (désentraînement) ---
  print('\n=== Perte d\'XP si on ne s\'entraîne pas ===\n');
  final xpJoueur = totalXpForLevel(5); // joueur pile au niveau 5
  for (final jours in [4, 7, 14, 30]) {
    final d = applyXpDecay(totalXp: xpJoueur, daysSinceLastWorkout: jours);
    final note = d.aPerduUnNiveau ? ' (niveau perdu !)' : '';
    final plancher = d.plancherAtteint ? ' [plancher de rang]' : '';
    print('$jours jours sans séance -> -${d.xpPerdu} XP, '
        'niveau ${d.niveauAvant} → ${d.niveauApres}$note$plancher');
  }

  // --- Exercices proposés selon l'équipement du profil ---
  print('\n=== Exercices proposés selon l\'équipement ===\n');
  afficheSalle('À la maison (haltères + banc plat)', {
    Equipment.dumbbells,
    Equipment.flatBench,
  });
  afficheSalle('Sans matériel (poids du corps)', {});
  print('Salle complète : ${availableExercises(Equipment.values.toSet()).length} '
      'exercices disponibles');
}

void afficheSalle(String titre, Set<Equipment> equipement) {
  final parGroupe = availableExercisesByGroup(equipement);
  final total = parGroupe.values.fold<int>(0, (s, l) => s + l.length);
  print('$titre -> $total exercices :');
  parGroupe.forEach((groupe, exos) {
    print('  ${groupe.name} : ${exos.map((e) => e.nom).join(', ')}');
  });
  print('');
}
