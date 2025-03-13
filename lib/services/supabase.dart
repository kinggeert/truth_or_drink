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
