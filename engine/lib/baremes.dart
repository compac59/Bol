import 'rank.dart';

/// Les exercices utilisés par le **test initial** (cf. baremes-force.md).
enum AssessmentExercise {
  bench,
  squat,
  deadlift,
  overhead,
  pullups,
}

/// Barèmes de force : pour chaque exercice, les **seuils** des 6 rangs.
///
/// - Pour le bench/squat/deadlift/overhead : le seuil est un **ratio
///   force/poids de corps** (ex. 1.00 = soulever 1× son poids de corps).
/// - Pour les tractions : le seuil est un **nombre de répétitions**.
///
/// L'ordre dans chaque liste suit l'ordre des rangs : [E, D, C, B, A, S].
const Map<AssessmentExercise, List<double>> baremes = {
  AssessmentExercise.bench: [0.50, 0.75, 1.00, 1.25, 1.50, 2.00],
  AssessmentExercise.squat: [0.75, 1.25, 1.50, 1.75, 2.25, 2.75],
  AssessmentExercise.deadlift: [1.00, 1.50, 1.75, 2.00, 2.50, 3.00],
  AssessmentExercise.overhead: [0.35, 0.55, 0.70, 0.85, 1.10, 1.40],
  AssessmentExercise.pullups: [1, 5, 8, 12, 16, 20],
};

/// Indique si l'exercice se mesure en **répétitions** (tractions) plutôt
/// qu'en ratio de charge.
bool isRepsBased(AssessmentExercise ex) => ex == AssessmentExercise.pullups;

/// Trouve le rang correspondant à une `valeur` (ratio ou reps selon l'exo)
/// en la comparant aux seuils du barème de l'exercice.
///
/// On prend le **rang le plus haut** dont le seuil est atteint. En dessous
/// du premier seuil, on reste au rang E (le plancher).
Rank rankForValue(AssessmentExercise ex, double valeur) {
  final seuils = baremes[ex]!;
  var rang = Rank.e;
  for (var i = 0; i < seuils.length; i++) {
    if (valeur >= seuils[i]) {
      rang = Rank.fromIndex(i);
    } else {
      break;
    }
  }
  return rang;
}

/// Score **continu** de force : indice du rang + position dans la fourchette.
///
/// Ex. bench à ratio 0.8125 (entre D=0.75 et C=1.00) :
/// fraction = (0.8125 - 0.75) / (1.00 - 0.75) = 0.25 → score = 1.25 (D + 25%).
/// Sert à calculer un niveau **fin** à l'intérieur du rang.
double rankScoreForValue(AssessmentExercise ex, double valeur) {
  final seuils = baremes[ex]!;
  if (valeur < seuils.first) return 0; // sous E -> bas de E
  for (var i = 0; i < seuils.length; i++) {
    // Dernier palier (S) : pas de borne supérieure.
    if (i == seuils.length - 1) return i.toDouble();
    final bas = seuils[i];
    final haut = seuils[i + 1];
    if (valeur >= bas && valeur < haut) {
      return i + (valeur - bas) / (haut - bas);
    }
  }
  return (seuils.length - 1).toDouble();
}
