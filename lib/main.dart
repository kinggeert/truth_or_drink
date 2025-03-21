import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truth_or_drink/pages/home_page.dart';
import 'package:truth_or_drink/pages/login_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://aljcspsqzuxewfxdsobc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsamNzcHNxenV4ZXdmeGRzb2JjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4NjU4MjksImV4cCI6MjA1NzQ0MTgyOX0.Aw8F4B5ST5Q83AkvyF_wiT8qGt8kdlfhoLP_85ONQb4',
  );
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());

  runApp(const MyApp());
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder:
          (_, __) => Scaffold(appBar: AppBar(title: const Text('Home Screen'))),
      routes: [
        GoRoute(
          path: 'game',
          builder:
              (_, __) =>
                  Scaffold(appBar: AppBar(title: const Text('Details Screen'))),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple);
        ColorScheme darkScheme =
            darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            );

        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
          themeMode: ThemeMode.system,
          home:
              Supabase.instance.client.auth.currentSession != null
                  ? HomePage()
                  : LoginPage(),
        );
      },
    );
  }
}
