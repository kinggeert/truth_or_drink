import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truth_or_drink/pages/game_page.dart';

class JoinPage extends StatelessWidget {
  const JoinPage({super.key});

  int _joinGame(String? url) {
    if (url == null) {
      return -1;
    }
    if (!url.contains("http://truthordrink.bruls/game/")) {
      return -1;
    }

    try {
      final gameId = int.parse(
        url.replaceFirst("http://truthordrink.bruls/game/", ""),
      );

      _insertGame(gameId);

      return gameId;
    } catch (e) {
      print('Error: $e');
      return -1;
    }
  }

  Future<void> _insertGame(int gameId) async {
    // Get the current user's ID from Supabase
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return; // User is not logged in
    }

    // Insert the user into the Participants table in Supabase
    final response = await Supabase.instance.client.from('Participants').upsert(
      {'game_id': gameId, 'user_id': user.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join")),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (capture) {
          final gameId = _joinGame(capture.barcodes.first.url?.url);
          if (gameId == -1) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text("Code invalid."),
                    content: Text(
                      "The QR-code you scanned does not contain a valid game code.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text("Ok"),
                      ),
                    ],
                  ),
            );
            return;
          }
          HapticFeedback.vibrate();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GamePage(gameId: gameId)),
          );
        },
      ),
    );
  }
}
