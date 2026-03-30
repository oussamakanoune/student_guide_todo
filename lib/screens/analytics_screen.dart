import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  int _touchedCategoryIndex = -1;
  int _touchedPriorityIndex = -1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

  List<_DayData> _getLast7DaysData(List<Task> allTasks) {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final completed = allTasks.where((t) {
        if (!t.isCompleted || t.completedAt == null) return false;
        return t.completedAt!.isAfter(dayStart) &&
            t.completedAt!.isBefore(dayEnd);
      }).length;

      final created = allTasks.where((t) {
        return t.createdAt.isAfter(dayStart) &&
            t.createdAt.isBefore(dayEnd);
      }).length;

      return _DayData(
        day: _shortDay(day.weekday),
        completed: completed,
        created: created,
      );
    });
  }

  String _shortDay(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTasks = provider.allTasks;
    final last7 = _getLast7DaysData(allTasks);
    final byCategory = provider.tasksByCategory;
    final byPriority = provider.tasksByPriority;

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
                  child: _buildOverviewCards(provider, isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _buildSectionTitle('📈 Last 7 Days', isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _buildLast7DaysChart(last7, isDark),
                ),
              ),
              if (byCategory.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: _buildSectionTitle('📚 Tasks by Category', isDark),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildCategoryChart(byCategory, isDark),
                  ),
                ),
              ],
              if (byPriority.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: _buildSectionTitle('🚦 Active Tasks by Priority', isDark),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildPriorityChart(byPriority, isDark),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _buildSectionTitle('🎯 Overall Progress', isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _buildOverallProgress(provider, isDark),
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
                  color: isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(width: 14),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Your productivity overview',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(TaskProvider provider, bool isDark) {
    final cards = [
      _OverviewData('Total', provider.totalTasks, Icons.list_alt_rounded, AppTheme.primaryColor),
      _OverviewData('Done', provider.completedTasks, Icons.check_circle_rounded, const Color(0xFF10B981)),
      _OverviewData('Active', provider.activeTasks, Icons.pending_actions_rounded, const Color(0xFF3B82F6)),
      _OverviewData('Overdue', provider.overdueTasks, Icons.warning_amber_rounded, AppTheme.priorityHigh),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: cards.map((data) => _buildOverviewCard(data, isDark)).toList(),
    );
  }

  Widget _buildOverviewCard(_OverviewData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withOpacity(0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${data.value}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                  height: 1.1,
                ),
              ),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildLast7DaysChart(List<_DayData> data, bool isDark) {
    final maxY = data
            .map((d) => (d.completed + d.created).toDouble())
            .fold(0.0, (a, b) => a > b ? a : b) + 2;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200,
        ),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY == 2 ? 5 : maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? const Color(0xFF2D2D44) : Colors.white,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = data[groupIndex];
                return BarTooltipItem(
                  rodIndex == 0 ? 'Done: ${d.completed}' : 'Created: ${d.created}',
                  TextStyle(
                    color: rodIndex == 0 ? const Color(0xFF10B981) : AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  final isToday = idx == 6;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[idx].day,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? AppTheme.primaryColor
                            : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            return BarChartGroupData(
              x: i,
              barsSpace: 3,
              barRods: [
                BarChartRodData(
                  toY: d.completed.toDouble(),
                  color: const Color(0xFF10B981),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: d.created.toDouble(),
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChart(Map<TaskCategory, int> byCategory, bool isDark) {
    final entries = byCategory.entries.toList();
    final total = entries.fold(0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedCategoryIndex = -1;
                        return;
                      }
                      _touchedCategoryIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final cat = entry.value.key;
                  final count = entry.value.value;
                  final isTouched = i == _touchedCategoryIndex;
                  final color = AppConstants.getCategoryColor(cat);
                  return PieChartSectionData(
                    color: color,
                    value: count.toDouble(),
                    title: isTouched ? '$count' : '',
                    radius: isTouched ? 55 : 45,
                    titleStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: entries.map((entry) {
              final cat = entry.key;
              final count = entry.value;
              final color = AppConstants.getCategoryColor(cat);
              final pct = total == 0 ? 0 : (count / total * 100).round();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${cat.emoji} ${cat.label} ($pct%)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChart(Map<TaskPriority, int> byPriority, bool isDark) {
    final priorities = [TaskPriority.high, TaskPriority.medium, TaskPriority.low];
    final maxY = byPriority.values.fold(0, (a, b) => a > b ? a : b) + 1.0;

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200,
        ),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY.toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? const Color(0xFF2D2D44) : Colors.white,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final p = priorities[groupIndex];
                return BarTooltipItem(
                  '${p.label}: ${rod.toY.toInt()}',
                  TextStyle(
                    color: AppConstants.getPriorityColor(p),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
// touchCallback: (event, response) {
//   setState(() {
//     if (!event.isInterestedForInteractions ||
//         response == null ||
//         response.touchedSection == null) {
//       _touchedPriorityIndex = -1;
//       return;
//     }
//     _touchedPriorityIndex =
//         response.touchedSection!.touchedBarGroupIndex;
//   });
// },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= priorities.length) return const SizedBox();
                  final p = priorities[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${p.emoji} ${p.label}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.getPriorityColor(p),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: priorities.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final count = (byPriority[p] ?? 0).toDouble();
            final isTouched = i == _touchedPriorityIndex;
            final color = AppConstants.getPriorityColor(p);
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count,
                  color: isTouched ? color : color.withOpacity(0.75),
                  width: 36,
                  borderRadius: BorderRadius.circular(8),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY.toDouble(),
                    color: color.withOpacity(0.08),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOverallProgress(TaskProvider provider, bool isDark) {
    final rate = provider.completionRate;
    final pct = (rate * 100).toStringAsFixed(1);

    String message;
    if (rate == 0) {
      message = 'Start completing tasks! 💪';
    } else if (rate < 0.3) {
      message = "You're just getting started! 🚀";
    } else if (rate < 0.6) {
      message = "Good progress, keep going! 🔥";
    } else if (rate < 1.0) {
      message = "Almost there, amazing work! ⭐";
    } else {
      message = "All tasks done! You're a legend! 🎉";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                  const Text(
                    'Completion Rate',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DayData {
  final String day;
  final int completed;
  final int created;
  _DayData({required this.day, required this.completed, required this.created});
}

class _OverviewData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  _OverviewData(this.label, this.value, this.icon, this.color);
}