import 'package:mybody_rpg_engine/streak.dart';
import 'package:test/test.dart';

void main() {
  group('Streak', () {
    test('première activité = streak 1', () {
      final u = registerActivity(const StreakState(), 100);
      expect(u.state.current, 1);
      expect(u.state.best, 1);
      expect(u.incremented, isTrue);
    });

    test('jours consécutifs : le streak monte', () {
      var s = const StreakState();
      s = registerActivity(s, 100).state; // 1
      s = registerActivity(s, 101).state; // 2
      s = registerActivity(s, 102).state; // 3
      expect(s.current, 3);
      expect(s.best, 3);
    });

    test('deux activités le même jour = compté une seule fois', () {
      var s = registerActivity(const StreakState(), 100).state; // 1
      final u = registerActivity(s, 100); // même jour
      expect(u.alreadyCountedToday, isTrue);
      expect(u.state.current, 1);
    });

    test('un jour manqué est sauvé par un joker', () {
      var s = const StreakState(freezesRemaining: 2);
      s = registerActivity(s, 100).state; // 1
      final u = registerActivity(s, 102); // saute le jour 101
      expect(u.freezesUsed, 1);
      expect(u.reset, isFalse);
      expect(u.state.current, 2);
      expect(u.state.freezesRemaining, 1);
    });

    test('trop de jours manqués (plus de jokers) : reset à 1', () {
      var s = const StreakState(freezesRemaining: 1);
      s = registerActivity(s, 100).state; // 1
      s = registerActivity(s, 101).state; // 2
      final u = registerActivity(s, 105); // saute 3 jours, 1 seul joker
      expect(u.reset, isTrue);
      expect(u.state.current, 1);
    });

    test('le record (best) est conservé même après un reset', () {
      var s = const StreakState(freezesRemaining: 0);
      s = registerActivity(s, 100).state; // 1
      s = registerActivity(s, 101).state; // 2
      s = registerActivity(s, 102).state; // 3 (record)
      final u = registerActivity(s, 110); // gros trou -> reset
      expect(u.state.current, 1);
      expect(u.state.best, 3);
    });

    test('dayIndex : deux jours consécutifs diffèrent de 1', () {
      final d1 = dayIndex(DateTime(2026, 6, 27));
      final d2 = dayIndex(DateTime(2026, 6, 28));
      expect(d2 - d1, 1);
    });

    test('streakIsBroken après une longue absence', () {
      final s = StreakState(
        current: 5,
        best: 5,
        lastActiveDay: 100,
        freezesRemaining: 1,
      );
      expect(streakIsBroken(s, 101), isFalse); // lendemain
      expect(streakIsBroken(s, 102), isFalse); // 1 manqué, 1 joker
      expect(streakIsBroken(s, 104), isTrue); // 3 manqués, 1 joker
    });
  });
}
