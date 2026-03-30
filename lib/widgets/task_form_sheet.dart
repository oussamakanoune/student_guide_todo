import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/date_utils.dart';

class TaskFormSheet extends StatefulWidget {
  final Task? task; // null = create mode, non-null = edit mode

  const TaskFormSheet({super.key, this.task});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subTaskController;

  late TaskPriority _priority;
  late TaskCategory _category;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  late List<SubTask> _subTasks;
  late bool _isStarred;
  RecurringType _recurringType = RecurringType.none;
  int _remindBeforeMinutes = 30;

  bool get _isEditing => widget.task != null;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _subTaskController = TextEditingController();
    _priority = task?.priority ?? TaskPriority.medium;
    _category = task?.category ?? TaskCategory.study;
    _dueDate = task?.dueDate;
    _dueTime = task?.dueTime;
    _subTasks = task?.subTasks.map((s) => s.copyWith()).toList() ?? [];
    _isStarred = task?.isStarred ?? false;
    _recurringType = task?.recurringType ?? RecurringType.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  // \u2500\u2500\u2500 Save Task \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();

    try {
      if (_isEditing) {
        final updated = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _priority,
          category: _category,
          dueDate: _dueDate,
          dueTime: _dueTime,
          subTasks: _subTasks,
          isStarred: _isStarred,
          recurringType: _recurringType,
          clearDueDate: _dueDate == null,
          clearDueTime: _dueTime == null,
          clearDescription: _descriptionController.text.trim().isEmpty,
          remindBeforeMinutes: _remindBeforeMinutes,
        );

        await provider.updateTask(updated);
      } else {
        final newTask = Task(
          id: _uuid.v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _priority,
          category: _category,
          dueDate: _dueDate,
          dueTime: _dueTime,
          subTasks: _subTasks,
          isStarred: _isStarred,
          recurringType: _recurringType,
          remindBeforeMinutes: _remindBeforeMinutes,
        );
        await provider.addTask(newTask);
      }

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // \u2500\u2500\u2500 Date/Time Pickers \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(
          () => _dueTime = TimeOfDay(hour: picked.hour, minute: picked.minute));
    }
  }

  // \u2500\u2500\u2500 Sub-task helpers \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

  void _addSubTask() {
    final text = _subTaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subTasks.add(SubTask(id: _uuid.v4(), title: text));
      _subTaskController.clear();
    });
  }

  void _removeSubTask(String id) {
    setState(() => _subTasks.removeWhere((s) => s.id == id));
  }

  void _toggleSubTask(String id) {
    setState(() {
      final index = _subTasks.indexWhere((s) => s.id == id);
      if (index != -1) {
        _subTasks[index] = _subTasks[index]
            .copyWith(isCompleted: !_subTasks[index].isCompleted);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.97,
        expand: false,
        builder: (_, scrollController) => Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              // \u2500\u2500 Handle \u2500\u2500
              _buildHandle(isDark),
              const SizedBox(height: 4),

              // \u2500\u2500 Header \u2500\u2500
              _buildHeader(isDark),
              const SizedBox(height: 24),

              // \u2500\u2500 Title field \u2500\u2500
              _buildSectionLabel('Task Title', Icons.title_rounded, isDark),
              const SizedBox(height: 8),
              _buildTitleField(isDark),
              const SizedBox(height: 20),

              // \u2500\u2500 Description \u2500\u2500
              _buildSectionLabel(
                  'Description (optional)', Icons.notes_rounded, isDark),
              const SizedBox(height: 8),
              _buildDescriptionField(isDark),
              const SizedBox(height: 20),

              // \u2500\u2500 Category \u2500\u2500
              _buildSectionLabel('Category', Icons.category_rounded, isDark),
              const SizedBox(height: 10),
              _buildCategorySelector(isDark),
              const SizedBox(height: 20),

              // \u2500\u2500 Priority \u2500\u2500
              _buildSectionLabel('Priority', Icons.flag_rounded, isDark),
              const SizedBox(height: 10),
              _buildPrioritySelector(isDark),
              const SizedBox(height: 20),

              // \u2500\u2500 Due Date & Time \u2500\u2500
              _buildSectionLabel(
                  'Due Date & Time', Icons.event_rounded, isDark),
              const SizedBox(height: 10),
              _buildDueDateSelector(isDark),
              const SizedBox(height: 20),

              // \u2500\u2500 Sub-tasks \u2500\u2500
              _buildSectionLabel('Sub-tasks', Icons.checklist_rounded, isDark),
              const SizedBox(height: 10),
              _buildSubTasksSection(isDark),
              const SizedBox(height: 20),
// ── Recurring ──
              _buildSectionLabel('Repeat', Icons.repeat_rounded, isDark),
              const SizedBox(height: 10),
              _buildRecurringSelector(isDark),
              const SizedBox(height: 20),
              const SizedBox(height: 20),

_buildSectionLabel('Reminder', Icons.notifications_rounded, isDark),
const SizedBox(height: 10),

DropdownButtonFormField<int>(
  value: _remindBeforeMinutes,
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
  ),
  items: [5, 10, 15, 30, 60].map((minutes) {
    return DropdownMenuItem(
      value: minutes,
      child: Text('$minutes minutes before'),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _remindBeforeMinutes = value!;
    });
  },
),
const SizedBox(height: 20),
              // \u2500\u2500 Star toggle \u2500\u2500
              _buildStarToggle(isDark),
              const SizedBox(height: 28),

              // \u2500\u2500 Save button \u2500\u2500
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // \u2500\u2500\u2500 Build Helpers \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

  Widget _buildHandle(bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? Colors.white24 : Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isEditing ? Icons.edit_rounded : Icons.add_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Task' : 'New Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
              Text(
                _isEditing
                    ? 'Update your task details'
                    : 'Fill in the details below',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        // \u2500\u2500 Star button in header \u2500\u2500
        GestureDetector(
          onTap: () => setState(() => _isStarred = !_isStarred),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isStarred
                  ? const Color(0xFFF59E0B).withOpacity(0.12)
                  : (isDark ? AppTheme.cardDark : AppTheme.backgroundLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isStarred
                  ? const Color(0xFFF59E0B)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField(bool isDark) {
    return TextFormField(
      controller: _titleController,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: 'e.g. Study for Math exam...',
        counterText: '',
        filled: true,
        fillColor: isDark ? AppTheme.cardDark : AppTheme.backgroundLight,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task title';
        }
        if (value.trim().length < 2) {
          return 'Title must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: 'Add more details about this task...',
        counterText: '',
        filled: true,
        fillColor: isDark ? AppTheme.cardDark : AppTheme.backgroundLight,
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskCategory.values.map((cat) {
        final isSelected = _category == cat;
        final color = AppConstants.getCategoryColor(cat);
        final icon = AppConstants.getCategoryIcon(cat);

        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : (isDark ? AppTheme.cardDark : AppTheme.backgroundLight),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? color.withOpacity(0.6)
                    : (isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 15,
                    color: isSelected
                        ? color
                        : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight)),
                const SizedBox(width: 6),
                Text(
                  '${cat.emoji} ${cat.label}',
                  style: TextStyle(
                    fontSize: 13,
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
      }).toList(),
    );
  }

  Widget _buildPrioritySelector(bool isDark) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = _priority == priority;
        final color = AppConstants.getPriorityColor(priority);
        final icon = AppConstants.getPriorityIcon(priority);

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                right: priority != TaskPriority.low ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : (isDark ? AppTheme.cardDark : AppTheme.backgroundLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? color.withOpacity(0.6)
                      : (isDark
                          ? const Color(0xFF3A3A52)
                          : Colors.grey.shade200),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      size: 20,
                      color: isSelected
                          ? color
                          : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight)),
                  const SizedBox(height: 4),
                  Text(
                    priority.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDueDateSelector(bool isDark) {
    return Row(
      children: [
        // \u2500\u2500 Date picker button \u2500\u2500
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: _dueDate != null
                    ? AppTheme.primaryColor.withOpacity(0.08)
                    : (isDark ? AppTheme.cardDark : AppTheme.backgroundLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _dueDate != null
                      ? AppTheme.primaryColor.withOpacity(0.4)
                      : (isDark
                          ? const Color(0xFF3A3A52)
                          : Colors.grey.shade200),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: _dueDate != null
                        ? AppTheme.primaryColor
                        : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dueDate != null
                          ? TaskDateUtils.formatDueDate(context, _dueDate!)
                          : 'Set date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _dueDate != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _dueDate != null
                            ? AppTheme.primaryColor
                            : (isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight),
                      ),
                    ),
                  ),
                  if (_dueDate != null)
                    GestureDetector(
                      onTap: () => setState(() {
                        _dueDate = null;
                        _dueTime = null;
                      }),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // \u2500\u2500 Time picker button \u2500\u2500
        Expanded(
          child: GestureDetector(
            onTap: _dueDate != null ? _pickTime : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: _dueTime != null
                    ? AppTheme.primaryColor.withOpacity(0.08)
                    : (isDark ? AppTheme.cardDark : AppTheme.backgroundLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _dueTime != null
                      ? AppTheme.primaryColor.withOpacity(0.4)
                      : (isDark
                          ? const Color(0xFF3A3A52)
                          : Colors.grey.shade200),
                  width: 1.5,
                ),
              ),
              child: Opacity(
                opacity: _dueDate != null ? 1.0 : 0.4,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: _dueTime != null
                          ? AppTheme.primaryColor
                          : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dueTime != null
                            ? _dueTime!.format(context)
                            : 'Set time',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _dueTime != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _dueTime != null
                              ? AppTheme.primaryColor
                              : (isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight),
                        ),
                      ),
                    ),
                    if (_dueTime != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueTime = null),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTasksSection(bool isDark) {
    return Column(
      children: [
        // \u2500\u2500 Subtask input \u2500\u2500
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subTaskController,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _addSubTask(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a sub-task...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor:
                      isDark ? AppTheme.cardDark : AppTheme.backgroundLight,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF3A3A52)
                          : Colors.grey.shade200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryColor, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addSubTask,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),

        // \u2500\u2500 Subtask list \u2500\u2500
        if (_subTasks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200,
              ),
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subTasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _subTasks.removeAt(oldIndex);
                  _subTasks.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final sub = _subTasks[index];
                return _SubTaskItem(
                  key: ValueKey(sub.id),
                  subTask: sub,
                  isDark: isDark,
                  onToggle: () => _toggleSubTask(sub.id),
                  onDelete: () => _removeSubTask(sub.id),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecurringSelector(bool isDark) {
    final options = [
      (RecurringType.none, 'No Repeat', Icons.block_rounded),
      (RecurringType.daily, 'Daily', Icons.today_rounded),
      (RecurringType.weekly, 'Weekly', Icons.view_week_rounded),
      (RecurringType.monthly, 'Monthly', Icons.calendar_month_rounded),
    ];

    return Row(
      children: options.map((option) {
        final type = option.$1;
        final label = option.$2;
        final icon = option.$3;
        final isSelected = _recurringType == type;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _recurringType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                right: type != RecurringType.monthly ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.12)
                    : (isDark ? AppTheme.cardDark : AppTheme.backgroundLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.5)
                      : (isDark
                          ? const Color(0xFF3A3A52)
                          : Colors.grey.shade200),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStarToggle(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _isStarred = !_isStarred),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _isStarred
              ? const Color(0xFFF59E0B).withOpacity(0.08)
              : (isDark ? AppTheme.cardDark : AppTheme.backgroundLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isStarred
                ? const Color(0xFFF59E0B).withOpacity(0.4)
                : (isDark ? const Color(0xFF3A3A52) : Colors.grey.shade200),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isStarred
                  ? const Color(0xFFF59E0B)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Mark as Important',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _isStarred
                    ? const Color(0xFFF59E0B)
                    : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: _isStarred
                    ? const Color(0xFFF59E0B)
                    : (isDark ? const Color(0xFF3A3A52) : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    _isStarred ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isEditing ? Icons.save_rounded : Icons.add_task_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// \u2500\u2500\u2500 Sub-task Item Widget \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

class _SubTaskItem extends StatelessWidget {
  final SubTask subTask;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubTaskItem({
    super.key,
    required this.subTask,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: subTask.isCompleted
                ? AppTheme.primaryColor
                : Colors.transparent,
            border: Border.all(
              color: subTask.isCompleted
                  ? AppTheme.primaryColor
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : Colors.grey.shade400),
              width: 1.5,
            ),
          ),
          child: subTask.isCompleted
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
              : null,
        ),
      ),
      title: Text(
        subTask.title,
        style: TextStyle(
          fontSize: 13,
          color: subTask.isCompleted
              ? (isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight)
              : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight),
          decoration: subTask.isCompleted ? TextDecoration.lineThrough : null,
          decorationColor:
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.drag_handle_rounded,
            size: 18,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}


// \u2500\u2500\u2500 Material TimeOfDay wrapper \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500


// typedef TimeOfDayMaterial = MaterialTimeOfDay;


// class MaterialTimeOfDay {
//   final int hour;
//   final int minute;


//   const MaterialTimeOfDay({required this.hour, required this.minute});


//   static MaterialTimeOfDay now() {
//     final now = DateTime.now();
//     return MaterialTimeOfDay(hour: now.hour, minute: now.minute);
//   }
// }