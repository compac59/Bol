import 'package:flutter/material.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

import '../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pseudo = TextEditingController();
  final _bodyWeight = TextEditingController(text: '75');
  TrainingGoal _goal = TrainingGoal.masse;
  int _days = 3;
  final Set<Equipment> _equipment = {};

  // Test initial (facultatif) : charges en kg, tractions en reps.
  final _bench = TextEditingController();
  final _squat = TextEditingController();
  final _deadlift = TextEditingController();
  final _ohp = TextEditingController();
  final _pullups = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _pseudo,
      _bodyWeight,
      _bench,
      _squat,
      _deadlift,
      _ohp,
      _pullups,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<PerformanceEntry> _buildTestEntries() {
    final entries = <PerformanceEntry>[];
    void add(TextEditingController c, AssessmentExercise ex) {
      final v = double.tryParse(c.text.replaceAll(',', '.'));
      if (v != null && v > 0) entries.add(PerformanceEntry(exercise: ex, charge: v));
    }

    add(_bench, AssessmentExercise.bench);
    add(_squat, AssessmentExercise.squat);
    add(_deadlift, AssessmentExercise.deadlift);
    add(_ohp, AssessmentExercise.overhead);
    add(_pullups, AssessmentExercise.pullups);
    return entries;
  }

  Future<void> _create() async {
    // Sans équipement, aucune séance ne peut être générée : on prévient.
    if (_equipment.isEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('AUCUN ÉQUIPEMENT'),
          content: const Text(
              'Tu n\'as coché aucun équipement : aucune séance ne pourra être '
              'proposée. Coche au moins un matériel (haltères, barre, machines…). '
              'Tu pourras le modifier plus tard dans ton profil.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('CHOISIR MON ÉQUIPEMENT'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('CONTINUER QUAND MÊME'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    final pseudo = _pseudo.text.trim().isEmpty ? 'Chasseur' : _pseudo.text.trim();
    final bw = double.tryParse(_bodyWeight.text.replaceAll(',', '.')) ?? 75;
    appState.completeOnboarding(
      pseudo: pseudo,
      bodyWeight: bw,
      goal: _goal,
      equipment: _equipment,
      daysPerWeek: _days,
      testEntries: _buildTestEntries(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crée ton chasseur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Ton profil'),
          TextField(
            controller: _pseudo,
            decoration: const InputDecoration(labelText: 'Pseudo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyWeight,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Poids de corps (kg)'),
          ),
          const SizedBox(height: 20),
          _section('Ton objectif'),
          Wrap(
            spacing: 8,
            children: [
              for (final g in TrainingGoal.values)
                ChoiceChip(
                  label: Text(g.label),
                  selected: _goal == g,
                  onSelected: (_) => setState(() => _goal = g),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _section('Séances par semaine'),
          Slider(
            value: _days.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: '$_days jours',
            onChanged: (v) => setState(() => _days = v.round()),
          ),
          Text('$_days jours / semaine',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          _section('Ton équipement'),
          const Text('Coche ce que tu possèdes (le poids du corps est inclus).'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final e in Equipment.values)
                if (e != Equipment.bodyweight)
                  FilterChip(
                    label: Text(e.label),
                    selected: _equipment.contains(e),
                    onSelected: (sel) => setState(() {
                      sel ? _equipment.add(e) : _equipment.remove(e);
                    }),
                  ),
            ],
          ),
          const SizedBox(height: 20),
          _section('Examen d\'entrée (facultatif)'),
          const Text(
              'Renseigne tes maxs pour démarrer à ton vrai niveau. Laisse vide pour commencer au niveau 1.'),
          const SizedBox(height: 8),
          _testField(_bench, 'Développé couché — max (kg)'),
          _testField(_squat, 'Squat — max (kg)'),
          _testField(_deadlift, 'Soulevé de terre — max (kg)'),
          _testField(_ohp, 'Développé militaire — max (kg)'),
          _testField(_pullups, 'Tractions — reps max'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _create,
              child: const Text('Créer mon chasseur'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(title.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(letterSpacing: 1.3)),
          ],
        ),
      );

  Widget _testField(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
        ),
      );
}
