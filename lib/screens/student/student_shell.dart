// lib/screens/student/student_shell.dart

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../widgets/app_shell.dart';
import '../profile_screen.dart';
import '../shared/announcements_screen.dart';
import '../shared/events_screen.dart';
import '../shared/tasks_screen.dart';
import 'student_dashboard.dart';

class StudentShell extends StatelessWidget {
  final User user;

  const StudentShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      pages: [
        StudentDashboard(user: user),
        TasksScreen(user: user),
        EventsScreen(user: user),
        AnnouncementsScreen(user: user),
        ProfileScreen(user: user),
      ],
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Tasks',
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
