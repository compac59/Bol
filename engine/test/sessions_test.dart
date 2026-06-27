import 'package:mybody_rpg_engine/catalog.dart';
import 'package:mybody_rpg_engine/progression.dart';
import 'package:mybody_rpg_engine/sessions.dart';
import 'package:test/test.dart';

void main() {
  final salleComplete = Equipment.values.toSet();

  group('Choix du split selon les jours', () {
    test('1-3 jours = full body, 4 = haut/bas, 5-6 = PPL', () {
      expect(splitForDays(3), SplitType.fullBody);
      expect(splitForDays(4), SplitType.upperLower);
      expect(splitForDays(6), SplitType.pushPullLegs);
    });
  });

  group('Génération de programme', () {
    test('3 jours = 3 séances full body', () {
      final plan = generateWeeklyPlan(
        equipment: salleComplete,
        goal: TrainingGoal.masse,
        daysPerWeek: 3,
      );
      expect(plan.split, SplitType.fullBody);
      expect(plan.days.length, 3);
      for (final d in plan.days) {
        expect(d.exercises, isNotEmpty);
      }
    });

    test('4 jours = haut/bas alterné', () {
      final plan = generateWeeklyPlan(
        equipment: salleComplete,
        goal: TrainingGoal.masse,
        daysPerWeek: 4,
      );
      expect(plan.days.map((d) => d.nom).toList(),
          ['Haut du corps', 'Bas du corps', 'Haut du corps', 'Bas du corps']);
    });

    test('6 jours = Push/Pull/Legs × 2', () {
      final plan = generateWeeklyPlan(
        equipment: salleComplete,
        goal: TrainingGoal.masse,
        daysPerWeek: 6,
      );
      expect(plan.split, SplitType.pushPullLegs);
      expect(plan.days.length, 6);
    });

    test('objectif force -> 4 séries, 5-8 reps, 3 min de repos', () {
      final plan = generateWeeklyPlan(
        equipment: salleComplete,
        goal: TrainingGoal.force,
        daysPerWeek: 3,
      );
      final premier = plan.days.first.exercises.first;
      expect(premier.sets, 4);
      expect(premier.minReps, 5);
      expect(premier.maxReps, 8);
      expect(premier.restSeconds, 180);
    });

    test('exercice poly-articulaire placé en premier pour un groupe', () {
      final plan = generateWeeklyPlan(
        equipment: salleComplete,
        goal: TrainingGoal.masse,
        daysPerWeek: 3,
      );
      // 1er exercice de la séance = jambes -> doit être un compound (squat...).
      expect(plan.days.first.exercises.first.exercise.isCompound, isTrue);
    });

    test('au poids du corps seul, le programme se génère quand même', () {
      final plan = generateWeeklyPlan(
        equipment: {},
        goal: TrainingGoal.endurance,
        daysPerWeek: 3,
      );
      expect(plan.days.first.exercises, isNotEmpty);
      // Tous les exercices ne demandent que le poids du corps.
      for (final d in plan.days) {
        for (final pe in d.exercises) {
          expect(pe.exercise.equipment, {Equipment.bodyweight});
        }
      }
    });
  });
}
