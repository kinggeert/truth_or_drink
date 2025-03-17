import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truth_or_drink/pages/share_page.dart';

import '../services/deck_history_db.dart';
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

  Future<void> _makeGame(int deckId, String deckName) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    try {
      // Save deck usage in SQLite
      await DeckHistoryDB.instance.addOrUpdateDeck(deckId, deckName);

      // Insert the new deck into the "Games" table
      final gameResponse =
          await supabase
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

            return FutureBuilder<List<int>>(
              future: DeckHistoryDB.instance.getDeckHistory(),
              builder: (context, historySnapshot) {
                if (historySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final history = historySnapshot.data ?? [];

                // Sort decks based on history order
                decks.sort((a, b) {
                  final indexA = history.indexOf(a['id']);
                  final indexB = history.indexOf(b['id']);
                  if (indexA == -1) return 1; // Unused decks go to the end
                  if (indexB == -1) return -1;
                  return indexA.compareTo(indexB);
                });

                return ListView.builder(
                  itemCount: decks.length,
                  itemBuilder: (context, index) {
                    final deck = decks[index];
                    final lastUsed = history.contains(deck['id']);
                    final subtitle = lastUsed ? 'Recently used' : 'Never used';

                    return Card(
                      child: ListTile(
                        title: Text(deck['name'] ?? 'Unnamed Deck'),
                        subtitle: Text(subtitle),
                        onTap: () => _makeGame(deck['id'], deck['name']),
                      ),
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
