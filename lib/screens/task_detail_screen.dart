import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/date_utils.dart';
import '../widgets/task_form_sheet.dart';


class TaskDetailScreen extends StatelessWidget {
  final Task task;


  const TaskDetailScreen({super.key, required this.task});


  @override
  Widget build(BuildContext context) {
    // Watch for live updates to this task
    final provider = context.watch<TaskProvider>();
    final liveTask = provider.allTasks.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );


final isDark = Theme.of(context).brightness == Brightness.dark;
final categoryColor = AppConstants.getCategoryColor(liveTask.category);
final priorityColor = AppConstants.getPriorityColor(liveTask.priority);

return Scaffold(
  backgroundColor:
      isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
  body: CustomScrollView(
    slivers: [
      // ── App bar ──
      _buildSliverAppBar(
          context, liveTask, isDark, categoryColor),

      // ── Content ──
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Status + Priority row ──
              _buildStatusRow(
                  context, liveTask, isDark, categoryColor, priorityColor),
              const SizedBox(height: 20),

              // ── Description ──
              if (liveTask.description != null &&
                  liveTask.description!.isNotEmpty) ...[
                _buildSection(
                  context,
                  isDark,
                  icon: Icons.notes_rounded,
                  title: 'Description',
                  child: _buildDescriptionCard(liveTask, isDark),
                ),
                const SizedBox(height: 20),
              ],

              // ── Due date ──
              if (liveTask.dueDate != null) ...[
                _buildSection(
                  context,
                  isDark,
                  icon: Icons.event_rounded,
                  title: 'Due Date',
                  child: _buildDueDateCard(context,liveTask, isDark),
                ),
                const SizedBox(height: 20),
              ],

              // ── Sub-tasks ──
              if (liveTask.subTasks.isNotEmpty) ...[
                _buildSection(
                  context,
                  isDark,
                  icon: Icons.checklist_rounded,
                  title:
                      'Sub-tasks (${liveTask.completedSubTasks}/${liveTask.subTasks.length})',
                  child: _buildSubTasksCard(
                      context, liveTask, isDark, categoryColor),
                ),
                const SizedBox(height: 20),
              ],

              // ── Meta info ──
              _buildSection(
                context,
                isDark,
                icon: Icons.info_outline_rounded,
                title: 'Details',
                child:
                    _buildMetaCard(liveTask, isDark, categoryColor),
              ),
              const SizedBox(height: 28),

              // ── Danger zone ──
              _buildDangerZone(context, liveTask, isDark),
            ],
          ),
        ),
      ),
    ],
  ),

  // ── FAB: mark complete ──
  floatingActionButton: _buildCompleteFAB(context, liveTask, isDark),
  floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
);

  }


  // ─── Sliver App Bar ───────────────────────────────────────────────────────


  Widget _buildSliverAppBar(
    BuildContext context,
    Task task,
    bool isDark,
    Color categoryColor,
  ) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ── 3D effect: darker background for contrast ──
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              // ── Shadow below (gives depth) ──
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              // ── Light on top (gives 3D feel) ──
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      actions: [
        // ── Star toggle ──
        GestureDetector(
          onTap: () =>
              context.read<TaskProvider>().toggleStarred(task.id),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ── 3D effect: darker background for contrast ──
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                // ── Shadow below (gives depth) ──
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                // ── Light on top (gives 3D feel) ──
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                task.isStarred
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: task.isStarred
                    ? const Color(0xFFF59E0B)
                    : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        // ── Edit button ──
        GestureDetector(
          onTap: () => _openEditSheet(context, task),
          child: Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              // ── 3D effect: darker background for contrast ──
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                // ── Shadow below (gives depth) ──
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                // ── Light on top (gives 3D feel) ──
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.edit_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withOpacity(0.9),
                categoryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ── Category badge ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${task.category.emoji}  ${task.category.label}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),


              // ── Title ──
              Text(
                task.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);

  }


  // ─── Status Row ───────────────────────────────────────────────────────────


  Widget _buildStatusRow(
    BuildContext context,
    Task task,
    bool isDark,
    Color categoryColor,
    Color priorityColor,
  ) {
    final dueDateStatus =
        TaskDateUtils.getDueDateStatus(task.dueDate, task.isCompleted);


return Row(
  children: [
    // Status chip
    _InfoChip(
      icon: task.isCompleted
          ? Icons.check_circle_rounded
          : Icons.radio_button_unchecked_rounded,
      label: task.isCompleted ? 'Completed' : 'In Progress',
      color: task.isCompleted
          ? AppTheme.priorityLow
          : AppTheme.primaryColor,
      isDark: isDark,
    ),
    const SizedBox(width: 8),

    // Priority chip
    _InfoChip(
      icon: AppConstants.getPriorityIcon(task.priority),
      label: '${task.priority.label} Priority',
      color: priorityColor,
      isDark: isDark,
    ),

    if (task.isOverdue) ...[
      const SizedBox(width: 8),
      _InfoChip(
        icon: Icons.warning_amber_rounded,
        label: 'Overdue',
        color: AppTheme.priorityHigh,
        isDark: isDark,
      ),
    ],
  ],
);

  }


  // ─── Description Card ─────────────────────────────────────────────────────


  Widget _buildDescriptionCard(Task task, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? [] : AppTheme.cardShadow,
      ),
      child: Text(
        task.description!,
        style: TextStyle(
          fontSize: 14,
          color: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight,
          height: 1.6,
        ),
      ),
    );
  }


  // ─── Due Date Card ────────────────────────────────────────────────────────


  Widget _buildDueDateCard( BuildContext context, task, bool isDark) {
    final dueDateStatus =
        TaskDateUtils.getDueDateStatus(task.dueDate, task.isCompleted);
    final daysLeft = TaskDateUtils.daysUntilDue(task.dueDate);


Color statusColor;
switch (dueDateStatus) {
  case DueDateStatus.overdue:
    statusColor = AppTheme.priorityHigh;
    break;
  case DueDateStatus.dueToday:
    statusColor = AppTheme.priorityMedium;
    break;
  default:
    statusColor = AppTheme.primaryColor;
}

return Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
    borderRadius: BorderRadius.circular(14),
    boxShadow: isDark ? [] : AppTheme.cardShadow,
  ),
  child: Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.event_rounded,
            color: statusColor, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TaskDateUtils.formatFullDate(task.dueDate!),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            if (task.dueTime != null) ...[
              const SizedBox(height: 2),
              Text(
                '⏰ ${task.dueTime!.format(context)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ],
        ),
      ),
      if (!task.isCompleted && daysLeft != null)
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            daysLeft < 0
                ? '${daysLeft.abs()}d late'
                : daysLeft == 0
                    ? 'Today'
                    : '${daysLeft}d left',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
    ],
  ),
);

  }


  // ─── Sub-tasks Card ───────────────────────────────────────────────────────


  Widget _buildSubTasksCard(
    BuildContext context,
    Task task,
    bool isDark,
    Color categoryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? [] : AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Progress bar at top
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.subTaskProgress,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.06),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(categoryColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(task.subTaskProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...task.subTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final sub = entry.value;
            return Column(
              children: [
                ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: GestureDetector(
                    onTap: () => context
                        .read<TaskProvider>()
                        .toggleSubTask(task.id, sub.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sub.isCompleted
                            ? categoryColor
                            : Colors.transparent,
                        border: Border.all(
                          color: sub.isCompleted
                              ? categoryColor
                              : (isDark
                                  ? Colors.white30
                                  : Colors.black26),
                          width: 1.8,
                        ),
                      ),
                      child: sub.isCompleted
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 13)
                          : null,
                    ),
                  ),
                  title: Text(
                    sub.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: sub.isCompleted
                          ? (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight)
                          : (isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight),
                      decoration: sub.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                if (index < task.subTasks.length - 1)
                  Divider(
                    height: 1,
                    indent: 54,
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }


  // ─── Meta Info Card ───────────────────────────────────────────────────────


  Widget _buildMetaCard(Task task, bool isDark, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? [] : AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _MetaRow(
            icon: Icons.category_rounded,
            label: 'Category',
            value: '${task.category.emoji} ${task.category.label}',
            isDark: isDark,
            color: categoryColor,
          ),
          _divider(isDark),
          _MetaRow(
            icon: AppConstants.getPriorityIcon(task.priority),
            label: 'Priority',
            value: task.priority.label,
            isDark: isDark,
            color: AppConstants.getPriorityColor(task.priority),
          ),
          _divider(isDark),
          _MetaRow(
            icon: Icons.access_time_rounded,
            label: 'Created',
            value: TaskDateUtils.formatCreatedAt(task.createdAt),
            isDark: isDark,
          ),
          if (task.completedAt != null) ...[
            _divider(isDark),
            _MetaRow(
              icon: Icons.check_circle_rounded,
              label: 'Completed',
              value: TaskDateUtils.formatCreatedAt(task.completedAt!),
              isDark: isDark,
              color: AppTheme.priorityLow,
            ),
          ],
          if (task.subTasks.isNotEmpty) ...[
            _divider(isDark),
            _MetaRow(
              icon: Icons.checklist_rounded,
              label: 'Sub-tasks',
              value:
                  '${task.completedSubTasks} of ${task.subTasks.length} done',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }


  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
    );
  }


  // ─── Danger Zone ──────────────────────────────────────────────────────────


  Widget _buildDangerZone(
      BuildContext context, Task task, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDark ? [] : AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              // Duplicate task
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.copy_rounded,
                      color: AppTheme.primaryColor, size: 18),
                ),
                title: Text(
                  'Duplicate Task',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
                onTap: () => _duplicateTask(context, task),
              ),
              Divider(
                height: 1,
                indent: 64,
                color:
                    isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              ),
              // Delete task
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.priorityHigh.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_rounded,
                      color: AppTheme.priorityHigh, size: 18),
                ),
                title: const Text(
                  'Delete Task',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.priorityHigh,
                  ),
                ),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
                onTap: () => _confirmDelete(context, task),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // ─── FAB ─────────────────────────────────────────────────────────────────


  Widget _buildCompleteFAB(
      BuildContext context, Task task, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () =>
            context.read<TaskProvider>().toggleTaskCompletion(task.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: task.isCompleted
              ? AppTheme.priorityMedium
              : AppTheme.priorityLow,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              task.isCompleted
                  ? Icons.replay_rounded
                  : Icons.check_rounded,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ─── Section Wrapper ──────────────────────────────────────────────────────


  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }


  // ─── Actions ──────────────────────────────────────────────────────────────


  void _openEditSheet(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(task: task),
    );
  }


  void _duplicateTask(BuildContext context, Task task) async {
    final provider = context.read<TaskProvider>();
    final duplicate = task.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${task.title} (Copy)',
      isCompleted: false,
      completedAt: null,
      clearCompletedAt: true,
    );
    await provider.addTask(duplicate);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task duplicated!'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }


  void _confirmDelete(BuildContext context, Task task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    backgroundColor:
        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: const Text(
      'Delete Task?',
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    ),
    content: Text(
      'This action cannot be undone. "${task.title}" will be permanently deleted.',
      style: TextStyle(
        color: isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight,
        fontSize: 14,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text(
          'Cancel',
          style: TextStyle(
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () async {
          await context.read<TaskProvider>().deleteTask(task.id);
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.priorityHigh,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text('Delete',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    ],
  ),
);

  }
}


// ─── Info Chip ────────────────────────────────────────────────────────────────


class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;


  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


// ─── Meta Row ─────────────────────────────────────────────────────────────────


class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? color;


  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.color,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ??
                (isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ??
                  (isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }
}