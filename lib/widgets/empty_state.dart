import 'package:flutter/material.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';


class EmptyStateWidget extends StatelessWidget {
  final FilterOption filter;
  final bool isSearching;
  final VoidCallback onAddTask;


  const EmptyStateWidget({
    super.key,
    required this.filter,
    required this.isSearching,
    required this.onAddTask,
  });


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getConfig(filter, isSearching);


return Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // \u2500\u2500 Illustration container \u2500\u2500
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              config.emoji,
              style: const TextStyle(fontSize: 52),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // \u2500\u2500 Title \u2500\u2500
        Text(
          config.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),

        // \u2500\u2500 Subtitle \u2500\u2500
        Text(
          config.subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            height: 1.5,
          ),
        ),

        // \u2500\u2500 CTA button (only for "all" filter when no tasks) \u2500\u2500
        if (config.showButton) ...[
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAddTask,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Your First Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ],
    ),
  ),
);

  }


  _EmptyStateConfig _getConfig(FilterOption filter, bool isSearching) {
    if (isSearching) {
      return const _EmptyStateConfig(
        emoji: '\ud83d\udd0d',
        title: 'No results found',
        subtitle:
            'Try searching with different keywords or check your spelling.',
        showButton: false,
      );
    }


switch (filter) {
  case FilterOption.all:
    return const _EmptyStateConfig(
      emoji: '\ud83d\udccb',
      title: 'No tasks yet',
      subtitle:
          'Start organizing your student life!\nCreate your first task and stay on top of things.',
          showButton: true,
        );
      case FilterOption.active:
        return const _EmptyStateConfig(
          emoji: '\ud83c\udf89',
          title: "You're all caught up!",
          subtitle:
              'No active tasks remaining.\nGreat work staying on top of your studies!',
          showButton: false,
        );
      case FilterOption.completed:
        return const _EmptyStateConfig(
          emoji: '\ud83c\udfc6',
          title: 'No completed tasks',
          subtitle:
              'Tasks you finish will appear here.\nComplete a task to see it here!',
          showButton: false,
        );
      case FilterOption.starred:
        return const _EmptyStateConfig(
          emoji: '\u2b50',
          title: 'No starred tasks',
          subtitle:
              'Star your most important tasks\nto quickly find them here.',
          showButton: false,
        );
      case FilterOption.overdue:
        return const _EmptyStateConfig(
          emoji: '\u2705',
          title: 'No overdue tasks!',
          subtitle:
              "You're on top of your deadlines.\nKeep up the great work!",
          showButton: false,
        );
      case FilterOption.today:
        return const _EmptyStateConfig(
          emoji: '\u2728',
          title: 'Nothing due today',
          subtitle:
              'Your schedule is clear for today.\nEnjoy your free time!',
          showButton: false,
        );
    }
  }
}


// \u2500\u2500\u2500 Config Model \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


class _EmptyStateConfig {
  final String emoji;
  final String title;
  final String subtitle;
  final bool showButton;


  const _EmptyStateConfig({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.showButton,
  });
}