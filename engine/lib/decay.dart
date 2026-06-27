import 'level_rank.dart';
import 'rank.dart';
import 'xp.dart';

/// Réglages de la perte de progression (désentraînement).
class DecayConfig {
  const DecayConfig({
    this.graceDays = 4,
    this.decayDaysForOneLevel = 10,
  });

  /// Jours de repos sans aucune perte (repos sain).
  final int graceDays;

  /// Nombre de jours de perte (après la grâce) pour perdre ~1 niveau.
  /// Avec grâce=4 et cette valeur=10, il faut ~14 jours (2 semaines)
  /// d'inactivité pour perdre un niveau.
  final int decayDaysForOneLevel;
}

/// Résultat d'un calcul de perte d'XP pour cause d'inactivité.
class XpDecayResult {
  const XpDecayResult({
    required this.xpPerdu,
    required this.newTotalXp,
    required this.plancherAtteint,
    required this.niveauAvant,
    required this.niveauApres,
  });

  final int xpPerdu;
  final int newTotalXp;

  /// Vrai si le plancher de rang a empêché une perte plus importante.
  final bool plancherAtteint;

  final int niveauAvant;
  final int niveauApres;

  bool get aPerduUnNiveau => niveauApres < niveauAvant;
}

/// Calcule la perte d'XP due à l'inactivité, avec délai de grâce et
/// plancher de rang (on ne descend jamais sous le bas de son rang actuel).
///
/// - [totalXp] : XP total accumulé.
/// - [daysSinceLastWorkout] : jours écoulés depuis la dernière séance.
XpDecayResult applyXpDecay({
  required int totalXp,
  required int daysSinceLastWorkout,
  DecayConfig config = const DecayConfig(),
}) {
  final avant = levelFromTotalXp(totalXp);
  final rang = rankForLevel(avant.level);
  final plancherXp = totalXpForLevel(rankBaseLevel(rang));

  final decayDays = daysSinceLastWorkout - config.graceDays;

  // Pas de perte : encore dans la grâce, ou déjà au plancher de son rang.
  if (decayDays <= 0 || totalXp <= plancherXp) {
    return XpDecayResult(
      xpPerdu: 0,
      newTotalXp: totalXp,
      plancherAtteint: totalXp <= plancherXp,
      niveauAvant: avant.level,
      niveauApres: avant.level,
    );
  }

  // Rythme calé sur le coût du niveau juste en dessous : retirer ce coût
  // complet fait redescendre d'exactement un niveau.
  final niveauReference = avant.level > 1 ? avant.level - 1 : 1;
  final perDay = xpToNextLevel(niveauReference) / config.decayDaysForOneLevel;
  final xpLostBrut = (perDay * decayDays).round();

  var newTotal = totalXp - xpLostBrut;
  var plancher = false;
  if (newTotal < plancherXp) {
    newTotal = plancherXp;
    plancher = true;
  }

  final apres = levelFromTotalXp(newTotal);
  return XpDecayResult(
    xpPerdu: totalXp - newTotal,
    newTotalXp: newTotal,
    plancherAtteint: plancher,
    niveauAvant: avant.level,
    niveauApres: apres.level,
  );
}
