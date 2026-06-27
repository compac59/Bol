import 'progression.dart' show MuscleGroup;

/// Les types d'équipement qu'un joueur peut cocher dans son profil.
///
/// [bodyweight] (poids du corps) est **toujours** disponible : pas besoin de
/// le cocher, on l'ajoute automatiquement.
enum Equipment {
  bodyweight('Poids du corps'),
  barbell('Barre + disques'),
  dumbbells('Haltères'),
  bench('Banc'),
  machine('Machines guidées'),
  cable('Poulie / câble'),
  pullupBar('Barre de traction');

  const Equipment(this.label);
  final String label;
}

/// Un exercice du catalogue.
class Exercise {
  const Exercise({
    required this.id,
    required this.nom,
    required this.group,
    required this.equipment,
  });

  final String id;
  final String nom;
  final MuscleGroup group;

  /// L'équipement **nécessaire** pour faire l'exercice (tout est requis).
  final Set<Equipment> equipment;
}

/// Le catalogue complet (cf. bibliotheque-exercices.md).
const List<Exercise> exerciseCatalog = [
  // --- Pectoraux ---
  Exercise(
    id: 'bench_press',
    nom: 'Développé couché',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.barbell, Equipment.bench},
  ),
  Exercise(
    id: 'incline_press',
    nom: 'Développé incliné',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.barbell, Equipment.bench},
  ),
  Exercise(
    id: 'db_press',
    nom: 'Développé haltères',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.dumbbells, Equipment.bench},
  ),
  Exercise(
    id: 'pec_deck',
    nom: 'Écarté (pec deck)',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.machine},
  ),
  Exercise(
    id: 'pushups',
    nom: 'Pompes',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.bodyweight},
  ),

  // --- Dos ---
  Exercise(
    id: 'pullups',
    nom: 'Tractions',
    group: MuscleGroup.dos,
    equipment: {Equipment.pullupBar},
  ),
  Exercise(
    id: 'barbell_row',
    nom: 'Rowing barre',
    group: MuscleGroup.dos,
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'lat_pulldown',
    nom: 'Tirage vertical',
    group: MuscleGroup.dos,
    equipment: {Equipment.machine},
  ),
  Exercise(
    id: 'seated_row',
    nom: 'Tirage horizontal',
    group: MuscleGroup.dos,
    equipment: {Equipment.cable},
  ),
  Exercise(
    id: 'deadlift',
    nom: 'Soulevé de terre',
    group: MuscleGroup.dos,
    equipment: {Equipment.barbell},
  ),

  // --- Épaules ---
  Exercise(
    id: 'ohp',
    nom: 'Développé militaire',
    group: MuscleGroup.epaules,
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'db_shoulder_press',
    nom: 'Développé haltères épaules',
    group: MuscleGroup.epaules,
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'lateral_raise',
    nom: 'Élévations latérales',
    group: MuscleGroup.epaules,
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'rear_delt',
    nom: 'Oiseau (arrière d\'épaule)',
    group: MuscleGroup.epaules,
    equipment: {Equipment.dumbbells},
  ),

  // --- Biceps ---
  Exercise(
    id: 'barbell_curl',
    nom: 'Curl barre',
    group: MuscleGroup.biceps,
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'db_curl',
    nom: 'Curl haltères',
    group: MuscleGroup.biceps,
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'hammer_curl',
    nom: 'Curl marteau',
    group: MuscleGroup.biceps,
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'preacher_curl',
    nom: 'Curl pupitre',
    group: MuscleGroup.biceps,
    equipment: {Equipment.machine},
  ),

  // --- Triceps ---
  Exercise(
    id: 'dips',
    nom: 'Dips',
    group: MuscleGroup.triceps,
    equipment: {Equipment.bodyweight},
  ),
  Exercise(
    id: 'pushdown',
    nom: 'Extension poulie',
    group: MuscleGroup.triceps,
    equipment: {Equipment.cable},
  ),
  Exercise(
    id: 'skull_crusher',
    nom: 'Barre au front',
    group: MuscleGroup.triceps,
    equipment: {Equipment.barbell, Equipment.bench},
  ),
  Exercise(
    id: 'db_overhead_ext',
    nom: 'Extension haltère nuque',
    group: MuscleGroup.triceps,
    equipment: {Equipment.dumbbells},
  ),

  // --- Jambes ---
  Exercise(
    id: 'squat',
    nom: 'Squat',
    group: MuscleGroup.jambes,
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'leg_press',
    nom: 'Presse à cuisses',
    group: MuscleGroup.jambes,
    equipment: {Equipment.machine},
  ),
  Exercise(
    id: 'lunges',
    nom: 'Fentes',
    group: MuscleGroup.jambes,
    equipment: {Equipment.bodyweight},
  ),
  Exercise(
    id: 'leg_extension',
    nom: 'Leg extension',
    group: MuscleGroup.jambes,
    equipment: {Equipment.machine},
  ),
  Exercise(
    id: 'leg_curl',
    nom: 'Leg curl',
    group: MuscleGroup.jambes,
    equipment: {Equipment.machine},
  ),
  Exercise(
    id: 'calf_raise',
    nom: 'Mollets debout',
    group: MuscleGroup.jambes,
    equipment: {Equipment.machine},
  ),

  // --- Abdos / gainage ---
  Exercise(
    id: 'crunch',
    nom: 'Crunch',
    group: MuscleGroup.abdos,
    equipment: {Equipment.bodyweight},
  ),
  Exercise(
    id: 'leg_raise',
    nom: 'Relevé de jambes',
    group: MuscleGroup.abdos,
    equipment: {Equipment.bodyweight},
  ),
  Exercise(
    id: 'plank',
    nom: 'Gainage (planche)',
    group: MuscleGroup.abdos,
    equipment: {Equipment.bodyweight},
  ),
];

/// Retourne les exercices réalisables avec l'équipement disponible.
///
/// Le poids du corps est toujours ajouté : on n'a jamais besoin de le cocher.
List<Exercise> availableExercises(Set<Equipment> available) {
  final dispo = {...available, Equipment.bodyweight};
  return exerciseCatalog
      .where((ex) => ex.equipment.every(dispo.contains))
      .toList();
}

/// Idem, mais regroupé par groupe musculaire (pratique pour l'affichage).
Map<MuscleGroup, List<Exercise>> availableExercisesByGroup(
  Set<Equipment> available,
) {
  final result = <MuscleGroup, List<Exercise>>{};
  for (final ex in availableExercises(available)) {
    result.putIfAbsent(ex.group, () => []).add(ex);
  }
  return result;
}
