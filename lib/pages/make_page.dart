import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truth_or_drink/pages/share_page.dart';

import '../services/supabase.dart'; // Assuming you have a GamePage to start the game

class MakePage extends StatefulWidget {
  const MakePage({super.key});

  @override
  _MakePageState createState() => _MakePageState();
}

class _MakePageState extends State<MakePage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _decksFuture = fetchDecks(
      supabase.auth.currentUser!.id,
    ); // Pass userId as needed
  }

  Future<void> _makeGame(int deckId) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    try {
      // Step 1: Insert the new deck into the "Decks" table
      final gameResponse =
          await Supabase.instance.client
              .from('Games')
              .insert({'deck_id': deckId, 'host_id': userId})
              .select('id')
              .single();

      if (gameResponse.isEmpty) {
        throw Exception("Saving deck failed: empty response.");
      }

      final gameId = gameResponse['id'] as int;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Game made successfully!')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SharePage(gameId: gameId)),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving game: $e')));
    }
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
                    _makeGame(deck['id']);
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
