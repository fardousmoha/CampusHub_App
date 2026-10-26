// lib/screens/lecturer/courses_screen.dart

import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/campus_task.dart';
import '../../models/course.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/cards.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/state_views.dart';

class CoursesScreen extends StatelessWidget {
  final User user;

  const CoursesScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final current = data.userById(user.id) ?? user;
        final courses = data.coursesForLecturer(current.id);

        return Scaffold(
          appBar: AppBar(title: const Text('My Courses')),
          body: courses.isEmpty
              ? const EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'No courses assigned',
                  message:
                      'Courses assigned to you by the administration office '
                      'will appear here.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.highlight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.menu_book_outlined,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your assigned courses',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${courses.length} '
                                '${courses.length == 1 ? 'course' : 'courses'} · '
                                'Tap a course to manage assignments.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (var index = 0; index < courses.length; index++) ...[
                      if (index > 0) const SizedBox(height: 10),
                      CourseCard(
                        course: courses[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailsScreen(
                                courseId: courses[index].id,
                                user: current,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    final schoolClass = CampusData.instance.classById(course.classId);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.highlight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBadge(
                          label: course.code,
                          color: AppTheme.primary,
                          icon: Icons.tag,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          course.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          schoolClass == null
                              ? 'Class not assigned'
                              : '${schoolClass.name} · '
                                  'Semester ${schoolClass.semester}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        course.schedule,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        course.room,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseDetailsScreen extends StatelessWidget {
  final int courseId;
  final User user;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final course = _findCourse(data, courseId);

        if (course == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Course details')),
            body: EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Course not found',
              message: 'This course is no longer available.',
              actionLabel: 'Back to courses',
              onAction: () => Navigator.pop(context),
            ),
          );
        }

        final schoolClass = data.classById(course.classId);
        final faculty = schoolClass == null
            ? null
            : data.facultyById(schoolClass.facultyId);
        final groups = _groupAssignments(data.tasksForCourse(course.id));

        return Scaffold(
          appBar: AppBar(title: Text(course.code)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        course.code,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schoolClass == null
                          ? 'Class not assigned'
                          : '${schoolClass.name} · Semester '
                              '${schoolClass.semester}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.18),
                      height: 1,
                    ),
                    const SizedBox(height: 14),
                    _CourseMeta(
                      icon: Icons.schedule,
                      text: course.schedule,
                    ),
                    const SizedBox(height: 8),
                    _CourseMeta(
                      icon: Icons.location_on_outlined,
                      text: course.room,
                    ),
                    const SizedBox(height: 8),
                    _CourseMeta(
                      icon: Icons.groups_outlined,
                      text:
                          '${data.studentsForClass(course.classId).length} students',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Course information',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
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
                      icon: Icons.tag,
                      label: 'Course code',
                      value: course.code,
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.layers_outlined,
                      label: 'Class',
                      value: schoolClass?.name ?? 'Not assigned',
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Semester',
                      value: schoolClass == null
                          ? 'Not assigned'
                          : 'Semester ${schoolClass.semester}',
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.school_outlined,
                      label: 'Faculty',
                      value: faculty?.name ?? 'Not assigned',
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Credits',
                      value: '${course.credits} credit hours',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Course description',
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
                  course.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assignments',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${groups.length} '
                          '${groups.length == 1 ? 'assignment' : 'assignments'} '
                          'for this course',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openAssignmentForm(context, course),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (groups.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No assignments yet. Create one to share it with '
                          'every student in this class.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (var index = 0; index < groups.length; index++) ...[
                  if (index > 0) const SizedBox(height: 9),
                  _AssignmentTile(
                    task: groups[index].first,
                    className: schoolClass?.name ?? 'this class',
                    onDelete: () => _deleteAssignment(
                      context,
                      groups[index].first,
                      schoolClass?.name ?? 'this class',
                    ),
                  ),
                ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static Course? _findCourse(CampusData data, int id) {
    for (final course in data.courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  static List<List<CampusTask>> _groupAssignments(
    List<CampusTask> tasks,
  ) {
    final grouped = <String, List<CampusTask>>{};
    for (final task in tasks) {
      grouped.putIfAbsent(task.assignmentKey, () => []).add(task);
    }
    final groups = grouped.values.toList()
      ..sort((a, b) => a.first.dueDate.compareTo(b.first.dueDate));
    return groups;
  }

  Future<void> _openAssignmentForm(
    BuildContext context,
    Course course,
  ) async {
    final addedCount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AssignmentFormSheet(course: course),
    );

    if (addedCount == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addedCount == 0
              ? 'No students are enrolled in this class yet.'
              : 'Assignment added for $addedCount '
                  '${addedCount == 1 ? 'student' : 'students'}.',
        ),
      ),
    );
  }

  Future<void> _deleteAssignment(
    BuildContext context,
    CampusTask task,
    String className,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete assignment?'),
        content: Text(
          'This removes "${task.title}" for every student in $className. '
          'This action only changes the demonstration data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.danger,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    CampusData.instance.deleteAssignmentGroup(
      courseId: task.courseId,
      title: task.title,
      dueDate: task.dueDate,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment deleted.')),
    );
  }
}

class _CourseMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CourseMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final CampusTask task;
  final String className;
  final VoidCallback onDelete;

  const _AssignmentTile({
    required this.task,
    required this.className,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.highlight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              taskTypeIcon(task.type),
              size: 20,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge(
                  label: task.type.label,
                  color: AppTheme.primary,
                  icon: taskTypeIcon(task.type),
                ),
                const SizedBox(height: 6),
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 13,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Due ${formatDueLabel(task.dueDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Assigned to $className',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Assignment actions',
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: AppTheme.danger,
                  ),
                  title: Text(
                    'Delete assignment',
                    style: TextStyle(color: AppTheme.danger),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AssignmentFormSheet extends StatefulWidget {
  final Course course;

  const AssignmentFormSheet({super.key, required this.course});

  @override
  State<AssignmentFormSheet> createState() => _AssignmentFormSheetState();
}

class _AssignmentFormSheetState extends State<AssignmentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _dueDate;
  TaskType _type = TaskType.assignment;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dueDate = DateTime(now.year, now.month, now.day, 23, 59)
        .add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_dueDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a due date in the future.')),
      );
      return;
    }

    final count = CampusData.instance.addAssignmentForCourse(
      course: widget.course,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      type: _type,
    );

    Navigator.pop(context, count);
  }

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;
    final schoolClass = data.classById(widget.course.classId);
    final studentCount = data.studentsForClass(widget.course.classId).length;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'New assignment',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.course.code} · ${widget.course.name}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.highlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 19,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will be assigned to $studentCount '
                          '${studentCount == 1 ? 'student' : 'students'} in '
                          '${schoolClass?.name ?? 'this class'}.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _titleController,
                  label: 'Assignment title',
                  hintText: 'For example Build a login screen',
                  prefixIcon: Icons.title,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the assignment title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Instructions',
                  hintText: 'Explain what students need to do',
                  maxLines: 5,
                  minLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the assignment instructions';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'Assignment type',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in TaskType.values)
                      AppFilterChip(
                        label: type.label,
                        icon: taskTypeIcon(type),
                        selected: _type == type,
                        onSelected: () => setState(() => _type = type),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: () async {
                    final picked = await _pickDueDate(context);
                    if (picked == null) return;
                    setState(() => _dueDate = picked);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due date and time',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    child: Text(
                      formatDateTime(_dueDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Create assignment',
                  icon: Icons.add,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
