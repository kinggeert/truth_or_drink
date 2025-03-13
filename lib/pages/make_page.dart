import 'package:flutter/material.dart';
import 'package:truth_or_drink/pages/share_page.dart';

class MakePage extends StatelessWidget {
  const MakePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Make")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SharePage()),
                );
              },
              child: Text("Share"),
            ),
          ],
        ),
      ),
    );
  }
}
