import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/models/category.dart';
import 'package:todoapp/services/notification_service.dart';

class AddTodoScreen extends StatefulWidget {
  final Todo? todo;
  const AddTodoScreen({super.key, this.todo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _priority = 0;
  final _formKey = GlobalKey<FormState>();
  Category? _selectedCategory;

  Color get _priorityColor {
    switch (_priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
      _selectedDate = widget.todo!.dueDate;
      _selectedTime = widget.todo!.dueTime;
      _priority = widget.todo!.priority;
      _selectedCategory = widget.todo!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    final todo = widget.todo?.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate,
      dueTime: _selectedTime,
      priority: _priority,
      category: _selectedCategory,
    ) ?? Todo(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate,
      dueTime: _selectedTime,
      priority: _priority,
      category: _selectedCategory,
    );

    final box = Hive.box<Todo>('todos');
    if (widget.todo != null) {
      await box.put(widget.todo!.key, todo);
    } else {
      await box.add(todo);
    }
    
    if (todo.dueDateWithTime != null) {
      await NotificationService.instance.scheduleTodoNotification(todo);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task ${widget.todo == null ? 'added' : 'updated'} successfully'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildCategoryIcon(Category category) {
    return Icon(
      category.icon,
      color: Color(category.colorValue),
      size: 24,
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final categoryBox = Hive.box<Category>('categories');
    final categories = categoryBox.values.toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((category) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedCategory?.key == category.key
                            ? Color(category.colorValue)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCategoryIcon(category),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: Color(category.colorValue),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Task' : 'Edit Task'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: TextFormField(
                              controller: _titleController,
                              style: Theme.of(context).textTheme.titleLarge,
                              decoration: const InputDecoration(
                                hintText: 'Task Title',
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Description (optional)',
                                border: InputBorder.none,
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Task Details',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (_selectedDate != null)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = null;
                                    _selectedTime = null;
                                  });
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear Date'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.flag, color: _priorityColor),
                                title: const Text('Priority'),
                                titleAlignment: ListTileTitleAlignment.center,
                                trailing: SizedBox(
                                  width: 180,
                                  child: SegmentedButton<int>(
                                    segments: const [
                                      ButtonSegment(
                                        value: 0,
                                        icon: Icon(Icons.keyboard_arrow_down, size: 16),
                                        label: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            'Low',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      ButtonSegment(
                                        value: 1,
                                        icon: Icon(Icons.remove, size: 16),
                                        label: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            'Med',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      ButtonSegment(
                                        value: 2,
                                        icon: Icon(Icons.keyboard_arrow_up, size: 16),
                                        label: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            'High',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                    selected: {_priority},
                                    onSelectionChanged: (Set<int> newSelection) {
                                      setState(() {
                                        _priority = newSelection.first;
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(MaterialState.selected)) {
                                            return _priorityColor.withOpacity(0.2);
                                          }
                                          return null;
                                        },
                                      ),
                                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                                      visualDensity: VisualDensity.compact,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 0),
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: const Text('Due Date'),
                                trailing: TextButton.icon(
                                  icon: const Icon(Icons.edit_calendar),
                                  label: Text(
                                    _selectedDate == null
                                        ? 'Set Date'
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  ),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _selectedDate = date;
                                        if (_selectedTime == null) {
                                          _selectedTime = TimeOfDay.now();
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                              if (_selectedDate != null) ...[
                                const Divider(height: 0),
                                ListTile(
                                  leading: const Icon(Icons.access_time),
                                  title: const Text('Due Time'),
                                  trailing: TextButton.icon(
                                    icon: const Icon(Icons.schedule),
                                    label: Text(
                                      _selectedTime == null
                                          ? 'Set Time'
                                          : _selectedTime!.format(context),
                                    ),
                                    onPressed: () => _selectTime(context),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Column(
                            children: [
                              ListTile(
                                leading: _selectedCategory != null
                                    ? _buildCategoryIcon(_selectedCategory!)
                                    : const Icon(Icons.category),
                                title: const Text('Category'),
                                subtitle: _selectedCategory != null
                                    ? Text(_selectedCategory!.name)
                                    : const Text('Select a category'),
                                onTap: () => _showCategoryPicker(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: FloatingActionButton.extended(
          onPressed: _saveTodo,
          icon: const Icon(Icons.save),
          label: const Text('Save Task'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
} 