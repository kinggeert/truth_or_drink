import 'package:flutter/material.dart';
import 'package:truth_or_drink/pages/share_page.dart';

import '../services/supabase.dart'; // Assuming you have a GamePage to start the game

class MakePage extends StatefulWidget {
  const MakePage({super.key});

  @override
  _MakePageState createState() => _MakePageState();
}

class _MakePageState extends State<MakePage> {
  late Future<List<Map<String, dynamic>>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _decksFuture = fetchDecks("userId"); // Pass userId as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Make")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _decksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No decks available.'));
          } else {
            final decks = snapshot.data!;
            return ListView.builder(
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                return ListTile(
                  title: Text(deck['name'] ?? 'Unnamed Deck'),
                  onTap: () {
                    // When the user taps a deck, navigate to the game page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SharePage()),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
