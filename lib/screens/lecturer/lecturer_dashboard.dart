// lib/screens/lecturer/lecturer_dashboard.dart

import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/course.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../profile_screen.dart';
import '../shared/announcements_screen.dart';
import '../shared/events_screen.dart';
import 'courses_screen.dart';

class LecturerDashboard extends StatelessWidget {
  final User user;

  const LecturerDashboard({super.key, required this.user});

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
        final courses = data.coursesForLecturer(current.id);
        final studentCount = data.uniqueStudentCountForLecturer(current.id);
        final upcomingEvents = data.upcomingEvents();
        final latestAnnouncements = data.announcementsNewestFirst();
        final coursePreview = courses.take(2).toList();
        final eventPreview = upcomingEvents.take(2).toList();
        final announcementPreview = latestAnnouncements.take(2).toList();

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
                            'Lecturer · ${current.universityId}',
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
                Container(
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
                      const Text(
                        'TEACHING PROFILE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        current.department.isEmpty
                            ? 'Faculty member'
                            : current.department,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${current.fullName} · ${current.universityId}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.18),
                        height: 1,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _TeachingStat(
                              value: '${courses.length}',
                              label: 'Courses',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                          Expanded(
                            child: _TeachingStat(
                              value: '$studentCount',
                              label: 'Students',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                          Expanded(
                            child: _TeachingStat(
                              value: '${upcomingEvents.length}',
                              label: 'Events',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.menu_book_outlined,
                        label: 'Courses',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CoursesScreen(user: current),
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
                  title: 'Assigned courses',
                  subtitle: courses.isEmpty
                      ? 'No courses are assigned to you'
                      : '${courses.length} active '
                          '${courses.length == 1 ? 'course' : 'courses'}',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CoursesScreen(user: current),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                if (coursePreview.isEmpty)
                  const _CompactMessage(
                    icon: Icons.menu_book_outlined,
                    message: 'Assigned courses will appear here.',
                  )
                else
                  for (
                    var index = 0;
                    index < coursePreview.length;
                    index++
                  ) ...[
                    if (index > 0) const SizedBox(height: 10),
                    CourseCard(
                      course: coursePreview[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailsScreen(
                              courseId: coursePreview[index].id,
                              user: current,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Teaching schedule',
                  subtitle: 'Your weekly classes',
                ),
                const SizedBox(height: 10),
                if (courses.isEmpty)
                  const _CompactMessage(
                    icon: Icons.schedule,
                    message: 'Your teaching schedule will appear here.',
                  )
                else
                  for (var index = 0; index < courses.length; index++) ...[
                    if (index > 0) const SizedBox(height: 9),
                    _ScheduleTile(course: courses[index]),
                  ],
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Upcoming events',
                  subtitle: 'Campus activities and opportunities',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EventsScreen(user: current),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                if (eventPreview.isEmpty)
                  const _CompactMessage(
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
                  subtitle: 'Updates for staff and students',
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
                  const _CompactMessage(
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
}

class _TeachingStat extends StatelessWidget {
  final String value;
  final String label;

  const _TeachingStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final Course course;

  const _ScheduleTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;
    final schoolClass = data.classById(course.classId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      course.code,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schoolClass == null ? 'Class not assigned' : schoolClass.name,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  course.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
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
                        course.schedule,
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
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      course.room,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _CompactMessage({required this.icon, required this.message});

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
