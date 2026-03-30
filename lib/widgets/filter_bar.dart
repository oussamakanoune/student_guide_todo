import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

// \u2500\u2500\u2500 Filter Bar \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: FilterOption.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = FilterOption.values[index];
          final isSelected = provider.activeFilter == filter;
          final count = _getCount(provider, filter);

          return _FilterChip(
            filter: filter,
            isSelected: isSelected,
            count: count,
            isDark: isDark,
            onTap: () => provider.setFilter(filter),
          );
        },
      ),
    );
  }

  int _getCount(TaskProvider provider, FilterOption filter) {
    switch (filter) {
      case FilterOption.all:
        return provider.totalTasks;
      case FilterOption.active:
        return provider.activeTasks;
      case FilterOption.completed:
        return provider.completedTasks;
      case FilterOption.starred:
        return provider.starredTasks;
      case FilterOption.overdue:
        return provider.overdueTasks;
      case FilterOption.today:
        return provider.todayTasks;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final FilterOption filter;
  final bool isSelected;
  final int count;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.count,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark ? AppTheme.cardDark : AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(filter.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// \u2500\u2500\u2500 Category Filter Bar \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: TaskCategory.values.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = provider.selectedCategory == null;
            return _CategoryChip(
              label: 'All',
              icon: Icons.apps_rounded,
              color: AppTheme.primaryColor,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => provider.setSelectedCategory(null),
            );
          }
          final category = TaskCategory.values[index - 1];
          final isSelected = provider.selectedCategory == category;
          final color = AppConstants.getCategoryColor(category);

          return _CategoryChip(
            label: category.label,
            icon: AppConstants.getCategoryIcon(category),
            color: color,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () =>
                provider.setSelectedCategory(isSelected ? null : category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? AppTheme.cardDark : AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : (isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? color
                  : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? color
                    : (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// \u2500\u2500\u2500 Search Bar Widget \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

class TaskSearchBar extends StatefulWidget {
  const TaskSearchBar({super.key});

  @override
  State<TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<TaskSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3A3A52)
                      : Colors.grey.shade200,
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: provider.setSearchQuery,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            provider.setSearchQuery('');
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // \u2500\u2500 Sort button \u2500\u2500
          _SortButton(isDark: isDark),
        ],
      ),
    );
  }
}

// \u2500\u2500\u2500 Sort Button \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

class _SortButton extends StatelessWidget {
  final bool isDark;

  const _SortButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return GestureDetector(
      onTap: () => _showSortMenu(context, provider),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          Icons.sort_rounded,
          color: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight,
          size: 22,
        ),
      ),
    );
  }

  void _showSortMenu(BuildContext context, TaskProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              'Sort Tasks',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            ...SortOption.values.map((option) {
              final isSelected = provider.sortOption == option;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.12)
                        : (isDark
                              ? AppTheme.cardDark
                              : AppTheme.backgroundLight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getSortIcon(option),
                    size: 18,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight),
                  ),
                ),
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : (isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight),
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        provider.sortAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 16,
                        color: AppTheme.primaryColor,
                      )
                    : null,
                onTap: () {
                  provider.setSortOption(option);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.createdAt:
        return Icons.access_time_rounded;
      case SortOption.dueDate:
        return Icons.event_rounded;
      case SortOption.priority:
        return Icons.flag_rounded;
      case SortOption.title:
        return Icons.sort_by_alpha_rounded;
      case SortOption.category:
        return Icons.category_rounded;
    }
  }
}
