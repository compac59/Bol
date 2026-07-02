import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';
import 'package:test/test.dart';

void main() {
  final salle = Equipment.values.toSet();

  WorkoutDay base() => generateWeeklyPlan(
        equipment: salle,
        goal: TrainingGoal.masse,
        daysPerWeek: 3,
      ).days.first;

  WorkoutDay fit(int minutes) => fitToDuration(
        day: base(),
        targetMinutes: minutes,
        equipment: salle,
        goal: TrainingGoal.masse,
      );

  group('Séance ajustée à la durée choisie', () {
    test('45 / 60 / 90 min donnent des séances différentes', () {
      final n30 = fit(30).exercises.length;
      final n45 = fit(45).exercises.length;
      final n60 = fit(60).exercises.length;
      final n90 = fit(90).exercises.length;
      expect(n30, lessThan(n45));
      expect(n45, lessThan(n60));
      expect(n60, lessThan(n90));
    });

    test('la durée estimée ne dépasse pas la cible', () {
      for (final m in [30, 45, 60, 90]) {
        final d = fit(m);
        expect(estimatedDurationMinutes(d), lessThanOrEqualTo(m),
            reason: 'cible $m min');
      }
    });

    test('la durée estimée remplit raisonnablement la cible (>= 70 %)', () {
      for (final m in [45, 60, 90]) {
        final d = fit(m);
        expect(estimatedDurationMinutes(d),
            greaterThanOrEqualTo((m * 0.7).floor()),
            reason: 'cible $m min trop peu remplie');
      }
    });

    test('pas de doublon d\'exercice dans une séance étendue', () {
      final ids = fit(90).exercises.map((e) => e.exercise.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('transition de 3 min comptée entre les exercices', () {
      expect(transitionSeconds, 180);
      final d = fit(45);
      final work =
          d.exercises.fold<int>(0, (a, e) => a + exerciseWorkSeconds(e));
      final attendu =
          ((work + (d.exercises.length - 1) * 180) / 60).round();
      expect(estimatedDurationMinutes(d), attendu);
    });

    test('garde toujours au moins un exercice même si durée minuscule', () {
      expect(fit(1).exercises.length, 1);
    });

    test('séance vide (aucun équipement) reste vide sans planter', () {
      final vide = generateWeeklyPlan(
        equipment: {},
        goal: TrainingGoal.masse,
        daysPerWeek: 3,
      ).days.first;
      final d = fitToDuration(
        day: vide,
        targetMinutes: 60,
        equipment: {},
        goal: TrainingGoal.masse,
      );
      expect(d.exercises, isEmpty);
    });
  });
}
