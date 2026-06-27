import 'baremes.dart';
import 'rank.dart';

/// Une performance saisie par le joueur lors du test initial.
///
/// On accepte deux façons de faire :
/// - le joueur connaît son **1RM** (max sur 1 rep) → `reps == 1` ;
/// - sinon il donne une charge faite pour plusieurs reps → on **estime** le
///   1RM avec la formule d'Epley.
class PerformanceEntry {
  const PerformanceEntry({
    required this.exercise,
    required this.charge,
    this.reps = 1,
  });

  final AssessmentExercise exercise;

  /// Charge soulevée en kg. Pour les tractions, on met le **nombre de reps**
  /// ici (au poids du corps) et on laisse `reps` à 1.
  final double charge;

  /// Nombre de répétitions réalisées avec cette charge.
  final int reps;
}

/// Estime le 1RM (max sur 1 rep) à partir d'une charge faite pour N reps.
///
/// Formule d'Epley : `1RM ≈ charge × (1 + reps / 30)`.
/// Avec 1 rep, on retombe exactement sur la charge.
double estimateOneRm(double charge, int reps) {
  if (reps <= 1) return charge;
  return charge * (1 + reps / 30);
}

/// Le résultat complet du test initial.
class AssessmentResult {
  const AssessmentResult({
    required this.perExerciseRank,
    required this.globalRank,
    required this.startingLevel,
    required this.stats,
  });

  /// Le rang obtenu sur chaque exercice testé.
  final Map<AssessmentExercise, Rank> perExerciseRank;

  /// Le rang global (moyenne des rangs).
  final Rank globalRank;

  /// Le niveau de départ déduit du rang global.
  final int startingLevel;

  /// Les stats de départ : Force, Endurance, Explosivité, Volonté, Vitalité.
  final CharacterStats stats;
}

/// Les 5 stats du personnage.
class CharacterStats {
  const CharacterStats({
    required this.force,
    required this.endurance,
    required this.explosivite,
    required this.volonte,
    required this.vitalite,
  });

  final int force; // STR
  final int endurance; // END
  final int explosivite; // AGI
  final int volonte; // WIL
  final int vitalite; // VIT

  @override
  String toString() =>
      'STR:$force END:$endurance AGI:$explosivite WIL:$volonte VIT:$vitalite';
}

/// Niveau de départ selon le rang global (bas de la fourchette du PRD).
const Map<Rank, int> _startingLevelByRank = {
  Rank.e: 1,
  Rank.d: 10,
  Rank.c: 20,
  Rank.b: 35,
  Rank.a: 50,
  Rank.s: 70,
};

/// Valeur de stat associée à un rang (E faible → S élevé).
const Map<Rank, int> _statValueByRank = {
  Rank.e: 10,
  Rank.d: 20,
  Rank.c: 35,
  Rank.b: 50,
  Rank.a: 70,
  Rank.s: 90,
};

/// Calcule le résultat du test initial à partir des performances saisies
/// et du poids de corps du joueur.
AssessmentResult evaluate({
  required List<PerformanceEntry> entries,
  required double bodyWeightKg,
}) {
  if (entries.isEmpty) {
    throw ArgumentError('Au moins une performance est requise.');
  }

  // 1) Rang par exercice.
  final perExerciseRank = <AssessmentExercise, Rank>{};
  for (final e in entries) {
    final double valeur;
    if (isRepsBased(e.exercise)) {
      // Tractions : la "charge" porte le nombre de reps.
      valeur = e.charge;
    } else {
      final oneRm = estimateOneRm(e.charge, e.reps);
      valeur = oneRm / bodyWeightKg; // ratio force/poids
    }
    perExerciseRank[e.exercise] = rankForValue(e.exercise, valeur);
  }

  // 2) Rang global = moyenne (arrondie) des indices de rang.
  final indices = perExerciseRank.values.map((r) => r.index).toList();
  final moyenne = indices.reduce((a, b) => a + b) / indices.length;
  final globalRank = Rank.fromIndex(moyenne.round());

  // 3) Niveau de départ.
  final startingLevel = _startingLevelByRank[globalRank]!;

  // 4) Stats de départ (moyenne des valeurs de rang des exos concernés).
  final stats = _statsFromRanks(perExerciseRank);

  return AssessmentResult(
    perExerciseRank: perExerciseRank,
    globalRank: globalRank,
    startingLevel: startingLevel,
    stats: stats,
  );
}

/// Quels exercices nourrissent quelle stat (cf. baremes-force.md §4).
const Map<String, List<AssessmentExercise>> _statSources = {
  'force': [
    AssessmentExercise.bench,
    AssessmentExercise.squat,
    AssessmentExercise.deadlift,
    AssessmentExercise.overhead,
  ],
  'endurance': [AssessmentExercise.pullups],
  'explosivite': [AssessmentExercise.overhead],
  'volonte': [AssessmentExercise.pullups],
  'vitalite': [AssessmentExercise.squat, AssessmentExercise.deadlift],
};

CharacterStats _statsFromRanks(Map<AssessmentExercise, Rank> ranks) {
  int statFor(String key) {
    final sources = _statSources[key]!
        .where(ranks.containsKey)
        .map((ex) => _statValueByRank[ranks[ex]!]!)
        .toList();
    if (sources.isEmpty) return _statValueByRank[Rank.e]!; // plancher
    final somme = sources.reduce((a, b) => a + b);
    return (somme / sources.length).round();
  }

  return CharacterStats(
    force: statFor('force'),
    endurance: statFor('endurance'),
    explosivite: statFor('explosivite'),
    volonte: statFor('volonte'),
    vitalite: statFor('vitalite'),
  );
}
