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

/// Prend [n] éléments de [pool] en partant de l'indice [rotation] (avec retour
/// au début), sans doublon. Sert à varier les exercices d'un jour à l'autre.
void _takeRotated(List<Exercise> pool, int n, int rotation, List<Exercise> out) {
  if (pool.isEmpty || n <= 0) return;
  for (var i = 0; i < n && i < pool.length; i++) {
    out.add(pool[(rotation + i) % pool.length]);
  }
}

/// Sélectionne jusqu'à [count] exercices d'un groupe, poly-articulaires
/// d'abord, parmi ceux réalisables avec l'équipement disponible.
///
/// [rotation] (l'indice du jour) décale la sélection pour **varier** les
/// exercices d'une séance à l'autre, en conservant le même nombre de
/// poly-articulaires / d'isolation.
List<Exercise> _pick(
  MuscleGroup group,
  int count,
  Set<Equipment> equipment,
  int rotation,
) {
  final candidats =
      availableExercises(equipment).where((e) => e.group == group).toList()
        ..sort((a, b) {
          if (a.isCompound == b.isCompound) return 0;
          return a.isCompound ? -1 : 1; // compounds en premier
        });
  if (candidats.isEmpty) return [];

  final compounds = candidats.where((e) => e.isCompound).toList();
  final isolations = candidats.where((e) => !e.isCompound).toList();

  // Combien de compounds dans une sélection « brute » des `count` premiers :
  // on garde ce ratio pour que la structure reste la même chaque jour.
  final nbCompound = candidats.take(count).where((e) => e.isCompound).length;

  final result = <Exercise>[];
  _takeRotated(compounds, nbCompound, rotation, result);
  _takeRotated(isolations, count - nbCompound, rotation, result);

  // Filet de sécurité : compléter si on n'a pas atteint `count`.
  for (final e in candidats) {
    if (result.length >= count) break;
    if (!result.contains(e)) result.add(e);
  }
  return result;
}

/// Temps de transition entre deux exercices (changement de machine,
/// installation) : 3 minutes.
const int transitionSeconds = 180;

/// Temps de travail d'un exercice (secondes) : séries + repos entre elles.
int exerciseWorkSeconds(PlannedExercise pe) {
  const workPerSet = 40; // secondes d'effort par série
  return pe.sets * workPerSet + (pe.sets - 1) * pe.restSeconds;
}

/// Durée totale estimée d'une séance, en minutes (travail + transitions).
int estimatedDurationMinutes(WorkoutDay day) {
  if (day.exercises.isEmpty) return 0;
  final work =
      day.exercises.fold<int>(0, (a, e) => a + exerciseWorkSeconds(e));
  final transitions = (day.exercises.length - 1) * transitionSeconds;
  return ((work + transitions) / 60).round();
}

/// Raccourcit une séance pour tenir dans [targetMinutes] : garde les exercices
/// dans l'ordre (poly-articulaires d'abord) tant qu'on ne dépasse pas la durée.
/// Conserve toujours au moins un exercice.
WorkoutDay trimToDuration(WorkoutDay day, int targetMinutes) {
  final target = targetMinutes * 60;
  final kept = <PlannedExercise>[];
  var acc = 0;
  for (final e in day.exercises) {
    final t = exerciseWorkSeconds(e) +
        (kept.isEmpty ? 0 : transitionSeconds);
    if (kept.isEmpty || acc + t <= target) {
      kept.add(e);
      acc += t;
    } else {
      break;
    }
  }
  return WorkoutDay(nom: day.nom, exercises: kept);
}

/// Ajuste une séance à la durée choisie : **étend** la séance avec d'autres
/// exercices des mêmes groupes musculaires (réalisables avec l'équipement)
/// si elle est trop courte, puis la **raccourcit** si elle est trop longue.
WorkoutDay fitToDuration({
  required WorkoutDay day,
  required int targetMinutes,
  required Set<Equipment> equipment,
  required TrainingGoal goal,
  int maxExercises = 12,
}) {
  if (day.exercises.isEmpty) return day;

  final target = targetMinutes * 60;
  final sets = _setsFor(goal);
  final rest = _restFor(goal);

  int totalOf(List<PlannedExercise> list) =>
      list.fold<int>(0, (a, e) => a + exerciseWorkSeconds(e)) +
      (list.length - 1) * transitionSeconds;

  final exercises = [...day.exercises];
  final usedIds = {for (final e in exercises) e.exercise.id};
  final groups = {for (final e in exercises) e.exercise.group}.toList();

  // Réserve d'exercices supplémentaires : mêmes groupes, équipement dispo,
  // pas déjà dans la séance ; poly-articulaires d'abord, en alternant les
  // groupes pour rester équilibré.
  final pool = <Exercise>[];
  final byGroup = {
    for (final g in groups)
      g: availableExercises(equipment)
          .where((e) => e.group == g && !usedIds.contains(e.id))
          .toList()
        ..sort((a, b) {
          if (a.isCompound == b.isCompound) return 0;
          return a.isCompound ? -1 : 1;
        }),
  };
  var added = true;
  while (added) {
    added = false;
    for (final g in groups) {
      final list = byGroup[g]!;
      if (list.isNotEmpty) {
        pool.add(list.removeAt(0));
        added = true;
      }
    }
  }

  // Extension : on ajoute tant que ça tient dans la durée cible.
  for (final ex in pool) {
    if (exercises.length >= maxExercises) break;
    final candidate = PlannedExercise(
      exercise: ex,
      sets: sets,
      minReps: goal.minReps,
      maxReps: goal.maxReps,
      restSeconds: rest,
    );
    final withCandidate = totalOf(exercises) +
        transitionSeconds +
        exerciseWorkSeconds(candidate);
    if (withCandidate <= target) {
      exercises.add(candidate);
    }
  }

  // Réduction si la base dépasse déjà la durée demandée.
  return trimToDuration(
      WorkoutDay(nom: day.nom, exercises: exercises), targetMinutes);
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
  for (var jour = 0; jour < templates.length; jour++) {
    final t = templates[jour];
    final exercises = <PlannedExercise>[];
    for (final g in t.groups) {
      for (final ex in _pick(g.group, g.count, equipment, jour)) {
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
