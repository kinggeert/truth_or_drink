import 'package:flutter/material.dart';
import 'package:truth_or_drink/pages/decks_page.dart';
import 'package:truth_or_drink/pages/join_page.dart';
import 'package:truth_or_drink/pages/make_page.dart';
import 'package:truth_or_drink/pages/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(), // Remove the title from the app bar
        actions: const [], // Remove the profile button from the app bar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center content horizontally
          children: [
            // Larger title text in the center
            Text(
              "Truth Or Drink",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40), // Space between title and buttons

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinPage()),
                );
              },
              icon: const Icon(Icons.group_add), // Icon for joining
              label: const Text("Join spel"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 40,
                ),
                elevation: 5,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MakePage()),
                );
              },
              icon: const Icon(Icons.create), // Icon for making a game
              label: const Text("Host een spel"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 40,
                ),
                elevation: 5,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DecksPage()),
                );
              },
              icon: const Icon(Icons.style), // Icon for viewing decks
              label: const Text("Decks"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 40,
                ),
                elevation: 5,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 40),

            // Move profile button to a more logical place, below the buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              icon: const Icon(Icons.account_circle), // Icon for profile
              label: const Text("Profiel"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 40,
                ),
                elevation: 5,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
