import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Task> _getTasksForDay(List<Task> allTasks, DateTime day) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return isSameDay(task.dueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTasks = provider.allTasks;
    final selectedTasks = _selectedDay != null
        ? _getTasksForDay(allTasks, _selectedDay!)
        : _getTasksForDay(allTasks, _focusedDay);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            _buildCalendar(allTasks, isDark),
            const SizedBox(height: 8),
            _buildSelectedDayTitle(isDark),
            Expanded(
              child: selectedTasks.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildTasksList(selectedTasks, isDark),
            ),
          ],
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
                'Calendar',
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
                'Tasks by due date',
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

  Widget _buildCalendar(List<Task> allTasks, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3A3A52)
              : Colors.grey.shade200,
        ),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: (day) => _getTasksForDay(allTasks, day),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: TextStyle(
            color: isDark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
          ),
          weekendTextStyle: TextStyle(
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
          outsideTextStyle: TextStyle(
            color: isDark
                ? AppTheme.textSecondaryDark.withOpacity(0.4)
                : AppTheme.textSecondaryLight.withOpacity(0.4),
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: isDark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
          weekendStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayTitle(bool isDark) {
    final day = _selectedDay ?? _focusedDay;
    final now = DateTime.now();
    String title;
    if (isSameDay(day, now)) {
      title = 'Today';
    } else if (isSameDay(day, now.add(const Duration(days: 1)))) {
      title = 'Tomorrow';
    } else if (isSameDay(day, now.subtract(const Duration(days: 1)))) {
      title = 'Yesterday';
    } else {
      title =
          '${day.day}/${day.month}/${day.year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 56,
            color: isDark
                ? AppTheme.textSecondaryDark.withOpacity(0.4)
                : AppTheme.textSecondaryLight.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks this day',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, isDark);
      },
    );
  }

  Widget _buildTaskCard(Task task, bool isDark) {
    final color = AppConstants.getPriorityColor(task.priority);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? Colors.grey.withOpacity(0.2)
              : color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? Colors.grey.withOpacity(0.4)
                  : color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      task.category.emoji,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.category.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                    if (task.dueTime != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (task.isCompleted)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 20,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.priority.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}