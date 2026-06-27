import 'package:mybody_rpg_engine/assessment.dart';
import 'package:mybody_rpg_engine/baremes.dart';
import 'package:mybody_rpg_engine/promotion.dart';
import 'package:mybody_rpg_engine/rank.dart';
import 'package:test/test.dart';

void main() {
  group('Disponibilité de l\'examen', () {
    test('verrouillé tant que le niveau requis n\'est pas atteint', () {
      // Rang D -> rang C demande le niveau 20.
      expect(promotionAvailable(currentRank: Rank.d, level: 19), isFalse);
      expect(promotionAvailable(currentRank: Rank.d, level: 20), isTrue);
    });

    test('pas d\'examen au rang maximum (S)', () {
      expect(promotionAvailable(currentRank: Rank.s, level: 100), isFalse);
      expect(rankAbove(Rank.s), isNull);
    });
  });

  group('Examen de promotion (D -> C)', () {
    test('réussi si la force atteint le rang visé', () {
      // bench 80 kg à 80 kg de PC = ratio 1.0 -> rang C.
      final r = evaluatePromotion(
        currentRank: Rank.d,
        level: 20,
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(exercise: AssessmentExercise.bench, charge: 80),
        ],
      );
      expect(r.available, isTrue);
      expect(r.achievedRank, Rank.c);
      expect(r.passed, isTrue);
      expect(r.newRank, Rank.c);
    });

    test('échoué si la force est insuffisante -> reste rang D', () {
      // bench 65 kg à 80 kg de PC = ratio 0.81 -> rang D (< C visé).
      final r = evaluatePromotion(
        currentRank: Rank.d,
        level: 20,
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(exercise: AssessmentExercise.bench, charge: 65),
        ],
      );
      expect(r.available, isTrue);
      expect(r.passed, isFalse);
      expect(r.achievedRank, Rank.d);
      expect(r.newRank, Rank.d); // pas de changement
    });

    test('niveau insuffisant -> examen indisponible, pas de changement', () {
      final r = evaluatePromotion(
        currentRank: Rank.d,
        level: 15,
        bodyWeightKg: 80,
        entries: const [
          PerformanceEntry(exercise: AssessmentExercise.bench, charge: 200),
        ],
      );
      expect(r.available, isFalse);
      expect(r.newRank, Rank.d);
    });
  });
}
