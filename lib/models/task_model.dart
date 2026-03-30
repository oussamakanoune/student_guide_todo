import 'dart:convert';
import 'package:flutter/material.dart';

// \u2500\u2500\u2500 Enums \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


enum TaskPriority { high, medium, low }


enum TaskCategory {
  study,
  assignment,
  exam,
  project,
  personal,
  reading,
  other,
}

enum RecurringType { none, daily, weekly, monthly }

// \u2500\u2500\u2500 Extensions \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }


  String get emoji {
    switch (this) {
      case TaskPriority.high:
        return '\ud83d\udd34';
      case TaskPriority.medium:
        return '\ud83d\udfe1';
      case TaskPriority.low:
        return '\ud83d\udfe2';
    }
  }


  int get value {
    switch (this) {
      case TaskPriority.high:
        return 2;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.low:
        return 0;
    }
  }
}


extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.assignment:
        return 'Assignment';
      case TaskCategory.exam:
        return 'Exam';
      case TaskCategory.project:
        return 'Project';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.reading:
        return 'Reading';
      case TaskCategory.other:
        return 'Other';
    }
  }


  String get emoji {
    switch (this) {
      case TaskCategory.study:
        return '\ud83d\udcda';
      case TaskCategory.assignment:
        return '\ud83d\udcdd';
      case TaskCategory.exam:
        return '\ud83d\udccb';
      case TaskCategory.project:
        return '\ud83d\ude80';
      case TaskCategory.personal:
        return '\ud83c\udf1f';
      case TaskCategory.reading:
        return '\ud83d\udcd6';
      case TaskCategory.other:
        return '\ud83d\udccc';
    }
  }
}


// \u2500\u2500\u2500 SubTask Model \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


class SubTask {
  final String id;
  String title;
  bool isCompleted;


  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });


  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }


  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }


  String toJson() => json.encode(toMap());


  factory SubTask.fromJson(String source) =>
      SubTask.fromMap(json.decode(source));
}


// \u2500\u2500\u2500 Task Model \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


class Task {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  TaskPriority priority;
  TaskCategory category;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  int remindBeforeMinutes;
  List<SubTask> subTasks;
  DateTime createdAt;
  DateTime? completedAt;
  bool isStarred;
  RecurringType recurringType;


  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.study,
    this.dueDate,
    this.dueTime,
    this.remindBeforeMinutes =30,
    List<SubTask>? subTasks,
    DateTime? createdAt,
    this.completedAt,
    this.isStarred = false,
    this.recurringType = RecurringType.none,
  })  : subTasks = subTasks ?? [],
        createdAt = createdAt ?? DateTime.now();


  // \u2500\u2500\u2500 Computed Properties \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    if (dueTime != null) {
      final dueDateTime = DateTime(
        due.year,
        due.month,
        due.day,
        dueTime!.hour,
        dueTime!.minute,
      );
      return now.isAfter(dueDateTime);
    }
    return now.isAfter(DateTime(due.year, due.month, due.day, 23, 59, 59));
  }


  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }


  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }


  double get subTaskProgress {
    if (subTasks.isEmpty) return 0.0;
    final completed = subTasks.where((s) => s.isCompleted).length;
    return completed / subTasks.length;
  }


  int get completedSubTasks =>
      subTasks.where((s) => s.isCompleted).length;


  // \u2500\u2500\u2500 CopyWith \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    List<SubTask>? subTasks,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isStarred,
    bool clearDueDate = false,
    bool clearDueTime = false,
    bool clearDescription = false,
    bool clearCompletedAt = false,
    RecurringType? recurringType,
    int? remindBeforeMinutes,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
          clearDescription ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
      subTasks: subTasks ?? this.subTasks,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      isStarred: isStarred ?? this.isStarred,
      recurringType: recurringType ?? this.recurringType,
      remindBeforeMinutes:
    remindBeforeMinutes ?? this.remindBeforeMinutes,
    );
  }


  // \u2500\u2500\u2500 Serialization \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'category': category.index,
      'dueDate': dueDate?.toIso8601String(),
      'dueTimeHour': dueTime?.hour,
      'dueTimeMinute': dueTime?.minute,
      'remindBeforeMinutes': remindBeforeMinutes,
      'subTasks': subTasks.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isStarred': isStarred,
      'recurringType': recurringType.index,
    };
  }


  factory Task.fromMap(Map<String, dynamic> map) {
    TimeOfDay? dueTime;
    if (map['dueTimeHour'] != null && map['dueTimeMinute'] != null) {
      dueTime = TimeOfDay(
        hour: map['dueTimeHour'],
        minute: map['dueTimeMinute'],
      );
    }


return Task(
  id: map['id'] ?? '',
  title: map['title'] ?? '',
  description: map['description'],
  isCompleted: map['isCompleted'] ?? false,
  priority: TaskPriority.values[map['priority'] ?? 1],
  category: TaskCategory.values[map['category'] ?? 0],
  dueDate:
      map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
  dueTime: dueTime,
  subTasks: map['subTasks'] != null
      ? List<SubTask>.from(
          (map['subTasks'] as List).map((x) => SubTask.fromMap(x)))
      : [],
  createdAt: map['createdAt'] != null
      ? DateTime.parse(map['createdAt'])
      : DateTime.now(),
  completedAt: map['completedAt'] != null
      ? DateTime.parse(map['completedAt'])
      : null,
  isStarred: map['isStarred'] ?? false,
  recurringType: RecurringType.values[map['recurringType'] ?? 0],
  remindBeforeMinutes: map['remindBeforeMinutes'] ?? 30,

);

  }


  String toJson() => json.encode(toMap());


  factory Task.fromJson(String source) =>
      Task.fromMap(json.decode(source));


  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority, category: $category)';
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }


  @override
  int get hashCode => id.hashCode;
}


// \u2500\u2500\u2500 TimeOfDay Serialization Helper \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


// class TimeOfDay {
//   final int hour;
//   final int minute;


//   const TimeOfDay({required this.hour, required this.minute});


//   String format() {
//     final h = hour % 12 == 0 ? 12 : hour % 12;
//     final m = minute.toString().padLeft(2, '0');
//     final period = hour < 12 ? 'AM' : 'PM';
//     return '$h:$m $period';
//   }


//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is TimeOfDay &&
//         other.hour == hour &&
//         other.minute == minute;
//   }


//   @override
//   int get hashCode => hour.hashCode ^ minute.hashCode;
// }