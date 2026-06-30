import 'package:mybody_rpg_engine/progression.dart';
import 'package:test/test.dart';

void main() {
  group('Fourchettes de reps selon l\'objectif', () {
    test('valeurs attendues', () {
      expect(TrainingGoal.endurance.minReps, 12);
      expect(TrainingGoal.endurance.maxReps, 20);
      expect(TrainingGoal.masse.minReps, 8);
      expect(TrainingGoal.masse.maxReps, 12);
      expect(TrainingGoal.force.minReps, 5);
      expect(TrainingGoal.force.maxReps, 8);
    });
  });

  group('Pas d\'augmentation du poids', () {
    test('bras = +2 kg', () {
      expect(weightIncrementKg(MuscleGroup.biceps), 2);
      expect(weightIncrementKg(MuscleGroup.triceps), 2);
    });
    test('haut du corps +2,5 kg, jambes +5 kg', () {
      expect(weightIncrementKg(MuscleGroup.pectoraux), 2.5);
      expect(weightIncrementKg(MuscleGroup.dos), 2.5);
      expect(weightIncrementKg(MuscleGroup.jambes), 5);
    });
  });

  group('Double progression', () {
    test('objectif atteint mais pas le max -> +1 rep', () {
      final r = applySession(
        state: const ProgressionState(weightKg: 60, targetReps: 9),
        repsPerSet: const [9, 9, 9],
        goal: TrainingGoal.masse, // 8-12
        group: MuscleGroup.pectoraux,
      );
      expect(r.outcome, ProgressOutcome.repUp);
      expect(r.next.weightKg, 60);
      expect(r.next.targetReps, 10);
    });

    test('haut de la fourchette atteint -> +poids et reset au min', () {
      final r = applySession(
        state: const ProgressionState(weightKg: 60, targetReps: 12),
        repsPerSet: const [12, 12, 12],
        goal: TrainingGoal.masse, // max 12
        group: MuscleGroup.pectoraux, // +5 kg
      );
      expect(r.outcome, ProgressOutcome.weightUp);
      expect(r.isMilestone, isTrue);
      expect(r.next.weightKg, 62.5); // pecs : +2,5 kg
      expect(r.next.targetReps, 8); // retour au bas de la fourchette
    });

    test('palier bras = +2 kg', () {
      final r = applySession(
        state: const ProgressionState(weightKg: 14, targetReps: 12),
        repsPerSet: const [12, 12],
        goal: TrainingGoal.masse,
        group: MuscleGroup.biceps,
      );
      expect(r.next.weightKg, 16);
    });

    test('objectif non atteint sur une série -> on garde tout', () {
      final r = applySession(
        state: const ProgressionState(weightKg: 60, targetReps: 10),
        repsPerSet: const [10, 9, 8], // une série en dessous
        goal: TrainingGoal.masse,
        group: MuscleGroup.pectoraux,
      );
      expect(r.outcome, ProgressOutcome.hold);
      expect(r.next.weightKg, 60);
      expect(r.next.targetReps, 10);
    });
  });
}
