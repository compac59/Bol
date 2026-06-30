import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';
import 'package:mybody_rpg/screens/home_screen.dart';
import 'package:mybody_rpg/screens/workout_screen.dart';
import 'package:mybody_rpg/state/app_state.dart';

void main() {
  testWidgets('La séance affiche des exercices', (tester) async {
    // Profil de test (salle complète).
    appState.onboarded = true;
    appState.pseudo = 'Test';
    appState.equipment = Equipment.values.toSet();
    appState.goal = TrainingGoal.masse;
    appState.daysPerWeek = 3;
    appState.totalXp = 0;
    appState.currentRank = Rank.e;

    await tester.pumpWidget(
      const MaterialApp(home: WorkoutScreen()),
    );
    await tester.pumpAndSettle();

    // On doit voir au moins un exercice (du catalogue poids du corps).
    final day = appState.todaysWorkout;
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

          await tester.pumpWidget(
            MaterialApp(home: WorkoutScreen(key: ValueKey('$eq-$g-$d'))),
          );
          await tester.pumpAndSettle();

          final day = appState.todaysWorkout;
          expect(day.exercises, isNotEmpty,
              reason: 'séance vide pour eq=${eq.length} goal=${g.name} d=$d');
          expect(find.text(day.exercises.first.exercise.nom), findsWidgets,
              reason: 'rendu vide pour eq=${eq.length} goal=${g.name} d=$d');
        }
      }
    }
  });

  testWidgets('Le bouton Démarrer ouvre la séance', (tester) async {
    // Grande surface pour que toute la liste (et le bouton) soit construite.
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    appState.onboarded = true;
    appState.equipment = Equipment.values.toSet();
    appState.goal = TrainingGoal.masse;
    appState.daysPerWeek = 3;

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final bouton = find.byIcon(Icons.fitness_center);
    expect(bouton, findsOneWidget);
    await tester.tap(bouton);
    await tester.pumpAndSettle();

    // L'écran de séance doit montrer un exercice.
    expect(find.text(appState.todaysWorkout.exercises.first.exercise.nom),
        findsWidgets);
  });
}
