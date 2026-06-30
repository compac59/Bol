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

    test('développé couché, objectif masse (8 reps)', () {
      final pr = prescribe(
        exercise: byId('bench_press'),
        profile: profile,
        goal: TrainingGoal.masse,
      );
      // 1RM 80 -> 80/(1+8/30)=63.2 -> arrondi 5 -> 65
      expect(pr.bodyweight, isFalse);
      expect(pr.suggestedWeightKg, 65);
      expect(pr.targetReps, 8);
    });

    test('exercice au poids du corps -> pas de charge', () {
      final pr = prescribe(
        exercise: byId('pushups'),
        profile: profile,
        goal: TrainingGoal.masse,
      );
      expect(pr.bodyweight, isTrue);
      expect(pr.suggestedWeightKg, isNull);
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
