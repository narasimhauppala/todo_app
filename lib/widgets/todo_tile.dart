import 'package:flutter/material.dart';
import 'package:todoapp/models/todo.dart';
import 'package:intl/intl.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Dismissible(
        key: Key(todo.key.toString()),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16.0),
          child: const Icon(Icons.delete, color: Colors.red),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          todo.delete();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) {
                todo.isCompleted = value!;
                todo.save();
              },
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(todo.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (todo.dueDate != null)
                  Chip(
                    label: Text(
                      DateFormat('MMM d').format(todo.dueDate!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.circle,
                  color: _getPriorityColor(todo.priority),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
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
} 