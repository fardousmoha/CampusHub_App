// lib/screens/shared/users_screen.dart

import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/state_views.dart';

Color _roleColor(Role role) {
  return switch (role) {
    Role.student => AppTheme.accent,
    Role.lecturer => AppTheme.violet,
    Role.admin => AppTheme.primary,
  };
}

IconData _roleIcon(Role role) {
  return switch (role) {
    Role.student => Icons.school_outlined,
    Role.lecturer => Icons.menu_book_outlined,
    Role.admin => Icons.admin_panel_settings_outlined,
  };
}

String _rolePlural(Role role) {
  return switch (role) {
    Role.student => 'Students',
    Role.lecturer => 'Lecturers',
    Role.admin => 'Admins',
  };
}

class UsersScreen extends StatefulWidget {
  final User currentUser;

  const UsersScreen({super.key, required this.currentUser});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  Role? _roleFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _roleFilter = null);
  }

  Future<void> _openAddUser() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(
          currentAdmin: widget.currentUser,
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User account created.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();
        final allUsers = [...data.users]
          ..sort((a, b) {
            if (a.isActive != b.isActive) {
              return a.isActive ? -1 : 1;
            }
            return a.fullName.toLowerCase().compareTo(
                  b.fullName.toLowerCase(),
                );
          });

        final filtered = allUsers.where((user) {
          final matchesRole =
              _roleFilter == null || user.role == _roleFilter;
          final matchesQuery = query.isEmpty ||
              user.fullName.toLowerCase().contains(query) ||
              user.universityId.toLowerCase().contains(query);
          return matchesRole && matchesQuery;
        }).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('User Management')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddUser,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add user'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: CustomTextField(
                  controller: _searchController,
                  label: 'Search users',
                  hintText: 'Search by name or university ID',
                  prefixIcon: Icons.search,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
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
                        selected: _roleFilter == null,
                        count: data.totalUsers,
                        onSelected: () =>
                            setState(() => _roleFilter = null),
                      ),
                      for (final role in const [
                        Role.student,
                        Role.lecturer,
                        Role.admin,
                      ]) ...[
                        const SizedBox(width: 8),
                        AppFilterChip(
                          label: _rolePlural(role),
                          icon: _roleIcon(role),
                          selected: _roleFilter == role,
                          count: data.users
                              .where((user) => user.role == role)
                              .length,
                          onSelected: () =>
                              setState(() => _roleFilter = role),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${filtered.length} '
                        '${filtered.length == 1 ? 'user' : 'users'} found',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    if (_roleFilter != null ||
                        _searchController.text.isNotEmpty)
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear filters'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        title: 'No users found',
                        message:
                            'Try a different name, university ID, or role.',
                        actionLabel: 'Clear filters',
                        onAction: _clearFilters,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 96),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          return _UserTile(
                            user: user,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailsScreen(
                                    userId: user.id,
                                    currentUser: widget.currentUser,
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

class _UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              UserAvatar(user: user, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${user.universityId} · ${user.role.label}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        AppBadge(
                          label: user.role.label,
                          color: _roleColor(user.role),
                          icon: _roleIcon(user.role),
                        ),
                        if (!user.isActive) ...[
                          const SizedBox(width: 6),
                          const AppBadge(
                            label: 'Inactive',
                            color: AppTheme.danger,
                            icon: Icons.block,
                          ),
                        ],
                      ],
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
        ),
      ),
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  final int userId;
  final User currentUser;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final user = data.userById(userId);

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('User details')),
            body: EmptyState(
              icon: Icons.person_off_outlined,
              title: 'User not found',
              message: 'This account is no longer available.',
              actionLabel: 'Back to users',
              onAction: () => Navigator.pop(context),
            ),
          );
        }

        final isSelf = user.id == currentUser.id;
        final schoolClass = data.classForUser(user.id);
        final faculty = data.facultyForUser(user.id);

        final accountRows = <Widget>[
          InfoRow(
            icon: Icons.badge_outlined,
            label: 'University ID',
            value: user.universityId,
          ),
          InfoRow(
            icon: Icons.email_outlined,
            label: 'Email address',
            value: user.email,
          ),
          InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Role',
            value: user.role.label,
          ),
          InfoRow(
            icon: Icons.account_tree_outlined,
            label: 'Department',
            value: user.department,
          ),
          InfoRow(
            icon: user.isActive
                ? Icons.check_circle_outline
                : Icons.block,
            label: 'Account status',
            value: user.isActive ? 'Active' : 'Deactivated',
          ),
        ];

        final academicRows = <Widget>[
          if (user.role == Role.student) ...[
            InfoRow(
              icon: Icons.school_outlined,
              label: 'Faculty',
              value: faculty?.name ?? 'Not assigned',
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
          ] else
            InfoRow(
              icon: Icons.workspace_premium_outlined,
              label: 'Staff role',
              value: user.role.label,
            ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('User details'),
            actions: [
              IconButton(
                tooltip: 'Edit user',
                onPressed: () => _openEdit(context, user),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
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
                    UserAvatar(user: user, radius: 38),
                    const SizedBox(height: 12),
                    Text(
                      user.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.universityId,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      alignment: WrapAlignment.center,
                      children: [
                        AppBadge(
                          label: user.role.label,
                          color: _roleColor(user.role),
                          icon: _roleIcon(user.role),
                        ),
                        AppBadge(
                          label: user.isActive ? 'Active' : 'Inactive',
                          color: user.isActive
                              ? AppTheme.success
                              : AppTheme.danger,
                          icon: user.isActive
                              ? Icons.check_circle_outline
                              : Icons.block,
                        ),
                        if (isSelf)
                          const AppBadge(
                            label: 'This is you',
                            color: AppTheme.accent,
                            icon: Icons.person_outline,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Account information'),
              const SizedBox(height: 8),
              _DetailsCard(rows: accountRows),
              const SizedBox(height: 20),
              _SectionLabel(
                user.role == Role.student
                    ? 'Academic information'
                    : 'Staff information',
              ),
              const SizedBox(height: 8),
              _DetailsCard(rows: academicRows),
              const SizedBox(height: 24),
              if (isSelf)
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
                        Icons.lock_outline,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You cannot deactivate your own administrator '
                          'account while you are signed in.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                CustomButton(
                  label: user.isActive
                      ? 'Deactivate account'
                      : 'Activate account',
                  icon: user.isActive
                      ? Icons.block
                      : Icons.check_circle_outline,
                  variant: user.isActive
                      ? AppButtonVariant.danger
                      : AppButtonVariant.secondary,
                  onPressed: () => _toggleActive(context, user),
                ),
              const SizedBox(height: 14),
              const Text(
                'Account changes are stored in the app demonstration data. '
                'The production PHP API must enforce authorization and '
                'validation on the server.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openEdit(BuildContext context, User user) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(
          currentAdmin: currentUser,
          existing: user,
        ),
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User account updated.')),
      );
    }
  }

  Future<void> _toggleActive(BuildContext context, User user) async {
    final willActivate = !user.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          willActivate ? 'Activate account?' : 'Deactivate account?',
        ),
        content: Text(
          willActivate
              ? '${user.fullName} will be able to log in again.'
              : '${user.fullName} will no longer be able to log in. This '
                  'change is kept in the demonstration data only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: willActivate
                ? null
                : FilledButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                  ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(willActivate ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    CampusData.instance.setUserActive(user.id, willActivate);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willActivate
              ? '${user.fullName} can now log in.'
              : '${user.fullName} has been deactivated.',
        ),
      ),
    );
  }
}

class UserFormScreen extends StatefulWidget {
  final User currentAdmin;
  final User? existing;

  const UserFormScreen({
    super.key,
    required this.currentAdmin,
    this.existing,
  });

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _departmentController;

  late Role _role;
  int? _classId;
  late bool _isActive;
  bool _hidePassword = true;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final data = CampusData.instance;
    final existing = widget.existing;
    final student = existing == null
        ? null
        : data.studentForUser(existing.id);

    _nameController = TextEditingController(text: existing?.fullName ?? '');
    _idController =
        TextEditingController(text: existing?.universityId ?? '');
    _emailController = TextEditingController(text: existing?.email ?? '');
    _passwordController = TextEditingController(
      text: existing == null ? demoPassword : '',
    );
    _departmentController =
        TextEditingController(text: existing?.department ?? '');
    _role = existing?.role ?? Role.student;
    _isActive = existing?.isActive ?? true;

    if (_role == Role.student) {
      _classId = student?.classId ??
          (data.classes.isEmpty ? null : data.classes.first.id);
      if (_departmentController.text.trim().isEmpty && _classId != null) {
        _departmentController.text =
            data.classById(_classId!)?.department ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _selectRole(Role role) {
    final data = CampusData.instance;
    setState(() {
      _role = role;
      if (role == Role.student) {
        _classId ??= data.classes.isEmpty ? null : data.classes.first.id;
        if (_classId != null &&
            _departmentController.text.trim().isEmpty) {
          _departmentController.text =
              data.classById(_classId!)?.department ?? '';
        }
      }
    });
  }

  void _selectClass(int classId) {
    final schoolClass = CampusData.instance.classById(classId);
    setState(() {
      _classId = classId;
      if (schoolClass != null) {
        _departmentController.text = schoolClass.department;
      }
    });
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_role == Role.student && _classId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a class for the student.')),
      );
      return;
    }

    final data = CampusData.instance;
    final existing = widget.existing;

    if (existing == null) {
      data.addUser(
        universityId: _idController.text,
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _role,
        department: _departmentController.text,
        classId: _role == Role.student ? _classId : null,
        isActive: _isActive,
      );
      Navigator.pop(context, true);
      return;
    }

    final updated = existing.copyWith(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _role,
      department: _departmentController.text.trim(),
      isActive: _isActive,
    );

    data.updateUser(
      updated,
      classId: _role == Role.student ? _classId : null,
    );

    final refreshed = data.userById(existing.id);
    if (refreshed != null && existing.id == widget.currentAdmin.id) {
      AuthService.instance.updateCurrentUser(refreshed);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;
    final isSelf = widget.existing?.id == widget.currentAdmin.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit user' : 'Add user'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionLabel('Basic information'),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _nameController,
              label: 'Full name',
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _idController,
              label: 'University ID',
              prefixIcon: Icons.badge_outlined,
              readOnly: _isEditing,
              helperText: _isEditing
                  ? 'University IDs cannot be changed after creation.'
                  : 'For example 20240170 or LEC16',
              textInputAction: TextInputAction.next,
              validator: (value) {
                final id = value?.trim() ?? '';
                if (id.isEmpty) return 'Enter a university ID';
                if (data.isUniversityIdTaken(
                  id,
                  ignoreUserId: widget.existing?.id,
                )) {
                  return 'This university ID is already used';
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
                  return 'Enter an email address';
                }
                final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!pattern.hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 14),
              CustomTextField(
                controller: _passwordController,
                label: 'Temporary password',
                prefixIcon: Icons.lock_outline,
                obscureText: _hidePassword,
                helperText:
                    'Demonstration only. The PHP API must hash passwords '
                    'and never store plain text.',
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a temporary password';
                  }
                  if (value.length < 4) {
                    return 'Use at least 4 characters';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 20),
            const _SectionLabel('Role and academic details'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final role in const [
                  Role.student,
                  Role.lecturer,
                  Role.admin,
                ])
                  AppFilterChip(
                    label: role.label,
                    icon: _roleIcon(role),
                    selected: _role == role,
                    onSelected: () => _selectRole(role),
                  ),
              ],
            ),
            if (_role == Role.student) ...[
              const SizedBox(height: 18),
              const Text(
                'Student class',
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
                  for (final schoolClass in data.classes)
                    AppFilterChip(
                      label:
                          '${schoolClass.name} · Sem ${schoolClass.semester}',
                      icon: Icons.layers_outlined,
                      selected: _classId == schoolClass.id,
                      onSelected: () => _selectClass(schoolClass.id),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            CustomTextField(
              controller: _departmentController,
              label: 'Department',
              prefixIcon: Icons.account_tree_outlined,
              textCapitalization: TextCapitalization.words,
              helperText: _role == Role.student
                  ? 'Usually matches the student class.'
                  : null,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a department';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _isActive,
              onChanged: isSelf
                  ? null
                  : (value) => setState(() => _isActive = value),
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Account is active',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                isSelf
                    ? 'You cannot deactivate your own account.'
                    : 'Inactive users cannot log in.',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: _isEditing ? 'Save changes' : 'Create account',
              icon: _isEditing ? Icons.save_outlined : Icons.person_add_alt_1,
              onPressed: _save,
            ),
            const SizedBox(height: 14),
            const Text(
              'New accounts exist only in the app demonstration data. '
              'Production changes must be validated and authorized by the '
              'PHP API.',
              style: TextStyle(
                fontSize: 10.5,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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

class _DetailsCard extends StatelessWidget {
  final List<Widget> rows;

  const _DetailsCard({required this.rows});

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
