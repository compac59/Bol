import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// État global de l'app, avec sauvegarde locale (shared_preferences).
///
/// Branche l'UI sur le moteur de jeu : profil, XP/niveau, rang, stats,
/// streak et défis du jour.
class AppState extends ChangeNotifier {
  static const _key = 'mybody_rpg_save_v1';
  SharedPreferences? _prefs;

  bool onboarded = false;

  String pseudo = '';
  double bodyWeight = 75;
  TrainingGoal goal = TrainingGoal.masse;
  Set<Equipment> equipment = {};
  int daysPerWeek = 3;
  int sessionMinutes = 45;

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

  /// Profil de force estimé (pour conseiller les charges).
  StrengthProfile profile = const StrengthProfile(
    bench: 40,
    squat: 60,
    deadlift: 80,
    overhead: 28,
    pull: 60,
  );

  /// Consigne (charge + reps) conseillée pour un exercice.
  ExercisePrescription prescriptionFor(Exercise ex) =>
      prescribe(exercise: ex, profile: profile, goal: goal);

  /// Défis du jour déjà complétés (par identifiant), et le jour concerné.
  Set<String> _questsDone = {};
  int _questsDoneDay = -1;

  // --- Valeurs dérivées ---
  LevelProgress get progress => levelFromTotalXp(totalXp);
  int get level => progress.level;

  int get today => dayIndex(DateTime.now());

  List<DailyQuest> get dailyQuests =>
      dailyQuestsForDay(rank: currentRank, daySeed: today);

  bool isQuestDone(DailyQuest q) =>
      _questsDoneDay == today && _questsDone.contains(q.template.id);

  bool promotionUnlocked() =>
      promotionAvailable(currentRank: currentRank, level: level);

  WeeklyPlan get weeklyPlan => generateWeeklyPlan(
        equipment: equipment,
        goal: goal,
        daysPerWeek: daysPerWeek,
      );

  WorkoutDay get todaysWorkout {
    final days = weeklyPlan.days;
    return days[today % days.length];
  }

  /// La séance du jour raccourcie pour tenir dans [minutes].
  WorkoutDay workoutForDuration(int minutes) =>
      trimToDuration(todaysWorkout, minutes);

  void setSessionMinutes(int minutes) {
    sessionMinutes = minutes;
    _save();
    notifyListeners();
  }

  // --- Chargement / sauvegarde ---
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_key);
    if (raw == null) return;
    try {
      _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // sauvegarde corrompue : on repart proprement
    }
    notifyListeners();
  }

  Future<void> _save() async {
    await _prefs?.setString(_key, jsonEncode(_toJson()));
  }

  /// Efface la sauvegarde et réinitialise (pour repartir de zéro).
  Future<void> reset() async {
    await _prefs?.remove(_key);
    onboarded = false;
    totalXp = 0;
    currentRank = Rank.e;
    equipment = {};
    streak = const StreakState();
    _questsDone = {};
    _questsDoneDay = -1;
    notifyListeners();
  }

  Map<String, dynamic> _toJson() => {
        'onboarded': onboarded,
        'pseudo': pseudo,
        'bodyWeight': bodyWeight,
        'goal': goal.name,
        'equipment': equipment.map((e) => e.name).toList(),
        'daysPerWeek': daysPerWeek,
        'sessionMinutes': sessionMinutes,
        'totalXp': totalXp,
        'currentRank': currentRank.name,
        'stats': {
          'force': stats.force,
          'endurance': stats.endurance,
          'explosivite': stats.explosivite,
          'volonte': stats.volonte,
          'vitalite': stats.vitalite,
        },
        'streak': {
          'current': streak.current,
          'best': streak.best,
          'lastActiveDay': streak.lastActiveDay,
          'freezesRemaining': streak.freezesRemaining,
        },
        'questsDone': _questsDone.toList(),
        'questsDoneDay': _questsDoneDay,
        'profile': {
          'bench': profile.bench,
          'squat': profile.squat,
          'deadlift': profile.deadlift,
          'overhead': profile.overhead,
          'pull': profile.pull,
        },
      };

  void _fromJson(Map<String, dynamic> j) {
    onboarded = j['onboarded'] as bool? ?? false;
    pseudo = j['pseudo'] as String? ?? '';
    bodyWeight = (j['bodyWeight'] as num?)?.toDouble() ?? 75;
    goal = TrainingGoal.values.byName(j['goal'] as String? ?? 'masse');
    equipment = ((j['equipment'] as List?) ?? [])
        .map((e) => Equipment.values.byName(e as String))
        .toSet();
    daysPerWeek = j['daysPerWeek'] as int? ?? 3;
    sessionMinutes = j['sessionMinutes'] as int? ?? 45;
    totalXp = j['totalXp'] as int? ?? 0;
    currentRank = Rank.values.byName(j['currentRank'] as String? ?? 'e');
    final st = j['stats'] as Map<String, dynamic>?;
    if (st != null) {
      stats = CharacterStats(
        force: st['force'] as int? ?? 10,
        endurance: st['endurance'] as int? ?? 10,
        explosivite: st['explosivite'] as int? ?? 10,
        volonte: st['volonte'] as int? ?? 10,
        vitalite: st['vitalite'] as int? ?? 10,
      );
    }
    final sk = j['streak'] as Map<String, dynamic>?;
    if (sk != null) {
      streak = StreakState(
        current: sk['current'] as int? ?? 0,
        best: sk['best'] as int? ?? 0,
        lastActiveDay: sk['lastActiveDay'] as int?,
        freezesRemaining: sk['freezesRemaining'] as int? ?? 2,
      );
    }
    _questsDone =
        ((j['questsDone'] as List?) ?? []).map((e) => e as String).toSet();
    _questsDoneDay = j['questsDoneDay'] as int? ?? -1;
    final pf = j['profile'] as Map<String, dynamic>?;
    if (pf != null) {
      profile = StrengthProfile(
        bench: (pf['bench'] as num).toDouble(),
        squat: (pf['squat'] as num).toDouble(),
        deadlift: (pf['deadlift'] as num).toDouble(),
        overhead: (pf['overhead'] as num).toDouble(),
        pull: (pf['pull'] as num).toDouble(),
      );
    } else {
      profile =
          strengthProfileFromTest(entries: const [], bodyWeightKg: bodyWeight);
    }
  }

  // --- Actions ---
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
    profile =
        strengthProfileFromTest(entries: testEntries, bodyWeightKg: bodyWeight);

    onboarded = true;
    _save();
    notifyListeners();
  }

  void _registerActivity() {
    streak = registerActivity(streak, today).state;
  }

  void gainXp(int amount, {bool activity = true}) {
    totalXp += amount;
    if (activity) _registerActivity();
    _save();
    notifyListeners();
  }

  void completeQuest(DailyQuest q) {
    if (_questsDoneDay != today) {
      _questsDone = {};
      _questsDoneDay = today;
    }
    if (_questsDone.contains(q.template.id)) return;
    _questsDone.add(q.template.id);
    gainXp(q.xpReward); // sauvegarde incluse
  }
}

/// Instance globale (simple pour cette première version).
final appState = AppState();
