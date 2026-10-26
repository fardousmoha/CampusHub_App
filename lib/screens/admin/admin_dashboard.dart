// lib/screens/admin/admin_dashboard.dart

import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../profile_screen.dart';
import '../shared/announcements_screen.dart';
import '../shared/events_screen.dart';
import '../shared/users_screen.dart';

class AdminDashboard extends StatelessWidget {
  final User user;

  const AdminDashboard({super.key, required this.user});

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
        final activeUsers = data.users.where((item) => item.isActive).length;
        final inactiveUsers = data.totalUsers - activeUsers;
        final upcomingEvents = data.upcomingEvents();
        final importantAnnouncements =
            data.announcements.where((item) => item.isImportant).length;
        final latestAnnouncements = data.announcementsNewestFirst();
        final announcementPreview = latestAnnouncements.take(2).toList();
        final eventPreview = upcomingEvents.take(2).toList();

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
                            'CAMPUSHUB ADMIN',
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
                            'Administrator · ${current.universityId}',
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
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 19,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'ADMINISTRATION CONSOLE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        current.department.isEmpty
                            ? 'Campus administration'
                            : current.department,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$activeUsers active accounts'
                        '${inactiveUsers > 0 ? ' · $inactiveUsers inactive' : ''}',
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
                            child: _ConsoleStat(
                              value: '${data.totalUsers}',
                              label: 'Users',
                            ),
                          ),
                          const _ConsoleDivider(),
                          Expanded(
                            child: _ConsoleStat(
                              value: '${data.totalStudents}',
                              label: 'Students',
                            ),
                          ),
                          const _ConsoleDivider(),
                          Expanded(
                            child: _ConsoleStat(
                              value: '${data.totalLecturers}',
                              label: 'Lecturers',
                            ),
                          ),
                          const _ConsoleDivider(),
                          Expanded(
                            child: _ConsoleStat(
                              value: '${data.totalAdmins}',
                              label: 'Admins',
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
                        icon: Icons.people_outline,
                        label: 'Users',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UsersScreen(currentUser: current),
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
                const SectionHeader(
                  title: 'Manage campus',
                  subtitle: 'Administrator tools',
                ),
                const SizedBox(height: 10),
                _ManageTile(
                  icon: Icons.people_alt_outlined,
                  color: AppTheme.primary,
                  title: 'Users & roles',
                  subtitle:
                      '${data.totalUsers} accounts · $inactiveUsers inactive',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UsersScreen(currentUser: current),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 9),
                _ManageTile(
                  icon: Icons.event_available_outlined,
                  color: AppTheme.accent,
                  title: 'Campus events',
                  subtitle:
                      '${upcomingEvents.length} upcoming of ${data.totalEvents} events',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventsScreen(user: current),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 9),
                _ManageTile(
                  icon: Icons.campaign_outlined,
                  color: AppTheme.violet,
                  title: 'Announcements',
                  subtitle:
                      '${data.totalAnnouncements} published · '
                      '$importantAnnouncements important',
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
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Latest announcements',
                  subtitle: 'Recently published notices',
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
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Upcoming events',
                  subtitle: 'What is happening on campus',
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConsoleStat extends StatelessWidget {
  final String value;
  final String label;

  const _ConsoleStat({required this.value, required this.label});

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

class _ConsoleDivider extends StatelessWidget {
  const _ConsoleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withValues(alpha: 0.16),
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManageTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
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
