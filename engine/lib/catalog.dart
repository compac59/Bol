import 'progression.dart' show MuscleGroup;

/// Les types d'équipement qu'un joueur peut cocher dans son profil (~20).
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
    required this.primaryMuscle,
    required this.equipment,
  });

  final String id;
  final String nom;

  /// Groupe musculaire large (pour la structure des séances).
  final MuscleGroup group;

  /// Muscle principal ciblé (libellé précis affiché au joueur).
  final String primaryMuscle;

  /// L'équipement **nécessaire** pour faire l'exercice (tout est requis).
  final Set<Equipment> equipment;
}

/// Le catalogue : uniquement des exercices **avec charge** (pas de poids du
/// corps, qui n'aurait pas de charge à conseiller). Les défis quotidiens au
/// poids du corps sont gérés à part (quests.dart).
const List<Exercise> exerciseCatalog = [
  // --- Pectoraux ---
  Exercise(
    id: 'bench_press',
    nom: 'Développé couché',
    group: MuscleGroup.pectoraux,
    primaryMuscle: 'Pectoraux',
    equipment: {Equipment.barbell, Equipment.flatBench},
  ),
  Exercise(
    id: 'incline_press',
    nom: 'Développé incliné',
    group: MuscleGroup.pectoraux,
    primaryMuscle: 'Haut des pectoraux',
    equipment: {Equipment.barbell, Equipment.inclineBench},
  ),
  Exercise(
    id: 'db_press',
    nom: 'Développé haltères',
    group: MuscleGroup.pectoraux,
    primaryMuscle: 'Pectoraux',
    equipment: {Equipment.dumbbells, Equipment.flatBench},
  ),
  Exercise(
    id: 'db_incline_press',
    nom: 'Développé incliné haltères',
    group: MuscleGroup.pectoraux,
    primaryMuscle: 'Haut des pectoraux',
    equipment: {Equipment.dumbbells, Equipment.inclineBench},
  ),
  Exercise(
    id: 'chest_press_machine',
    nom: 'Presse à pectoraux',
    group: MuscleGroup.pectoraux,
    primaryMuscle: 'Pectoraux',
    equipment: {Equipment.chestPress},
  ),
  Exercise(
    id: 'pec_deck',
    nom: 'Écarté (pec deck)',
    group: MuscleGroup.pectoraux,
    primaryMuscle: 'Pectoraux',
    equipment: {Equipment.pecDeck},
  ),
  Exercise(
    id: 'cable_fly',
    nom: 'Écarté à la poulie',
    group: MuscleGroup.pectoraux,
    primaryMuscle: 'Pectoraux',
    equipment: {Equipment.cable},
  ),

  // --- Dos ---
  Exercise(
    id: 'barbell_row',
    nom: 'Rowing barre',
    group: MuscleGroup.dos,
    primaryMuscle: 'Grand dorsal',
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'db_row',
    nom: 'Rowing haltère',
    group: MuscleGroup.dos,
    primaryMuscle: 'Grand dorsal',
    equipment: {Equipment.dumbbells, Equipment.flatBench},
  ),
  Exercise(
    id: 'lat_pulldown',
    nom: 'Tirage vertical',
    group: MuscleGroup.dos,
    primaryMuscle: 'Grand dorsal',
    equipment: {Equipment.latPulldown},
  ),
  Exercise(
    id: 'seated_row',
    nom: 'Rowing assis',
    group: MuscleGroup.dos,
    primaryMuscle: 'Dos (rhomboïdes)',
    equipment: {Equipment.seatedRow},
  ),
  Exercise(
    id: 'deadlift',
    nom: 'Soulevé de terre',
    group: MuscleGroup.dos,
    primaryMuscle: 'Chaîne postérieure',
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'kb_swing',
    nom: 'Swing kettlebell',
    group: MuscleGroup.dos,
    primaryMuscle: 'Fessiers / ischio-jambiers',
    equipment: {Equipment.kettlebell},
  ),
  Exercise(
    id: 'band_row',
    nom: 'Tirage élastique',
    group: MuscleGroup.dos,
    primaryMuscle: 'Grand dorsal',
    equipment: {Equipment.bands},
  ),

  // --- Épaules ---
  Exercise(
    id: 'ohp',
    nom: 'Développé militaire',
    group: MuscleGroup.epaules,
    primaryMuscle: 'Deltoïde antérieur',
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'db_shoulder_press',
    nom: 'Développé haltères épaules',
    group: MuscleGroup.epaules,
    primaryMuscle: 'Deltoïdes',
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'shoulder_press_machine',
    nom: 'Développé épaules machine',
    group: MuscleGroup.epaules,
    primaryMuscle: 'Deltoïdes',
    equipment: {Equipment.shoulderPress},
  ),
  Exercise(
    id: 'lateral_raise',
    nom: 'Élévations latérales',
    group: MuscleGroup.epaules,
    primaryMuscle: 'Deltoïde latéral',
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'face_pull',
    nom: 'Face pull (poulie)',
    group: MuscleGroup.epaules,
    primaryMuscle: 'Deltoïde postérieur',
    equipment: {Equipment.cable},
  ),
  Exercise(
    id: 'band_pull_apart',
    nom: 'Écarté élastique',
    group: MuscleGroup.epaules,
    primaryMuscle: 'Deltoïde postérieur',
    equipment: {Equipment.bands},
  ),

  // --- Biceps ---
  Exercise(
    id: 'barbell_curl',
    nom: 'Curl barre',
    group: MuscleGroup.biceps,
    primaryMuscle: 'Biceps',
    equipment: {Equipment.barbell},
  ),
  Exercise(
    id: 'ez_curl',
    nom: 'Curl barre EZ',
    group: MuscleGroup.biceps,
    primaryMuscle: 'Biceps',
    equipment: {Equipment.ezBar},
  ),
  Exercise(
    id: 'db_curl',
    nom: 'Curl haltères',
    group: MuscleGroup.biceps,
    primaryMuscle: 'Biceps',
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'hammer_curl',
    nom: 'Curl marteau',
    group: MuscleGroup.biceps,
    primaryMuscle: 'Biceps / brachial',
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'cable_curl',
    nom: 'Curl à la poulie',
    group: MuscleGroup.biceps,
    primaryMuscle: 'Biceps',
    equipment: {Equipment.cable},
  ),

  // --- Triceps ---
  Exercise(
    id: 'pushdown',
    nom: 'Extension poulie',
    group: MuscleGroup.triceps,
    primaryMuscle: 'Triceps',
    equipment: {Equipment.cable},
  ),
  Exercise(
    id: 'skull_crusher',
    nom: 'Barre au front',
    group: MuscleGroup.triceps,
    primaryMuscle: 'Triceps',
    equipment: {Equipment.ezBar, Equipment.flatBench},
  ),
  Exercise(
    id: 'db_overhead_ext',
    nom: 'Extension haltère nuque',
    group: MuscleGroup.triceps,
    primaryMuscle: 'Triceps (longue portion)',
    equipment: {Equipment.dumbbells},
  ),

  // --- Jambes ---
  Exercise(
    id: 'squat',
    nom: 'Squat',
    group: MuscleGroup.jambes,
    primaryMuscle: 'Quadriceps',
    equipment: {Equipment.barbell, Equipment.squatRack},
  ),
  Exercise(
    id: 'smith_squat',
    nom: 'Squat à la Smith',
    group: MuscleGroup.jambes,
    primaryMuscle: 'Quadriceps',
    equipment: {Equipment.smithMachine},
  ),
  Exercise(
    id: 'leg_press',
    nom: 'Presse à cuisses',
    group: MuscleGroup.jambes,
    primaryMuscle: 'Quadriceps',
    equipment: {Equipment.legPress},
  ),
  Exercise(
    id: 'goblet_squat',
    nom: 'Goblet squat',
    group: MuscleGroup.jambes,
    primaryMuscle: 'Quadriceps',
    equipment: {Equipment.kettlebell},
  ),
  Exercise(
    id: 'db_lunges',
    nom: 'Fentes haltères',
    group: MuscleGroup.jambes,
    primaryMuscle: 'Quadriceps / fessiers',
    equipment: {Equipment.dumbbells},
  ),
  Exercise(
    id: 'leg_extension',
    nom: 'Leg extension',
    group: MuscleGroup.jambes,
    primaryMuscle: 'Quadriceps',
    equipment: {Equipment.legExtension},
  ),
  Exercise(
    id: 'leg_curl',
    nom: 'Leg curl',
    group: MuscleGroup.jambes,
    primaryMuscle: 'Ischio-jambiers',
    equipment: {Equipment.legCurl},
  ),
  Exercise(
    id: 'calf_raise',
    nom: 'Mollets debout',
    group: MuscleGroup.jambes,
    primaryMuscle: 'Mollets',
    equipment: {Equipment.calfMachine},
  ),

  // --- Abdos ---
  Exercise(
    id: 'cable_crunch',
    nom: 'Crunch à la poulie',
    group: MuscleGroup.abdos,
    primaryMuscle: 'Abdominaux',
    equipment: {Equipment.cable},
  ),
];

