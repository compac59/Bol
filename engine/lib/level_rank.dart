import 'rank.dart';

/// Niveau de départ (bas de fourchette) de chaque rang, pendant le jeu.
/// E:1-9, D:10-19, C:20-34, B:35-49, A:50-69, S:70+.
const Map<Rank, int> rankBaseLevels = {
  Rank.e: 1,
  Rank.d: 10,
  Rank.c: 20,
  Rank.b: 35,
  Rank.a: 50,
  Rank.s: 70,
};

/// Le rang correspondant à un niveau de personnage.
Rank rankForLevel(int level) {
  if (level >= 70) return Rank.s;
  if (level >= 50) return Rank.a;
  if (level >= 35) return Rank.b;
  if (level >= 20) return Rank.c;
  if (level >= 10) return Rank.d;
  return Rank.e;
}

/// Le niveau le plus bas du rang (sert de plancher anti-perte).
int rankBaseLevel(Rank rank) => rankBaseLevels[rank]!;
