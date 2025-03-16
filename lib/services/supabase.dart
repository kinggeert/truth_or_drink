import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> fetchCards(int deckId) async {
  final response = await Supabase.instance.client
      .from('Cards')
      .select()
      .eq('deck_id', deckId);
  return List<Map<String, dynamic>>.from(response);
}

Future<Map<String, dynamic>> fetchDeck(int deckId) async {
  final response =
      await Supabase.instance.client
          .from('Decks')
          .select()
          .eq('id', deckId)
          .single();
  return Map<String, dynamic>.from(response);
}

Future<List<Map<String, dynamic>>> fetchDecks(String userId) async {
  final response = await Supabase.instance.client
      .from('Decks')
      .select()
      .eq('user_id', userId);
  return List<Map<String, dynamic>>.from(response);
}

String? getCurrentUserId() {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    print("User not authenticated");
    return null;
  }
  print("Authenticated User ID: ${user.id}");
  return user.id;
}

Future<bool> deleteDeck(int deckId) async {
  try {
    final response = await Supabase.instance.client
        .from('Decks') // Replace with your table name
        .delete()
        .eq('id', deckId);

    return true; // Return true if no error
  } catch (e) {
    print("Error deleting deck: $e");
    return false;
  }
}
