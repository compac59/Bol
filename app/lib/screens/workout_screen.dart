import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/body_map.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key, required this.day});

  /// La séance à réaliser (déjà adaptée à la durée choisie).
  final WorkoutDay day;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final WorkoutDay _day;
  late final WorkoutSession _session;
  late final List<TextEditingController> _weights;
  late final List<ExercisePrescription> _presc;

  // Minuteur de repos.
  Timer? _timer;
  int _restRemaining = 0;
  int _restTotal = 0;

  @override
  void initState() {
    super.initState();
    _day = widget.day;
    _session = WorkoutSession(_day);
    _presc = [
      for (final pe in _day.exercises) appState.prescriptionFor(pe.exercise),
    ];
    _weights = [
      for (final pr in _presc)
        TextEditingController(
          text: pr.bodyweight
              ? '0'
              : (pr.suggestedWeightKg ?? 0).toStringAsFixed(0),
        ),
    ];
    // Force un second rendu après la première frame : corrige le cas où
    // la liste reste blanche au chargement de l'écran sur Flutter web.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _weights) {
      c.dispose();
    }
    super.dispose();
  }

  void _startRest(int seconds) {
    _timer?.cancel();
    setState(() {
      _restRemaining = seconds;
      _restTotal = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _restRemaining--;
        if (_restRemaining <= 0) t.cancel();
      });
    });
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() => _restRemaining = 0);
  }

  void _validate(int index) {
    final weight =
        double.tryParse(_weights[index].text.replaceAll(',', '.')) ?? 0;
    final reps = _day.exercises[index].minReps;
    final rest = _session.validateSet(index, reps: reps, weightKg: weight);
    setState(() {});
    if (rest != null && rest > 0) _startRest(rest);
    if (_session.isComplete) _finish();
  }

  void _finish() {
    _timer?.cancel();
    final xp = _session.computeXp(streakDays: appState.streak.current);
    appState.gainXp(xp.total.round());
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('SÉANCE TERMINÉE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppColors.gold, size: 56)
                .animate()
                .scale(
                    begin: const Offset(0.4, 0.4),
                    curve: Curves.elasticOut,
                    duration: 800.ms)
                .then()
                .shimmer(duration: 900.ms, color: Colors.white54),
            const SizedBox(height: 12),
            Text(
              '+${xp.total.round()} XP',
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 4),
            Text('Bien joué, chasseur !',
                style: Theme.of(ctx).textTheme.bodyMedium),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('RÉCUPÉRER'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _day.exercises;
    return Scaffold(
      appBar: AppBar(
        title: Text(_day.nom.toUpperCase()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _session.progress,
              minHeight: 6,
              color: AppColors.neon,
              backgroundColor: AppColors.surfaceAlt,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _restRemaining > 0 ? _restBar() : null,
      body: exercises.isEmpty
          ? const Center(child: Text('Aucun exercice pour cette séance.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (var i = 0; i < exercises.length; i++)
                  _exerciseCard(i)
                      .animate()
                      .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                      .slideY(begin: 0.05, curve: Curves.easeOutCubic),
              ],
            ),
    );
  }

  Widget _exerciseCard(int i) {
    final pe = _day.exercises[i];
    final done = _session.setsOf(i).length;
    final isCurrent = _session.currentExerciseIndex == i;
    final complete = _session.isExerciseComplete(i);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isCurrent
              ? AppColors.neon.withValues(alpha: 0.6)
              : complete
                  ? AppColors.success.withValues(alpha: 0.45)
                  : AppColors.border,
          width: isCurrent ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MuscleThumbnail(group: pe.exercise.group),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pe.exercise.nom,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color:
                                    complete ? AppColors.success : null,
                              ),
                        ),
                      ),
                      if (complete)
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 22)
                      else
                        IconButton(
                          icon: const Icon(Icons.play_circle_outline,
                              color: AppColors.textDim),
                          tooltip: 'Voir la technique',
                          onPressed: () => _showVideo(pe.exercise),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _tag(pe.exercise.primaryMuscle, AppColors.violet),
                      _tag(
                          '${pe.sets} × ${_presc[i].targetReps} reps',
                          AppColors.textDim),
                      _tag('repos ${pe.restSeconds}s', AppColors.textDim),
                      if (!_presc[i].bodyweight)
                        _tag(
                            '${_presc[i].suggestedWeightKg!.toStringAsFixed(0)} kg conseillé',
                            AppColors.neon),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 104,
                        child: TextField(
                          controller: _weights[i],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Charge',
                            suffixText: 'kg',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      _setDots(done, pe.sets),
                      const Spacer(),
                      FilledButton(
                        onPressed: (complete || !isCurrent)
                            ? null
                            : () => _validate(i),
                        child: const Text('VALIDER'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  Widget _setDots(int done, int total) {
    return Row(
      children: [
        for (var k = 0; k < total; k++)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: k < done ? AppColors.success : AppColors.surfaceAlt,
                border: Border.all(
                  color: k < done ? AppColors.success : AppColors.border,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _restBar() {
    final frac = _restTotal == 0 ? 0.0 : _restRemaining / _restTotal;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neon.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.neon.withValues(alpha: 0.18),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: frac,
                    strokeWidth: 4,
                    color: AppColors.neon,
                    backgroundColor: AppColors.surfaceAlt,
                  ),
                  const Icon(Icons.timer, size: 18, color: AppColors.neon),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'REPOS  $_restRemaining s',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.neon,
                    letterSpacing: 1.2,
                  ),
            ),
            const Spacer(),
            TextButton(onPressed: _skipRest, child: const Text('PASSER')),
          ],
        ),
      ),
    );
  }

  void _showVideo(Exercise ex) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ex.nom),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vidéo technique (copie le lien) :'),
            const SizedBox(height: 8),
            SelectableText(ex.videoSearchUrl,
                style: const TextStyle(color: AppColors.neon)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('FERMER'),
          ),
        ],
      ),
    );
  }
}
