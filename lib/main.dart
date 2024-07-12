import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tato/config/app_stylers.dart';
import 'package:tato/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tato/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  runApp(const MainApp());
}

final chaveDeNavegacao = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        '/aviso': (context) => const MyHomePage(
              title: 'Just Another Pomodoro Timer',
            ),
      },
      theme: ThemeData(
        fontFamily: GoogleFonts.inter().fontFamily,
        scaffoldBackgroundColor: AppStyles.primaryColor,
        primaryColor: Colors.white,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Just Another Pomodoro Timer'),
    );
  }
}
