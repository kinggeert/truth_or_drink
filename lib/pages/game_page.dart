import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.gameId});

  final int gameId;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool isHost = false;
  bool isTurn = false;
  List<String> participants = [];
  String? currentCard;
  String? currentUserId;
  List<int> usedCardIds = [];

  @override
  void initState() {
    super.initState();
    _initializeGameState();
  }

  Future<void> _initializeGameState() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    currentUserId = user.id;

    final gameResponse =
        await Supabase.instance.client
            .from("Games")
            .select()
            .eq("id", widget.gameId)
            .single();

    final game = Map<String, dynamic>.from(gameResponse);
    isHost = (game["host_id"] == currentUserId);
    isTurn = (game["current_user_id"] == currentUserId);

    if (isHost) {
      final participantsResponse = await Supabase.instance.client
          .from("Participants")
          .select("user_id")
          .eq("game_id", widget.gameId);
      participants = List<String>.from(
        participantsResponse.map((p) => p["user_id"]),
      );

      // Include the host as a participant
      if (!participants.contains(currentUserId)) {
        participants.add(currentUserId!);
      }

      participants.shuffle(Random());
      await _nextTurn();
    } else {
      _fetchCurrentCard();
    }

    setState(() {});
  }

  Future<void> _fetchCurrentCard() async {
    final gameResponse =
        await Supabase.instance.client
            .from("Games")
            .select("current_card_id")
            .eq("id", widget.gameId)
            .single();
    final game = Map<String, dynamic>.from(gameResponse);

    if (game["current_card_id"] != null) {
      final cardResponse =
          await Supabase.instance.client
              .from("Cards")
              .select("content")
              .eq("id", game["current_card_id"])
              .single();
      currentCard = cardResponse["content"];
    }
  }

  Future<void> _nextTurn() async {
    if (participants.isEmpty) return;

    final nextUserId = participants.removeAt(0);
    participants.add(nextUserId);

    final cardResponse = await Supabase.instance.client
        .from("Cards")
        .select()
        .limit(1);

    if (cardResponse.isEmpty) return;

    final nextCard = cardResponse[0];
    final nextCardId = nextCard["id"];
    currentCard = nextCard["content"];
    usedCardIds.add(nextCardId);

    await Supabase.instance.client
        .from("Games")
        .update({"current_user_id": nextUserId, "current_card_id": nextCardId})
        .eq("id", widget.gameId);

    setState(() {
      isTurn = (nextUserId == currentUserId);
    });
  }

  void _endTurn() async {
    await Supabase.instance.client
        .from("Games")
        .update({"current_user_id": null})
        .eq("id", widget.gameId);

    setState(() => isTurn = false);
  }

  Widget _turnWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Your Card: ${currentCard ?? 'Waiting...'}"),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _endTurn, child: const Text("Done")),
      ],
    );
  }

  Widget _waitWidget() {
    return Center(child: Text("Not your turn. Waiting for others..."));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game")),
      body: isTurn ? _turnWidget() : _waitWidget(),
    );
  }
}