/// Identifiants des exercices d'**isolation** (un seul muscle / une articulation).
/// Tout le reste est considéré poly-articulaire (compound).
const Set<String> isolationExerciseIds = {
  'pec_deck', 'cable_fly',
  'lateral_raise', 'face_pull', 'band_pull_apart',
  'barbell_curl', 'ez_curl', 'db_curl', 'hammer_curl', 'cable_curl',
  'pushdown', 'skull_crusher', 'db_overhead_ext',
  'leg_extension', 'leg_curl', 'calf_raise',
  'cable_crunch',
};

extension ExerciseKind on Exercise {
  /// Vrai si l'exercice est poly-articulaire (à placer en premier dans la séance).
  bool get isCompound => !isolationExerciseIds.contains(id);

  /// Chemin de l'illustration (GIF/image) à intégrer dans l'app, par convention
  /// basée sur l'identifiant. Les fichiers seront ajoutés côté app Flutter.
  String get imageAsset => 'assets/exercises/$id.gif';

  /// Lien vidéo « technique » qui fonctionne dès maintenant (recherche YouTube).
  String get videoSearchUrl {
    final q = Uri.encodeComponent('$nom musculation technique exécution');
    return 'https://www.youtube.com/results?search_query=$q';
  }
}

/// Retourne les exercices réalisables avec l'équipement disponible.
List<Exercise> availableExercises(Set<Equipment> available) {
  return exerciseCatalog
      .where((ex) => ex.equipment.every(available.contains))
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
