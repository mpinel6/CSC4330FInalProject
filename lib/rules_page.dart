import 'package:flutter/material.dart';
import "settings.dart";
import "main.dart";
//hunter todd
//kollin bassie

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  int _selectedIndex = 1; // Rules tab

  void _onItemTapped(int index) {
    if (index == 0) {
      // Go to Home, pop until root
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      // Already on Rules, do nothing
    } else if (index == 2) {
      // Go to Settings, replace current page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Joker's Joint Rules",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Zubilo',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: textShadows,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 49, 49, 49),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 161, 159, 159),
      body: const RulesLayout(),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Image.asset(
      //         'assets/images/Beer.png',
      //         width: 35,
      //         height: 35,
      //       ),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Image.asset(
      //         'assets/images/Question.png',
      //         width: 35,
      //         height: 35,
      //       ),
      //       label: 'Rules',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Image.asset(
      //         'assets/images/Settings.png',
      //         width: 35,
      //         height: 35,
      //       ),
      //       label: 'Settings',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: const Color(0xFF232323),
      //   unselectedItemColor: const Color(0xFFB0B0B0),
      //   backgroundColor: const Color(0xFFD6D6D6),
      //   selectedLabelStyle: const TextStyle(
      //     fontFamily: 'Zubilo',
      //     fontWeight: FontWeight.bold,
      //     fontSize: 14,
      //   ),
      //   unselectedLabelStyle: const TextStyle(
      //     fontFamily: 'Zubilo',
      //     fontSize: 14,
      //   ),
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

// Add this global key to access the RulesContent state
final GlobalKey<RulesContentState> rulesContentKey =
    GlobalKey<RulesContentState>();

class RulesLayout extends StatelessWidget {
  const RulesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: RulesContent(key: rulesContentKey),
    );
  }
}

class RulesNavigation extends StatelessWidget {
  const RulesNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the global key to access the state directly - no need for findAncestorStateOfType
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RulesSectionButton(
            title: "Overview",
            index: 0,
            onPressed: () => rulesContentKey.currentState?.scrollToSection(0),
          ),
          const SizedBox(width: 10),
          RulesSectionButton(
            title: "Setup",
            index: 1,
            onPressed: () => rulesContentKey.currentState?.scrollToSection(1),
          ),
          const SizedBox(width: 10),
          RulesSectionButton(
            title: "Gameplay",
            index: 2,
            onPressed: () => rulesContentKey.currentState?.scrollToSection(2),
          ),
          const SizedBox(width: 10),
          RulesSectionButton(
            title: "Lives",
            index: 3,
            onPressed: () => rulesContentKey.currentState?.scrollToSection(3),
          ),
          const SizedBox(width: 10),
          RulesSectionButton(
            title: "Special Rules",
            index: 4,
            onPressed: () => rulesContentKey.currentState?.scrollToSection(4),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.casino, size: 32, color: Colors.brown),
            onPressed: () => rulesContentKey.currentState?._scrollToTop(),
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
        backgroundColor: Colors.brown[50],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
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
              content:
                  "Welcome to Joker's Joint, where bluffing is an art and deception pays! "
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
                  "• The game is designed for 2 players\n"
                  "• Each player starts with 3 lives\n"
                  "• Deal 5 cards to each player\n"
                  "• Choose a starting player randomly",
            ),
            const SizedBox(height: 24),
            RulesSection(
              key: _sectionKeys[2],
              title: "Gameplay",
              content: "On your turn:\n\n"
                  "1. Make a claim about up to three cards from your hand\n"
                  "2. Place these cards face down in the center\n"
                  "3. Your opponent can either:\n"
                  "   • Call your bluff: If you were lying, you lose a life. If you were telling the truth, the challenger loses a life\n"
                  "   • Pass and let play continue to the opponent\n\n"
                  "4. If no one calls your bluff, add your played cards to the discard pile without revealing them\n"
                  "5. Draw replacement cards when out of cards\n"
                  "6. Play alternates between players\n\n"
                  "7. The game consists of 3 rounds. A round ends when a player loses all three lives. After each round, the table card is changed. The first player to win 2 rounds wins the game.\n\n",
            ),
            const SizedBox(height: 24),
            RulesSection(
                key: _sectionKeys[3],
                title: "Lives & Elimination",
                content: "• Each player begins with 3 lives\n"
                    "• Lose a life when:\n"
                    "   - You're caught in a lie (placing cards that don't match your claim)\n"
                    "   - You incorrectly challenge another player's claim\n\n"
                    "• When you lose all 3 lives, your opponent wins that round\n"),
            const SizedBox(height: 24),
            RulesSection(
              key: _sectionKeys[4],
              title: "Special Rules",
              content:
                  "• Joker's Rule: Jokers are wild cards and can be played as any card type (Ace, King, or Queen)\n",
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 49, 49, 49), width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: const Text(
                  "Remember, at Joker's Joint, it's not whether you win or lose... it's how well you deceive!",
                  style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 49, 49, 49),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Zubilo'),
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
            backgroundColor: const Color.fromARGB(255, 49, 49, 49),
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
            color: const Color.fromARGB(255, 49, 49, 49),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
                fontFamily: 'Zubilo',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: textShadows),
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
