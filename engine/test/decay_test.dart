import 'package:mybody_rpg_engine/decay.dart';
import 'package:mybody_rpg_engine/level_rank.dart';
import 'package:mybody_rpg_engine/rank.dart';
import 'package:mybody_rpg_engine/xp.dart';
import 'package:test/test.dart';

void main() {
  group('Rang selon le niveau', () {
    test('frontières des rangs', () {
      expect(rankForLevel(1), Rank.e);
      expect(rankForLevel(9), Rank.e);
      expect(rankForLevel(10), Rank.d);
      expect(rankForLevel(20), Rank.c);
      expect(rankForLevel(35), Rank.b);
      expect(rankForLevel(50), Rank.a);
      expect(rankForLevel(70), Rank.s);
    });
  });

  group('Perte d\'XP par inactivité', () {
    test('aucune perte pendant le délai de grâce (4 jours)', () {
      final totalXp = totalXpForLevel(5);
      final r = applyXpDecay(totalXp: totalXp, daysSinceLastWorkout: 4);
      expect(r.xpPerdu, 0);
      expect(r.niveauApres, 5);
    });

    test('2 semaines d\'inactivité = ~1 niveau perdu', () {
      // Au pile début du niveau 5, 14 jours d'absence -> retombe au niveau 4.
      final totalXp = totalXpForLevel(5);
      final r = applyXpDecay(totalXp: totalXp, daysSinceLastWorkout: 14);
      expect(r.aPerduUnNiveau, isTrue);
      expect(r.niveauApres, 4);
      expect(r.newTotalXp, totalXpForLevel(4));
    });

    test('le plancher de rang empêche de descendre de rang', () {
      // Niveau 25 (rang C, plancher = niveau 20). Très longue absence.
      final totalXp = totalXpForLevel(25);
      final r = applyXpDecay(totalXp: totalXp, daysSinceLastWorkout: 400);
      expect(r.plancherAtteint, isTrue);
      expect(r.niveauApres, 20); // bas du rang C
      expect(rankForLevel(r.niveauApres), Rank.c); // reste rang C
      expect(r.newTotalXp, totalXpForLevel(20));
    });

    test('déjà au plancher de son rang = aucune perte', () {
      final totalXp = totalXpForLevel(20); // pile au bas du rang C
      final r = applyXpDecay(totalXp: totalXp, daysSinceLastWorkout: 100);
      expect(r.xpPerdu, 0);
      expect(r.plancherAtteint, isTrue);
      expect(r.niveauApres, 20);
    });
  });
}
