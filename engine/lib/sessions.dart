import 'catalog.dart';
import 'progression.dart';

/// Le type de découpage hebdomadaire, choisi selon le nombre de jours.
enum SplitType {
  fullBody('Full body'),
  upperLower('Haut / Bas'),
  pushPullLegs('Push / Pull / Legs');

  const SplitType(this.label);
  final String label;
}

/// Un exercice planifié dans une séance : séries, fourchette de reps, repos.
class PlannedExercise {
  const PlannedExercise({
    required this.exercise,
    required this.sets,
    required this.minReps,
    required this.maxReps,
    required this.restSeconds,
  });

  final Exercise exercise;
  final int sets;
  final int minReps;
  final int maxReps;
  final int restSeconds;
}

/// Une séance : un nom + la liste des exercices planifiés.
class WorkoutDay {
  const WorkoutDay({required this.nom, required this.exercises});
  final String nom;
  final List<PlannedExercise> exercises;
}

/// Un programme hebdomadaire généré.
class WeeklyPlan {
  const WeeklyPlan({required this.split, required this.days});
  final SplitType split;
  final List<WorkoutDay> days;
}

/// Nombre de séries de travail par exercice selon l'objectif.
int _setsFor(TrainingGoal goal) => goal == TrainingGoal.force ? 4 : 3;

/// Temps de repos conseillé (secondes) selon l'objectif.
int _restFor(TrainingGoal goal) {
  switch (goal) {
    case TrainingGoal.force:
      return 180;
    case TrainingGoal.masse:
      return 90;
    case TrainingGoal.endurance:
      return 45;
  }
}

/// Combien d'exercices viser par groupe musculaire, pour une « case » de séance.
class _GroupPick {
  const _GroupPick(this.group, this.count);
  final MuscleGroup group;
  final int count;
}

class _DayTemplate {
  const _DayTemplate(this.nom, this.groups);
  final String nom;
  final List<_GroupPick> groups;
}

// --- Modèles de séances (basés sur les splits classiques) ---

const _fullBody = [
  _GroupPick(MuscleGroup.jambes, 1),
  _GroupPick(MuscleGroup.pectoraux, 1),
  _GroupPick(MuscleGroup.dos, 1),
  _GroupPick(MuscleGroup.epaules, 1),
  _GroupPick(MuscleGroup.biceps, 1),
  _GroupPick(MuscleGroup.triceps, 1),
];

const _upper = [
  _GroupPick(MuscleGroup.pectoraux, 2),
  _GroupPick(MuscleGroup.dos, 2),
  _GroupPick(MuscleGroup.epaules, 1),
  _GroupPick(MuscleGroup.biceps, 1),
  _GroupPick(MuscleGroup.triceps, 1),
];

const _lower = [
  _GroupPick(MuscleGroup.jambes, 4),
  _GroupPick(MuscleGroup.abdos, 2),
];

const _push = [
  _GroupPick(MuscleGroup.pectoraux, 2),
  _GroupPick(MuscleGroup.epaules, 2),
  _GroupPick(MuscleGroup.triceps, 2),
];

const _pull = [
  _GroupPick(MuscleGroup.dos, 3),
  _GroupPick(MuscleGroup.biceps, 2),
  _GroupPick(MuscleGroup.abdos, 1),
];

const _legs = [
  _GroupPick(MuscleGroup.jambes, 4),
  _GroupPick(MuscleGroup.abdos, 2),
];

/// Choisit le type de split selon le nombre de jours par semaine.
SplitType splitForDays(int daysPerWeek) {
  if (daysPerWeek <= 3) return SplitType.fullBody;
  if (daysPerWeek == 4) return SplitType.upperLower;
  return SplitType.pushPullLegs;
}

List<_DayTemplate> _templatesFor(SplitType split, int days) {
  switch (split) {
    case SplitType.fullBody:
      return [
        for (var i = 1; i <= days; i++) _DayTemplate('Full body $i', _fullBody),
      ];
    case SplitType.upperLower:
      const cycle = [
        _DayTemplate('Haut du corps', _upper),
        _DayTemplate('Bas du corps', _lower),
      ];
      return [for (var i = 0; i < days; i++) cycle[i % cycle.length]];
    case SplitType.pushPullLegs:
      const cycle = [
        _DayTemplate('Push (pousser)', _push),
        _DayTemplate('Pull (tirer)', _pull),
        _DayTemplate('Legs (jambes)', _legs),
      ];
      return [for (var i = 0; i < days; i++) cycle[i % cycle.length]];
  }
}

/// Sélectionne jusqu'à [count] exercices d'un groupe, poly-articulaires
/// d'abord, parmi ceux réalisables avec l'équipement disponible.
List<Exercise> _pick(MuscleGroup group, int count, Set<Equipment> equipment) {
  final candidats =
      availableExercises(equipment).where((e) => e.group == group).toList()
        ..sort((a, b) {
          if (a.isCompound == b.isCompound) return 0;
          return a.isCompound ? -1 : 1; // compounds en premier
        });
  return candidats.take(count).toList();
}

/// Génère un programme hebdomadaire adapté à l'équipement et à l'objectif.
///
/// - [equipment] : matériel coché dans le profil.
/// - [goal] : objectif (force / masse / endurance) → reps, séries, repos.
/// - [daysPerWeek] : nombre de séances → choix du split.
WeeklyPlan generateWeeklyPlan({
  required Set<Equipment> equipment,
  required TrainingGoal goal,
  required int daysPerWeek,
}) {
  final split = splitForDays(daysPerWeek);
  final templates = _templatesFor(split, daysPerWeek);
  final sets = _setsFor(goal);
  final rest = _restFor(goal);

  final days = <WorkoutDay>[];
  for (final t in templates) {
    final exercises = <PlannedExercise>[];
    for (final g in t.groups) {
      for (final ex in _pick(g.group, g.count, equipment)) {
        exercises.add(PlannedExercise(
          exercise: ex,
          sets: sets,
          minReps: goal.minReps,
          maxReps: goal.maxReps,
          restSeconds: rest,
        ));
      }
    }
    days.add(WorkoutDay(nom: t.nom, exercises: exercises));
  }
  return WeeklyPlan(split: split, days: days);
}
