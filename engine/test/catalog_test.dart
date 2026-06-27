import 'package:mybody_rpg_engine/catalog.dart';
import 'package:mybody_rpg_engine/progression.dart' show MuscleGroup;
import 'package:test/test.dart';

void main() {
  group('Catalogue & équipement', () {
    test('~20 équipements cochables (hors poids du corps)', () {
      expect(Equipment.values.length - 1, greaterThanOrEqualTo(18));
    });

    test('aucun équipement coché = seulement le poids du corps', () {
      final dispo = availableExercises({});
      expect(dispo, isNotEmpty);
      for (final ex in dispo) {
        expect(ex.equipment, {Equipment.bodyweight});
      }
      final ids = dispo.map((e) => e.id).toSet();
      expect(ids, containsAll(['pushups', 'bodyweight_squat', 'plank']));
      expect(ids, isNot(contains('bench_press')));
    });

    test('barre + banc plat = on débloque le développé couché', () {
      final dispo =
          availableExercises({Equipment.barbell, Equipment.flatBench});
      final ids = dispo.map((e) => e.id).toSet();
      expect(ids, contains('bench_press'));
      expect(ids, contains('barbell_row')); // barre seule suffit
      // Incliné pas encore (banc inclinable manquant).
      expect(ids, isNot(contains('incline_press')));
    });

    test('équipement précis : presse à cuisses seule', () {
      final dispo = availableExercises({Equipment.legPress});
      final ids = dispo.map((e) => e.id).toSet();
      expect(ids, contains('leg_press'));
      // Pas de leg extension (machine différente non cochée).
      expect(ids, isNot(contains('leg_extension')));
    });

    test('presse à pectoraux seule débloque l\'exercice machine', () {
      final dispo = availableExercises({Equipment.chestPress});
      final ids = dispo.map((e) => e.id).toSet();
      expect(ids, contains('chest_press_machine'));
      expect(ids, isNot(contains('pec_deck'))); // machine différente
    });

    test('tout l\'équipement = tout le catalogue', () {
      final tout = Equipment.values.toSet();
      expect(availableExercises(tout).length, exerciseCatalog.length);
    });

    test('chaque groupe musculaire a au moins un exercice (salle complète)', () {
      final parGroupe = availableExercisesByGroup(Equipment.values.toSet());
      for (final g in MuscleGroup.values) {
        expect(parGroupe[g], isNotNull, reason: 'groupe $g vide');
        expect(parGroupe[g]!, isNotEmpty);
      }
    });

    test('tous les identifiants d\'exercices sont uniques', () {
      final ids = exerciseCatalog.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
