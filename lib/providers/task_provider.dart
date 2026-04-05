import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';
import '../services/notification_service.dart';

// ─── Sort Options ─────────────────────────────────────────────────────────────

enum SortOption {
  createdAt,
  dueDate,
  priority,
  title,
  category,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.createdAt:
        return 'Date Created';
      case SortOption.dueDate:
        return 'Due Date';
      case SortOption.priority:
        return 'Priority';
      case SortOption.title:
        return 'Title';
      case SortOption.category:
        return 'Category';
    }
  }
}

// ─── Filter Options ───────────────────────────────────────────────────────────

enum FilterOption { all, active, completed, starred, overdue, today }

extension FilterOptionExtension on FilterOption {
  String get label {
    switch (this) {
      case FilterOption.all:
        return 'All';
      case FilterOption.active:
        return 'Active';
      case FilterOption.completed:
        return 'Done';
      case FilterOption.starred:
        return 'Starred';
      case FilterOption.overdue:
        return 'Overdue';
      case FilterOption.today:
        return 'Today';
    }
  }

  String get emoji {
    switch (this) {
      case FilterOption.all:
        return '📋';
      case FilterOption.active:
        return '⏳';
      case FilterOption.completed:
        return '✅';
      case FilterOption.starred:
        return '⭐';
      case FilterOption.overdue:
        return '🔥';
      case FilterOption.today:
        return '📅';
    }
  }
}

