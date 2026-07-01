import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';
import 'package:test/test.dart';

void main() {
  final salle = Equipment.values.toSet();

  group('Durée de séance', () {
    test('une durée plus courte = moins d\'exercices', () {
      final full = generateWeeklyPlan(
        equipment: salle,
        goal: TrainingGoal.masse,
        daysPerWeek: 3,
      ).days.first;

      final court = trimToDuration(full, 20);
      final long = trimToDuration(full, 90);

      expect(court.exercises.length, lessThan(long.exercises.length));
      expect(court.exercises, isNotEmpty); // au moins un exercice
    });

    test('la durée estimée respecte à peu près la cible', () {
      final day = generateWeeklyPlan(
        equipment: salle,
        goal: TrainingGoal.masse,
        daysPerWeek: 3,
      ).days.first;
      final trimmed = trimToDuration(day, 30);
      expect(estimatedDurationMinutes(trimmed), lessThanOrEqualTo(31));
    });

    test('garde toujours au moins un exercice même si durée minuscule', () {
      final day = generateWeeklyPlan(
        equipment: salle,
        goal: TrainingGoal.force,
        daysPerWeek: 3,
      ).days.first;
      expect(trimToDuration(day, 1).exercises.length, 1);
    });
  });
}
