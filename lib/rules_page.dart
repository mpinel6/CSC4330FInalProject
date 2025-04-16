import 'package:flutter/material.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Force landscape orientation
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liar's Bar Rules"),
        backgroundColor: Colors.brown[700],
      ),
      backgroundColor: Colors.brown[100],
      body: const LandscapeRulesLayout(),
    );
  }
}

class LandscapeRulesLayout extends StatelessWidget {
  const LandscapeRulesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left sidebar with navigation
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          color: Colors.brown[200],
          child: ListView(
            padding: const EdgeInsets.all(12.0),
            children: [
              const RulesSectionButton(title: "Overview", index: 0),
              const SizedBox(height: 8),
              const RulesSectionButton(title: "Setup", index: 1),
              const SizedBox(height: 8),
              const RulesSectionButton(title: "Gameplay", index: 2),
              const SizedBox(height: 8),
              const RulesSectionButton(title: "Scoring", index: 3),
              const SizedBox(height: 8),
              const RulesSectionButton(title: "Special Rules", index: 4),
              const SizedBox(height: 24),
              Image.asset(
                'assets/liars_bar_logo.png', 
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.sports_bar, size: 80, color: Colors.brown),
              ),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: const RulesContent(),
          ),
        ),
      ],
    );
  }
}

class RulesSectionButton extends StatelessWidget {
  final String title;
  final int index;

  const RulesSectionButton({
    super.key,
    required this.title,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: () {
        // Scroll to appropriate section - would implement with a ScrollController
        // in a real implementation
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RulesContent extends StatelessWidget {
  const RulesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        RulesSection(
          title: "Game Overview",
          content: "Welcome to Liar's Bar, where deception is on tap and the truth is optional! "
              "In this game of bluff and strategy, players take on the role of patrons at a shady establishment "
              "trying to outmaneuver each other through crafty deception and keen observation.\n\n"
              "The objective is to be the last player with tokens by making successful bluffs "
              "about the cards in your hand or by correctly challenging other players' claims.",
        ),
        const SizedBox(height: 24),
        RulesSection(
          title: "Setup",
          content: "• Each player starts with 10 tokens\n"
              "• Shuffle the deck of special Liar's Bar cards\n"
              "• Deal 3 cards to each player\n"
              "• Place the remaining deck face down in the center\n"
              "• The player who most recently told a lie goes first\n"
              "• Set up drinks (optional but recommended)",
        ),
        const SizedBox(height: 24),
        RulesSection(
          title: "Gameplay",
          content: "On your turn:\n\n"
              "1. Draw a card from the deck\n"
              "2. Make a claim about your hand by placing 1-3 cards face down and declaring what they are\n"
              "3. Other players can either:\n"
              "   • Call your bluff: If you were lying, you drink and lose a token. If you were truthful, they drink and lose a token\n"
              "   • Pass and let play continue to the next player\n\n"
              "4. If no one calls your bluff, add your played cards to the discard pile without revealing them\n"
              "5. Play continues clockwise\n\n"
              "Remember: You must always declare your cards as the same card type (e.g., \"Three Queens\"), "
              "but the number of cards you actually place down can vary from 1-3.",
        ),
        const SizedBox(height: 24),
        RulesSection(
          title: "Scoring",
          content: "• Last player with tokens wins the game\n"
              "• If you lose all tokens, you're out\n"
              "• Optional house rule: Players who are eliminated must finish their drink\n"
              "• Special achievements:\n"
              "   - The Honest Barkeep: Win without ever being caught in a lie\n"
              "   - The Perfect Read: Correctly call bluffs 3 times in a row\n"
              "   - The Great Deceiver: Successfully bluff 5 times in one game",
        ),
        const SizedBox(height: 24),
        RulesSection(
          title: "Special Rules",
          content: "• Wild Cards: Jokers can be played as any card\n"
              "• Last Call: When the deck is depleted, enter 'Last Call' mode where each player gets one final turn\n"
              "• Bar Tab: If all players agree, the game loser buys the next round\n"
              "• The Bartender's Favor: Once per game, you may peek at the top card of the deck\n"
              "• House Special: If you correctly call someone's bluff on a 'House Special' card, they lose 2 tokens instead of 1",
        ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown[700]!, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.brown[50],
            ),
            child: const Text(
              "Remember, in Liar's Bar, the best liars win... most of the time!",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RulesSection extends StatelessWidget {
  final String title;
  final String content;

  const RulesSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.brown[700],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.brown[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            border: Border.all(color: Colors.brown[200]!),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}