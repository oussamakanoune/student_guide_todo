import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/stats_header.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';
import 'task_detail_screen.dart';
import 'analytics_screen.dart';
// import '../models/goal_model.dart';
import 'goals_screen.dart';
import 'calendar_screen.dart';
import 'gamificatino_screen.dart';
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});


  @override
  State<TodoScreen> createState() => _TodoScreenState();
}


class _TodoScreenState extends State<TodoScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showCategoryFilter = false;
  bool _isScrolled = false;


  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();


_scrollController.addListener(() {
  final scrolled = _scrollController.offset > 10;
  if (scrolled != _isScrolled) {
    setState(() => _isScrolled = scrolled);
  }
});

  }


  @override
  void dispose() {
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  // \u2500\u2500\u2500 Open Add Task Sheet \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  void _openAddTaskSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const TaskFormSheet(),
    );
  }


  // \u2500\u2500\u2500 Open Edit Task Sheet \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  void _openEditTaskSheet(Task task) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => TaskFormSheet(task: task),
    );
  }


  // \u2500\u2500\u2500 Navigate to Detail \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  void _openTaskDetail(Task task) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => TaskDetailScreen(task: task),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }


  // \u2500\u2500\u2500 Delete Task \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  void _deleteTask(BuildContext context, Task task) {
    HapticFeedback.mediumImpact();
    final provider = context.read<TaskProvider>();
    provider.deleteTask(task.id);


ScaffoldMessenger.of(context).clearSnackBars();
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '"${task.title}" deleted',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
    action: SnackBarAction(
      label: 'Undo',
      textColor: Colors.white,
      onPressed: () async => await provider.addTask(task),
    ),
    backgroundColor: const Color(0xFF1E1E2E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    duration: const Duration(seconds: 4),
  ),
);

  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<TaskProvider>();


return Scaffold(
  backgroundColor:
      isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
  body: SafeArea(
    child: Column(
      children: [
        // \u2500\u2500 Top App Bar \u2500\u2500
        _buildAppBar(context, isDark, provider),

        // \u2500\u2500 Body \u2500\u2500
        Expanded(
          child: provider.isLoading
              ? _buildLoadingState()
              : _buildContent(context, isDark, provider),
        ),
      ],
    ),
  ),

  // \u2500\u2500 FAB \u2500\u2500
  floatingActionButton: ScaleTransition(
    scale: _fabAnimation,
    child: FloatingActionButton.extended(
      onPressed: _openAddTaskSheet,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text(
        'New Task',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  ),
);

  }


  // \u2500\u2500\u2500 App Bar \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  Widget _buildAppBar(
      BuildContext context, bool isDark, TaskProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        boxShadow: _isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
      child: Row(
        children: [
          // \u2500\u2500 Title \u2500\u2500
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.todoFeatureName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _getSubtitle(provider),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),


      // \u2500\u2500 Category toggle \u2500\u2500
// ── Analytics button ──
_AppBarIconButton(
  icon: Icons.bar_chart_rounded,
  isDark: isDark,
  isActive: false,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AnalyticsScreen(),
    ),
  ),
  tooltip: 'Analytics',
),


      const SizedBox(width: 6),

      // ── Goals button ──
_AppBarIconButton(
  icon: Icons.track_changes_rounded,
  isDark: isDark,
  isActive: false,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const GoalsScreen(),
    ),
  ),
  tooltip: 'Goals',
),
const SizedBox(width: 6),

// ── Calendar button ──
_AppBarIconButton(
  icon: Icons.calendar_month_rounded,
  isDark: isDark,
  isActive: false,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CalendarScreen(),
    ),
  ),
  tooltip: 'Calendar',
),


