import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddDeckPage extends StatefulWidget {
  const AddDeckPage({super.key});

  @override
  State<AddDeckPage> createState() => _AddDeckPageState();
}

class _AddDeckPageState extends State<AddDeckPage> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _cardControllers = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCard() {
    setState(() {
      _cardControllers.add(TextEditingController());
    });
  }

  void _removeCard(int index) {
    setState(() {
      _cardControllers[index].dispose();
      _cardControllers.removeAt(index);
    });
  }

  Future<void> _saveDeck() async {
    final deckTitle = _titleController.text;
    final cardContents = _cardControllers.map((c) => c.text).toList();
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (deckTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deck title cannot be empty')),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Step 1: Insert the new deck into the "Decks" table
      final deckResponse =
          await Supabase.instance.client
              .from('Decks')
              .insert({'name': deckTitle, 'user_id': userId})
              .select('id')
              .single();

      if (deckResponse.isEmpty) {
        throw Exception("Saving deck failed: empty response.");
      }

      final deckId = deckResponse['id'] as int;

      // Step 2: Insert the cards into the "Cards" table
      if (cardContents.isNotEmpty) {
        final cardData =
            cardContents
                .where((content) => content.isNotEmpty) // Ignore empty cards
                .map(
                  (content) => {
                    'content': content,
                    'deck_id': deckId,
                    'user_id': userId,
                  },
                )
                .toList();

        final cardResponse = await Supabase.instance.client
            .from('Cards')
            .insert(cardData);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Deck saved successfully!')));
      Navigator.pop(context); // Go back to the previous screen after saving
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving deck: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Deck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveDeck,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Deck Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _cardControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cardControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Card ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeCard(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _addCard,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Card'),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveDeck,
                  icon:
                      _isSaving
                          ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Icon(Icons.save),
                  label: const Text('Save Deck'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
