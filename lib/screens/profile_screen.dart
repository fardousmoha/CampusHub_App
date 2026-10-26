// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cards.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  Color _roleColor(Role role) {
    return switch (role) {
      Role.student => AppTheme.accent,
      Role.lecturer => AppTheme.violet,
      Role.admin => AppTheme.primary,
    };
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
        final courses = data.coursesForLecturer(current.id);

        final accountRows = <Widget>[
          InfoRow(
            icon: Icons.email_outlined,
            label: 'Email address',
            value: current.email,
          ),
          InfoRow(
            icon: Icons.badge_outlined,
            label: 'University ID',
            value: current.universityId,
          ),
          InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Account role',
            value: current.role.label,
          ),
        ];

        final academicRows = <Widget>[
          if (current.role == Role.student) ...[
            InfoRow(
              icon: Icons.school_outlined,
              label: 'Faculty',
              value: faculty?.name ?? 'Not assigned',
            ),
            InfoRow(
              icon: Icons.account_tree_outlined,
              label: 'Department',
              value: schoolClass?.department.isNotEmpty == true
                  ? schoolClass!.department
                  : current.department,
            ),
            InfoRow(
              icon: Icons.layers_outlined,
              label: 'Class',
              value: schoolClass?.name ?? 'Not assigned',
            ),
            InfoRow(
              icon: Icons.calendar_month_outlined,
              label: 'Semester',
              value: schoolClass == null
                  ? 'Not assigned'
                  : 'Semester ${schoolClass.semester}',
            ),
          ] else ...[
            InfoRow(
              icon: Icons.account_tree_outlined,
              label: 'Department',
              value: current.department,
            ),
            if (current.role == Role.lecturer)
              InfoRow(
                icon: Icons.menu_book_outlined,
                label: 'Assigned courses',
                value: '${courses.length} '
                    '${courses.length == 1 ? 'course' : 'courses'}',
              ),
            if (current.role == Role.admin)
              const InfoRow(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Access level',
                value: 'Administrator',
              ),
          ],
        ];

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    UserAvatar(user: current, radius: 40),
                    const SizedBox(height: 14),
                    Text(
                      current.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      current.universityId,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppBadge(
                      label: current.role.label,
                      color: _roleColor(current.role),
                      icon: current.role == Role.student
                          ? Icons.school_outlined
                          : current.role == Role.lecturer
                              ? Icons.menu_book_outlined
                              : Icons.admin_panel_settings_outlined,
                    ),
                    if (!current.isActive) ...[
                      const SizedBox(height: 10),
                      const AppBadge(
                        label: 'Account deactivated',
                        color: AppTheme.danger,
                        icon: Icons.block,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Account information'),
              const SizedBox(height: 8),
              _InfoCard(rows: accountRows),
              const SizedBox(height: 20),
              _SectionLabel(
                current.role == Role.student
                    ? 'Academic information'
                    : 'Work information',
              ),
              const SizedBox(height: 8),
              _InfoCard(rows: academicRows),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Edit profile',
                icon: Icons.edit_outlined,
                variant: AppButtonVariant.secondary,
                onPressed: () => _openEditProfile(context, current),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: BorderSide(
                      color: AppTheme.danger.withValues(alpha: 0.35),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Log out'),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppTheme.highlight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This profile uses fictional demonstration data stored '
                        'in the app. It is not linked to a real university '
                        'database.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openEditProfile(BuildContext context, User current) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _EditProfileSheet(
        user: current,
        canEditDepartment: current.role != Role.student,
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to log out of CampusHub?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    AuthService.instance.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const Divider(),
            rows[index],
          ],
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final User user;
  final bool canEditDepartment;

  const _EditProfileSheet({
    required this.user,
    required this.canEditDepartment,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _departmentController = TextEditingController(
      text: widget.user.department,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = CampusData.instance;
    data.updateProfile(
      userId: widget.user.id,
      fullName: _nameController.text,
      email: _emailController.text,
      department: widget.canEditDepartment
          ? _departmentController.text
          : widget.user.department,
    );

    final updated = data.userById(widget.user.id);
    if (updated != null) {
      AuthService.instance.updateCurrentUser(updated);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
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
                      'Edit profile',
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
              const SizedBox(height: 6),
              CustomTextField(
                controller: _nameController,
                label: 'Full name',
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _emailController,
                label: 'Email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your email address';
                  }
                  final email = value.trim();
                  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!pattern.hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              if (widget.canEditDepartment) ...[
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _departmentController,
                  label: 'Department',
                  prefixIcon: Icons.account_tree_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your department';
                    }
                    return null;
                  },
                ),
              ] else ...[
                const SizedBox(height: 12),
                const Text(
                  'Your faculty, department, class, and semester are managed '
                  'by the university and cannot be changed here.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                label: 'Save changes',
                icon: Icons.save_outlined,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
