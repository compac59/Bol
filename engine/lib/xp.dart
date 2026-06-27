import 'dart:math';

/// Une série réalisée pendant une séance : `reps` répétitions à `charge` kg.
class WorkoutSet {
  const WorkoutSet({required this.reps, required this.charge});

  final int reps;
  final double charge; // kg

  /// Tonnage de la série = reps × charge (kg soulevés au total).
  double get tonnage => reps * charge;
}

/// Constantes d'équilibrage de l'XP (cf. PRD §3.1). Centralisées ici pour
/// pouvoir les ajuster facilement plus tard sans toucher au reste du code.
class XpConfig {
  const XpConfig({
    this.xpBase = 50,
    this.facteurVolume = 100, // 1 XP par 100 kg de tonnage
    this.xpParJourStreak = 10,
    this.streakMaxBonusJours = 7, // bonus de streak plafonné à 7 jours
    this.xpParRecord = 75,
    this.plafondXpParJour = 1000, // garde-fou anti-farm
  });

  final double xpBase;
  final double facteurVolume;
  final double xpParJourStreak;
  final int streakMaxBonusJours;
  final double xpParRecord;
  final double plafondXpParJour;
}

/// Détail du calcul d'XP d'une séance (pour l'afficher joliment à l'écran).
class XpBreakdown {
  const XpBreakdown({
    required this.base,
    required this.volume,
    required this.streak,
    required this.records,
    required this.quetes,
    required this.total,
    required this.plafonne,
  });

  final double base;
  final double volume;
  final double streak;
  final double records;
  final double quetes;

  /// XP total réellement attribué (après plafond éventuel).
  final double total;

  /// Vrai si le plafond anti-farm a réduit le total.
  final bool plafonne;

  @override
  String toString() => 'base:$base + volume:$volume + streak:$streak + '
      'records:$records + quetes:$quetes = $total'
      '${plafonne ? " (plafonné)" : ""}';
}

/// Calcule l'XP gagné pour une séance (cf. PRD §3.1).
///
/// - [sets] : toutes les séries de la séance.
/// - [streakJours] : nombre de jours d'entraînement d'affilée.
/// - [nbRecords] : nombre de records personnels battus pendant la séance.
/// - [xpQuetes] : XP issu des quêtes complétées.
XpBreakdown computeWorkoutXp({
  required List<WorkoutSet> sets,
  int streakJours = 0,
  int nbRecords = 0,
  double xpQuetes = 0,
  XpConfig config = const XpConfig(),
}) {
  final tonnage = sets.fold<double>(0, (sum, s) => sum + s.tonnage);

  final base = sets.isEmpty ? 0.0 : config.xpBase;
  final volume = tonnage / config.facteurVolume;
  final streak =
      min(streakJours, config.streakMaxBonusJours) * config.xpParJourStreak;
  final records = nbRecords * config.xpParRecord;

  final brut = base + volume + streak + records + xpQuetes;
  final total = min(brut, config.plafondXpParJour);

  return XpBreakdown(
    base: base,
    volume: volume,
    streak: streak.toDouble(),
    records: records,
    quetes: xpQuetes,
    total: total,
    plafonne: brut > config.plafondXpParJour,
  );
}

/// XP nécessaire pour passer du niveau [level] au niveau suivant.
///
/// Courbe du PRD : `100 × level^1.5` (arrondi).
/// Ex. niv 1→2 = 100, niv 2→3 = 283, niv 10→11 = 3162.
int xpToNextLevel(int level) {
  if (level < 1) return 0;
  return (100 * pow(level, 1.5)).round();
}

/// XP cumulé total nécessaire pour atteindre le niveau [level] depuis le niv 1.
int totalXpForLevel(int level) {
  var somme = 0;
  for (var n = 1; n < level; n++) {
    somme += xpToNextLevel(n);
  }
  return somme;
}

/// État de progression : à quel niveau on est avec un XP total donné, et
/// combien il reste avant le prochain niveau.
class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.xpDansNiveau,
    required this.xpPourNiveauSuivant,
  });

  final int level;

  /// XP déjà acquis à l'intérieur du niveau courant.
  final int xpDansNiveau;

  /// XP total requis pour finir le niveau courant.
  final int xpPourNiveauSuivant;

  /// Avancement dans le niveau courant, de 0.0 à 1.0 (pour la barre d'XP).
  double get fraction =>
      xpPourNiveauSuivant == 0 ? 0 : xpDansNiveau / xpPourNiveauSuivant;
}

/// Déduit le niveau et la progression à partir d'un XP total accumulé.
LevelProgress levelFromTotalXp(int totalXp) {
  var level = 1;
  var reste = totalXp;
  while (reste >= xpToNextLevel(level)) {
    reste -= xpToNextLevel(level);
    level++;
  }
  return LevelProgress(
    level: level,
    xpDansNiveau: reste,
    xpPourNiveauSuivant: xpToNextLevel(level),
  );
}
