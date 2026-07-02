import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';
import 'package:mybody_rpg/screens/home_screen.dart';
import 'package:mybody_rpg/screens/profile_screen.dart';
import 'package:mybody_rpg/screens/workout_screen.dart';
import 'package:mybody_rpg/state/app_state.dart';

void main() {
  testWidgets('La séance affiche des exercices', (tester) async {
    appState.onboarded = true;
    appState.pseudo = 'Test';
    appState.equipment = Equipment.values.toSet();
    appState.goal = TrainingGoal.masse;
    appState.daysPerWeek = 3;
    appState.totalXp = 0;
    appState.currentRank = Rank.e;

    final day = appState.todaysWorkout;
    await tester.pumpWidget(MaterialApp(home: WorkoutScreen(day: day)));
    await tester.pumpAndSettle();

    expect(day.exercises, isNotEmpty);
    expect(find.text(day.exercises.first.exercise.nom), findsOneWidget);
  });

  testWidgets('L\'écran de séance ne plante pour aucun profil', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final equipSets = <Set<Equipment>>[
      {Equipment.dumbbells},
      {Equipment.barbell, Equipment.flatBench, Equipment.squatRack},
      Equipment.values.toSet(),
    ];
    for (final eq in equipSets) {
      for (final g in TrainingGoal.values) {
        for (final d in [1, 4, 6]) {
          appState.onboarded = true;
          appState.equipment = eq;
          appState.goal = g;
          appState.daysPerWeek = d;

          final day = appState.todaysWorkout;
          await tester.pumpWidget(MaterialApp(
            home: WorkoutScreen(key: ValueKey('$eq-$g-$d'), day: day),
          ));
          await tester.pumpAndSettle();

          expect(day.exercises, isNotEmpty,
              reason: 'séance vide pour eq=${eq.length} goal=${g.name} d=$d');
          expect(find.text(day.exercises.first.exercise.nom), findsWidgets,
              reason: 'rendu vide pour eq=${eq.length} goal=${g.name} d=$d');
        }
      }
    }
  });

  testWidgets('Le bouton Démarrer propose une durée puis ouvre la séance',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    appState.onboarded = true;
    appState.equipment = Equipment.values.toSet();
    appState.goal = TrainingGoal.masse;
    appState.daysPerWeek = 3;

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('DÉMARRER'));
    await tester.pumpAndSettle();

    // Le choix de durée apparaît avec les options.
    expect(find.text('Durée de la séance ?'), findsOneWidget);
    expect(find.text('45 minutes'), findsOneWidget);
    expect(find.text('60 minutes'), findsOneWidget);
  });

  testWidgets('Progression automatique : +1 rep puis palier de charge',
      (tester) async {
    appState.goal = TrainingGoal.masse;
    appState.exerciseProgress.clear();
    final ex = exerciseCatalog.firstWhere((e) => e.id == 'bench_press');

    // Milieu de fourchette : +1 rep.
    appState.exerciseProgress[ex.id] =
        const ProgressionState(weightKg: 60, targetReps: 10);
    final r1 = appState.recordExerciseResult(
        exercise: ex, weightKg: 60, repsPerSet: const [10, 10, 10]);
    expect(r1.outcome, ProgressOutcome.repUp);
    expect(appState.exerciseProgress[ex.id]!.targetReps, 11);

    // Haut de fourchette : palier +2,5 kg (pecs) et retour a 8 reps.
    appState.exerciseProgress[ex.id] =
        const ProgressionState(weightKg: 60, targetReps: 12);
    final r2 = appState.recordExerciseResult(
        exercise: ex, weightKg: 60, repsPerSet: const [12, 12, 12]);
    expect(r2.isMilestone, isTrue);
    expect(appState.exerciseProgress[ex.id]!.weightKg, 62.5);
    expect(appState.exerciseProgress[ex.id]!.targetReps, 8);

    // La prescription reprend l'etat memorise.
    final presc = appState.prescriptionFor(ex);
    expect(presc.suggestedWeightKg, 62.5);
    expect(presc.targetReps, 8);
  });

  testWidgets("L'ecran profil s'affiche", (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    appState.onboarded = true;
    appState.pseudo = 'Test';
    appState.equipment = {Equipment.dumbbells};

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('PROFIL'), findsOneWidget);
    expect(find.text('MON ÉQUIPEMENT'), findsOneWidget);
    expect(find.text('Haltères'), findsOneWidget);
  });
}
