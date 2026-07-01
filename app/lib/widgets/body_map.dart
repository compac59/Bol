import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart' as atlas;
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart' as engine;

/// Schéma anatomique (vues avant + arrière) qui met en surbrillance les
/// groupes musculaires travaillés, via le package flutter_body_atlas.
class BodyMap extends StatelessWidget {
  const BodyMap({super.key, required this.worked, this.height = 240});

  final Set<engine.MuscleGroup> worked;
  final double height;

  /// Nos groupes -> muscles du package à colorer.
  List<atlas.MuscleInfo> _musclesFor(engine.MuscleGroup g) {
    switch (g) {
      case engine.MuscleGroup.pectoraux:
        return atlas.MuscleCatalog.chest;
      case engine.MuscleGroup.dos:
        return atlas.MuscleCatalog.back;
      case engine.MuscleGroup.epaules:
        return atlas.MuscleCatalog.shoulders;
      case engine.MuscleGroup.biceps:
      case engine.MuscleGroup.triceps:
        return atlas.MuscleCatalog.arms;
      case engine.MuscleGroup.jambes:
        return [
          ...atlas.MuscleCatalog.legs,
          ...atlas.MuscleCatalog.hamstrings,
          ...atlas.MuscleCatalog.glutes,
          ...atlas.MuscleCatalog.adductors,
        ];
      case engine.MuscleGroup.abdos:
        return atlas.MuscleCatalog.core;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mapping = <atlas.MuscleInfo, Color?>{};
    for (final g in worked) {
      for (final m in _musclesFor(g)) {
        mapping[m] = accent;
      }
    }

    Widget view(atlas.AtlasAsset asset) => Expanded(
          child: atlas.BodyAtlasView<atlas.MuscleInfo>(
            view: asset,
            resolver: const atlas.MuscleResolver(),
            colorMapping: mapping,
          ),
        );

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          view(atlas.AtlasAsset.musclesFront),
          const SizedBox(width: 12),
          view(atlas.AtlasAsset.musclesBack),
        ],
      ),
    );
  }
}
