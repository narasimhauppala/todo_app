import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:todoapp/screens/home_screen.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/models/category.dart';
import 'package:todoapp/services/notification_service.dart';
import 'package:todoapp/services/theme_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todoapp/adapters/time_of_day_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive
    await Hive.initFlutter();
  
    // Register adapters
    if (!Hive.isAdapterRegistered(TodoAdapter().typeId)) {
      Hive.registerAdapter(TodoAdapter());
    }
    if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(TimeOfDayAdapter().typeId)) {
      Hive.registerAdapter(TimeOfDayAdapter());
    }
  
    // Open boxes
    await Hive.openBox<Todo>('todos');
    await Hive.openBox<Category>('categories');
  
    // Add default categories if none exist
    final categoryBox = Hive.box<Category>('categories');
    if (categoryBox.isEmpty) {
      await categoryBox.addAll([
        Category(
          name: 'Personal',
          colorValue: Colors.blue.value,
          iconData: Icons.person_outline.codePoint,
        ),
        Category(
          name: 'Work',
          colorValue: Colors.red.value,
          iconData: Icons.work_outline.codePoint,
        ),
        Category(
          name: 'Shopping',
          colorValue: Colors.green.value,
          iconData: Icons.shopping_cart_outlined.codePoint,
        ),
        Category(
          name: 'Health',
          colorValue: Colors.purple.value,
          iconData: Icons.favorite_outline.codePoint,
        ),
        Category(
          name: 'Education',
          colorValue: Colors.orange.value,
          iconData: Icons.school_outlined.codePoint,
        ),
        Category(
          name: 'Others',
          colorValue: Colors.grey.value,
          iconData: Icons.folder_outlined.codePoint,
        ),
      ]);
    }
  
    // Initialize notifications
    await NotificationService.instance.initializeNotifications();

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error during initialization: $e');
    // Delete Hive boxes and try again
    await Hive.deleteBoxFromDisk('todos');
    await Hive.deleteBoxFromDisk('categories');
    
    // Initialize again
    await Hive.openBox<Todo>('todos');
    await Hive.openBox<Category>('categories');
    
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.teal.shade200,
          secondary: Colors.teal.shade100,
          surface: Colors.grey.shade900,
          background: Colors.black,
          error: Colors.red.shade300,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardTheme(
          color: Colors.grey.shade900,
          elevation: 2,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal.shade200,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey.shade900,
          elevation: 8,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey.shade800,
          contentTextStyle: const TextStyle(color: Colors.white),
          actionTextColor: Colors.teal.shade200,
        ),
        dividerColor: Colors.grey.shade800,
        listTileTheme: ListTileThemeData(
          tileColor: Colors.grey.shade900,
        ),
      ),
      home: const HomeScreen(),
    );
  }
} 