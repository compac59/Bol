import 'progression.dart' show MuscleGroup;

/// Les types d'équipement qu'un joueur peut cocher dans son profil (~20).
///
/// [bodyweight] (poids du corps) est **toujours** disponible : pas besoin de
/// le cocher, on l'ajoute automatiquement.
enum Equipment {
  bodyweight('Poids du corps'),
  // Poids libres
  barbell('Barre + disques'),
  dumbbells('Haltères'),
  ezBar('Barre EZ'),
  kettlebell('Kettlebell'),
  bands('Élastiques'),
  // Bancs & supports
  flatBench('Banc plat'),
  inclineBench('Banc inclinable'),
  squatRack('Rack à squat'),
  smithMachine('Smith machine'),
  pullupBar('Barre de traction'),
  dipStation('Station à dips'),
  cable('Poulie / câble'),
  // Machines guidées spécifiques
  latPulldown('Tirage vertical (machine)'),
  seatedRow('Rowing assis (machine)'),
  chestPress('Presse à pectoraux'),
  pecDeck('Pec deck'),
  shoulderPress('Développé épaules (machine)'),
  legPress('Presse à cuisses'),
  legExtension('Leg extension'),
  legCurl('Leg curl'),
  calfMachine('Machine à mollets');

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
    equipment: {Equipment.barbell, Equipment.flatBench},
  ),
  Exercise(
    id: 'incline_press',
    nom: 'Développé incliné',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.barbell, Equipment.inclineBench},
  ),
  Exercise(
    id: 'db_press',
    nom: 'Développé haltères',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.dumbbells, Equipment.flatBench},
  ),
  Exercise(
    id: 'db_incline_press',
    nom: 'Développé incliné haltères',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.dumbbells, Equipment.inclineBench},
  ),
  Exercise(
    id: 'chest_press_machine',
    nom: 'Presse à pectoraux',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.chestPress},
  ),
  Exercise(
    id: 'pec_deck',
    nom: 'Écarté (pec deck)',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.pecDeck},
  ),
  Exercise(
    id: 'cable_fly',
    nom: 'Écarté à la poulie',
    group: MuscleGroup.pectoraux,
    equipment: {Equipment.cable},
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
    id: 'db_row',
    nom: 'Rowing haltère',
    group: MuscleGroup.dos,
    equipment: {Equipment.dumbbells, Equipment.flatBench},
  ),
  Exercise(
    id: 'lat_pulldown',
    nom: 'Tirage vertical',
    group: MuscleGroup.dos,
    equipment: {Equipment.latPulldown},
  ),
  Exercise(
    id: 'seated_row',
    nom: 'Rowing assis',
    group: MuscleGroup.dos,
    equipment: {Equipment.seatedRow},
  ),
  Exercise(
    id: 'deadlift',
    nom: 'Soulevé de terre',
    group: MuscleGroup.dos,
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'kb_swing',
    nom: 'Swing kettlebell',
    group: MuscleGroup.dos,
    equipment: {Equipment.kettlebell},
  ),
  Exercise(
    id: 'band_row',
    nom: 'Tirage élastique',
    group: MuscleGroup.dos,
    equipment: {Equipment.bands},
  ),
  Exercise(
    id: 'superman',
    nom: 'Superman (lombaires)',
    group: MuscleGroup.dos,
    equipment: {Equipment.bodyweight},
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
    id: 'shoulder_press_machine',
    nom: 'Développé épaules machine',
    group: MuscleGroup.epaules,
    equipment: {Equipment.shoulderPress},
  ),
  Exercise(
    id: 'lateral_raise',
    nom: 'Élévations latérales',
    group: MuscleGroup.epaules,
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'face_pull',
    nom: 'Face pull (poulie)',
    group: MuscleGroup.epaules,
    equipment: {Equipment.cable},
  ),
  Exercise(
    id: 'band_pull_apart',
    nom: 'Écarté élastique',
    group: MuscleGroup.epaules,
    equipment: {Equipment.bands},
  ),
  Exercise(
    id: 'pike_pushups',
    nom: 'Pompes piquées',
    group: MuscleGroup.epaules,
    equipment: {Equipment.bodyweight},
  ),

  // --- Biceps ---
  Exercise(
    id: 'barbell_curl',
    nom: 'Curl barre',
    group: MuscleGroup.biceps,
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'ez_curl',
    nom: 'Curl barre EZ',
    group: MuscleGroup.biceps,
    equipment: {Equipment.ezBar},
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
    id: 'cable_curl',
    nom: 'Curl à la poulie',
    group: MuscleGroup.biceps,
    equipment: {Equipment.cable},
  ),

  // --- Triceps ---
  Exercise(
    id: 'dips',
    nom: 'Dips',
    group: MuscleGroup.triceps,
    equipment: {Equipment.dipStation},
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
    equipment: {Equipment.ezBar, Equipment.flatBench},
  ),
  Exercise(
    id: 'db_overhead_ext',
    nom: 'Extension haltère nuque',
    group: MuscleGroup.triceps,
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'diamond_pushups',
    nom: 'Pompes diamant',
    group: MuscleGroup.triceps,
    equipment: {Equipment.bodyweight},
  ),

  // --- Jambes ---
  Exercise(
    id: 'squat',
    nom: 'Squat',
    group: MuscleGroup.jambes,
    equipment: {Equipment.barbell, Equipment.squatRack},
  ),
  Exercise(
    id: 'smith_squat',
    nom: 'Squat à la Smith',
    group: MuscleGroup.jambes,
    equipment: {Equipment.smithMachine},
  ),
  Exercise(
    id: 'leg_press',
    nom: 'Presse à cuisses',
    group: MuscleGroup.jambes,
    equipment: {Equipment.legPress},
  ),
  Exercise(
    id: 'goblet_squat',
    nom: 'Goblet squat',
    group: MuscleGroup.jambes,
    equipment: {Equipment.kettlebell},
  ),
  Exercise(
    id: 'db_lunges',
    nom: 'Fentes haltères',
    group: MuscleGroup.jambes,
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'lunges',
    nom: 'Fentes',
    group: MuscleGroup.jambes,
    equipment: {Equipment.bodyweight},
  ),
  Exercise(
    id: 'bodyweight_squat',
    nom: 'Squat au poids du corps',
    group: MuscleGroup.jambes,
    equipment: {Equipment.bodyweight},
  ),
  Exercise(
    id: 'leg_extension',
    nom: 'Leg extension',
    group: MuscleGroup.jambes,
    equipment: {Equipment.legExtension},
  ),
  Exercise(
    id: 'leg_curl',
    nom: 'Leg curl',
    group: MuscleGroup.jambes,
    equipment: {Equipment.legCurl},
  ),
  Exercise(
    id: 'calf_raise',
    nom: 'Mollets debout',
    group: MuscleGroup.jambes,
    equipment: {Equipment.calfMachine},
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
    id: 'hanging_leg_raise',
    nom: 'Relevé de jambes suspendu',
    group: MuscleGroup.abdos,
    equipment: {Equipment.pullupBar},
  ),
  Exercise(
    id: 'cable_crunch',
    nom: 'Crunch à la poulie',
    group: MuscleGroup.abdos,
    equipment: {Equipment.cable},
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
