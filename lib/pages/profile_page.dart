import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truth_or_drink/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profiel")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                try {
                  final supabase = Supabase.instance.client;
                  final response = supabase.auth.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Succesvol uitgelogd!')),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text("Uitloggen"),
            ),
          ],
        ),
      ),
    );
  }
}
