import 'package:flutter/material.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

/// Schéma stylisé du corps qui met en surbrillance les groupes musculaires
/// travaillés.
class BodyMap extends StatelessWidget {
  const BodyMap({super.key, required this.worked, this.height = 200});

  final Set<MuscleGroup> worked;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _BodyPainter(
          worked: worked,
          accent: Theme.of(context).colorScheme.primary,
          base: const Color(0xFF2A2F3A),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.worked,
    required this.accent,
    required this.base,
  });

  final Set<MuscleGroup> worked;
  final Color accent;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Paint p(bool on) => Paint()..color = on ? accent : base;
    bool has(MuscleGroup g) => worked.contains(g);
    final arms = has(MuscleGroup.biceps) || has(MuscleGroup.triceps);

    RRect box(double l, double t, double r, double b) =>
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * l, h * t, w * r, h * b),
          const Radius.circular(6),
        );

    // Tête (neutre).
    canvas.drawCircle(Offset(w * 0.5, h * 0.09), h * 0.06, p(false));

    // Épaules.
    canvas.drawCircle(Offset(w * 0.34, h * 0.20), h * 0.05, p(has(MuscleGroup.epaules)));
    canvas.drawCircle(Offset(w * 0.66, h * 0.20), h * 0.05, p(has(MuscleGroup.epaules)));

    // Bras (biceps / triceps).
    canvas.drawRRect(box(0.23, 0.22, 0.31, 0.45), p(arms));
    canvas.drawRRect(box(0.69, 0.22, 0.77, 0.45), p(arms));

    // Dos (lats, sur les côtés du tronc).
    canvas.drawRRect(box(0.33, 0.24, 0.38, 0.42), p(has(MuscleGroup.dos)));
    canvas.drawRRect(box(0.62, 0.24, 0.67, 0.42), p(has(MuscleGroup.dos)));

    // Pectoraux.
    canvas.drawRRect(box(0.37, 0.16, 0.63, 0.30), p(has(MuscleGroup.pectoraux)));

    // Abdominaux.
    canvas.drawRRect(box(0.41, 0.30, 0.59, 0.47), p(has(MuscleGroup.abdos)));

    // Jambes (cuisses + mollets).
    final legs = has(MuscleGroup.jambes);
    canvas.drawRRect(box(0.40, 0.48, 0.485, 0.70), p(legs));
    canvas.drawRRect(box(0.515, 0.48, 0.60, 0.70), p(legs));
    canvas.drawRRect(box(0.42, 0.71, 0.485, 0.92), p(legs));
    canvas.drawRRect(box(0.515, 0.71, 0.58, 0.92), p(legs));
  }

  @override
  bool shouldRepaint(covariant _BodyPainter old) =>
      old.worked != worked || old.accent != accent;
}
