/// Les rangs de chasseur, du plus faible (E) au plus fort (S).
///
/// L'ordre de déclaration est important : `Rank.values.indexOf(...)` donne
/// 0 pour E, 1 pour D, ... 5 pour S. On s'en sert pour faire des moyennes.
enum Rank {
  e('E'),
  d('D'),
  c('C'),
  b('B'),
  a('A'),
  s('S');

  const Rank(this.label);

  /// Le libellé affiché à l'écran ("E", "D", ...).
  final String label;

  // Note : `index` (E=0, D=1, ... S=5) est déjà fourni par l'enum Dart,
  // basé sur l'ordre de déclaration. On s'en sert pour les moyennes.

  /// Reconstruit un rang depuis un indice (utile après une moyenne arrondie).
  static Rank fromIndex(int i) {
    final clamped = i.clamp(0, Rank.values.length - 1);
    return Rank.values[clamped];
  }
}
