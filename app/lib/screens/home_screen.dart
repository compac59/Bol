import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          final cards = <Widget>[
            _CharacterCard(state: s, progress: p),
            _StatsCard(stats: s.stats),
            if (s.promotionUnlocked()) const _PromotionBanner(),
            _QuestsCard(state: s),
            _StartButton(
              label: s.todaysWorkout.nom,
              onTap: () => _chooseDurationAndStart(context),
            ),
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              for (var i = 0; i < cards.length; i++)
                cards[i]
                    .animate()
                    .fadeIn(delay: (70 * i).ms, duration: 350.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),
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
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Durée de la séance ?',
                  style: Theme.of(ctx).textTheme.titleLarge),
            ),
            for (final m in durations)
              ListTile(
                leading: const Icon(Icons.timer_outlined,
                    color: AppColors.neon),
                title: Text('$m minutes',
                    style: Theme.of(ctx).textTheme.titleMedium),
                subtitle: Text(
                    '~${appState.workoutForDuration(m).exercises.length} exercices',
                    style: Theme.of(ctx).textTheme.bodySmall),
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

class _StartButton extends StatelessWidget {
  const _StartButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.neon, Color(0xFF3AA8F5)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, color: Color(0xFF06282E)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'DÉMARRER — ${label.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF06282E),
                          letterSpacing: 1.1,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.10),
              AppColors.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(18),
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
                      const SizedBox(height: 2),
                      Text(
                        'CHASSEUR RANG ${state.currentRank.label} · NIVEAU ${progress.level}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(letterSpacing: 1.1),
                      ),
                    ],
                  ),
                ),
                _StreakFlame(days: state.streak.current),
              ],
            ),
            const SizedBox(height: 18),
            _XpBar(progress: progress, color: color),
          ],
        ),
      ),
    );
  }
}

class _XpBar extends StatelessWidget {
  const _XpBar({required this.progress, required this.color});
  final LevelProgress progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(height: 14, color: AppColors.surfaceAlt),
              AnimatedFractionallySizedBox(
                duration: 600.ms,
                curve: Curves.easeOutCubic,
                widthFactor: progress.fraction.clamp(0.02, 1.0),
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.7), color],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('XP ${progress.xpDansNiveau} / ${progress.xpPourNiveauSuivant}',
                style: Theme.of(context).textTheme.bodySmall),
            Text('${(progress.fraction * 100).round()} %',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _StreakFlame extends StatelessWidget {
  const _StreakFlame({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final active = days > 0;
    final color = active ? const Color(0xFFFF8A3D) : AppColors.textDim;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: color, size: 22),
          Text('$days j',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color)),
        ],
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
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 16),
        ],
      ),
      child: Text(
        rank.label,
        style: TextStyle(
          fontFamily: 'Rajdhani',
          color: color,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final CharacterStats stats;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, IconData, String, int)>[
      ('force', Icons.fitness_center, 'Force', stats.force),
      ('endurance', Icons.local_fire_department, 'Endurance', stats.endurance),
      ('explosivite', Icons.bolt, 'Explosivité', stats.explosivite),
      ('volonte', Icons.shield_outlined, 'Volonté', stats.volonte),
      ('vitalite', Icons.favorite, 'Vitalité', stats.vitalite),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('STATISTIQUES',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(letterSpacing: 1.4)),
            const SizedBox(height: 14),
            for (final (key, icon, label, value) in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 128,
                      child: Row(
                        children: [
                          Icon(icon, size: 16, color: statColor(key)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(
                                height: 9, color: AppColors.surfaceAlt),
                            AnimatedFractionallySizedBox(
                              duration: 700.ms,
                              curve: Curves.easeOutCubic,
                              widthFactor: (value / 100).clamp(0.02, 1.0),
                              child: Container(
                                height: 9,
                                color: statColor(key),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$value',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: statColor(key),
                        ),
                      ),
                    ),
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
    final quests = state.dailyQuests;
    final doneCount = quests.where(state.isQuestDone).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('DÉFIS DU JOUR',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(letterSpacing: 1.4)),
                ),
                Text('$doneCount / ${quests.length}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.neon)),
              ],
            ),
            const SizedBox(height: 10),
            for (final q in quests) _QuestTile(state: state, quest: q),
          ],
        ),
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({required this.state, required this.quest});
  final AppState state;
  final DailyQuest quest;

  @override
  Widget build(BuildContext context) {
    final done = state.isQuestDone(quest);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: done ? null : () => state.completeQuest(quest),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: done
                ? AppColors.success.withValues(alpha: 0.08)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: done
                  ? AppColors.success.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? AppColors.success : AppColors.textDim,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quest.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? AppColors.textDim : AppColors.text,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${quest.xpReward} XP',
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  const _PromotionBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              AppColors.violet.withValues(alpha: 0.25),
              AppColors.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.military_tech, color: AppColors.violet, size: 30)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(end: 1.15, duration: 700.ms),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Examen de promotion débloqué !\nRepasse le test de force pour monter de rang.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
