import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truth_or_drink/pages/game_page.dart';

// Assuming you have a method to start the game
Future<void> startGame(int gameId) async {
  // This would be where you set the game to active, e.g., by calling Supabase API to update the game
  await Supabase.instance.client
      .from('Games')
      .update({'active': true})
      .eq('id', gameId);
}

class SharePage extends StatelessWidget {
  final int gameId; // gameId to share

  // Constructor to receive gameId
  const SharePage({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deel spel")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show the QR code representing the gameId
            Material(
              elevation: 10.0, // This adds the elevation to create the shadow
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
              shadowColor: Colors.black, // Shadow color
              child: QrImageView(
                data: "http://truthordrink.bruls/game/$gameId",
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Deel deze QR-code met je vrienden om ze toe te voegen aan het spel!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Start the game when the button is pressed
                await startGame(gameId);
                // Optionally, navigate to a new page after starting the game
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GamePage(gameId: gameId)),
                );
              },
              child: const Text("Start spel"),
            ),
          ],
        ),
      ),
    );
  }
}
