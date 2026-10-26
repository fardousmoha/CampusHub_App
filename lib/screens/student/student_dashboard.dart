// lib/screens/student/student_dashboard.dart

import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/campus_task.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/cards.dart';
import '../profile_screen.dart';
import '../shared/announcements_screen.dart';
import '../shared/events_screen.dart';
import '../shared/tasks_screen.dart';

class StudentDashboard extends StatelessWidget {
  final User user;

  const StudentDashboard({super.key, required this.user});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final current = data.userById(user.id) ?? user;
        final schoolClass = data.classForUser(current.id);
        final faculty = data.facultyForUser(current.id);
        final allTasks = data.tasksForStudent(current.id);
        final pendingTasks = allTasks
            .where((task) => task.status == TaskStatus.pending)
            .toList();
        final upcomingEvents = data.upcomingEvents();
        final latestAnnouncements = data.announcementsNewestFirst();
        final importantCount = latestAnnouncements
            .where((announcement) => announcement.isImportant)
            .length;
        final taskPreview = allTasks
            .where((task) => task.status != TaskStatus.completed)
            .take(2)
            .toList();
        final eventPreview = upcomingEvents.take(2).toList();
        final announcementPreview = latestAnnouncements.take(2).toList();
        final notificationCount = pendingTasks.length + importantCount;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CAMPUSHUB',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '$_greeting,',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            current.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Student · ${current.universityId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _NotificationBell(
                      count: notificationCount,
                      onTap: () => _showNotifications(context, current),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Open profile',
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(user: current),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: UserAvatar(user: current, radius: 23),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _AcademicCard(
                  studentName: current,
                  className: schoolClass?.name ?? 'Not assigned',
                  semester: schoolClass?.semester,
                  facultyName: faculty?.name ?? 'Not assigned',
                  department: schoolClass?.department.isNotEmpty == true
                      ? schoolClass!.department
                      : current.department,
                  pendingCount: pendingTasks.length,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.assignment_outlined,
                        label: 'Tasks',
                        badgeCount: pendingTasks.length,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TasksScreen(user: current),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.event_outlined,
                        label: 'Events',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventsScreen(user: current),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.campaign_outlined,
                        label: 'News',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AnnouncementsScreen(user: current),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.person_outline,
                        label: 'Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(user: current),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Upcoming tasks',
                  subtitle: pendingTasks.isEmpty
                      ? 'You have no pending tasks'
                      : '${pendingTasks.length} pending '
                          '${pendingTasks.length == 1 ? 'task' : 'tasks'}',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TasksScreen(user: current),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                if (taskPreview.isEmpty)
                  const _CompactEmpty(
                    icon: Icons.task_alt,
                    message: 'You are all caught up. No tasks need attention.',
                  )
                else
                  for (var index = 0; index < taskPreview.length; index++) ...[
                    if (index > 0) const SizedBox(height: 10),
                    TaskCard(
                      task: taskPreview[index],
                      compact: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsScreen(
                              taskId: taskPreview[index].id,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Campus events',
                  subtitle: 'Discover what is happening',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventsScreen(user: current),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                if (eventPreview.isEmpty)
                  const _CompactEmpty(
                    icon: Icons.event_busy_outlined,
                    message: 'No upcoming events at the moment.',
                  )
                else
                  for (var index = 0; index < eventPreview.length; index++) ...[
                    if (index > 0) const SizedBox(height: 10),
                    EventCard(
                      event: eventPreview[index],
                      compact: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailsScreen(
                              eventId: eventPreview[index].id,
                              user: current,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Latest announcements',
                  subtitle: 'Updates from your university',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AnnouncementsScreen(user: current),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                if (announcementPreview.isEmpty)
                  const _CompactEmpty(
                    icon: Icons.campaign_outlined,
                    message: 'No announcements have been published yet.',
                  )
                else
                  for (
                    var index = 0;
                    index < announcementPreview.length;
                    index++
                  ) ...[
                    if (index > 0) const SizedBox(height: 10),
                    AnnouncementCard(
                      announcement: announcementPreview[index],
                      compact: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnouncementDetailsScreen(
                              announcementId: announcementPreview[index].id,
                              user: current,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotifications(BuildContext context, User current) {
    final data = CampusData.instance;
    final dueTasks = data
        .tasksForStudent(current.id)
        .where((task) => task.status == TaskStatus.pending)
        .take(3)
        .toList();
    final importantAnnouncements = data
        .announcementsNewestFirst()
        .where((announcement) => announcement.isImportant)
        .take(3)
        .toList();
    final nextEvents = data.upcomingEvents().take(2).toList();

    final children = <Widget>[
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dueTasks.length + importantAnnouncements.length + nextEvents.length} '
                  'recent campus updates',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      const SizedBox(height: 10),
    ];

    if (dueTasks.isEmpty && importantAnnouncements.isEmpty && nextEvents.isEmpty) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 12),
          child: Column(
            children: [
              Icon(
                Icons.notifications_none,
                size: 44,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: 10),
              Text(
                'No new notifications',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Campus updates will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      if (dueTasks.isNotEmpty) {
        children.add(const _SheetSectionLabel('Task reminders'));
        for (final task in dueTasks) {
          children.add(
            _NotificationTile(
              icon: task.isOverdue
                  ? Icons.warning_amber_rounded
                  : Icons.assignment_outlined,
              color: task.isOverdue ? AppTheme.danger : AppTheme.warning,
              title: task.title,
              subtitle:
                  'Due ${formatDueLabel(task.dueDate)} · ${task.courseName}',
            ),
          );
        }
      }

      if (importantAnnouncements.isNotEmpty) {
        children.add(const _SheetSectionLabel('Important announcements'));
        for (final announcement in importantAnnouncements) {
          children.add(
            _NotificationTile(
              icon: Icons.campaign_outlined,
              color: AppTheme.danger,
              title: announcement.title,
              subtitle:
                  '${announcement.author} · ${formatRelativeDate(announcement.publishedAt)}',
            ),
          );
        }
      }

      if (nextEvents.isNotEmpty) {
        children.add(const _SheetSectionLabel('Upcoming events'));
        for (final event in nextEvents) {
          children.add(
            _NotificationTile(
              icon: Icons.event_outlined,
              color: AppTheme.accent,
              title: event.title,
              subtitle:
                  '${formatShortDate(event.start)} · ${event.location}',
            ),
          );
        }
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.78,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        );
      },
    );
  }
}

class _AcademicCard extends StatelessWidget {
  final User studentName;
  final String className;
  final int? semester;
  final String facultyName;
  final String department;
  final int pendingCount;

  const _AcademicCard({
    required this.studentName,
    required this.className,
    required this.semester,
    required this.facultyName,
    required this.department,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT SEMESTER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      className,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      semester == null
                          ? 'Semester not assigned'
                          : 'Semester $semester',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$pendingCount pending',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.18), height: 1),
          const SizedBox(height: 14),
          _AcademicMeta(
            icon: Icons.person_outline,
            label: 'Student',
            value: '${studentName.fullName} · ${studentName.universityId}',
          ),
          const SizedBox(height: 10),
          _AcademicMeta(
            icon: Icons.school_outlined,
            label: 'Faculty',
            value: facultyName,
          ),
          const SizedBox(height: 10),
          _AcademicMeta(
            icon: Icons.account_tree_outlined,
            label: 'Department',
            value: department,
          ),
        ],
      ),
    );
  }
}

class _AcademicMeta extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AcademicMeta({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value.isEmpty ? 'Not assigned' : value,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.border),
          ),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: onTap,
            icon: const Icon(
              Icons.notifications_none,
              color: AppTheme.primary,
              size: 23,
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 3,
            top: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18),
              decoration: BoxDecoration(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompactEmpty extends StatelessWidget {
  final IconData icon;
  final String message;

  const _CompactEmpty({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetSectionLabel extends StatelessWidget {
  final String text;

  const _SheetSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                    height: 1.4,
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
