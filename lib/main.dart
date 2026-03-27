import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'home_screen.dart';
import 'screens/kidus_yared_screen.dart';
import 'screens/about_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/search_screen.dart';
import 'providers/app_settings_provider.dart';
import 'about_zema_screen.dart';
import 'about_amharic_letters_screen.dart';
import 'launch_decider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize the database
  await DBHelper.instance.database;

  // Configure system UI
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A192F),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettingsProvider(),
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'ፍኖተ ያሬድ',
            debugShowCheckedModeBanner: false,
            theme: settings.theme,
            home: const LaunchDecider(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/kidus-yared': (context) => const KidusYaredScreen(),
              '/about': (context) => const AboutScreen(),
              '/contact': (context) => const ContactScreen(),
              '/search': (context) => const SearchScreen(),
              '/about-zema': (context) => const AboutZemaScreen(),
              '/about-amharic-letters':
                  (context) => const AboutAmharicLettersScreen(),
            },
            builder: (context, child) {
              final mediaQuery = MediaQuery.maybeOf(context);
              if (mediaQuery == null) {
                return child ?? const SizedBox.shrink();
              }
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(settings.textSize / 16.0),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
