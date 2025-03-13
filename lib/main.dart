import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truth_or_drink/pages/home_page.dart';
import 'package:truth_or_drink/pages/login_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://aljcspsqzuxewfxdsobc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsamNzcHNxenV4ZXdmeGRzb2JjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4NjU4MjksImV4cCI6MjA1NzQ0MTgyOX0.Aw8F4B5ST5Q83AkvyF_wiT8qGt8kdlfhoLP_85ONQb4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:
          Supabase.instance.client.auth.currentSession != null
              ? HomePage()
              : LoginPage(),
    );
  }
}
