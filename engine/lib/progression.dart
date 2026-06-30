/// L'objectif d'entraînement, choisi par le joueur à la création du profil.
/// Il détermine la **fourchette de répétitions** visée sur chaque exercice.
enum TrainingGoal {
  /// Endurance musculaire : beaucoup de reps, charges légères.
  endurance(minReps: 12, maxReps: 20, label: 'Endurance'),

  /// Prise de masse (hypertrophie) : fourchette intermédiaire.
  masse(minReps: 8, maxReps: 12, label: 'Prise de masse'),

  /// Force / charge : peu de reps, charges lourdes.
  force(minReps: 5, maxReps: 8, label: 'Force');

  const TrainingGoal({
    required this.minReps,
    required this.maxReps,
    required this.label,
  });

  final int minReps;
  final int maxReps;
  final String label;
}

/// Groupes musculaires (utilisés pour le pas d'augmentation du poids).
enum MuscleGroup {
  pectoraux,
  dos,
  epaules,
  biceps,
  triceps,
  jambes,
  abdos,
}

/// De combien on augmente le poids quand un palier est débloqué.
///
/// Basé sur les preuves (incréments fixes ~2-5 %, plus petits pour le haut
/// du corps) :
/// - bas du corps (jambes) : +5 kg ;
/// - haut du corps poly-articulaire (pecs, dos) : +2,5 kg ;
/// - petits muscles / isolation (épaules, bras, abdos) : +2 kg.
double weightIncrementKg(MuscleGroup group) {
  switch (group) {
    case MuscleGroup.jambes:
      return 5;
    case MuscleGroup.pectoraux:
    case MuscleGroup.dos:
      return 2.5;
    case MuscleGroup.epaules:
    case MuscleGroup.biceps:
    case MuscleGroup.triceps:
    case MuscleGroup.abdos:
      return 2;
  }
}

/// L'état de progression d'un exercice pour un joueur : le poids de travail
/// actuel et l'objectif de reps en cours (dans la fourchette de l'objectif).
class ProgressionState {
  const ProgressionState({required this.weightKg, required this.targetReps});

  final double weightKg;
  final int targetReps;
}

/// Le type d'évolution décidé après une séance.
enum ProgressOutcome {
  /// Objectif atteint : on ajoute une répétition pour la prochaine fois.
  repUp,

  /// Haut de la fourchette atteint : on augmente le poids (= palier débloqué).
  weightUp,

  /// Objectif non atteint : on reste sur le même poids/reps et on réessaie.
  hold,
}

/// Le résultat d'une séance pour un exercice : le nouvel état + un message
/// prêt à afficher au joueur.
class ProgressionResult {
  const ProgressionResult({
    required this.outcome,
    required this.next,
    required this.message,
  });

  final ProgressOutcome outcome;
  final ProgressionState next;
  final String message;

  /// Vrai si un palier de poids vient d'être débloqué (pour fêter ça + XP).
  bool get isMilestone => outcome == ProgressOutcome.weightUp;
}

/// Applique la **double progression** après une séance.
///
/// Règle :
/// - si **toutes** les séries atteignent l'objectif de reps en cours :
///   - si on est déjà au **haut de la fourchette** → on augmente le poids et
///     on repart au bas de la fourchette (**palier débloqué**) ;
///   - sinon → on vise **+1 rep** la prochaine fois ;
/// - sinon → on garde le même objectif et on réessaie.
ProgressionResult applySession({
  required ProgressionState state,
  required List<int> repsPerSet,
  required TrainingGoal goal,
  required MuscleGroup group,
}) {
  final toutesReussies =
      repsPerSet.isNotEmpty && repsPerSet.every((r) => r >= state.targetReps);

  if (!toutesReussies) {
    return ProgressionResult(
      outcome: ProgressOutcome.hold,
      next: state,
      message: 'Presque ! Garde ${state.weightKg.toStringAsFixed(1)} kg et '
          'vise ${state.targetReps} reps sur toutes tes séries.',
    );
  }

  if (state.targetReps >= goal.maxReps) {
    final increment = weightIncrementKg(group);
    final next = ProgressionState(
      weightKg: state.weightKg + increment,
      targetReps: goal.minReps,
    );
    return ProgressionResult(
      outcome: ProgressOutcome.weightUp,
      next: next,
      message: '🎉 Palier débloqué ! Passe à '
          '${next.weightKg.toStringAsFixed(1)} kg '
          '(+${increment.toStringAsFixed(0)} kg) et recommence à '
          '${goal.minReps} reps.',
    );
  }

  final next = ProgressionState(
    weightKg: state.weightKg,
    targetReps: state.targetReps + 1,
  );
  return ProgressionResult(
    outcome: ProgressOutcome.repUp,
    next: next,
    message: 'Bravo ! La prochaine fois, vise ${next.targetReps} reps à '
        '${state.weightKg.toStringAsFixed(1)} kg.',
  );
}
