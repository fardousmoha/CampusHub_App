// lib/screens/admin/admin_shell.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../widgets/app_shell.dart';
import '../profile_screen.dart';
import '../shared/announcements_screen.dart';
import '../shared/events_screen.dart';
import '../shared/users_screen.dart';
import 'admin_dashboard.dart';

class AdminShell extends StatelessWidget {
  final User user;
  const AdminShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      pages: [
        AdminDashboard(user: user),
        UsersScreen(currentUser: user),
        EventsScreen(user: user),
        AnnouncementsScreen(user: user),
        ProfileScreen(user: user),
      ],
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Users',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event),
          label: 'Events',
        ),
        NavigationDestination(
          icon: Icon(Icons.campaign_outlined),
          selectedIcon: Icon(Icons.campaign),
          label: 'News',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
