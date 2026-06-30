import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';
import 'package:test/test.dart';

void main() {
  Exercise byId(String id) => exerciseCatalog.firstWhere((e) => e.id == id);

  group('Profil de force depuis le test', () {
    test('utilise les maxs renseignés et complète le reste', () {
      final p = strengthProfileFromTest(
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(exercise: AssessmentExercise.bench, charge: 80),
        ],
      );
      expect(p.bench, 80); // renseigné
      expect(p.squat, 60); // défaut 0.75 × 80
    });

    test('tractions -> 1RM de tirage basé sur le poids de corps', () {
      final p = strengthProfileFromTest(
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(exercise: AssessmentExercise.pullups, charge: 10),
        ],
      );
      // 80 × (1 + 10/30) ≈ 106.7
      expect(p.pull, closeTo(106.7, 0.1));
    });
  });

  group('Prescription de charge', () {
    final profile = strengthProfileFromTest(
      bodyWeightKg: 80,
      entries: const [
        PerformanceEntry(exercise: AssessmentExercise.bench, charge: 80),
        PerformanceEntry(exercise: AssessmentExercise.squat, charge: 120),
      ],
    );

    test('développé couché, objectif masse (8 reps, ~2 RIR)', () {
      final pr = prescribe(
        exercise: byId('bench_press'),
        profile: profile,
        goal: TrainingGoal.masse,
      );
      // 1RM 80, viser 8 reps + 2 RIR = 10 -> 80/(1+10/30)=60 -> arrondi 2,5 -> 60
      expect(pr.bodyweight, isFalse);
      expect(pr.suggestedWeightKg, 60);
      expect(pr.targetReps, 8);
    });

    test('tous les exercices du catalogue ont une charge conseillée', () {
      for (final ex in exerciseCatalog) {
        final pr =
            prescribe(exercise: ex, profile: profile, goal: TrainingGoal.masse);
        expect(pr.bodyweight, isFalse, reason: '${ex.id} sans charge');
        expect(pr.suggestedWeightKg, isNotNull, reason: '${ex.id} sans charge');
      }
    });

    test('objectif force = charge plus lourde que masse', () {
      final force = prescribe(
        exercise: byId('squat'),
        profile: profile,
        goal: TrainingGoal.force,
      );
      final endurance = prescribe(
        exercise: byId('squat'),
        profile: profile,
        goal: TrainingGoal.endurance,
      );
      expect(force.suggestedWeightKg! > endurance.suggestedWeightKg!, isTrue);
    });

    test('charge arrondie au palier (5 kg jambes, 2 kg bras)', () {
      final squat = prescribe(
          exercise: byId('squat'), profile: profile, goal: TrainingGoal.masse);
      final curl = prescribe(
          exercise: byId('db_curl'),
          profile: profile,
          goal: TrainingGoal.masse);
      expect(squat.suggestedWeightKg! % 5, 0);
      expect(curl.suggestedWeightKg! % 2, 0);
    });
  });
}
