import 'package:flutter/material.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

import '../state/app_state.dart';
import '../theme.dart';

/// Profil du chasseur : identité, équipement, maxs et examen de promotion.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _bench = TextEditingController();
  final _squat = TextEditingController();
  final _deadlift = TextEditingController();
  final _ohp = TextEditingController();
  final _pullups = TextEditingController();

  @override
  void dispose() {
    for (final c in [_bench, _squat, _deadlift, _ohp, _pullups]) {
      c.dispose();
    }
    super.dispose();
  }

  List<PerformanceEntry> _entries() {
    final entries = <PerformanceEntry>[];
    void add(TextEditingController c, AssessmentExercise ex) {
      final v = double.tryParse(c.text.replaceAll(',', '.'));
      if (v != null && v > 0) {
        entries.add(PerformanceEntry(exercise: ex, charge: v));
      }
    }

    add(_bench, AssessmentExercise.bench);
    add(_squat, AssessmentExercise.squat);
    add(_deadlift, AssessmentExercise.deadlift);
    add(_ohp, AssessmentExercise.overhead);
    add(_pullups, AssessmentExercise.pullups);
    return entries;
  }

  void _submit() {
    final entries = _entries();
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Renseigne au moins un exercice.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (appState.promotionUnlocked()) {
      final result = appState.attemptPromotion(entries);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(result.passed ? 'PROMOTION !' : 'EXAMEN ÉCHOUÉ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                result.passed ? Icons.military_tech : Icons.fitness_center,
                size: 52,
                color: result.passed ? AppColors.gold : AppColors.textDim,
              ),
              const SizedBox(height: 12),
              Text(result.message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      appState.updateStrengthProfile(entries);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Charges de référence mises à jour ✔'),
        behavior: SnackBarBehavior.floating,
      ));
    }
    setState(() {});
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('RECOMMENCER À ZÉRO ?'),
        content: const Text(
            'Tout sera effacé : niveau, XP, streak, progression des exercices. '
            'Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ANNULER'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('TOUT EFFACER'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await appState.reset();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROFIL')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final s = appState;
          final color = rankColor(s.currentRank);
          final examUnlocked = s.promotionUnlocked();
          final nextRank = rankAbove(s.currentRank);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              // --- Identité ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          border: Border.all(color: color, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 14),
                          ],
                        ),
                        child: Text(
                          s.currentRank.label,
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.pseudo,
                                style:
                                    Theme.of(context).textTheme.titleLarge),
                            Text(
                              'Niveau ${s.level} · ${s.totalXp} XP total\n'
                              'Record de streak : ${s.streak.best} j · '
                              'Jokers : ${s.streak.freezesRemaining}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Réglages d'entraînement ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ENTRAÎNEMENT',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(letterSpacing: 1.4)),
                      const SizedBox(height: 8),
                      Text(
                        'Objectif : ${s.goal.label} (${s.goal.minReps}-${s.goal.maxReps} reps)\n'
                        'Fréquence : ${s.daysPerWeek} j/semaine · '
                        'Durée préférée : ${s.sessionMinutes} min\n'
                        'Poids de corps : ${s.bodyWeight.toStringAsFixed(0)} kg',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // --- Équipement (modifiable) ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MON ÉQUIPEMENT',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(letterSpacing: 1.4)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final e in Equipment.values)
                            if (e != Equipment.bodyweight)
                              FilterChip(
                                label: Text(e.label),
                                selected: s.equipment.contains(e),
                                onSelected: (_) => s.toggleEquipment(e),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- Maxs / examen de promotion ---
              Card(
                shape: examUnlocked
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                            color: AppColors.violet.withValues(alpha: 0.6),
                            width: 1.4),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        examUnlocked
                            ? 'EXAMEN DE PROMOTION — RANG ${nextRank!.label}'
                            : 'MES CHARGES DE RÉFÉRENCE',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              letterSpacing: 1.4,
                              color: examUnlocked ? AppColors.violet : null,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        examUnlocked
                            ? 'Prouve ta force pour passer au rang supérieur : renseigne tes maxs actuels.'
                            : 'Mets à jour tes maxs pour recalibrer les charges conseillées.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      _maxField(_bench, 'Développé couché — max (kg)'),
                      _maxField(_squat, 'Squat — max (kg)'),
                      _maxField(_deadlift, 'Soulevé de terre — max (kg)'),
                      _maxField(_ohp, 'Développé militaire — max (kg)'),
                      _maxField(_pullups, 'Tractions — reps max'),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: examUnlocked
                              ? FilledButton.styleFrom(
                                  backgroundColor: AppColors.violet,
                                  foregroundColor: Colors.white)
                              : null,
                          onPressed: _submit,
                          child: Text(examUnlocked
                              ? 'PASSER L\'EXAMEN'
                              : 'METTRE À JOUR'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Danger ---
              TextButton.icon(
                onPressed: _confirmReset,
                icon: const Icon(Icons.restart_alt, color: AppColors.danger),
                label: const Text('Recommencer à zéro',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _maxField(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );
}
