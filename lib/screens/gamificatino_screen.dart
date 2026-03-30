import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context, isDark)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildStreakCard(provider, isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildPointsCard(provider, isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildBadgesSection(provider, isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildStatsSection(provider, isDark),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

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
                'Achievements',
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
                'Your progress & rewards',
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

  Widget _buildStreakCard(TaskProvider provider, bool isDark) {
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
                  'Current Streak',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${provider.streak}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'days',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  provider.streakMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '🔥',
            style: TextStyle(fontSize: 64),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(TaskProvider provider, bool isDark) {
    final nextLevel = _getNextLevelProgress(provider.progress);
    final currentLevelPoints = _getCurrentLevelProgress(provider.progress);
    final progress = nextLevel == 0
        ? 1.0
        : (provider.progress - currentLevelPoints) /
            (nextLevel - currentLevelPoints);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3A3A52)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.progress} Progress',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  provider.progressLevel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextLevel == 0
                ? 'Max level reached! 🏆'
                : '${nextLevel - provider.progress} to next level',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentLevelProgress(int progress) {
    if (progress < 50) return 0;
    if (progress < 150) return 50;
    if (progress < 300) return 150;
    if (progress < 500) return 300;
    return 500;
  }

  int _getNextLevelProgress(int progress) {
    if (progress < 50) return 50;
    if (progress < 150) return 150;
    if (progress < 300) return 300;
    if (progress < 500) return 500;
    return 0;
  }

  Widget _buildBadgesSection(TaskProvider provider, bool isDark) {
    final badges = [
      _Badge('First Task', 'Complete your first task', '🎯',
          provider.progress >= 10),
      _Badge('On Fire', '3 day streak', '🔥', provider.streak >= 3),
      _Badge('Week Warrior', '7 day streak', '⚡', provider.streak >= 7),
      _Badge('Scholar', 'Earn 150 progress', '📚', provider.progress >= 150),
      _Badge('Expert', 'Earn 300  progress', '⭐', provider.progress >= 300),
      _Badge('Master', 'Earn 500  progress', '🏆', provider.progress >= 500),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏅 Badges',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: badges
              .map((badge) => _buildBadgeCard(badge, isDark))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(_Badge badge, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badge.unlocked
            ? AppTheme.primaryColor.withOpacity(0.08)
            : (isDark ? AppTheme.cardDark : AppTheme.surfaceLight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.unlocked
              ? AppTheme.primaryColor.withOpacity(0.3)
              : (isDark
                  ? const Color(0xFF3A3A52)
                  : Colors.grey.shade200),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.emoji,
            style: TextStyle(
              fontSize: 28,
              color: badge.unlocked ? null : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badge.unlocked
                  ? AppTheme.primaryColor
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.unlocked ? 'Unlocked!' : badge.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: badge.unlocked
                  ? const Color(0xFF10B981)
                  : (isDark
                      ? AppTheme.textSecondaryDark.withOpacity(0.6)
                      : AppTheme.textSecondaryLight.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(TaskProvider provider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Quick Stats',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '${provider.completedTasks}',
                'Tasks Done',
                '✅',
                isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                '${(provider.completionRate * 100).toInt()}%',
                'Completion',
                '🎯',
                isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                '${provider.streak}',
                'Day Streak',
                '🔥',
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, String emoji, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3A3A52)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;

  _Badge(this.title, this.description, this.emoji, this.unlocked);
}