const SizedBox(width: 6),
// ── Achievements button ──
_AppBarIconButton(
  icon: Icons.emoji_events_rounded,
  isDark: isDark,
  isActive: false,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const GamificationScreen(),
    ),
  ),
  tooltip: 'Achievements',
),
const SizedBox(width: 6),


      // \u2500\u2500 More menu \u2500\u2500
      _AppBarIconButton(
        icon: Icons.more_vert_rounded,
        isDark: isDark,
        onTap: () => _showMoreMenu(context, isDark, provider),
        tooltip: 'More Options',
      ),
    ],
  ),
);

  }


  String _getSubtitle(TaskProvider provider) {
    if (provider.totalTasks == 0) return 'Add your first task';
    if (provider.activeTasks == 0) return 'All tasks completed \ud83c\udf89';
    return '${provider.activeTasks} task${provider.activeTasks == 1 ? '' : 's'} remaining';
  }


  // \u2500\u2500\u2500 Main Content \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  Widget _buildContent(
      BuildContext context, bool isDark, TaskProvider provider) {
    final tasks = provider.filteredTasks;
    final isSearching = provider.searchQuery.isNotEmpty;


return CustomScrollView(
  controller: _scrollController,
  physics: const BouncingScrollPhysics(),
  slivers: [
    // \u2500\u2500 Stats header \u2500\u2500
    const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: StatsHeader(),
      ),
    ),

    // \u2500\u2500 Search bar \u2500\u2500
    const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: TaskSearchBar(),
      ),
    ),

    // \u2500\u2500 Filter bar \u2500\u2500
    const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FilterBar(),
      ),
    ),

    // \u2500\u2500 Category filter bar \u2500\u2500
    if (_showCategoryFilter)
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: CategoryFilterBar(),
        ),
      ),

    // \u2500\u2500 Section title \u2500\u2500
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSearching
                  ? 'Search results (${tasks.length})'
                  : '${provider.activeFilter.label} (${tasks.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
            if (provider.completedTasks > 0 &&
                provider.activeFilter == FilterOption.all)
              GestureDetector(
                onTap: () => _confirmClearCompleted(context, isDark,
                    provider.completedTasks),
                child: Text(
                  'Clear done (${provider.completedTasks})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.priorityHigh,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),

    // \u2500\u2500 Task list or empty state \u2500\u2500
    tasks.isEmpty
        ? SliverFillRemaining(
            child: EmptyStateWidget(
              filter: provider.activeFilter,
              isSearching: isSearching,
              onAddTask: _openAddTaskSheet,
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = tasks[index];
                return AnimatedTaskCard(
                  key: ValueKey(task.id),
                  task: task,
                  index: index,
                  onTap: () => _openTaskDetail(task),
                  onEdit: () => _openEditTaskSheet(task),
                  onDelete: () => _deleteTask(context, task),
                );
              },
              childCount: tasks.length,
            ),
          ),

    // \u2500\u2500 Bottom padding for FAB \u2500\u2500
    const SliverToBoxAdapter(
      child: SizedBox(height: 100),
    ),
  ],
);

  }


  // \u2500\u2500\u2500 Loading State \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your tasks...',
            style: TextStyle(
              color: AppTheme.textSecondaryLight.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  // \u2500\u2500\u2500 More Menu \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  void _showMoreMenu(
      BuildContext context, bool isDark, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreMenuSheet(
        isDark: isDark,
        provider: provider,
        onClearCompleted: () => _confirmClearCompleted(
            context, isDark, provider.completedTasks),
        onClearFilters: () => provider.clearFilters(),
        onToggleTheme: () =>
            context.read<ThemeProvider>().toggleTheme(),
      ),
    );
  }


  // \u2500\u2500\u2500 Confirm Clear Completed \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  void _confirmClearCompleted(
      BuildContext context, bool isDark, int count) {
    if (count == 0) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Clear Completed?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'This will permanently delete $count completed task${count == 1 ? '' : 's'}. This action cannot be undone.',
          style: TextStyle(
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskProvider>().deleteCompletedTasks();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.priorityHigh,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Clear All',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}


// \u2500\u2500\u2500 Animated Task Card Wrapper \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


class AnimatedTaskCard extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;


  const AnimatedTaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });


  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}


class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: 300 + (widget.index.clamp(0, 10) * 40)),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: TaskCard(
          task: widget.task,
          onTap: widget.onTap,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
        ),
      ),
    );
  }
}


// \u2500\u2500\u2500 App Bar Icon Button \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;


  const _AppBarIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
    required this.tooltip,
    this.isActive = false,
  });


  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor.withOpacity(0.12)
                : (isDark ? AppTheme.cardDark : AppTheme.surfaceLight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : (isDark
                      ? const Color(0xFF3A3A52)
                      : Colors.grey.shade200),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? AppTheme.primaryColor
                : (isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}


// \u2500\u2500\u2500 More Menu Sheet \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


class _MoreMenuSheet extends StatelessWidget {
  final bool isDark;
  final TaskProvider provider;
  final VoidCallback onClearCompleted;
  final VoidCallback onClearFilters;
  final VoidCallback onToggleTheme;


  const _MoreMenuSheet({
    required this.isDark,
    required this.provider,
    required this.onClearCompleted,
    required this.onClearFilters,
    required this.onToggleTheme,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),


      Text(
        'Options',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppTheme.textPrimaryDark
              : AppTheme.textPrimaryLight,
        ),
      ),
      const SizedBox(height: 12),

      // Toggle theme
      _MenuItem(
        icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        label: isDark ? 'Light Mode' : 'Dark Mode',
        color: AppTheme.primaryColor,
        isDark: isDark,
        onTap: () {
          Navigator.pop(context);
          onToggleTheme();
        },
      ),

      // Clear filters
      if (provider.searchQuery.isNotEmpty ||
          provider.activeFilter != FilterOption.all ||
          provider.selectedCategory != null)
        _MenuItem(
          icon: Icons.filter_alt_off_rounded,
          label: 'Clear All Filters',
          color: AppTheme.primaryColor,
          isDark: isDark,
          onTap: () {
            Navigator.pop(context);
            onClearFilters();
          },
        ),

      // Clear completed
      if (provider.completedTasks > 0)
        _MenuItem(
          icon: Icons.delete_sweep_rounded,
          label:
              'Clear Completed (${provider.completedTasks})',
          color: AppTheme.priorityHigh,
          isDark: isDark,
          onTap: () {
            Navigator.pop(context);
            onClearCompleted();
          },
        ),

      const SizedBox(height: 8),
    ],
  ),
);

  }
}


class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;


  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppTheme.textPrimaryDark
              : AppTheme.textPrimaryLight,
        ),
      ),
      onTap: onTap,
    );
  }
}