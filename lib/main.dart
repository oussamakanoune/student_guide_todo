import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/todo_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Notifications ──
  await NotificationService().initialize();
  await NotificationService().requestPermission();

  // Lock to portrait orientation for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const StudentGuideApp());
}

class StudentGuideApp extends StatelessWidget {
  const StudentGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Student Guide – Tasks',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const TodoScreen(),
          );
        },
      ),
    );
  }
}