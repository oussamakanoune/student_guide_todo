import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showSetGoalDialog(
      BuildContext context, TaskCategory category, int currentTarget) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int selectedTarget = currentTarget == 0 ? 1 : currentTarget;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor:
              isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How many tasks per week?',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Minus button ──
                  GestureDetector(
                    onTap: () {
                      if (selectedTarget > 1) {
                        setDialogState(() => selectedTarget--);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.remove_rounded,
                          color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // ── Number ──
                  Text(
                    '$selectedTarget',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // ── Plus button ──
                  GestureDetector(
                    onTap: () {
                      if (selectedTarget < 50) {
                        setDialogState(() => selectedTarget++);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'tasks this week',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
          actions: [
            // ── Remove goal button ──
            if (currentTarget > 0)
              TextButton(
                onPressed: () {
                  context.read<TaskProvider>().removeGoal(category);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: AppTheme.priorityHigh),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .read<TaskProvider>()
                    .setGoal(category, selectedTarget);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = TaskCategory.values;

    // ── Count active goals ──
    final activeGoals = categories
        .where((c) => provider.getGoalTarget(c) > 0)
        .length;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ──
              SliverToBoxAdapter(
                child: _buildAppBar(context, isDark),
              ),

              // ── Summary card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildSummaryCard(provider, isDark, activeGoals),
                ),
              ),

              // ── Section title ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    '🎯 Weekly Goals by Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
              ),

              // ── Goals list ──
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    final target = provider.getGoalTarget(category);
                    final progress = provider.getGoalProgress(category);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _buildGoalCard(
                        context,
                        category,
                        target,
                        progress,
                        isDark,
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3A3A52)
                      : Colors.grey.shade200,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Goals',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Set your targets for this week',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard(
      TaskProvider provider, bool isDark, int activeGoals) {
    final categories = TaskCategory.values;
    final completedGoals = categories
        .where((c) =>
            provider.getGoalTarget(c) > 0 &&
            provider.getGoalProgress(c) >= provider.getGoalTarget(c))
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Week',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedGoals / $activeGoals goals reached',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: activeGoals == 0
                        ? 0
                        : completedGoals / activeGoals,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // ── Goal Card ─────────────────────────────────────────────────────────────

  Widget _buildGoalCard(
    BuildContext context,
    TaskCategory category,
    int target,
    int progress,
    bool isDark,
  ) {
    final color = AppConstants.getCategoryColor(category);
    final hasGoal = target > 0;
    final isCompleted = hasGoal && progress >= target;
    final progressValue = hasGoal
        ? (progress / target).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => _showSetGoalDialog(context, category, target),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF10B981).withOpacity(0.4)
                : hasGoal
                    ? color.withOpacity(0.2)
                    : (isDark
                        ? const Color(0xFF3A3A52)
                        : Colors.grey.shade200),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? const Color(0xFF10B981).withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // ── Category icon ──
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Category info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                      Text(
                        hasGoal
                            ? '$progress / $target tasks this week'
                            : 'No goal set — tap to add',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Status icon ──
                if (isCompleted)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    hasGoal
                        ? Icons.edit_rounded
                        : Icons.add_circle_outline_rounded,
                    color: hasGoal
                        ? color
                        : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
                    size: 22,
                  ),
              ],
            ),

            // ── Progress bar ──
            if (hasGoal) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? const Color(0xFF10B981) : color,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCompleted ? '🎉 Goal reached!' : '$progress done',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight),
                    ),
                  ),
                  Text(
                    '${(progressValue * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : color,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
