import 'sessions.dart';
import 'xp.dart';

/// Une série réellement réalisée et validée par le joueur.
class CompletedSet {
  const CompletedSet({required this.reps, required this.weightKg});
  final int reps;
  final double weightKg;
}

/// Suit une séance **en cours** : validation des séries, déclenchement du
/// repos, et bilan final (XP). Le compte à rebours du repos est géré côté UI ;
/// ici on fournit seulement la **durée** à lancer.
class WorkoutSession {
  WorkoutSession(this.day)
      : _done = {
          for (var i = 0; i < day.exercises.length; i++) i: <CompletedSet>[],
        };

  final WorkoutDay day;
  final Map<int, List<CompletedSet>> _done;

  /// Séries déjà validées pour l'exercice [i].
  List<CompletedSet> setsOf(int i) => List.unmodifiable(_done[i]!);

  /// Nombre de séries prévues pour l'exercice [i].
  int targetSets(int i) => day.exercises[i].sets;

  bool isExerciseComplete(int i) => _done[i]!.length >= targetSets(i);

  /// Index du premier exercice non terminé (null si la séance est finie).
  int? get currentExerciseIndex {
    for (var i = 0; i < day.exercises.length; i++) {
      if (!isExerciseComplete(i)) return i;
    }
    return null;
  }

  bool get isComplete => currentExerciseIndex == null;

  int get totalSets =>
      day.exercises.fold(0, (s, e) => s + e.sets);

  int get setsDone => _done.values.fold(0, (s, l) => s + l.length);

  /// Avancement global de la séance, de 0.0 à 1.0.
  double get progress => totalSets == 0 ? 0 : setsDone / totalSets;

  /// Valide une série de l'exercice [exerciseIndex].
  ///
  /// Renvoie le **temps de repos** conseillé (secondes) à lancer après la
  /// série, ou `null` si c'était la dernière série (exercice terminé →
  /// pas de repos à enchaîner).
  int? validateSet(
    int exerciseIndex, {
    required int reps,
    required double weightKg,
  }) {
    final list = _done[exerciseIndex]!;
    if (list.length >= targetSets(exerciseIndex)) {
      throw StateError('Toutes les séries de cet exercice sont déjà validées.');
    }
    list.add(CompletedSet(reps: reps, weightKg: weightKg));
    if (list.length >= targetSets(exerciseIndex)) return null; // exercice fini
    return day.exercises[exerciseIndex].restSeconds;
  }

  /// Toutes les séries validées, converties pour le calcul d'XP.
  List<WorkoutSet> toWorkoutSets() => [
        for (final list in _done.values)
          for (final s in list)
            WorkoutSet(reps: s.reps, charge: s.weightKg),
      ];

  /// Bilan d'XP de la séance (réutilise le moteur d'XP).
  XpBreakdown computeXp({
    int streakDays = 0,
    int nbRecords = 0,
    double questXp = 0,
  }) {
    return computeWorkoutXp(
      sets: toWorkoutSets(),
      streakJours: streakDays,
      nbRecords: nbRecords,
      xpQuetes: questXp,
    );
  }
}
