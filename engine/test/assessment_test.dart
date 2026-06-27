import 'package:mybody_rpg_engine/assessment.dart';
import 'package:mybody_rpg_engine/baremes.dart';
import 'package:mybody_rpg_engine/rank.dart';
import 'package:test/test.dart';

void main() {
  group('Formule d\'Epley (estimation du 1RM)', () {
    test('1 rep = la charge elle-même', () {
      expect(estimateOneRm(100, 1), 100);
    });

    test('plusieurs reps augmentent le 1RM estimé', () {
      // 100 kg × 5 reps ≈ 100 × (1 + 5/30) ≈ 116.67
      expect(estimateOneRm(100, 5), closeTo(116.67, 0.01));
    });
  });

  group('Rang par valeur (barèmes)', () {
    test('bench à 1.00× poids de corps = rang C', () {
      expect(rankForValue(AssessmentExercise.bench, 1.00), Rank.c);
    });

    test('en dessous du premier seuil = rang E (plancher)', () {
      expect(rankForValue(AssessmentExercise.bench, 0.10), Rank.e);
    });

    test('au-dessus du dernier seuil = rang S (plafond)', () {
      expect(rankForValue(AssessmentExercise.deadlift, 5.0), Rank.s);
    });

    test('valeur entre deux seuils = rang inférieur', () {
      // overhead 0.625 est entre D(0.55) et C(0.70) -> D
      expect(rankForValue(AssessmentExercise.overhead, 0.625), Rank.d);
    });
  });

  group('Test initial complet — exemple du doc (homme 80 kg)', () {
    late AssessmentResult result;

    setUp(() {
      result = evaluate(
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(exercise: AssessmentExercise.bench, charge: 80),
          PerformanceEntry(exercise: AssessmentExercise.squat, charge: 120),
          PerformanceEntry(exercise: AssessmentExercise.deadlift, charge: 160),
          PerformanceEntry(exercise: AssessmentExercise.overhead, charge: 50),
          // tractions : 10 reps (au poids du corps)
          PerformanceEntry(exercise: AssessmentExercise.pullups, charge: 10),
        ],
      );
    });

    test('rangs par exercice conformes au doc', () {
      expect(result.perExerciseRank[AssessmentExercise.bench], Rank.c);
      expect(result.perExerciseRank[AssessmentExercise.squat], Rank.c);
      expect(result.perExerciseRank[AssessmentExercise.deadlift], Rank.b);
      expect(result.perExerciseRank[AssessmentExercise.overhead], Rank.d);
      expect(result.perExerciseRank[AssessmentExercise.pullups], Rank.c);
    });

    test('rang global = C', () {
      expect(result.globalRank, Rank.c);
    });

    test('niveau de départ fin = 23 (dans la tranche du rang C)', () {
      // Score moyen ≈ 2.2 (rang C + 20%) -> niveau 20 + floor(0.2×15) = 23.
      expect(result.startingLevel, 23);
    });

    test('les stats sont cohérentes (valeurs entre 10 et 90)', () {
      final s = result.stats;
      for (final v in [
        s.force,
        s.endurance,
        s.explosivite,
        s.volonte,
        s.vitalite,
      ]) {
        expect(v, inInclusiveRange(10, 90));
      }
    });
  });

  group('Niveau fin dans la tranche du rang (exemple utilisateur)', () {
    test('homme 80 kg, bench 65 kg -> rang D, niveau 12 (pas 10)', () {
      // ratio = 65/80 = 0.8125, entre D(0.75) et C(1.00) -> 25% dans D.
      // Rang D = niveaux 10-19 -> niveau 10 + floor(0.25×10) = 12.
      final r = evaluate(
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(exercise: AssessmentExercise.bench, charge: 65),
        ],
      );
      expect(r.perExerciseRank[AssessmentExercise.bench], Rank.d);
      expect(r.globalRank, Rank.d);
      expect(r.startingLevel, 12);
    });

    test('au tout début de la fourchette D (60 kg) -> niveau 10', () {
      // ratio = 60/80 = 0.75 exactement -> 0% dans D -> niveau de base 10.
      final r = evaluate(
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(exercise: AssessmentExercise.bench, charge: 60),
        ],
      );
      expect(r.globalRank, Rank.d);
      expect(r.startingLevel, 10);
    });
  });

  group('Cas limites', () {
    test('liste vide -> erreur', () {
      expect(
        () => evaluate(entries: const [], bodyWeightKg: 80),
        throwsArgumentError,
      );
    });

    test('saisie en charge × reps via Epley (débutant)', () {
      // 40 kg × 8 reps au bench ≈ 50.7 kg de 1RM, pour 80 kg de PC -> ratio
      // ≈ 0.63, entre E(0.50) et D(0.75) -> rang E.
      final r = evaluate(
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(
              exercise: AssessmentExercise.bench, charge: 40, reps: 8),
        ],
      );
      expect(r.perExerciseRank[AssessmentExercise.bench], Rank.e);
    });
  });
}
