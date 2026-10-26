// lib/screens/shared/events_screen.dart

import 'package:flutter/material.dart';

import '../../data/sample_data.dart';
import '../../models/campus_event.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/cards.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/state_views.dart';

class EventsScreen extends StatefulWidget {
  final User user;

  const EventsScreen({super.key, required this.user});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventCategory? _filter;

  bool get _isAdmin => widget.user.role == Role.admin;

  Future<void> _openCreateForm() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => EventFormSheet(currentUser: widget.user),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final upcoming = data.upcomingEvents();
        final visible = _filter == null
            ? upcoming
            : upcoming
                .where((event) => event.category == _filter)
                .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Campus Events')),
          floatingActionButton: _isAdmin
              ? FloatingActionButton.extended(
                  onPressed: _openCreateForm,
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('New event'),
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
                        Icons.event_available_outlined,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'What is happening on campus?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${upcoming.length} upcoming '
                            '${upcoming.length == 1 ? 'event' : 'events'} for '
                            'students and staff.',
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
                      for (final category in EventCategory.values) ...[
                        const SizedBox(width: 8),
                        AppFilterChip(
                          label: category.label,
                          icon: eventCategoryIcon(category),
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
                        icon: Icons.event_busy_outlined,
                        title: _filter == null
                            ? 'No upcoming events'
                            : 'No ${_filter!.label.toLowerCase()} events',
                        message: _filter == null
                            ? 'New university events will appear here.'
                            : 'Try another category to see more events.',
                        actionLabel: _filter == null ? null : 'Show all events',
                        onAction:
                            _filter == null ? null : () => setState(() => _filter = null),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: visible.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final event = visible[index];
                          return EventCard(
                            event: event,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(
                                    eventId: event.id,
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

class EventDetailsScreen extends StatelessWidget {
  final int eventId;
  final User user;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.user,
  });

  bool get _isAdmin => user.role == Role.admin;

  @override
  Widget build(BuildContext context) {
    final data = CampusData.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        final event = _findEvent(data, eventId);

        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Event details')),
            body: EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Event not found',
              message: 'This event is no longer available.',
              actionLabel: 'Back to events',
              onAction: () => Navigator.pop(context),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Event details'),
            actions: [
              if (_isAdmin)
                PopupMenuButton<String>(
                  tooltip: 'Event actions',
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openEditForm(context, event);
                    } else if (value == 'delete') {
                      _deleteEvent(context, event);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit event'),
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
                          'Delete event',
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            eventCategoryIcon(event.category),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            event.category.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _HeaderMeta(
                      icon: Icons.calendar_month_outlined,
                      text: formatDate(event.start),
                    ),
                    const SizedBox(height: 8),
                    _HeaderMeta(
                      icon: Icons.schedule,
                      text:
                          '${formatTime(event.start)} - ${formatTime(event.end)}',
                    ),
                    const SizedBox(height: 8),
                    _HeaderMeta(
                      icon: Icons.location_on_outlined,
                      text: event.location,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'About this event',
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
                  event.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.65,
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
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: formatDate(event.start),
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.schedule,
                      label: 'Time',
                      value:
                          '${formatTime(event.start)} - ${formatTime(event.end)}',
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: event.location,
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: event.category.label,
                    ),
                    const Divider(),
                    InfoRow(
                      icon: Icons.groups_outlined,
                      label: 'Organized by',
                      value: event.organizer,
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

  static CampusEvent? _findEvent(CampusData data, int id) {
    for (final event in data.events) {
      if (event.id == id) return event;
    }
    return null;
  }

  Future<void> _openEditForm(
    BuildContext context,
    CampusEvent event,
  ) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => EventFormSheet(
        currentUser: user,
        existing: event,
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully.')),
      );
    }
  }

  Future<void> _deleteEvent(BuildContext context, CampusEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text(
          'This will remove "${event.title}" from the demonstration data.',
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

    CampusData.instance.deleteEvent(event.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted.')),
    );
    Navigator.pop(context);
  }
}

class _HeaderMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class EventFormSheet extends StatefulWidget {
  final User currentUser;
  final CampusEvent? existing;

  const EventFormSheet({
    super.key,
    required this.currentUser,
    this.existing,
  });

  @override
  State<EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<EventFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _organizerController;

  late EventCategory _category;
  late DateTime _start;
  late DateTime _end;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _locationController = TextEditingController(
      text: existing?.location ?? '',
    );
    _organizerController = TextEditingController(
      text: existing?.organizer ??
          (widget.currentUser.department.isEmpty
              ? 'Administration'
              : widget.currentUser.department),
    );
    _category = existing?.category ?? EventCategory.academic;

    final now = DateTime.now();
    _start = existing?.start ??
        DateTime(now.year, now.month, now.day, 10, 0)
            .add(const Duration(days: 1));
    _end = existing?.end ?? _start.add(const Duration(hours: 2));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime initial,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3, 12, 31),
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;

    if (!_end.isAfter(_start)) {
      setState(() => _timeError = 'End time must be after the start time.');
      return;
    }
    setState(() => _timeError = null);

    if (!formValid) return;

    final data = CampusData.instance;
    final existing = widget.existing;

    if (existing == null) {
      data.addEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        start: _start,
        end: _end,
        location: _locationController.text,
        category: _category,
        organizer: _organizerController.text,
      );
    } else {
      data.updateEvent(
        existing.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          start: _start,
          end: _end,
          location: _locationController.text.trim(),
          category: _category,
          organizer: _organizerController.text.trim(),
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
                        isEditing ? 'Edit event' : 'Create event',
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
                  label: 'Event title',
                  hintText: 'For example Cyber security seminar',
                  prefixIcon: Icons.title,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hintText: 'Tell students what to expect',
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'For example Main Auditorium',
                  prefixIcon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the event location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _organizerController,
                  label: 'Organizer',
                  hintText: 'Department or office',
                  prefixIcon: Icons.groups_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the organizer';
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
                    for (final category in EventCategory.values)
                      AppFilterChip(
                        label: category.label,
                        icon: eventCategoryIcon(category),
                        selected: _category == category,
                        onSelected: () =>
                            setState(() => _category = category),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _DateTimeField(
                  label: 'Start date and time',
                  value: _start,
                  icon: Icons.event_outlined,
                  onTap: () async {
                    final picked = await _pickDateTime(context, _start);
                    if (picked == null) return;
                    setState(() {
                      _start = picked;
                      if (!_end.isAfter(_start)) {
                        _end = _start.add(const Duration(hours: 2));
                      }
                      _timeError = null;
                    });
                  },
                ),
                const SizedBox(height: 14),
                _DateTimeField(
                  label: 'End date and time',
                  value: _end,
                  icon: Icons.event_available_outlined,
                  onTap: () async {
                    final picked = await _pickDateTime(context, _end);
                    if (picked == null) return;
                    setState(() {
                      _end = picked;
                      _timeError = null;
                    });
                  },
                ),
                if (_timeError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _timeError!,
                    style: const TextStyle(
                      color: AppTheme.danger,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                CustomButton(
                  label: isEditing ? 'Save changes' : 'Create event',
                  icon: isEditing ? Icons.save_outlined : Icons.add,
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

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(
          formatDateTime(value),
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
