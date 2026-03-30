import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';


class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key});


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = provider.totalTasks;
    final completed = provider.completedTasks;
    final active = provider.activeTasks;
    final overdue = provider.overdueTasks;
    final progress = provider.completionRate;


return Container(
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: AppTheme.headerGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppTheme.primaryColor.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // \u2500\u2500 Top Row: greeting + percentage \u2500\u2500
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Let's get things done!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // \u2500\u2500 Circular progress \u2500\u2500
          _CircularProgressWidget(progress: progress, total: total),
        ],
      ),

      const SizedBox(height: 18),

      // \u2500\u2500 Progress bar \u2500\u2500
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                total == 0
                    ? 'No tasks yet'
                    : '$completed of $total tasks completed',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 7,
            ),
          ),
        ],
      ),

      const SizedBox(height: 18),

      // \u2500\u2500 Stat pills \u2500\u2500
      Row(
        children: [
          _StatPill(
            label: 'Active',
            value: active,
            icon: Icons.pending_actions_rounded,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          _StatPill(
            label: 'Done',
            value: completed,
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF6EE7B7),
          ),
          const SizedBox(width: 8),
          _StatPill(
            label: 'Overdue',
            value: overdue,
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFFCA5A5),
          ),
        ],
      ),
    ],
  ),
);

  }


  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '\ud83c\udf05 Good morning!';
    if (hour < 17) return '\u2600\ufe0f Good afternoon!';
    if (hour < 21) return '\ud83c\udf06 Good evening!';
    return '\ud83c\udf19 Good night!';
  }
}


// \u2500\u2500\u2500 Circular Progress Widget \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


class _CircularProgressWidget extends StatelessWidget {
  final double progress;
  final int total;


  const _CircularProgressWidget({
    required this.progress,
    required this.total,
  });


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            total == 0
                ? '\u2013'
                : '${(progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


// \u2500\u2500\u2500 Stat Pill \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;


  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}