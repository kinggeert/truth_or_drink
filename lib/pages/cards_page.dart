import 'package:flutter/material.dart';

import '../services/supabase.dart'; // Assuming you have this file for database operations

class CardsPage extends StatefulWidget {
  final int deckId;

  CardsPage({required this.deckId});

  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  late TextEditingController _deckNameController;
  late Future<Map<String, dynamic>> _deckFuture;
  late Future<List<Map<String, dynamic>>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _deckNameController = TextEditingController();
    _deckFuture = fetchDeck(widget.deckId);
    _cardsFuture = fetchCards(widget.deckId);
  }

  // Function to update the deck name
  Future<void> _updateDeckName() async {
    final newName = _deckNameController.text;
    final success = await updateDeckName(widget.deckId, newName);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deck name updated successfully')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update deck name')));
    }
  }

  // Function to delete a specific card
  Future<void> _deleteCard(int cardId) async {
    final success = await deleteCard(cardId);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Card deleted successfully')));
      setState(() {
        _cardsFuture = fetchCards(widget.deckId); // Refresh cards
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete card')));
    }
  }

  // Function to add a new card
  Future<void> _addCard() async {
    final newCardContent = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController _cardController = TextEditingController();
        return AlertDialog(
          title: Text('Vul inhoud in'),
          content: TextField(
            controller: _cardController,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Kaart inhoud'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Anuleren'),
            ),
            TextButton(
              onPressed: () {
                // Only close the dialog if the content is not empty
                if (_cardController.text.isNotEmpty) {
                  Navigator.pop(context, _cardController.text);
                }
              },
              child: Text('Toevoegen'),
            ),
          ],
        );
      },
    );

    if (newCardContent != null && newCardContent.isNotEmpty) {
      final success = await addCardToDeck(widget.deckId, newCardContent);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kaart succesvol toegevoegd')));
        setState(() {
          _cardsFuture = fetchCards(widget.deckId); // Refresh cards
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kaart toevoegen gefaald')));
      }
    }
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _deckFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text('Edit ${snapshot.data!['name']}');
            } else {
              return Text('Geen data gevonden');
            }
          },
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _deckFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final deck = snapshot.data!;
                _deckNameController.text = deck['name'];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _deckNameController,
                    decoration: InputDecoration(labelText: 'Deck naam'),
                    onSubmitted: (_) => _updateDeckName(),
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _cardsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final cards = snapshot.data ?? [];
                return Expanded(
                  child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return Card(
                        child: ListTile(
                          title: Text(card['content']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteCard(card['id']),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _updateDeckName,
          child: Text('Opslaan'),
        ),
      ),
    );
  }
}
