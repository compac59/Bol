/// État du streak (jours d'entraînement d'affilée).
///
/// Un « jour » est représenté par un entier (numéro de jour). Utilise
/// [dayIndex] pour le calculer depuis une date.
class StreakState {
  const StreakState({
    this.current = 0,
    this.best = 0,
    this.lastActiveDay,
    this.freezesRemaining = 2,
  });

  /// Streak actuel (jours consécutifs).
  final int current;

  /// Meilleur streak atteint (record).
  final int best;

  /// Numéro du dernier jour d'activité (null si jamais actif).
  final int? lastActiveDay;

  /// Jokers de « gel de streak » restants (couvrent un jour manqué).
  final int freezesRemaining;
}

/// Résultat d'un enregistrement d'activité.
class StreakUpdate {
  const StreakUpdate({
    required this.state,
    required this.incremented,
    required this.alreadyCountedToday,
    required this.freezesUsed,
    required this.reset,
  });

  final StreakState state;

  /// Le streak a augmenté avec cette activité.
  final bool incremented;

  /// L'activité d'aujourd'hui avait déjà été comptée (rien ne change).
  final bool alreadyCountedToday;

  /// Nombre de jokers consommés pour sauver le streak.
  final int freezesUsed;

  /// Le streak était cassé : il est reparti à 1.
  final bool reset;
}

/// Convertit une date en numéro de jour (jours depuis l'époque, en UTC).
int dayIndex(DateTime date) {
  final utc = DateTime.utc(date.year, date.month, date.day);
  return utc.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}

/// Enregistre une activité le jour [today] et met à jour le streak.
StreakUpdate registerActivity(StreakState s, int today) {
  // Première activité.
  if (s.lastActiveDay == null) {
    return StreakUpdate(
      state: StreakState(
        current: 1,
        best: s.best < 1 ? 1 : s.best,
        lastActiveDay: today,
        freezesRemaining: s.freezesRemaining,
      ),
      incremented: true,
      alreadyCountedToday: false,
      freezesUsed: 0,
      reset: false,
    );
  }

  final last = s.lastActiveDay!;

  // Déjà compté aujourd'hui, ou date dans le passé : on ne change rien.
  if (today <= last) {
    return StreakUpdate(
      state: s,
      incremented: false,
      alreadyCountedToday: today == last,
      freezesUsed: 0,
      reset: false,
    );
  }

  final gap = today - last;

  StreakUpdate grow(int newCurrent, int freezesUsed, {bool reset = false}) {
    return StreakUpdate(
      state: StreakState(
        current: newCurrent,
        best: newCurrent > s.best ? newCurrent : s.best,
        lastActiveDay: today,
        freezesRemaining: s.freezesRemaining - freezesUsed,
      ),
      incremented: true,
      alreadyCountedToday: false,
      freezesUsed: freezesUsed,
      reset: reset,
    );
  }

  // Jour suivant : streak continue.
  if (gap == 1) return grow(s.current + 1, 0);

  // Jours manqués : les jokers peuvent sauver le streak.
  final missed = gap - 1;
  if (missed <= s.freezesRemaining) {
    return grow(s.current + 1, missed);
  }

  // Trop de jours manqués : le streak repart à 1.
  return grow(1, 0, reset: true);
}

/// Vrai si, au jour [today], le streak est rompu (sans nouvelle activité et
/// sans assez de jokers pour couvrir les jours manqués).
bool streakIsBroken(StreakState s, int today) {
  if (s.lastActiveDay == null) return false;
  final missed = today - s.lastActiveDay! - 1;
  return missed > s.freezesRemaining;
}
