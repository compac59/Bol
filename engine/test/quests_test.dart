import 'package:mybody_rpg_engine/quests.dart';
import 'package:mybody_rpg_engine/rank.dart';
import 'package:test/test.dart';

void main() {
  group('Objectif chiffré selon le rang', () {
    test('exemple : pompes au rang D = 20', () {
      final pushups = dailyQuestPool.firstWhere((q) => q.id == 'pushups');
      expect(pushups.targetForRank(Rank.e), 10);
      expect(pushups.targetForRank(Rank.d), 20);
      expect(pushups.targetForRank(Rank.c), 30);
      expect(pushups.targetForRank(Rank.s), 60);
    });

    test('un rang plus élevé = objectif plus dur', () {
      for (final t in dailyQuestPool) {
        expect(t.targetForRank(Rank.s), greaterThan(t.targetForRank(Rank.e)));
      }
    });
  });

  group('Défis du jour', () {
    test('renvoie 3 défis par défaut', () {
      final q = dailyQuestsForDay(rank: Rank.d, daySeed: 0);
      expect(q.length, 3);
    });

    test('les défis tournent d\'un jour à l\'autre', () {
      List<String> ids(int day) =>
          dailyQuestsForDay(rank: Rank.d, daySeed: day)
              .map((q) => q.template.id)
              .toList();
      expect(ids(0), isNot(equals(ids(1))));
    });

    test('déterministe : même jour => mêmes défis', () {
      final a = dailyQuestsForDay(rank: Rank.c, daySeed: 42);
      final b = dailyQuestsForDay(rank: Rank.c, daySeed: 42);
      expect(a.map((q) => q.template.id), b.map((q) => q.template.id));
    });

    test('description lisible', () {
      // On force le rang D et le jour 0 -> 1er défi = pompes (début du pool).
      final q = dailyQuestsForDay(rank: Rank.d, daySeed: 0).first;
      expect(q.description, 'Faire 20 pompes');
      expect(q.xpReward, greaterThan(0));
    });

    test('défi en temps : formulation « Tenir … s »', () {
      // Le gainage est à l'indice 3 du pool -> daySeed 3 le met en premier.
      final q = dailyQuestsForDay(rank: Rank.e, daySeed: 3).first;
      expect(q.template.id, 'plank');
      expect(q.description, 'Tenir 20 s de gainage');
    });
  });
}
