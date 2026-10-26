// lib/screens/shared/tasks_screen.dart

import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/campus_task.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/cards.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/state_views.dart';

class TasksScreen extends StatefulWidget {
  final User user;

  const TasksScreen({super.key, required this.user});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final user = data.userById(widget.user.id) ?? widget.user;
        final allTasks = data.tasksForStudent(user.id);
        final visibleTasks = _filter == null
            ? allTasks
            : allTasks
                .where((task) => task.status == _filter)
                .toList();

        final pending = allTasks
            .where((task) => task.status == TaskStatus.pending)
            .length;
        final submitted = allTasks
            .where((task) => task.status == TaskStatus.submitted)
            .length;
        final completed = allTasks
            .where((task) => task.status == TaskStatus.completed)
            .length;

        return Scaffold(
          appBar: AppBar(title: const Text('My Tasks')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Pending',
                        value: pending,
                        color: AppTheme.warning,
                        icon: Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Submitted',
                        value: submitted,
                        color: AppTheme.accent,
                        icon: Icons.upload_file_outlined,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Completed',
                        value: completed,
                        color: AppTheme.success,
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 52,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      AppFilterChip(
                        label: 'All',
                        selected: _filter == null,
                        count: allTasks.length,
                        onSelected: () => setState(() => _filter = null),
                      ),
                      const SizedBox(width: 8),
                      AppFilterChip(
                        label: 'Pending',
                        selected: _filter == TaskStatus.pending,
                        count: pending,
                        onSelected: () =>
                            setState(() => _filter = TaskStatus.pending),
                      ),
                      const SizedBox(width: 8),
                      AppFilterChip(
                        label: 'Submitted',
                        selected: _filter == TaskStatus.submitted,
                        count: submitted,
                        onSelected: () =>
                            setState(() => _filter = TaskStatus.submitted),
                      ),
                      const SizedBox(width: 8),
                      AppFilterChip(
                        label: 'Completed',
                        selected: _filter == TaskStatus.completed,
                        count: completed,
                        onSelected: () =>
                            setState(() => _filter = TaskStatus.completed),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: visibleTasks.isEmpty
                    ? EmptyState(
                        icon: Icons.assignment_outlined,
                        title: _filter == null
                            ? 'No tasks assigned'
                            : 'No ${_filter!.label.toLowerCase()} tasks',
                        message: _filter == null
                            ? 'New assignments and quizzes will appear here.'
                            : 'Try another filter to see your other tasks.',
                        actionLabel: _filter == null ? null : 'Show all tasks',
                        onAction:
                            _filter == null ? null : () => setState(() => _filter = null),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: visibleTasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final task = visibleTasks[index];
                          return TaskCard(
                            task: task,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskDetailsScreen(
                                    taskId: task.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 7),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailsScreen extends StatelessWidget {
  final int taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final task = _findTask(data, taskId);

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task details')),
            body: EmptyState(
              icon: Icons.assignment_late_outlined,
              title: 'Task not found',
              message: 'This task is no longer available.',
              actionLabel: 'Back to tasks',
              onAction: () => Navigator.pop(context),
            ),
          );
        }

        final Widget? action;
        if (task.status == TaskStatus.pending && task.canSubmit) {
          action = CustomButton(
            label: 'Mark as submitted',
            icon: Icons.upload_file_outlined,
            onPressed: () =>
                _changeStatus(context, task, TaskStatus.submitted),
          );
        } else if (task.status == TaskStatus.submitted) {
          action = CustomButton(
            label: 'Mark as completed',
            icon: Icons.task_alt,
            onPressed: () =>
                _changeStatus(context, task, TaskStatus.completed),
          );
        } else {
          action = null;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Task details')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TaskStatusBadge(task: task),
                  AppBadge(
                    label: task.type.label,
                    color: AppTheme.primary,
                    icon: taskTypeIcon(task.type),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task.courseName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.isOverdue) ...[
                const SizedBox(height: 18),
                const _NoticeBanner(
                  icon: Icons.warning_amber_rounded,
                  title: 'This task is overdue',
                  message:
                      'The due date has passed. Check with your lecturer if '
                      'late submission is still possible.',
                  color: AppTheme.danger,
                ),
              ],
              if (task.status == TaskStatus.pending && !task.canSubmit) ...[
                const SizedBox(height: 18),
                const _NoticeBanner(
                  icon: Icons.lock_clock_outlined,
                  title: 'Submission is closed',
                  message:
                      'You can still read the task details, but submissions '
                      'are no longer accepted.',
                  color: AppTheme.warning,
                ),
              ],
              if (task.status == TaskStatus.completed) ...[
                const SizedBox(height: 18),
                const _NoticeBanner(
                  icon: Icons.check_circle_outline,
                  title: 'Task completed',
                  message: 'This task has been marked as completed.',
                  color: AppTheme.success,
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.menu_book_outlined,
                      label: 'Course',
                      value: task.courseName,
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Due date',
                      value: formatDateTime(task.dueDate),
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.flag_outlined,
                      label: 'Task type',
                      value: task.type.label,
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.info_outline,
                      label: 'Submission',
                      value: task.canSubmit
                          ? 'Open for submission'
                          : 'Closed',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          bottomNavigationBar: action == null
              ? null
              : Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppTheme.border),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: action,
                    ),
                  ),
                ),
        );
      },
    );
  }

  static CampusTask? _findTask(CampusData data, int id) {
    for (final task in data.tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> _changeStatus(
    BuildContext context,
    CampusTask task,
    TaskStatus newStatus,
  ) async {
    final isSubmitting = newStatus == TaskStatus.submitted;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isSubmitting ? 'Mark as submitted?' : 'Mark as completed?',
        ),
        content: Text(
          isSubmitting
              ? 'Confirm that you have submitted this task to your lecturer.'
              : 'Confirm that this task is fully completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    CampusData.instance.updateTaskStatus(task.id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task marked as ${newStatus.label.toLowerCase()}.'),
      ),
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _NoticeBanner({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
