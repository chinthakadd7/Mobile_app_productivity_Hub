import 'package:flutter/material.dart';
import '../Services/local_storage_service.dart';
import '../Services/notification_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final LocalStorageService _storageService = LocalStorageService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadReminders();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _loadReminders() async {
    final reminders = await _storageService.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _showAddReminderDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedDateTime = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _selectDateTime();
                    setDialogState(() {});
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDateTime == null
                        ? 'Select Date & Time'
                        : '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty && _selectedDateTime != null) {
                  final reminderData = {
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'dateTime': _selectedDateTime!.toIso8601String(),
                    'isCompleted': false,
                  };
                  await _storageService.saveReminder(reminderData);
                  
                  // Schedule notification
                  final reminders = await _storageService.getReminders();
                  final notificationId = reminders.length - 1;
                  await _notificationService.scheduleNotification(
                    id: notificationId,
                    title: _titleController.text,
                    body: _descriptionController.text.isEmpty 
                        ? 'Reminder' 
                        : _descriptionController.text,
                    scheduledDate: _selectedDateTime!,
                  );
                  
                  await _loadReminders();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReminderDialog(String id, Map<String, dynamic> reminder) {
    _titleController.text = reminder['title'];
    _descriptionController.text = reminder['description'];
    _selectedDateTime = DateTime.parse(reminder['dateTime']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _selectDateTime();
                    setDialogState(() {});
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty && _selectedDateTime != null) {
                  await _storageService.updateReminder(id, {
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'dateTime': _selectedDateTime!.toIso8601String(),
                    'isCompleted': reminder['isCompleted'],
                  });
                  
                  // Reschedule notification
                  final index = _reminders.indexWhere((r) => r['id'] == id);
                  if (index != -1) {
                    await _notificationService.cancelNotification(index);
                    await _notificationService.scheduleNotification(
                      id: index,
                      title: _titleController.text,
                      body: _descriptionController.text.isEmpty 
                          ? 'Reminder' 
                          : _descriptionController.text,
                      scheduledDate: _selectedDateTime!,
                    );
                  }
                  
                  await _loadReminders();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_outlined, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first reminder',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                final dateTime = DateTime.parse(reminder['dateTime']);
                final id = reminder['id'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Checkbox(
                      value: reminder['isCompleted'] ?? false,
                      onChanged: (value) async {
                        await _storageService.updateReminder(id, {
                          ...reminder,
                          'isCompleted': value ?? false,
                        });
                        await _loadReminders();
                      },
                    ),
                    title: Text(
                      reminder['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        decoration: (reminder['isCompleted'] ?? false)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reminder['description'] != null && reminder['description'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              reminder['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.blue[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showEditReminderDialog(id, reminder);
                        } else if (value == 'delete') {
                          final index = _reminders.indexWhere((r) => r['id'] == id);
                          if (index != -1) {
                            await _notificationService.cancelNotification(index);
                          }
                          await _storageService.deleteReminder(id);
                          await _loadReminders();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}