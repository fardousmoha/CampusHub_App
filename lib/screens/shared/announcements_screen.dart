// lib/screens/shared/announcements_screen.dart

import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/announcement.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/cards.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/state_views.dart';

class AnnouncementsScreen extends StatefulWidget {
  final User user;

  const AnnouncementsScreen({super.key, required this.user});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  AnnouncementCategory? _filter;

  bool get _isAdmin => widget.user.role == Role.admin;

  Future<void> _openCreateForm() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AnnouncementFormSheet(
        currentUser: widget.user,
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement published.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final all = data.announcementsForList();
        final visible = _filter == null
            ? all
            : all.where((item) => item.category == _filter).toList();
        final important = all.where((item) => item.isImportant).length;

        return Scaffold(
          appBar: AppBar(title: const Text('Announcements')),
          floatingActionButton: _isAdmin
              ? FloatingActionButton.extended(
                  onPressed: _openCreateForm,
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('New announcement'),
                )
              : null,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
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
                        Icons.campaign_outlined,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Updates from your university',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${all.length} announcements · '
                            '$important marked important',
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
                        icon: Icons.apps,
                        selected: _filter == null,
                        onSelected: () => setState(() => _filter = null),
                      ),
                      for (final category in AnnouncementCategory.values) ...[
                        const SizedBox(width: 8),
                        AppFilterChip(
                          label: category.label,
                          icon: announcementCategoryIcon(category),
                          selected: _filter == category,
                          onSelected: () =>
                              setState(() => _filter = category),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: visible.isEmpty
                    ? EmptyState(
                        icon: Icons.campaign_outlined,
                        title: _filter == null
                            ? 'No announcements yet'
                            : 'No ${_filter!.label.toLowerCase()} announcements',
                        message: _filter == null
                            ? 'University updates will appear here.'
                            : 'Try another category to see more updates.',
                        actionLabel:
                            _filter == null ? null : 'Show all announcements',
                        onAction:
                            _filter == null ? null : () => setState(() => _filter = null),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: visible.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final announcement = visible[index];
                          return AnnouncementCard(
                            announcement: announcement,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AnnouncementDetailsScreen(
                                    announcementId: announcement.id,
                                    user: widget.user,
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

class AnnouncementDetailsScreen extends StatelessWidget {
  final int announcementId;
  final User user;

  const AnnouncementDetailsScreen({
    super.key,
    required this.announcementId,
    required this.user,
  });

  bool get _isAdmin => user.role == Role.admin;

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final announcement = _findAnnouncement(data, announcementId);

        if (announcement == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Announcement')),
            body: EmptyState(
              icon: Icons.campaign_outlined,
              title: 'Announcement not found',
              message: 'This announcement is no longer available.',
              actionLabel: 'Back to announcements',
              onAction: () => Navigator.pop(context),
            ),
          );
        }

        final categoryColor =
            announcementCategoryColor(announcement.category);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Announcement'),
            actions: [
              if (_isAdmin)
                PopupMenuButton<String>(
                  tooltip: 'Announcement actions',
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openEditForm(context, announcement);
                    } else if (value == 'delete') {
                      _deleteAnnouncement(context, announcement);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit announcement'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline,
                          color: AppTheme.danger,
                        ),
                        title: Text(
                          'Delete announcement',
                          style: TextStyle(color: AppTheme.danger),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppBadge(
                    label: announcement.category.label,
                    color: categoryColor,
                    icon: announcementCategoryIcon(announcement.category),
                  ),
                  if (announcement.isImportant)
                    const AppBadge(
                      label: 'Important',
                      color: AppTheme.danger,
                      icon: Icons.priority_high_rounded,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_outlined,
                    size: 15,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      announcement.author,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    formatDate(announcement.publishedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              if (announcement.isImportant) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppTheme.danger.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.priority_high_rounded,
                        size: 20,
                        color: AppTheme.danger,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'This is an important announcement. Please read the '
                          'full message carefully.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.danger,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  announcement.message,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
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
                      icon: Icons.account_balance_outlined,
                      label: 'Published by',
                      value: announcement.author,
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Publication date',
                      value: formatDateTime(announcement.publishedAt),
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: announcement.category.label,
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.flag_outlined,
                      label: 'Priority',
                      value: announcement.isImportant ? 'Important' : 'Normal',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static Announcement? _findAnnouncement(CampusData data, int id) {
    for (final announcement in data.announcements) {
      if (announcement.id == id) return announcement;
    }
    return null;
  }

  Future<void> _openEditForm(
    BuildContext context,
    Announcement announcement,
  ) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AnnouncementFormSheet(
        currentUser: user,
        existing: announcement,
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement updated.')),
      );
    }
  }

  Future<void> _deleteAnnouncement(
    BuildContext context,
    Announcement announcement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete announcement?'),
        content: Text(
          'This will remove "${announcement.title}" from the demonstration '
          'data.',
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

    CampusData.instance.deleteAnnouncement(announcement.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement deleted.')),
    );
    Navigator.pop(context);
  }
}

class AnnouncementFormSheet extends StatefulWidget {
  final User currentUser;
  final Announcement? existing;

  const AnnouncementFormSheet({
    super.key,
    required this.currentUser,
    this.existing,
  });

  @override
  State<AnnouncementFormSheet> createState() =>
      _AnnouncementFormSheetState();
}

class _AnnouncementFormSheetState extends State<AnnouncementFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  late final TextEditingController _authorController;

  late AnnouncementCategory _category;
  late bool _isImportant;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _messageController = TextEditingController(text: existing?.message ?? '');
    _authorController = TextEditingController(
      text: existing?.author ??
          (widget.currentUser.department.isEmpty
              ? widget.currentUser.fullName
              : widget.currentUser.department),
    );
    _category = existing?.category ?? AnnouncementCategory.academic;
    _isImportant = existing?.isImportant ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = CampusData.instance;
    final existing = widget.existing;

    if (existing == null) {
      data.addAnnouncement(
        title: _titleController.text,
        message: _messageController.text,
        author: _authorController.text,
        category: _category,
        isImportant: _isImportant,
      );
    } else {
      data.updateAnnouncement(
        existing.copyWith(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          author: _authorController.text.trim(),
          category: _category,
          isImportant: _isImportant,
        ),
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

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
                        isEditing
                            ? 'Edit announcement'
                            : 'Create announcement',
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
                  controller: _titleController,
                  label: 'Title',
                  hintText: 'A short, clear headline',
                  prefixIcon: Icons.title,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the announcement title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _messageController,
                  label: 'Full message',
                  hintText: 'Write the complete announcement here',
                  maxLines: 7,
                  minLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the announcement message';
                    }
                    if (value.trim().length < 20) {
                      return 'Write at least 20 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _authorController,
                  label: 'Author or department',
                  hintText: 'For example Examinations Office',
                  prefixIcon: Icons.account_balance_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the author or department';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'Category',
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
                    for (final category in AnnouncementCategory.values)
                      AppFilterChip(
                        label: category.label,
                        icon: announcementCategoryIcon(category),
                        selected: _category == category,
                        onSelected: () =>
                            setState(() => _category = category),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _isImportant,
                  onChanged: (value) =>
                      setState(() => _isImportant = value),
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Mark as important',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Important announcements are highlighted and shown first.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: isEditing
                      ? 'Save changes'
                      : 'Publish announcement',
                  icon: isEditing ? Icons.save_outlined : Icons.send_outlined,
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
