import 'package:event_manager2/firebase_options.dart';
import 'package:event_manager2/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:event_manager2/evnt_manger/event_view.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
          localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ], supportedLocales: [
          Locale('en'),
          Locale('vi'),
        ], locale: Locale('vi'),
        home: HomeScreenChat());
  }
}
