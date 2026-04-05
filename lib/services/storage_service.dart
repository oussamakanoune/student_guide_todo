import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../models/task_model.dart';

class StorageService {
  static const String _tasksKey = 'student_guide_tasks';
  static const String _onboardingKey = 'student_guide_onboarding_done';
  static const String _themeKey = 'student_guide_theme_dark';
  static const String _pendingSyncKey = 'student_guide_pending_sync';

  // ─── Base URL ─────────────────────────────────────────────
  static const String _baseUrl = 'http://api.talabadz.com/todolist';

  // ─── Token ────────────────────────────────────────────────
  // ⚠️ أي token يشتغل الحين لأن الـ backend يقبل أي شيء
  static const String _token = 'Bearer test-token';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': _token,
    },
  ));

  // ─── Internet Check ───────────────────────────────────────
  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ─── Set Auth Token ───────────────────────────────────────
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ══════════════════════════════════════════════════════════
  // TASKS
  // ══════════════════════════════════════════════════════════

  Future<List<Task>> loadTasks() async {
    try {
      final online = await _isOnline();

      if (online) {
        try {
          final response = await _dio.get('/tasks');
          if (response.statusCode == 200) {
            final List<dynamic> tasksList = response.data['data']['tasks'];
            final tasks = tasksList
                .map((t) => Task.fromMap(Map<String, dynamic>.from(t)))
                .toList();
            await _saveLocalTasks(tasks);
            await _syncPending();
            return tasks;
          }
        } catch (e) {
          return await _loadLocalTasks();
        }
      }

      return await _loadLocalTasks();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveTasks(List<Task> tasks) async {
    return await _saveLocalTasks(tasks);
  }

  Future<bool> addTask(Task task) async {
    try {
      final online = await _isOnline();

      final tasks = await _loadLocalTasks();
      tasks.insert(0, task);
      await _saveLocalTasks(tasks);

      if (online) {
        try {
          await _dio.post('/tasks', data: task.toMap());
        } catch (e) {
          await _addToPending('add', task.toMap());
        }
      } else {
        await _addToPending('add', task.toMap());
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTask(Task updatedTask) async {
    try {
      final online = await _isOnline();

      final tasks = await _loadLocalTasks();
      final index = tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
        await _saveLocalTasks(tasks);
      }

      if (online) {
        try {
          await _dio.put('/tasks/${updatedTask.id}', data: updatedTask.toMap());
        } catch (e) {
          await _addToPending('update', updatedTask.toMap());
        }
      } else {
        await _addToPending('update', updatedTask.toMap());
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      final online = await _isOnline();

      final tasks = await _loadLocalTasks();
      tasks.removeWhere((t) => t.id == taskId);
      await _saveLocalTasks(tasks);

      if (online) {
        try {
          await _dio.delete('/tasks/$taskId');
        } catch (e) {
          await _addToPending('delete', {'id': taskId});
        }
      } else {
        await _addToPending('delete', {'id': taskId});
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted, String? completedAt) async {
    try {
      final online = await _isOnline();

      if (online) {
        try {
          await _dio.patch('/tasks/$taskId/complete', data: {
            'isCompleted': isCompleted,
            'completedAt': completedAt,
          });
        } catch (e) {
          await _addToPending('toggleComplete', {
            'id': taskId,
            'isCompleted': isCompleted,
            'completedAt': completedAt,
          });
        }
      } else {
        await _addToPending('toggleComplete', {
          'id': taskId,
          'isCompleted': isCompleted,
          'completedAt': completedAt,
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleStar(String taskId, bool isStarred) async {
    try {
      final online = await _isOnline();

      if (online) {
        try {
          await _dio.patch('/tasks/$taskId/star', data: {'isStarred': isStarred});
        } catch (e) {
          await _addToPending('toggleStar', {'id': taskId, 'isStarred': isStarred});
        }
      } else {
        await _addToPending('toggleStar', {'id': taskId, 'isStarred': isStarred});
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleSubTask(String taskId, String subTaskId, bool isCompleted) async {
    try {
      final online = await _isOnline();

      if (online) {
        try {
          await _dio.patch('/tasks/$taskId/subtasks/$subTaskId', data: {'isCompleted': isCompleted});
        } catch (e) {
          await _addToPending('toggleSubTask', {
            'taskId': taskId,
            'subTaskId': subTaskId,
            'isCompleted': isCompleted,
          });
        }
      } else {
        await _addToPending('toggleSubTask', {
          'taskId': taskId,
          'subTaskId': subTaskId,
          'isCompleted': isCompleted,
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAllTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tasksKey);
    } catch (e) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // GOALS
  // ══════════════════════════════════════════════════════════

  static const String _goalsKey = 'student_guide_goals';

  Future<Map<String, int>> loadGoals() async {
    try {
      final online = await _isOnline();

      if (online) {
        try {
          final response = await _dio.get('/goals');
          if (response.statusCode == 200) {
            final Map<String, dynamic> map = response.data['data']['goals'];
            final goals = map.map((k, v) => MapEntry(k, v as int));
            await _saveLocalGoals(goals);
            return goals;
          }
        } catch (e) {
          return await _loadLocalGoals();
        }
      }

      return await _loadLocalGoals();
    } catch (e) {
      return {};
    }
  }

  Future<bool> saveGoals(Map<String, int> goals) async {
    try {
      final online = await _isOnline();
      await _saveLocalGoals(goals);

      if (online) {
        try {
          for (final entry in goals.entries) {
            await _dio.post('/goals', data: {
              'category': int.parse(entry.key),
              'targetCount': entry.value,
            });
          }
        } catch (e) {
          await _addToPending('saveGoals', goals);
        }
      } else {
        await _addToPending('saveGoals', goals);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGoal(int category) async {
    try {
      final online = await _isOnline();

      if (online) {
        try {
          await _dio.delete('/goals/$category');
        } catch (e) {
          await _addToPending('deleteGoal', {'category': category});
        }
      } else {
        await _addToPending('deleteGoal', {'category': category});
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // GAMIFICATION
  // ══════════════════════════════════════════════════════════

  static const String _streakKey = 'student_guide_streak';
  static const String _progressKey = 'student_guide_progress';
  static const String _lastCompletedKey = 'student_guide_last_completed';

  Future<Map<String, dynamic>> loadGamification() async {
    try {
      final online = await _isOnline();

      if (online) {
        try {
          final response = await _dio.get('/gamification');
          if (response.statusCode == 200) {
            final data = response.data['data'];
            await _saveLocalGamification(
              data['streak'],
              data['progress'],
              data['lastCompleted'],
            );
            return data;
          }
        } catch (e) {
          return await _loadLocalGamification();
        }
      }

      return await _loadLocalGamification();
    } catch (e) {
      return {'streak': 0, 'progress': 0, 'lastCompleted': ''};
    }
  }

  Future<void> saveGamification(int streak, int progress, String lastCompleted) async {
    try {
      await _saveLocalGamification(streak, progress, lastCompleted);

      final online = await _isOnline();
      if (online) {
        try {
          await _dio.put('/gamification', data: {
            'streak': streak,
            'progress': progress,
            'lastCompleted': lastCompleted,
          });
        } catch (e) {
          await _addToPending('gamification', {
            'streak': streak,
            'progress': progress,
            'lastCompleted': lastCompleted,
          });
        }
      } else {
        await _addToPending('gamification', {
          'streak': streak,
          'progress': progress,
          'lastCompleted': lastCompleted,
        });
      }
    } catch (e) {
      return;
    }
  }

  // ══════════════════════════════════════════════════════════
  // PENDING SYNC
  // ══════════════════════════════════════════════════════════

  Future<void> _addToPending(String action, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? pendingJson = prefs.getString(_pendingSyncKey);
      final List<dynamic> pending =
          pendingJson != null ? json.decode(pendingJson) : [];
      pending.add({'action': action, 'data': data});
      await prefs.setString(_pendingSyncKey, json.encode(pending));
    } catch (e) {
      return;
    }
  }

  Future<void> _syncPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? pendingJson = prefs.getString(_pendingSyncKey);
      if (pendingJson == null || pendingJson.isEmpty) return;

      final List<dynamic> pending = json.decode(pendingJson);
      if (pending.isEmpty) return;

      final List<dynamic> failedItems = [];

      for (final item in pending) {
        final action = item['action'];
        final data = item['data'];

        try {
          switch (action) {
            case 'add':
              await _dio.post('/tasks', data: data);
              break;
            case 'update':
              await _dio.put('/tasks/${data['id']}', data: data);
              break;
            case 'delete':
              await _dio.delete('/tasks/${data['id']}');
              break;
            case 'toggleComplete':
              await _dio.patch('/tasks/${data['id']}/complete', data: {
                'isCompleted': data['isCompleted'],
                'completedAt': data['completedAt'],
              });
              break;
            case 'toggleStar':
              await _dio.patch('/tasks/${data['id']}/star', data: {
                'isStarred': data['isStarred'],
              });
              break;
            case 'toggleSubTask':
              await _dio.patch(
                  '/tasks/${data['taskId']}/subtasks/${data['subTaskId']}',
                  data: {'isCompleted': data['isCompleted']});
              break;
            case 'saveGoals':
              for (final entry in (data as Map).entries) {
                await _dio.post('/goals', data: {
                  'category': int.parse(entry.key),
                  'targetCount': entry.value,
                });
              }
              break;
            case 'deleteGoal':
              await _dio.delete('/goals/${data['category']}');
              break;
            case 'gamification':
              await _dio.put('/gamification', data: data);
              break;
          }
        } catch (e) {
          failedItems.add(item);
        }
      }

      await prefs.setString(_pendingSyncKey, json.encode(failedItems));
    } catch (e) {
      return;
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOCAL HELPERS
  // ══════════════════════════════════════════════════════════

  Future<List<Task>> _loadLocalTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString(_tasksKey);
      if (tasksJson == null || tasksJson.isEmpty) return [];
      final List<dynamic> tasksList = json.decode(tasksJson);
      return tasksList
          .map((t) => Task.fromMap(Map<String, dynamic>.from(t)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> _saveLocalTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
          _tasksKey, json.encode(tasks.map((t) => t.toMap()).toList()));
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, int>> _loadLocalGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? goalsJson = prefs.getString(_goalsKey);
      if (goalsJson == null || goalsJson.isEmpty) return {};
      final Map<String, dynamic> map = json.decode(goalsJson);
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (e) {
      return {};
    }
  }

  Future<bool> _saveLocalGoals(Map<String, int> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_goalsKey, json.encode(goals));
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _loadLocalGamification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'streak': prefs.getInt(_streakKey) ?? 0,
        'progress': prefs.getInt(_progressKey) ?? 0,
        'lastCompleted': prefs.getString(_lastCompletedKey) ?? '',
      };
    } catch (e) {
      return {'streak': 0, 'progress': 0, 'lastCompleted': ''};
    }
  }

  Future<void> _saveLocalGamification(
      int streak, int progress, String lastCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_streakKey, streak);
      await prefs.setInt(_progressKey, progress);
      await prefs.setString(_lastCompletedKey, lastCompleted);
    } catch (e) {
      return;
    }
  }

  // ══════════════════════════════════════════════════════════
  // APP PREFERENCES
  // ══════════════════════════════════════════════════════════

  Future<bool> isDarkTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_themeKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setDarkTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isOnboardingDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setOnboardingDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      return false;
    }
  }
}