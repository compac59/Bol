import 'package:mybody_rpg_engine/catalog.dart';
import 'package:mybody_rpg_engine/progression.dart' show MuscleGroup;
import 'package:test/test.dart';

void main() {
  group('Filtrage des exercices par équipement', () {
    test('aucun équipement coché = seulement le poids du corps', () {
      final dispo = availableExercises({});
      // Tous les exercices renvoyés ne demandent que le poids du corps.
      expect(dispo, isNotEmpty);
      for (final ex in dispo) {
        expect(ex.equipment, {Equipment.bodyweight});
      }
      // On retrouve bien quelques classiques au poids du corps.
      final ids = dispo.map((e) => e.id).toSet();
      expect(ids, containsAll(['pushups', 'dips', 'plank', 'lunges']));
      // Mais pas le développé couché (barre + banc requis).
      expect(ids, isNot(contains('bench_press')));
    });

    test('barre + banc = on débloque le développé couché', () {
      final dispo = availableExercises({Equipment.barbell, Equipment.bench});
      final ids = dispo.map((e) => e.id).toSet();
      expect(ids, contains('bench_press'));
      expect(ids, contains('barbell_row')); // barre seule suffit
      // Pas encore le curl haltères (haltères non cochés).
      expect(ids, isNot(contains('db_curl')));
    });

    test('haltères seuls : pas le développé haltères (banc manquant)', () {
      final dispo = availableExercises({Equipment.dumbbells});
      final ids = dispo.map((e) => e.id).toSet();
      expect(ids, contains('db_curl'));
      expect(ids, contains('lateral_raise'));
      expect(ids, isNot(contains('db_press'))); // a besoin du banc
    });

    test('tout l\'équipement = tout le catalogue', () {
      final tout = Equipment.values.toSet();
      expect(availableExercises(tout).length, exerciseCatalog.length);
    });

    test('regroupement par muscle', () {
      final parGroupe = availableExercisesByGroup(Equipment.values.toSet());
      // Chaque groupe musculaire a au moins un exercice.
      for (final g in MuscleGroup.values) {
        expect(parGroupe[g], isNotNull, reason: 'groupe $g vide');
        expect(parGroupe[g]!, isNotEmpty);
      }
    });
  });
}
