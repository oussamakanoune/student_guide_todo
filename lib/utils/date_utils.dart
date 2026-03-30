import 'package:intl/intl.dart';
import '../models/task_model.dart';
import 'package:flutter/material.dart';

class TaskDateUtils {
  // \u2500\u2500\u2500 Formatters \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static final DateFormat _dayMonthYear = DateFormat('MMM d, yyyy');
  static final DateFormat _dayMonth = DateFormat('MMM d');
  static final DateFormat _fullDate = DateFormat('EEEE, MMM d');
  static final DateFormat _shortDay = DateFormat('EEE');


  // \u2500\u2500\u2500 Format Due Date Label \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static String formatDueDate( BuildContext context, DateTime date, {TimeOfDay? time}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;


String dateLabel;
if (diff == 0) {
  dateLabel = 'Today';
} else if (diff == 1) {
  dateLabel = 'Tomorrow';
} else if (diff == -1) {
  dateLabel = 'Yesterday';
} else if (diff > 1 && diff <= 7) {
  dateLabel = _shortDay.format(date);
} else if (date.year == now.year) {
  dateLabel = _dayMonth.format(date);
} else {
  dateLabel = _dayMonthYear.format(date);
}

if (time != null) {
  return '$dateLabel \u00b7 ${time.format(context)}';
}
return dateLabel;

  }


  // \u2500\u2500\u2500 Format Full Date \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static String formatFullDate(DateTime date) {
    return _fullDate.format(date);
  }


  // \u2500\u2500\u2500 Format Created At \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static String formatCreatedAt(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);


if (diff.inSeconds < 60) return 'Just now';
if (diff.inMinutes < 60) {
  return '${diff.inMinutes}m ago';
}
if (diff.inHours < 24) {
  return '${diff.inHours}h ago';
}
if (diff.inDays == 1) return 'Yesterday';
if (diff.inDays < 7) return '${diff.inDays}d ago';
return _dayMonthYear.format(date);

  }


  // \u2500\u2500\u2500 Due Date Status \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static DueDateStatus getDueDateStatus(DateTime? dueDate, bool isCompleted) {
    if (dueDate == null) return DueDateStatus.none;
    if (isCompleted) return DueDateStatus.completed;


final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);
final target =
    DateTime(dueDate.year, dueDate.month, dueDate.day);
final diff = target.difference(today).inDays;

if (diff < 0) return DueDateStatus.overdue;
if (diff == 0) return DueDateStatus.dueToday;
if (diff == 1) return DueDateStatus.dueTomorrow;
if (diff <= 3) return DueDateStatus.dueSoon;
return DueDateStatus.upcoming;

  }


  // \u2500\u2500\u2500 Group Tasks by Date \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static String getDateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;


if (diff == 0) return 'Today';
if (diff == 1) return 'Tomorrow';
if (diff == -1) return 'Yesterday';
if (diff > 1 && diff <= 7) return 'This Week';
if (diff > 7 && diff <= 14) return 'Next Week';
if (diff < -1 && diff >= -7) return 'Last Week';
return _dayMonthYear.format(date);

  }


  // \u2500\u2500\u2500 Days Until Due \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static int? daysUntilDue(DateTime? dueDate) {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }


  // \u2500\u2500\u2500 Weekly Progress \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(
        7, (i) => DateTime(monday.year, monday.month, monday.day + i));
  }
}


// \u2500\u2500\u2500 Due Date Status Enum \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


enum DueDateStatus {
  none,
  overdue,
  dueToday,
  dueTomorrow,
  dueSoon,
  upcoming,
  completed,
}


extension DueDateStatusExtension on DueDateStatus {
  String get label {
    switch (this) {
      case DueDateStatus.none:
        return '';
      case DueDateStatus.overdue:
        return 'Overdue';
      case DueDateStatus.dueToday:
        return 'Due Today';
      case DueDateStatus.dueTomorrow:
        return 'Due Tomorrow';
      case DueDateStatus.dueSoon:
        return 'Due Soon';
      case DueDateStatus.upcoming:
        return 'Upcoming';
      case DueDateStatus.completed:
        return 'Completed';
    }
  }
}