import 'package:mybody_rpg_engine/xp.dart';
import 'package:test/test.dart';

void main() {
  group('Gain d\'XP d\'une séance', () {
    test('séance simple : base + volume', () {
      // 3 séries de 10 reps à 50 kg = 1500 kg de tonnage -> 15 XP de volume
      final r = computeWorkoutXp(sets: const [
        WorkoutSet(reps: 10, charge: 50),
        WorkoutSet(reps: 10, charge: 50),
        WorkoutSet(reps: 10, charge: 50),
      ]);
      expect(r.base, 50);
      expect(r.volume, 15);
      expect(r.total, 65);
      expect(r.plafonne, isFalse);
    });

    test('bonus de streak plafonné à 7 jours', () {
      final r = computeWorkoutXp(
        sets: const [WorkoutSet(reps: 1, charge: 100)], // 100 kg -> 1 XP volume
        streakJours: 20, // au-delà du plafond
      );
      // base 50 + volume 1 + streak (7×10=70) = 121
      expect(r.streak, 70);
      expect(r.total, 121);
    });

    test('bonus de records', () {
      final r = computeWorkoutXp(
        sets: const [WorkoutSet(reps: 5, charge: 100)], // 500 kg -> 5 XP
        nbRecords: 2,
      );
      // base 50 + volume 5 + records (2×75=150) = 205
      expect(r.records, 150);
      expect(r.total, 205);
    });

    test('séance vide = 0 XP', () {
      final r = computeWorkoutXp(sets: const []);
      expect(r.total, 0);
    });

    test('plafond anti-farm', () {
      final r = computeWorkoutXp(
        sets: const [WorkoutSet(reps: 100, charge: 1000)], // tonnage énorme
      );
      expect(r.plafonne, isTrue);
      expect(r.total, 1000); // plafond par défaut
    });
  });

  group('Courbe de niveaux', () {
    test('valeurs du PRD', () {
      expect(xpToNextLevel(1), 100);
      expect(xpToNextLevel(2), 283);
      expect(xpToNextLevel(5), 1118);
      expect(xpToNextLevel(10), 3162);
    });

    test('niveau déduit de l\'XP total', () {
      // 0 XP -> niveau 1
      expect(levelFromTotalXp(0).level, 1);
      // 100 XP -> juste assez pour le niveau 2
      expect(levelFromTotalXp(100).level, 2);
      // 99 XP -> encore niveau 1, à 99/100
      final p = levelFromTotalXp(99);
      expect(p.level, 1);
      expect(p.xpDansNiveau, 99);
      expect(p.fraction, closeTo(0.99, 0.001));
    });

    test('totalXpForLevel est cohérent avec xpToNextLevel', () {
      // pour atteindre le niveau 3 il faut xp(1) + xp(2) = 100 + 283 = 383
      expect(totalXpForLevel(3), 383);
      expect(levelFromTotalXp(383).level, 3);
    });
  });
}
