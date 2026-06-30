import 'assessment.dart';
import 'baremes.dart';
import 'catalog.dart';
import 'progression.dart';

/// Mouvements de référence dont on connaît (ou estime) le 1RM via le test.
enum RefLift { bench, squat, deadlift, overhead, pull }

/// Profil de force du joueur : un 1RM estimé (kg) par mouvement de référence.
class StrengthProfile {
  const StrengthProfile({
    required this.bench,
    required this.squat,
    required this.deadlift,
    required this.overhead,
    required this.pull,
  });

  final double bench;
  final double squat;
  final double deadlift;
  final double overhead;
  final double pull;

  double of(RefLift r) {
    switch (r) {
      case RefLift.bench:
        return bench;
      case RefLift.squat:
        return squat;
      case RefLift.deadlift:
        return deadlift;
      case RefLift.overhead:
        return overhead;
      case RefLift.pull:
        return pull;
    }
  }
}

/// Construit le profil de force depuis le test d'entrée. Les mouvements non
/// renseignés reçoivent une estimation prudente basée sur le poids de corps
/// (seuils du rang E).
StrengthProfile strengthProfileFromTest({
  required List<PerformanceEntry> entries,
  required double bodyWeightKg,
}) {
  double? bench, squat, deadlift, overhead, pull;
  for (final e in entries) {
    switch (e.exercise) {
      case AssessmentExercise.bench:
        bench = estimateOneRm(e.charge, e.reps);
        break;
      case AssessmentExercise.squat:
        squat = estimateOneRm(e.charge, e.reps);
        break;
      case AssessmentExercise.deadlift:
        deadlift = estimateOneRm(e.charge, e.reps);
        break;
      case AssessmentExercise.overhead:
        overhead = estimateOneRm(e.charge, e.reps);
        break;
      case AssessmentExercise.pullups:
        // "charge" porte le nombre de tractions : 1RM ≈ poids de corps soulevé.
        pull = bodyWeightKg * (1 + e.charge / 30);
        break;
    }
  }
  return StrengthProfile(
    bench: bench ?? 0.50 * bodyWeightKg,
    squat: squat ?? 0.75 * bodyWeightKg,
    deadlift: deadlift ?? 1.00 * bodyWeightKg,
    overhead: overhead ?? 0.35 * bodyWeightKg,
    pull: pull ?? 0.80 * bodyWeightKg,
  );
}

/// Coefficient d'estimation du 1RM de chaque exercice par rapport à un
/// mouvement de référence (valeurs indicatives, affinées ensuite par la
/// progression). Pour les haltères, la valeur vise la charge **par haltère**.
const Map<String, (RefLift, double)> _exerciseCoef = {
  // Pectoraux
  'bench_press': (RefLift.bench, 1.00),
  'incline_press': (RefLift.bench, 0.85),
  'db_press': (RefLift.bench, 0.40),
  'db_incline_press': (RefLift.bench, 0.35),
  'chest_press_machine': (RefLift.bench, 1.00),
  'pec_deck': (RefLift.bench, 0.50),
  'cable_fly': (RefLift.bench, 0.35),
  // Dos
  'barbell_row': (RefLift.bench, 0.80),
  'db_row': (RefLift.bench, 0.40),
  'lat_pulldown': (RefLift.pull, 0.90),
  'seated_row': (RefLift.pull, 0.90),
  'deadlift': (RefLift.deadlift, 1.00),
  'kb_swing': (RefLift.deadlift, 0.25),
  'band_row': (RefLift.pull, 0.40),
  // Épaules
  'ohp': (RefLift.overhead, 1.00),
  'db_shoulder_press': (RefLift.overhead, 0.40),
  'shoulder_press_machine': (RefLift.overhead, 0.90),
  'lateral_raise': (RefLift.overhead, 0.20),
  'face_pull': (RefLift.overhead, 0.40),
  'band_pull_apart': (RefLift.overhead, 0.25),
  // Biceps
  'barbell_curl': (RefLift.bench, 0.35),
  'ez_curl': (RefLift.bench, 0.33),
  'db_curl': (RefLift.bench, 0.16),
  'hammer_curl': (RefLift.bench, 0.18),
  'cable_curl': (RefLift.bench, 0.30),
  // Triceps
  'pushdown': (RefLift.bench, 0.40),
  'skull_crusher': (RefLift.bench, 0.30),
  'db_overhead_ext': (RefLift.bench, 0.16),
  // Jambes
  'squat': (RefLift.squat, 1.00),
  'smith_squat': (RefLift.squat, 0.90),
  'leg_press': (RefLift.squat, 1.80),
  'goblet_squat': (RefLift.squat, 0.35),
  'db_lunges': (RefLift.squat, 0.25),
  'leg_extension': (RefLift.squat, 0.55),
  'leg_curl': (RefLift.squat, 0.40),
  'calf_raise': (RefLift.squat, 0.80),
  // Abdos
  'cable_crunch': (RefLift.bench, 0.40),
};

/// La consigne pour un exercice : charge conseillée (ou poids du corps) + reps.
class ExercisePrescription {
  const ExercisePrescription({
    required this.suggestedWeightKg,
    required this.targetReps,
    required this.bodyweight,
  });

  /// Charge conseillée en kg (null si exercice au poids du corps).
  final double? suggestedWeightKg;

  /// Répétitions à viser (bas de la fourchette de l'objectif → marge de
  /// progression avant d'augmenter la charge).
  final int targetReps;

  /// Vrai si l'exercice se fait au poids du corps (pas de charge).
  final bool bodyweight;
}

double _roundTo(double value, double step) {
  final r = (value / step).round() * step;
  return r < step ? step : r;
}

/// Calcule la charge et les reps conseillées pour un exercice, à partir du
/// profil de force et de l'objectif.
ExercisePrescription prescribe({
  required Exercise exercise,
  required StrengthProfile profile,
  required TrainingGoal goal,
}) {
  final targetReps = goal.minReps;

  // Exercice au poids du corps : pas de charge à proposer.
  if (exercise.equipment.length == 1 &&
      exercise.equipment.contains(Equipment.bodyweight)) {
    return ExercisePrescription(
      suggestedWeightKg: null,
      targetReps: targetReps,
      bodyweight: true,
    );
  }

  final coef = _exerciseCoef[exercise.id] ?? (RefLift.bench, 0.30);
  final oneRm = profile.of(coef.$1) * coef.$2;

  // Charge de DÉPART en gardant ~2 reps en réserve (RIR) : on calcule comme si
  // on visait quelques reps de plus, pour ne pas démarrer à l'échec.
  const rir = 2;
  final raw = oneRm / (1 + (targetReps + rir) / 30);
  final step = weightIncrementKg(exercise.group); // 2 kg bras, 5 kg gros groupes
  final weight = _roundTo(raw, step);

  return ExercisePrescription(
    suggestedWeightKg: weight,
    targetReps: targetReps,
    bodyweight: false,
  );
}
