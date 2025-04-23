import 'package:flutter/material.dart';
//hunter todd
//kollin bassie

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Joker's Joint Rules"),
        backgroundColor: Colors.brown[700],
      ),
      backgroundColor: Colors.brown[100],
      body: const RulesLayout(),
    );
  }
}

class RulesLayout extends StatelessWidget {
  const RulesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main content area - now takes full width
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: RulesContent(),
          ),
        ),
        
        // Bottom navigation bar
        Container(
          color: Colors.brown[200],
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: const RulesNavigation(),
        ),
      ],
    );
  }
}

class RulesNavigation extends StatelessWidget {
  const RulesNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // We need to access the RulesContent's scrolling method
    final RulesContentState? rulesContentState = 
        context.findAncestorStateOfType<RulesContentState>();
        
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RulesSectionButton(
            title: "Overview", 
            index: 0,
            onPressed: () => rulesContentState?.scrollToSection(0),
          ),
          const SizedBox(width: 10),
          RulesSectionButton(
            title: "Setup", 
            index: 1,
            onPressed: () => rulesContentState?.scrollToSection(1),
          ),
          const SizedBox(width: 10),
          RulesSectionButton(
            title: "Gameplay", 
            index: 2,
            onPressed: () => rulesContentState?.scrollToSection(2),
          ),
          const SizedBox(width: 10),
          RulesSectionButton(
            title: "Lives", 
            index: 3,
            onPressed: () => rulesContentState?.scrollToSection(3),
          ),
          const SizedBox(width: 10),
          RulesSectionButton(
            title: "Special Rules", 
            index: 4,
            onPressed: () => rulesContentState?.scrollToSection(4),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.casino, size: 32, color: Colors.brown),
            onPressed: () => rulesContentState?._scrollToTop(),
            tooltip: 'Back to top',
          ),
        ],
      ),
    );
  }
}

class RulesSectionButton extends StatelessWidget {
  final String title;
  final int index;
  final VoidCallback? onPressed;

  const RulesSectionButton({
    super.key,
    required this.title,
    required this.index,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RulesContent extends StatefulWidget {
  const RulesContent({super.key});
  
  @override
  State<RulesContent> createState() => RulesContentState();
}

class RulesContentState extends State<RulesContent> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());
  bool _showBackToTop = false; // Track whether to show back to top button
  
  @override
  void initState() {
    super.initState();
    // Add scroll listener to show/hide back to top button
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300 && !_showBackToTop) {
        setState(() {
          _showBackToTop = true;
        });
      } else if (_scrollController.offset < 300 && _showBackToTop) {
        setState(() {
          _showBackToTop = false;
        });
      }
    });
  }
  
  void scrollToSection(int index) {
    if (index < _sectionKeys.length) {
      final context = _sectionKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }
  
  // Add method to scroll back to top
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          children: [
            RulesSection(
              key: _sectionKeys[0],
              title: "Game Overview",
              content: "Welcome to Joker's Joint, where bluffing is an art and deception pays! "
                  "In this retro-styled game of strategy and deceit, players take on the role of card sharks "
                  "trying to outwit each other through masterful bluffing and keen observation.\n\n"
                  "The objective is to be the last player standing by protecting your lives while "
                  "successfully calling out other players' bluffs or making convincing bluffs of your own.",
            ),
            const SizedBox(height: 24),
            RulesSection(
              key: _sectionKeys[1],
              title: "Setup",
              content: "• Use a special deck of just 20 cards consisting of:\n"
                  "   - 6 Aces\n"
                  "   - 6 Kings\n"
                  "   - 6 Queens\n"
                  "   - 2 Jokers\n\n"
                  "• The game is designed for 4 players\n"
                  "• Each player starts with 3 lives\n"
                  "• Deal 5 cards to each player\n"
                  "• Choose a starting player randomly",
            ),
            const SizedBox(height: 24),
            RulesSection(
              key: _sectionKeys[2],
              title: "Gameplay",
              content: "On your turn:\n\n"
                  "1. Make a claim about one or more cards from your hand\n"
                  "2. Place these cards face down in the center\n"
                  "3. Other players can either:\n"
                  "   • Call your bluff: If you were lying, you lose a life. If you were telling the truth, the challenger loses a life\n"
                  "   • Pass and let play continue to the next player\n\n"
                  "4. If no one calls your bluff, add your played cards to the discard pile without revealing them\n"
                  "5. Draw replacement cards if available\n"
                  "6. Play continues clockwise\n\n"
                  "The game consists of 3 rounds. If multiple players still have lives at the end of the third round, reshuffle the deck and continue until only one player remains.",
            ),
            const SizedBox(height: 24),
            RulesSection(
              key: _sectionKeys[3],
              title: "Lives & Elimination",
              content: "• Each player begins with 3 lives\n"
                  "• Lose a life when:\n"
                  "   - You're caught in a lie (placing cards that don't match your claim)\n"
                  "   - You incorrectly challenge another player's claim\n\n"
                  "• When you lose all 3 lives, you're eliminated from the game\n"
                  "• The last player with any lives remaining wins the game\n"
                  "• If multiple players are still alive after 3 rounds, continue playing until there's a single winner",
            ),
            const SizedBox(height: 24),
            RulesSection(
              key: _sectionKeys[4],
              title: "Special Rules",
              content: "• Joker's Rule: Jokers are wild cards and can be played as any card type (Ace, King, or Queen)\n"
                  "• Final Countdown: When the deck runs out, everyone gets one last turn to try to eliminate opponents\n"
                  "• Bluff Master: If you successfully make 3 bluffs in a row without being challenged, you gain an extra life (max 3)\n"
                  "• Card Counter: You may look through the discard pile once per round",
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown[700]!, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.amber[50],
                ),
                child: const Text(
                  "Remember, at Joker's Joint, it's not whether you win or lose... it's how well you deceive!",
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Add extra space at bottom
            const SizedBox(height: 30),
          ],
        ),
        // Back to top floating action button with animation
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom: _showBackToTop ? 20 : -60,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.brown[700],
            onPressed: _scrollToTop,
            mini: true,
            tooltip: 'Back to top',
            child: const Icon(Icons.arrow_upward, color: Colors.white),
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