// ─── Task Provider ────────────────────────────────────────────────────────────

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  FilterOption _activeFilter = FilterOption.all;
  SortOption _sortOption = SortOption.createdAt;
  bool _sortAscending = false;
  TaskCategory? _selectedCategory;

  Map<String, int> _weeklyGoals = {};

  int _streak = 0;
  int _progress = 0;
  int get progress => _progress;
  String _lastCompletedDate = '';

  int get streak => _streak;

  String get streakMessage {
    if (_streak == 0) return 'Start your streak today! 💪';
    if (_streak < 3) return 'Keep it up! 🔥';
    if (_streak < 7) return 'You\'re on fire! 🔥🔥';
    if (_streak < 14) return 'Unstoppable! ⚡';
    return 'Legendary streak! 🏆';
  }

  String get progressLevel {
    if (_progress < 50) return 'Beginner 🌱';
    if (_progress < 150) return 'Student 📚';
    if (_progress < 300) return 'Scholar 🎓';
    if (_progress < 500) return 'Expert ⭐';
    return 'Master 🏆';
  }

  Map<String, int> get weeklyGoals => _weeklyGoals;

  int getGoalProgress(TaskCategory category) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _tasks.where((t) {
      return t.category == category &&
          t.isCompleted &&
          t.completedAt != null &&
          t.completedAt!.isAfter(weekStart);
    }).length;
  }

  int getGoalTarget(TaskCategory category) {
    return _weeklyGoals[category.index.toString()] ?? 0;
  }

  Future<void> setGoal(TaskCategory category, int target) async {
    _weeklyGoals[category.index.toString()] = target;
    notifyListeners();
    await _storageService.saveGoals(_weeklyGoals);
  }

  Future<void> removeGoal(TaskCategory category) async {
    _weeklyGoals.remove(category.index.toString());
    notifyListeners();
    await _storageService.saveGoals(_weeklyGoals);
    // ─── بعث للـ backend ───
    await _storageService.deleteGoal(category.index);
  }

  // ─── Constructor ──────────────────────────────────────────────────────────

  TaskProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService() {
    _loadTasks();
  }

  // ─── Getters ──────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  FilterOption get activeFilter => _activeFilter;
  SortOption get sortOption => _sortOption;
  bool get sortAscending => _sortAscending;
  TaskCategory? get selectedCategory => _selectedCategory;
  List<Task> get allTasks => List.unmodifiable(_tasks);

  List<Task> get filteredTasks {
    List<Task> result = List.from(_tasks);

    // ── Apply filter ──
    switch (_activeFilter) {
      case FilterOption.all:
        break;
      case FilterOption.active:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case FilterOption.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case FilterOption.starred:
        result = result.where((t) => t.isStarred).toList();
        break;
      case FilterOption.overdue:
        result = result.where((t) => t.isOverdue).toList();
        break;
      case FilterOption.today:
        result = result.where((t) => t.isDueToday).toList();
        break;
    }

    // ── Apply category filter ──
    if (_selectedCategory != null) {
      result = result.where((t) => t.category == _selectedCategory).toList();
    }

    // ── Apply search ──
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(q) ||
            (t.description?.toLowerCase().contains(q) ?? false) ||
            t.category.label.toLowerCase().contains(q);
      }).toList();
    }

    // ── Apply sort ──
    result.sort((a, b) {
      int comparison = 0;
      switch (_sortOption) {
        case SortOption.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case SortOption.priority:
          comparison = b.priority.value.compareTo(a.priority.value);
          break;
        case SortOption.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case SortOption.category:
          comparison = a.category.index.compareTo(b.category.index);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    // ── Always push completed tasks to bottom ──
    if (_activeFilter == FilterOption.all ||
        _activeFilter == FilterOption.active) {
      final active = result.where((t) => !t.isCompleted).toList();
      final completed = result.where((t) => t.isCompleted).toList();
      result = [...active, ...completed];
    }

    return result;
  }

  // ─── Statistics ───────────────────────────────────────────────────────────

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get activeTasks => _tasks.where((t) => !t.isCompleted).length;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;
  int get todayTasks => _tasks.where((t) => t.isDueToday).length;
  int get starredTasks => _tasks.where((t) => t.isStarred).length;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks / _tasks.length;
  }

  Map<TaskCategory, int> get tasksByCategory {
    final map = <TaskCategory, int>{};
    for (final task in _tasks) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  Map<TaskPriority, int> get tasksByPriority {
    final map = <TaskPriority, int>{};
    for (final task in _tasks.where((t) => !t.isCompleted)) {
      map[task.priority] = (map[task.priority] ?? 0) + 1;
    }
    return map;
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _storageService.loadTasks();
      _weeklyGoals = await _storageService.loadGoals();
      final gamData = await _storageService.loadGamification();
      _streak = gamData['streak'] ?? 0;
      _progress = gamData['progress'] ?? 0;
      _lastCompletedDate = gamData['lastCompleted'] ?? '';
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    try {
      await _storageService.saveTasks(_tasks);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  // ─── CRUD Operations ──────────────────────────────────────────────────────

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    notifyListeners();
    // ─── بعث للـ backend ───
    await _storageService.addTask(task);
    await NotificationService().scheduleTaskNotification(task);
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
      // ─── بعث للـ backend ───
      await _storageService.updateTask(updatedTask);
      await NotificationService().cancelTaskNotification(updatedTask.id);
      await NotificationService().scheduleTaskNotification(updatedTask);
    }
  }

  Future<void> deleteTask(String taskId) async {
    await NotificationService().cancelTaskNotification(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
    // ─── بعث للـ backend ───
    await _storageService.deleteTask(taskId);
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newIsCompleted = !task.isCompleted;
      final completedAt = newIsCompleted ? DateTime.now().toIso8601String() : null;

      _tasks[index] = task.copyWith(
        isCompleted: newIsCompleted,
        completedAt: newIsCompleted ? DateTime.now() : null,
        clearCompletedAt: !newIsCompleted,
      );
      notifyListeners();

      // ─── بعث للـ backend ───
      await _storageService.toggleTaskCompletion(taskId, newIsCompleted, completedAt);
      await _saveTasks();
      await _updateGamification(newIsCompleted);
      await _handleRecurring(_tasks[index]);

      if (newIsCompleted) {
        await NotificationService().cancelTaskNotification(taskId);
      }
    }
  }

  Future<void> _updateGamification(bool taskCompleted) async {
    if (!taskCompleted) return;
    _progress += 10;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastCompletedDate != today) {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);
      if (_lastCompletedDate == yesterday) {
        _streak++;
      } else {
        _streak = 1;
      }
      _lastCompletedDate = today;
    }
    notifyListeners();
    await _storageService.saveGamification(_streak, _progress, _lastCompletedDate);
  }

  Future<void> _handleRecurring(Task task) async {
    if (!task.isCompleted) return;
    if (task.recurringType == RecurringType.none) return;
    if (task.dueDate == null) return;

    DateTime nextDate;
    switch (task.recurringType) {
      case RecurringType.daily:
        nextDate = task.dueDate!.add(const Duration(days: 1));
        break;
      case RecurringType.weekly:
        nextDate = task.dueDate!.add(const Duration(days: 7));
        break;
      case RecurringType.monthly:
        nextDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month + 1,
          task.dueDate!.day,
        );
        break;
      default:
        return;
    }

    final newTask = task.copyWith(
      id: const Uuid().v4(),
      isCompleted: false,
      completedAt: null,
      dueDate: nextDate,
      clearCompletedAt: true,
    );
    await addTask(newTask);
  }

  Future<void> toggleStarred(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newIsStarred = !task.isStarred;
      _tasks[index] = task.copyWith(isStarred: newIsStarred);
      notifyListeners();
      // ─── بعث للـ backend ───
      await _storageService.toggleStar(taskId, newIsStarred);
      await _saveTasks();
    }
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      bool newIsCompleted = false;
      final updatedSubTasks = task.subTasks.map((s) {
        if (s.id == subTaskId) {
          newIsCompleted = !s.isCompleted;
          return s.copyWith(isCompleted: newIsCompleted);
        }
        return s;
      }).toList();
      _tasks[taskIndex] = task.copyWith(subTasks: updatedSubTasks);
      notifyListeners();
      // ─── بعث للـ backend ───
      await _storageService.toggleSubTask(taskId, subTaskId, newIsCompleted);
      await _saveTasks();
    }
  }

  Future<void> deleteCompletedTasks() async {
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
    await _saveTasks();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    notifyListeners();
    await _saveTasks();
  }

  // ─── Filter & Sort ────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(FilterOption filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    if (_sortOption == option) {
      _sortAscending = !_sortAscending;
    } else {
      _sortOption = option;
      _sortAscending = false;
    }
    notifyListeners();
  }

  void setSelectedCategory(TaskCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _activeFilter = FilterOption.all;
    _selectedCategory = null;
    _sortOption = SortOption.createdAt;
    _sortAscending = false;
    notifyListeners();
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    await _loadTasks();
  }
}