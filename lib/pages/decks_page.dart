import 'package:flutter/material.dart';

class DecksPage extends StatelessWidget {
  const DecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Decks")),
      body: Center(child: Column(children: [Text("Decks page")])),
    );
  }
}
