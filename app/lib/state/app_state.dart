import 'package:flutter/foundation.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

/// État global de l'app (en mémoire pour cette première version).
///
/// Branche l'UI sur le moteur de jeu : profil, XP/niveau, rang, stats,
/// streak et défis du jour.
class AppState extends ChangeNotifier {
  bool onboarded = false;

  String pseudo = '';
  double bodyWeight = 75;
  TrainingGoal goal = TrainingGoal.masse;
  Set<Equipment> equipment = {};
  int daysPerWeek = 3;

  int totalXp = 0;
  Rank currentRank = Rank.e;
  CharacterStats stats = const CharacterStats(
    force: 10,
    endurance: 10,
    explosivite: 10,
    volonte: 10,
    vitalite: 10,
  );
  StreakState streak = const StreakState();

  /// Défis du jour déjà complétés (par identifiant).
  final Set<String> _questsDone = {};

  // --- Valeurs dérivées ---
  LevelProgress get progress => levelFromTotalXp(totalXp);
  int get level => progress.level;

  int get today => dayIndex(DateTime.now());

  List<DailyQuest> get dailyQuests =>
      dailyQuestsForDay(rank: currentRank, daySeed: today);

  bool isQuestDone(DailyQuest q) => _questsDone.contains(q.template.id);

  bool promotionUnlocked() =>
      promotionAvailable(currentRank: currentRank, level: level);

  /// Finalise l'onboarding et calcule le point de départ via le test de force.
  void completeOnboarding({
    required String pseudo,
    required double bodyWeight,
    required TrainingGoal goal,
    required Set<Equipment> equipment,
    required int daysPerWeek,
    required List<PerformanceEntry> testEntries,
  }) {
    this.pseudo = pseudo;
    this.bodyWeight = bodyWeight;
    this.goal = goal;
    this.equipment = equipment;
    this.daysPerWeek = daysPerWeek;

    if (testEntries.isNotEmpty) {
      final result = evaluate(entries: testEntries, bodyWeightKg: bodyWeight);
      currentRank = result.globalRank;
      stats = result.stats;
      totalXp = totalXpForLevel(result.startingLevel);
    } else {
      currentRank = Rank.e;
      totalXp = 0;
    }

    onboarded = true;
    notifyListeners();
  }

  /// Programme hebdomadaire généré pour le profil.
  WeeklyPlan get weeklyPlan => generateWeeklyPlan(
        equipment: equipment,
        goal: goal,
        daysPerWeek: daysPerWeek,
      );

  /// La séance du jour (tourne selon le jour).
  WorkoutDay get todaysWorkout {
    final days = weeklyPlan.days;
    return days[today % days.length];
  }

  void _registerActivity() {
    streak = registerActivity(streak, today).state;
  }

  /// Ajoute de l'XP et compte une activité du jour.
  void gainXp(int amount, {bool activity = true}) {
    totalXp += amount;
    if (activity) _registerActivity();
    notifyListeners();
  }

  /// Marque un défi comme complété (rapporte son XP, une seule fois).
  void completeQuest(DailyQuest q) {
    if (_questsDone.contains(q.template.id)) return;
    _questsDone.add(q.template.id);
    gainXp(q.xpReward);
  }
}

/// Instance globale (simple pour cette première version).
final appState = AppState();
