import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.gameId});
  final int gameId;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int? deckId;
  bool isHost = false;
  bool isTurn = false;
  List<String> participants = [];
  String? currentCard;
  String? currentUserId;
  List<int> usedCardIds = [];
  RealtimeChannel? _channel;

  // Banner ad variables
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeGameState();
    _subscribeToGameUpdates();
    _loadBannerAd();
  }

  // Load the banner ad using Google Mobile Ads
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Replace with your actual ad unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('BannerAd failed to load: ${error.message}');
        },
      ),
    );
    _bannerAd!.load();
  }

  Future<void> _initializeGameState() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    currentUserId = user.id;

    try {
      final gameResponse =
          await Supabase.instance.client
              .from("Games")
              .select()
              .eq("id", widget.gameId)
              .single();

      final game = Map<String, dynamic>.from(gameResponse);
      isHost = (game["host_id"] == currentUserId);
      isTurn = (game["current_user_id"] == currentUserId);
      deckId = game["deck_id"];

      if (isHost) {
        final participantsResponse = await Supabase.instance.client
            .from("Participants")
            .select("user_id")
            .eq("game_id", widget.gameId);
        participants = List<String>.from(
          participantsResponse.map((p) => p["user_id"]),
        );

        // Include the host as a participant if not already included.
        if (!participants.contains(currentUserId)) {
          participants.add(currentUserId!);
        }

        participants.shuffle(Random());
        await _nextTurn();
      } else {
        _fetchCurrentCard();
      }
      setState(() {});
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Code invalid."),
              content: const Text("De QR-code bevat geen valide spelcode."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // First pop
                    Navigator.pop(context); // Second pop
                  },
                  child: const Text("Ok"),
                ),
              ],
            ),
      );
    }
  }

  // Subscribe to realtime changes on the Games table.
  void _subscribeToGameUpdates() {
    _channel =
        Supabase.instance.client
            .channel('public:Games')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'Games',
              callback: (payload) async {
                print('Change received: ${payload.toString()}');
                final updatedGame = payload.newRecord;
                if (updatedGame != null) {
                  final cardId = updatedGame["current_card_id"];
                  if (cardId != null) {
                    // Fetch the card content using the card id.
                    final cardResponse =
                        await Supabase.instance.client
                            .from("Cards")
                            .select("content")
                            .eq("id", cardId)
                            .single();
                    final card = Map<String, dynamic>.from(cardResponse);
                    setState(() {
                      currentCard = card["content"];
                      isTurn =
                          (updatedGame["current_user_id"] == currentUserId);
                    });
                  } else {
                    setState(() {
                      isTurn =
                          (updatedGame["current_user_id"] == currentUserId);
                    });
                  }
                  // If the game indicates a turn has ended (current_user_id is null)
                  // and this client is the host, trigger the next turn.
                  if (updatedGame["current_user_id"] == null && isHost) {
                    _nextTurn();
                  }
                }
              },
            )
            .subscribe();
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
      final card = Map<String, dynamic>.from(cardResponse);
      currentCard = card["content"];
    }
  }

  Future<void> _nextTurn() async {
    if (participants.isEmpty) return;

    final nextUserId = participants.removeAt(0);
    participants.add(nextUserId);

    final cardResponse = await Supabase.instance.client
        .from("Cards")
        .select("id, content")
        .eq("deck_id", deckId!);

    if (cardResponse == null || cardResponse.isEmpty) {
      print('Error: Geen kaarten gevonden.');
      return;
    }

    final availableCards = List<Map<String, dynamic>>.from(cardResponse);
    final unusedCards =
        availableCards
            .where((card) => !usedCardIds.contains(card['id']))
            .toList();

    if (unusedCards.isEmpty) {
      print('Geen kaarten meer beschikbaar.');
      return;
    }

    final nextCard = (unusedCards..shuffle()).first;
    final nextCardId = nextCard["id"];
    currentCard = nextCard["content"];
    usedCardIds.add(nextCardId);

    await Supabase.instance.client.from("Games").upsert({
      "id": widget.gameId,
      "current_user_id": nextUserId,
      "current_card_id": nextCardId,
    });

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
        Material(
          elevation: 10.0, // This adds the elevation to create the shadow
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          shadowColor: Colors.black, // Shadow color
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Het is jouw beurt om een vraag te stellen!"),
                subtitle: Text(currentCard ?? 'Wachten...'),
              ),

              ElevatedButton(onPressed: _endTurn, child: const Text("Klaar")),
            ],
          ),
        ),
      ],
    );
  }

  // When not your turn, show waiting text plus the banner ad.
  Widget _waitWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Het is niet jouw beurt..."),
          const SizedBox(height: 20),
          if (_isAdLoaded && _bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spel")),
      body: isTurn ? _turnWidget() : _waitWidget(),
    );
  }
}
