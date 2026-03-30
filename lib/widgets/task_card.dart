import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/date_utils.dart';


class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;


  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });


  @override
  State<TaskCard> createState() => _TaskCardState();
}


class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;


  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _checkScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );
  }


  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }


  void _handleCheck() async {
    await _checkController.forward();
    await _checkController.reverse();
    if (mounted) {
      context.read<TaskProvider>().toggleTaskCompletion(widget.task.id);
    }
  }


  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = AppConstants.getCategoryColor(task.category);
    final priorityColor = AppConstants.getPriorityColor(task.priority);
    final dueDateStatus = TaskDateUtils.getDueDateStatus(
      task.dueDate,
      task.isCompleted,
    );


return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
  child: Slidable(
    key: ValueKey(task.id),
    startActionPane: ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.25,
      children: [
        SlidableAction(
          onPressed: (_) => widget.onEdit(),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          icon: Icons.edit_rounded,
          label: 'Edit',
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
      ],
    ),
    endActionPane: ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.25,
      dismissible: DismissiblePane(onDismissed: widget.onDelete),
      children: [
        SlidableAction(
          onPressed: (_) => widget.onDelete(),
          backgroundColor: AppTheme.priorityHigh,
          foregroundColor: Colors.white,
          icon: Icons.delete_rounded,
          label: 'Delete',
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
      ],
    ),
    child: _buildCard(
        context, task, isDark, categoryColor, priorityColor, dueDateStatus),
  ),
);

  }


  Widget _buildCard(
    BuildContext context,
    Task task,
    bool isDark,
    Color categoryColor,
    Color priorityColor,
    DueDateStatus dueDateStatus,
  ) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? Colors.transparent
                : categoryColor.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: task.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // \u2500\u2500 Priority left bar \u2500\u2500
            if (!task.isCompleted)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),


        // \u2500\u2500 Main content \u2500\u2500
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // \u2500\u2500 Checkbox \u2500\u2500
              _buildCheckbox(task, categoryColor),
              const SizedBox(width: 12),

              // \u2500\u2500 Task info \u2500\u2500
              Expanded(
                child: _buildTaskInfo(
                    context, task, isDark, categoryColor, dueDateStatus),
              ),

              // \u2500\u2500 Right actions \u2500\u2500
              _buildRightActions(context, task, isDark),
            ],
          ),
        ),
      ],
    ),
  ),
);

  }


  Widget _buildCheckbox(Task task, Color categoryColor) {
    return ScaleTransition(
      scale: _checkScale,
      child: GestureDetector(
        onTap: _handleCheck,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: task.isCompleted
                ? categoryColor
                : Colors.transparent,
            border: Border.all(
              color: task.isCompleted
                  ? categoryColor
                  : categoryColor.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: task.isCompleted
              ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                )
              : null,
        ),
      ),
    );
  }


  Widget _buildTaskInfo(
    BuildContext context,
    Task task,
    bool isDark,
    Color categoryColor,
    DueDateStatus dueDateStatus,
  ) {
    final textPrimary = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.textPrimaryLight;
    final textSecondary = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;


return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // \u2500\u2500 Category chip \u2500\u2500
    Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppConstants.getCategoryIcon(task.category),
                size: 11,
                color: categoryColor,
              ),
              const SizedBox(width: 4),
              Text(
                task.category.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        if (task.isStarred) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: Color(0xFFF59E0B),
          ),
        ],
      ],
    ),
    const SizedBox(height: 7),

    // \u2500\u2500 Title \u2500\u2500
    Text(
      task.title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: task.isCompleted
            ? textSecondary
            : textPrimary,
        decoration:
            task.isCompleted ? TextDecoration.lineThrough : null,
        decorationColor: textSecondary,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),

    // \u2500\u2500 Description \u2500\u2500
    if (task.description != null &&
        task.description!.isNotEmpty) ...[
      const SizedBox(height: 4),
      Text(
        task.description!,
        style: TextStyle(
          fontSize: 12,
          color: textSecondary,
          height: 1.4,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],

    // \u2500\u2500 Sub-tasks progress \u2500\u2500
    if (task.subTasks.isNotEmpty) ...[
      const SizedBox(height: 8),
      _buildSubTaskProgress(task, isDark, categoryColor),
    ],

    const SizedBox(height: 8),

    // \u2500\u2500 Footer row: due date + priority \u2500\u2500
    _buildFooterRow(task, isDark, dueDateStatus),
  ],
);

  }


  Widget _buildSubTaskProgress(Task task, bool isDark, Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 12,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
            const SizedBox(width: 4),
            Text(
              '${task.completedSubTasks}/${task.subTasks.length} subtasks',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: task.subTaskProgress,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
              task.isCompleted ? Colors.grey : categoryColor,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }


  Widget _buildFooterRow(
      Task task, bool isDark, DueDateStatus dueDateStatus) {
    final bool showDueDate = task.dueDate != null;
    final priorityColor = AppConstants.getPriorityColor(task.priority);
    final priorityIcon = AppConstants.getPriorityIcon(task.priority);


return Wrap(
  spacing: 6,
  runSpacing: 4,
  children: [
    // \u2500\u2500 Due date badge \u2500\u2500
    if (showDueDate)
      _buildBadge(
        icon: _getDueDateIcon(dueDateStatus),
        label: TaskDateUtils.formatDueDate(context,task.dueDate!,
            time: task.dueTime),
        color: _getDueDateColor(dueDateStatus),
        isDark: isDark,
      ),

    // \u2500\u2500 Priority badge \u2500\u2500
    if (!task.isCompleted)
      _buildBadge(
        icon: priorityIcon,
        label: task.priority.label,
        color: priorityColor,
        isDark: isDark,
      ),
  ],
);

  }


  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRightActions(BuildContext context, Task task, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // \u2500\u2500 Star button \u2500\u2500
        GestureDetector(
          onTap: () =>
              context.read<TaskProvider>().toggleStarred(task.id),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              task.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              key: ValueKey(task.isStarred),
              size: 22,
              color: task.isStarred
                  ? const Color(0xFFF59E0B)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
            ),
          ),
        ),
      ],
    );
  }


  IconData _getDueDateIcon(DueDateStatus status) {
    switch (status) {
      case DueDateStatus.overdue:
        return Icons.warning_amber_rounded;
      case DueDateStatus.dueToday:
        return Icons.today_rounded;
      case DueDateStatus.dueTomorrow:
        return Icons.event_rounded;
      case DueDateStatus.dueSoon:
        return Icons.schedule_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }


  Color _getDueDateColor(DueDateStatus status) {
    switch (status) {
      case DueDateStatus.overdue:
        return AppTheme.priorityHigh;
      case DueDateStatus.dueToday:
        return AppTheme.priorityMedium;
      case DueDateStatus.dueTomorrow:
        return const Color(0xFF3B82F6);
      case DueDateStatus.dueSoon:
        return AppTheme.primaryColor;
      case DueDateStatus.completed:
        return AppTheme.priorityLow;
      default:
        return AppTheme.textSecondaryLight;
    }
  }
}