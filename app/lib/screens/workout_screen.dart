import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

import '../state/app_state.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final WorkoutDay _day;
  late final WorkoutSession _session;
  late final List<TextEditingController> _weights;

  // Minuteur de repos.
  Timer? _timer;
  int _restRemaining = 0;

  @override
  void initState() {
    super.initState();
    _day = appState.todaysWorkout;
    _session = WorkoutSession(_day);
    _weights = [
      for (final e in _day.exercises)
        TextEditingController(
            text: e.exercise.equipment.contains(Equipment.bodyweight)
                ? '0'
                : ''),
    ];
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
    setState(() => _restRemaining = seconds);
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
        title: const Text('Séance terminée 🎉'),
        content: Text('Tu as gagné ${xp.total.round()} XP !'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Super !'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_day.nom)),
      body: Column(
        children: [
          LinearProgressIndicator(value: _session.progress, minHeight: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _day.exercises.length,
              itemBuilder: (context, i) => _exerciseCard(i),
            ),
          ),
          if (_restRemaining > 0) _restBar(),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                          color: complete ? Colors.greenAccent : null,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.ondemand_video),
                  tooltip: 'Voir la technique',
                  onPressed: () => _showVideo(pe.exercise),
                ),
              ],
            ),
            Text('${pe.sets} séries × ${pe.minReps}-${pe.maxReps} reps · '
                'repos ${pe.restSeconds}s'),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _weights[i],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Charge (kg)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Séries : $done / ${pe.sets}'),
                const Spacer(),
                FilledButton(
                  onPressed: (complete || !isCurrent) ? null : () => _validate(i),
                  child: const Text('Valider'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _restBar() {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.timer),
          const SizedBox(width: 12),
          Text('Repos : $_restRemaining s',
              style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          TextButton(onPressed: _skipRest, child: const Text('Passer')),
        ],
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
            SelectableText(ex.videoSearchUrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
