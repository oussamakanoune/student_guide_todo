import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';


class AppConstants {
  // \u2500\u2500\u2500 App Info \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const String appName = 'Student Guide';
  static const String todoFeatureName = 'My Tasks';
  static const String appVersion = '1.0.0';


  // \u2500\u2500\u2500 Animation Durations \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);


  // \u2500\u2500\u2500 Spacing \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;


  // \u2500\u2500\u2500 Border Radius \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 100.0;


  // \u2500\u2500\u2500 Icon Sizes \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;


  // \u2500\u2500\u2500 Category Color Map \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static Color getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.study:
        return AppTheme.catStudy;
      case TaskCategory.assignment:
        return AppTheme.catAssignment;
      case TaskCategory.exam:
        return AppTheme.catExam;
      case TaskCategory.project:
        return AppTheme.catProject;
      case TaskCategory.personal:
        return AppTheme.catPersonal;
      case TaskCategory.reading:
        return AppTheme.catReading;
      case TaskCategory.other:
        return AppTheme.catOther;
    }
  }


  // \u2500\u2500\u2500 Priority Color Map \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppTheme.priorityHigh;
      case TaskPriority.medium:
        return AppTheme.priorityMedium;
      case TaskPriority.low:
        return AppTheme.priorityLow;
    }
  }


  // \u2500\u2500\u2500 Priority Icon Map \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static IconData getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.low:
        return Icons.keyboard_double_arrow_down_rounded;
    }
  }


  // \u2500\u2500\u2500 Category Icon Map \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static IconData getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.study:
        return Icons.menu_book_rounded;
      case TaskCategory.assignment:
        return Icons.assignment_rounded;
      case TaskCategory.exam:
        return Icons.fact_check_rounded;
      case TaskCategory.project:
        return Icons.rocket_launch_rounded;
      case TaskCategory.personal:
        return Icons.star_rounded;
      case TaskCategory.reading:
        return Icons.auto_stories_rounded;
      case TaskCategory.other:
        return Icons.push_pin_rounded;
    }
  }


  // \u2500\u2500\u2500 Empty State Messages \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
 static const Map<String, String> emptyStateMessages = {
  'all': 'No tasks yet!\nTap + to create your first task.',
  'active': 'No active tasks.\nYou\'re all caught up! 🎉',
  'completed': 'No completed tasks yet.\nKeep going, you\'ve got this!',
  'starred': 'No starred tasks.\nStar important tasks to find them here.',
  'overdue': 'No overdue tasks! 🎉\nYou\'re on top of everything.',
  'today': 'Nothing due today.\nEnjoy your day! ✨',
  'search': 'No tasks match your search.\nTry a different keyword.',
};
}