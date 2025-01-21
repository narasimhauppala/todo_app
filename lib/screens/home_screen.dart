import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/screens/add_todo_screen.dart';
import 'package:todoapp/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  int? _priorityFilter;
  bool? _completionFilter;

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Tasks'),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priorityFilter = null;
                      _completionFilter = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _priorityFilter == null,
                        onSelected: (selected) {
                          setState(() => _priorityFilter = null);
                        },
                      ),
                      FilterChip(
                        label: const Text('Low'),
                        selected: _priorityFilter == 0,
                        onSelected: (selected) {
                          setState(() => _priorityFilter = selected ? 0 : null);
                        },
                      ),
                      FilterChip(
                        label: const Text('Medium'),
                        selected: _priorityFilter == 1,
                        onSelected: (selected) {
                          setState(() => _priorityFilter = selected ? 1 : null);
                        },
                      ),
                      FilterChip(
                        label: const Text('High'),
                        selected: _priorityFilter == 2,
                        onSelected: (selected) {
                          setState(() => _priorityFilter = selected ? 2 : null);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _completionFilter == null,
                        onSelected: (selected) {
                          setState(() => _completionFilter = null);
                        },
                      ),
                      FilterChip(
                        label: const Text('Active'),
                        selected: _completionFilter == false,
                        onSelected: (selected) {
                          setState(() => _completionFilter = selected ? false : null);
                        },
                      ),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: _completionFilter == true,
                        onSelected: (selected) {
                          setState(() => _completionFilter = selected ? true : null);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      // Update the state when dialog is closed
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<Todo> _filterTodos(List<Todo> todos) {
    if (_priorityFilter == null && _completionFilter == null && _searchQuery.isEmpty) {
      return todos;
    }
    
    return todos.where((todo) {
      bool matchesSearch = true;
      bool matchesPriority = true;
      bool matchesCompletion = true;

      if (_searchQuery.isNotEmpty) {
        matchesSearch = todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            todo.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      if (_priorityFilter != null) {
        matchesPriority = todo.priority == _priorityFilter;
      }

      if (_completionFilter != null) {
        matchesCompletion = todo.isCompleted == _completionFilter;
      }

      return matchesSearch && matchesPriority && matchesCompletion;
    }).toList();
  }

  void _updateSearch(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Todo>('todos').listenable(),
        builder: (context, Box<Todo> box, _) {
          final allTodos = box.values.toList();
          final filteredTodos = _filterTodos(allTodos);
          final completedTodos = filteredTodos.where((todo) => todo.isCompleted).length;
          final progress = filteredTodos.isEmpty ? 0.0 : completedTodos / filteredTodos.length;

          return CustomScrollView(
        slivers: [
          SliverAppBar.large(
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
            title: const Text('My Tasks'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.primary,
                        ],
                      ),
                    ),
                  ),
                ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                    onPressed: () async {
                      final String? result = await showSearch(
                        context: context,
                        delegate: TodoSearchDelegate(
                          initialQuery: _searchQuery,
                        ),
                      );
                      if (result != null) {
                        _updateSearch(result);
                      }
                },
              ),
              IconButton(
                    icon: Badge(
                      isLabelVisible: _priorityFilter != null || _completionFilter != null,
                      child: const Icon(Icons.filter_list),
                    ),
                    onPressed: _showFilterDialog,
              ),
            ],
          ),
          SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
            child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${completedTodos} of ${filteredTodos.length} tasks completed',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final todo = filteredTodos[index];
                    return Dismissible(
                      key: Key(todo.key.toString()),
                      background: Container(
                        color: Colors.red.shade100,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete, color: Colors.red.shade700),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await NotificationService.instance.cancelNotification(todo.key);
                        await box.delete(todo.key);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${todo.title} deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  await box.add(todo);
                                  if (todo.dueDateWithTime != null) {
                                    await NotificationService.instance.scheduleTodoNotification(todo);
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              color: todo.isCompleted 
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                todo.description,
                                style: TextStyle(
                                  color: todo.isCompleted 
                                    ? Theme.of(context).colorScheme.onSurfaceVariant
                                    : null,
                                ),
                              ),
                              if (todo.dueDate != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    if (todo.dueTime != null) ...[
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        todo.dueTime!.format(context),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              color: todo.isCompleted 
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            ),
                            onPressed: () {
                              final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
                              box.put(todo.key, updatedTodo);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTodoScreen(todo: todo),
                ),
              );
            },
                        ),
                      ),
                    );
                  },
                  childCount: filteredTodos.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTodoScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class TodoSearchDelegate extends SearchDelegate<String> {
  final String initialQuery;

  TodoSearchDelegate({
    this.initialQuery = '',
  }) : super(
    searchFieldLabel: 'Search tasks',
    searchFieldStyle: const TextStyle(
      fontSize: 18,
      decorationThickness: 0,
    ),
  ) {
    query = initialQuery;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: theme.textTheme.titleLarge?.copyWith(
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showResults(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  List<Todo> _searchTodos(String query) {
    final box = Hive.box<Todo>('todos');
        final todos = box.values.toList();
    if (query.isEmpty) return todos;

    return todos.where((todo) {
      return todo.title.toLowerCase().contains(query.toLowerCase()) ||
          todo.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Widget _buildTodoList(List<Todo> todos) {
    return ListView.builder(
      itemCount: todos.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: todo.description.isNotEmpty
                ? Text(
                    todo.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            leading: Icon(
              todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: todo.isCompleted ? Theme.of(context).colorScheme.primary : null,
            ),
            trailing: todo.dueDate != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${todo.dueDate!.day}/${todo.dueDate!.month}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  )
                : null,
            onTap: () {
              close(context, query);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTodoScreen(todo: todo),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final todos = _searchTodos(query);
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }
    return _buildTodoList(todos);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final todos = _searchTodos(query);
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search your tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }
    return _buildTodoList(todos);
  }
} 