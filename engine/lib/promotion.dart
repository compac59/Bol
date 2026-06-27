import 'assessment.dart';
import 'baremes.dart';
import 'level_rank.dart';
import 'rank.dart';

/// Le rang juste au-dessus, ou null si on est déjà au maximum (S).
Rank? rankAbove(Rank r) {
  if (r.index >= Rank.values.length - 1) return null;
  return Rank.fromIndex(r.index + 1);
}

/// L'examen de promotion est-il débloqué ?
///
/// Il l'est quand le **niveau** atteint le seuil du rang supérieur — mais il
/// faudra encore le **réussir** (test de force) pour changer de rang.
bool promotionAvailable({required Rank currentRank, required int level}) {
  final target = rankAbove(currentRank);
  if (target == null) return false;
  return level >= rankBaseLevel(target);
}

/// Résultat d'un examen de promotion du chasseur.
class PromotionResult {
  const PromotionResult({
    required this.available,
    required this.passed,
    required this.targetRank,
    required this.achievedRank,
    required this.newRank,
    required this.message,
  });

  /// L'examen était débloqué (niveau suffisant).
  final bool available;

  /// L'examen a été réussi.
  final bool passed;

  /// Le rang visé (null si déjà au max).
  final Rank? targetRank;

  /// Le rang prouvé par le test de force passé pendant l'examen.
  final Rank achievedRank;

  /// Le rang après l'examen (= rang visé si réussi, sinon rang actuel).
  final Rank newRank;

  final String message;
}

/// Passe l'**examen de promotion du chasseur** : on refait le test de force
/// initial, et la promotion n'est accordée que si le niveau de force atteint
/// (ou dépasse) celui du rang visé.
///
/// - [currentRank] : rang actuel du joueur.
/// - [level] : niveau actuel (débloque l'examen).
/// - [entries] / [bodyWeightKg] : la performance refaite pour l'examen.
PromotionResult evaluatePromotion({
  required Rank currentRank,
  required int level,
  required List<PerformanceEntry> entries,
  required double bodyWeightKg,
}) {
  final target = rankAbove(currentRank);

  if (target == null) {
    return PromotionResult(
      available: false,
      passed: false,
      targetRank: null,
      achievedRank: currentRank,
      newRank: currentRank,
      message: 'Tu es déjà au rang maximum (S).',
    );
  }

  if (level < rankBaseLevel(target)) {
    return PromotionResult(
      available: false,
      passed: false,
      targetRank: target,
      achievedRank: currentRank,
      newRank: currentRank,
      message: 'Examen verrouillé : atteins le niveau ${rankBaseLevel(target)} '
          'pour tenter le rang ${target.label}.',
    );
  }

  // On refait le test de force.
  final exam = evaluate(entries: entries, bodyWeightKg: bodyWeightKg);
  final achieved = exam.globalRank;
  final passed = achieved.index >= target.index;

  return PromotionResult(
    available: true,
    passed: passed,
    targetRank: target,
    achievedRank: achieved,
    newRank: passed ? target : currentRank,
    message: passed
        ? '🎉 Examen de promotion réussi ! Tu passes rang ${target.label}.'
        : 'Examen échoué : ta force correspond au rang ${achieved.label}. '
            'Continue à t\'entraîner et retente bientôt !',
  );
}
