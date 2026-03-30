import 'dart:convert';
import '../models/task_model.dart';

class WeeklyGoal {
  final TaskCategory category;
  final int targetCount;

  WeeklyGoal({
    required this.category,
    required this.targetCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category.index,
      'targetCount': targetCount,
    };
  }

  factory WeeklyGoal.fromMap(Map<String, dynamic> map) {
    return WeeklyGoal(
      category: TaskCategory.values[map['category'] ?? 0],
      targetCount: map['targetCount'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());
  factory WeeklyGoal.fromJson(String source) =>
      WeeklyGoal.fromMap(json.decode(source));
}