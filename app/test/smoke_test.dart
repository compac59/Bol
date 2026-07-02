import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';
import 'package:mybody_rpg/screens/home_screen.dart';
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
}
