import 'package:mybody_rpg_engine/catalog.dart';
import 'package:mybody_rpg_engine/progression.dart';
import 'package:mybody_rpg_engine/sessions.dart';
import 'package:mybody_rpg_engine/workout_session.dart';
import 'package:test/test.dart';

void main() {
  WorkoutDay sampleDay() => generateWeeklyPlan(
        equipment: Equipment.values.toSet(),
        goal: TrainingGoal.masse, // 3 séries / exercice, repos 90s
        daysPerWeek: 3,
      ).days.first;

  group('Suivi de séance', () {
    test('progression et validation des séries', () {
      final s = WorkoutSession(sampleDay());
      expect(s.progress, 0);
      expect(s.isComplete, isFalse);
      expect(s.currentExerciseIndex, 0);

      // 1re série -> renvoie le temps de repos.
      final rest = s.validateSet(0, reps: 10, weightKg: 60);
      expect(rest, 90);
      expect(s.setsDone, 1);
      expect(s.progress, greaterThan(0));
    });

    test('la dernière série d\'un exercice ne renvoie pas de repos', () {
      final s = WorkoutSession(sampleDay());
      s.validateSet(0, reps: 10, weightKg: 60); // 1
      s.validateSet(0, reps: 10, weightKg: 60); // 2
      final rest = s.validateSet(0, reps: 10, weightKg: 60); // 3 = dernière
      expect(rest, isNull);
      expect(s.isExerciseComplete(0), isTrue);
      expect(s.currentExerciseIndex, 1); // on passe à l'exercice suivant
    });

    test('valider au-delà du nombre de séries lève une erreur', () {
      final s = WorkoutSession(sampleDay());
      s.validateSet(0, reps: 8, weightKg: 60);
      s.validateSet(0, reps: 8, weightKg: 60);
      s.validateSet(0, reps: 8, weightKg: 60);
      expect(
        () => s.validateSet(0, reps: 8, weightKg: 60),
        throwsStateError,
      );
    });

    test('séance complète + bilan XP', () {
      final day = sampleDay();
      final s = WorkoutSession(day);
      for (var i = 0; i < day.exercises.length; i++) {
        for (var k = 0; k < day.exercises[i].sets; k++) {
          s.validateSet(i, reps: 10, weightKg: 50);
        }
      }
      expect(s.isComplete, isTrue);
      expect(s.progress, 1.0);
      final xp = s.computeXp(streakDays: 3, nbRecords: 1);
      expect(xp.total, greaterThan(0));
    });
  });

  group('Médias des exercices', () {
    test('chemin d\'illustration par convention', () {
      final bench = exerciseCatalog.firstWhere((e) => e.id == 'bench_press');
      expect(bench.imageAsset, 'assets/exercises/bench_press.gif');
    });

    test('lien vidéo valide et encodé', () {
      final bench = exerciseCatalog.firstWhere((e) => e.id == 'bench_press');
      expect(bench.videoSearchUrl, startsWith('https://www.youtube.com/'));
      expect(bench.videoSearchUrl, contains('musculation'));
    });
  });
}
