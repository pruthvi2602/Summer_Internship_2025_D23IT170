import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/profile_screen.dart';
import 'models/task.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data
  tz.initializeTimeZones();
  
  const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
  
  const InitializationSettings initializationSettings = 
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  // Request permissions for notifications
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  
  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'todo_channel',
    'ToDo Notifications',
    description: 'Notifications for upcoming tasks',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF2D3748)),
          titleTextStyle: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<Task> _tasks = [];
  final String userName = 'Pruthvi Buhecha';
  final String email = 'pruthvi@example.com';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
    _scheduleNotification(task);
  }

  void _deleteTask(int index) {
    setState(() {
      // Cancel the notification for this task before deleting
      _cancelNotification(_tasks[index]);
      _tasks.removeAt(index);
    });
  }

  void _editTask(int index, Task updatedTask) {
    setState(() {
      // Cancel the old notification
      _cancelNotification(_tasks[index]);
      _tasks[index] = updatedTask;
    });
    // Schedule new notification if task is not completed
    if (!updatedTask.isDone) {
      _scheduleNotification(updatedTask);
    }
  }

  // Generate a unique notification ID for each task
  int _generateNotificationId(Task task) {
    return task.title.hashCode ^ task.dateTime.millisecondsSinceEpoch.hashCode;
  }

  void _scheduleNotification(Task task) async {
    // Only schedule notification if task is not completed
    if (task.isDone) return;
    
    // Calculate notification time: 2 minutes before the task deadline
    final scheduledDate = task.dateTime.subtract(const Duration(minutes: 2));
    
    // Only schedule if the notification time is in the future
    if (scheduledDate.isAfter(DateTime.now())) {
      try {
        final notificationId = _generateNotificationId(task);
        
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId, // Unique ID for each task
          '⏰ Task Due Soon!',
          'Only 2 minutes left for: ${task.title}',
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'todo_channel',
              'ToDo Notifications',
              channelDescription: 'Notifications for upcoming tasks',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
              icon: '@mipmap/ic_launcher',
              color: Color(0xFF6C63FF),
              enableVibration: true,
              playSound: true,
              styleInformation: BigTextStyleInformation(''),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'default',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        
        print('Notification scheduled for: ${task.title} at ${scheduledDate.toString()}');
        
        // Show a snackbar to confirm notification scheduling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder set for ${task.title}'),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF6C63FF),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        print('Error scheduling notification: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error setting reminder: $e'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } else {
      print('Task ${task.title} is too close to deadline, notification not scheduled');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task is too close to deadline for reminder'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _cancelNotification(Task task) async {
    try {
      final notificationId = _generateNotificationId(task);
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      print('Notification cancelled for: ${task.title}');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  void _toggleTaskComplete(int index) {
    final task = _tasks[index];
    final updatedTask = Task(
      task.title,
      task.priority,
      task.dateTime,
      description: task.description,
      isDone: !task.isDone,
    );
    
    // If task is being marked as complete, cancel its notification
    if (updatedTask.isDone) {
      _cancelNotification(task);
      // Show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.title}" completed! 🎉'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      // If task is being marked as incomplete, schedule notification again
      _scheduleNotification(updatedTask);
    }
    
    setState(() {
      _tasks[index] = updatedTask;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        tasks: _tasks, 
        onDelete: _deleteTask, 
        onEdit: _editTask, 
        onToggleComplete: _toggleTaskComplete,
      ),
      AddTaskScreen(onAddTask: _addTask),
      ProfileScreen(userName: userName, email: email, tasks: _tasks)
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.add_circle_rounded, 'Add', 1),
                _buildNavItem(Icons.person_rounded, 'Profile', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}