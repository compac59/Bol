import 'package:flutter/material.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyBody:RPG')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final s = appState;
          final p = s.progress;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CharacterCard(state: s, progress: p),
              const SizedBox(height: 16),
              _StatsCard(stats: s.stats),
              const SizedBox(height: 16),
              if (s.promotionUnlocked()) ...[
                _PromotionBanner(),
                const SizedBox(height: 16),
              ],
              _QuestsCard(state: s),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _chooseDurationAndStart(context),
                  icon: const Icon(Icons.fitness_center),
                  label: Text('Démarrer la séance — ${s.todaysWorkout.nom}'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Future<void> _chooseDurationAndStart(BuildContext context) async {
    const durations = [30, 45, 60, 90];
    final chosen = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Durée de la séance ?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final m in durations)
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text('$m minutes'),
                subtitle: Text(
                    '~${appState.workoutForDuration(m).exercises.length} exercices'),
                onTap: () => Navigator.of(ctx).pop(m),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen == null || !context.mounted) return;
    appState.setSessionMinutes(chosen);
    final day = appState.workoutForDuration(chosen);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkoutScreen(day: day)),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.state, required this.progress});
  final AppState state;
  final LevelProgress progress;

  @override
  Widget build(BuildContext context) {
    final color = rankColor(state.currentRank);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RankBadge(rank: state.currentRank, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.pseudo,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Niveau ${progress.level}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange),
                    Text('${state.streak.current} j',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 12,
                color: color,
                backgroundColor: Colors.white12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'XP ${progress.xpDansNiveau} / ${progress.xpPourNiveauSuivant}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.color});
  final Rank rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rank.label,
        style: TextStyle(
            color: color, fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final CharacterStats stats;

  @override
  Widget build(BuildContext context) {
    final rows = <List<dynamic>>[
      ['💪 Force', stats.force],
      ['🔥 Endurance', stats.endurance],
      ['⚡ Explosivité', stats.explosivite],
      ['🛡️ Volonté', stats.volonte],
      ['❤️ Vitalité', stats.vitalite],
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistiques',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 120, child: Text(r[0] as String)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (r[1] as int) / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${r[1]}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuestsCard extends StatelessWidget {
  const _QuestsCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Défis du jour',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final q in state.dailyQuests)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: state.isQuestDone(q),
                onChanged: state.isQuestDone(q)
                    ? null
                    : (_) => state.completeQuest(q),
                title: Text(q.description),
                subtitle: Text('+${q.xpReward} XP'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.military_tech),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                  'Examen de promotion débloqué ! Repasse le test de force pour monter de rang.'),
            ),
          ],
        ),
      ),
    );
  }
}
