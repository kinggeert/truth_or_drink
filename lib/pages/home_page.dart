import 'package:flutter/material.dart';
import 'package:truth_or_drink/pages/join_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MEXICANO")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ik wil een mexicano"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinPage()),
                );
              },
              child: Text("Join game"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                print("Button 2 Pressed");
              },
              child: Text("Make a game"),
            ),
          ],
        ),
      ),
    );
  }
}
