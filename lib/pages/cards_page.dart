import 'package:flutter/material.dart';

import '../services/supabase.dart'; // Assuming you have this file for database operations

class CardsPage extends StatelessWidget {
  final int deckId;

  CardsPage({required this.deckId});

  Future<void> _deleteDeck(BuildContext context) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Deck'),
            content: Text(
              'Are you sure you want to delete this deck? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      // Call your method to delete the deck from Supabase (or any service you're using)
      final success = await deleteDeck(deckId);

      if (success) {
        // If delete is successful, show a message and pop the page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deck deleted successfully')));
        Navigator.pop(context); // Pop the current page
      } else {
        // Handle failure
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete deck')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: fetchDeck(deckId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text('Cards in ${snapshot.data!['name']}');
            } else {
              return Text('No data found');
            }
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCards(deckId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final cards = snapshot.data ?? [];
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return ListTile(title: Text(card['content']));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _deleteDeck(context), // Call the delete method
        child: const Icon(Icons.delete),
      ),
    );
  }
}
