import 'rank.dart';

/// Unité d'un défi : des répétitions ou un temps (gainage, chaise...).
enum QuestUnit {
  reps('répétitions'),
  seconds('secondes');

  const QuestUnit(this.label);
  final String label;
}

/// Modèle d'un défi quotidien (au poids du corps, sans matériel).
///
/// L'objectif chiffré dépend du rang : `baseTarget + stepPerRank × indice`
/// (E=0, D=1, ... S=5). Ex. pompes base 10, step 10 → E:10, D:20, C:30...
class QuestTemplate {
  const QuestTemplate({
    required this.id,
    required this.nom,
    required this.unit,
    required this.baseTarget,
    required this.stepPerRank,
    required this.xpReward,
  });

  final String id;
  final String nom;
  final QuestUnit unit;
  final int baseTarget;
  final int stepPerRank;
  final int xpReward;

  /// L'objectif chiffré pour un rang donné.
  int targetForRank(Rank rank) => baseTarget + stepPerRank * rank.index;
}

/// La réserve de défis quotidiens (tous réalisables sans équipement).
const List<QuestTemplate> dailyQuestPool = [
  QuestTemplate(
    id: 'pushups',
    nom: 'Pompes',
    unit: QuestUnit.reps,
    baseTarget: 10,
    stepPerRank: 10,
    xpReward: 20,
  ),
  QuestTemplate(
    id: 'squats',
    nom: 'Squats',
    unit: QuestUnit.reps,
    baseTarget: 15,
    stepPerRank: 10,
    xpReward: 20,
  ),
  QuestTemplate(
    id: 'lunges',
    nom: 'Fentes',
    unit: QuestUnit.reps,
    baseTarget: 12,
    stepPerRank: 8,
    xpReward: 20,
  ),
  QuestTemplate(
    id: 'plank',
    nom: 'Gainage',
    unit: QuestUnit.seconds,
    baseTarget: 20,
    stepPerRank: 10,
    xpReward: 20,
  ),
  QuestTemplate(
    id: 'crunches',
    nom: 'Crunchs',
    unit: QuestUnit.reps,
    baseTarget: 15,
    stepPerRank: 10,
    xpReward: 15,
  ),
  QuestTemplate(
    id: 'jumping_jacks',
    nom: 'Jumping jacks',
    unit: QuestUnit.reps,
    baseTarget: 20,
    stepPerRank: 15,
    xpReward: 15,
  ),
  QuestTemplate(
    id: 'burpees',
    nom: 'Burpees',
    unit: QuestUnit.reps,
    baseTarget: 5,
    stepPerRank: 3,
    xpReward: 25,
  ),
  QuestTemplate(
    id: 'mountain_climbers',
    nom: 'Mountain climbers',
    unit: QuestUnit.reps,
    baseTarget: 20,
    stepPerRank: 10,
    xpReward: 15,
  ),
  QuestTemplate(
    id: 'wall_sit',
    nom: 'Chaise (wall sit)',
    unit: QuestUnit.seconds,
    baseTarget: 20,
    stepPerRank: 10,
    xpReward: 20,
  ),
  QuestTemplate(
    id: 'leg_raises',
    nom: 'Relevés de jambes',
    unit: QuestUnit.reps,
    baseTarget: 10,
    stepPerRank: 8,
    xpReward: 15,
  ),
];

/// Un défi quotidien concret (modèle + objectif chiffré pour le rang du jour).
class DailyQuest {
  const DailyQuest({
    required this.template,
    required this.target,
    required this.xpReward,
  });

  final QuestTemplate template;
  final int target;
  final int xpReward;

  /// Texte prêt à afficher, ex. « Faire 20 pompes » / « Tenir 30 s de gainage ».
  String get description {
    final nom = template.nom.toLowerCase();
    switch (template.unit) {
      case QuestUnit.reps:
        return 'Faire $target $nom';
      case QuestUnit.seconds:
        return 'Tenir $target s de $nom';
    }
  }
}

/// Renvoie les défis du jour pour un rang donné.
///
/// - [rank] : le rang du joueur (déduit de son niveau) → fixe la difficulté.
/// - [daySeed] : un numéro de jour (ex. jours depuis une date de référence)
///   → fait tourner les défis chaque jour, de façon déterministe.
/// - [count] : nombre de défis (3 par défaut).
List<DailyQuest> dailyQuestsForDay({
  required Rank rank,
  required int daySeed,
  int count = 3,
}) {
  final n = dailyQuestPool.length;
  final start = ((daySeed % n) + n) % n; // gère les valeurs négatives
  final quests = <DailyQuest>[];
  for (var i = 0; i < count && i < n; i++) {
    final t = dailyQuestPool[(start + i) % n];
    quests.add(DailyQuest(
      template: t,
      target: t.targetForRank(rank),
      xpReward: t.xpReward,
    ));
  }
  return quests;
}
