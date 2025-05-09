import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 161, 159, 159),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 49, 49, 49),
        centerTitle: true,
        title: const Text(
          'Credits',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Zubilo',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(-2, -2), color: Colors.black),
              Shadow(offset: Offset(2, -2), color: Colors.black),
              Shadow(offset: Offset(-2, 2), color: Colors.black),
              Shadow(offset: Offset(2, 2), color: Colors.black),
              Shadow(offset: Offset(0, -2), color: Colors.black),
              Shadow(offset: Offset(0, 2), color: Colors.black),
              Shadow(offset: Offset(-2, 0), color: Colors.black),
              Shadow(offset: Offset(2, 0), color: Colors.black),
              Shadow(offset: Offset(-1, -1), color: Colors.black),
              Shadow(offset: Offset(1, -1), color: Colors.black),
              Shadow(offset: Offset(-1, 1), color: Colors.black),
              Shadow(offset: Offset(1, 1), color: Colors.black),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCreditSection(
                  'LAN Development',
                  [
                    'Hunter Todd',
                  ],
                ),
                const SizedBox(height: 32),
                _buildCreditSection(
                  'AI Development',
                  [
                    'Kollin Bassie',
                    'Matthew Balachowski',
                    'Christian Fullerton',
                  ],
                ),
                const SizedBox(height: 32),
                _buildCreditSection(
                  'Sound',
                  [
                    'Jacob Rodrigue',
                  ],
                ),
                const SizedBox(height: 32),
                _buildCreditSection(
                  'Digital Art & Graphics',
                  [
                    'Maycie Pinell',
                    'Julia Everett',
                  ],
                ),
                const SizedBox(height: 32),
                _buildCreditSection(
                  'Game Development',
                  [
                    'Steven Reed',
                    'Ian Waskom',
                    'Samuel Bustmante',
                    'Colby Blank',
                  ],
                ),
                const SizedBox(height: 32),
                _buildCreditSection(
                  'Special Thanks',
                  [
                    'Professor Shepherd',
                    'Monster Energy',
                    'Mike The Tiger',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditSection(String title, List<String> roles) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 49, 49, 49),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Zubilo',
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(offset: Offset(-1, -1), color: Colors.black),
                Shadow(offset: Offset(1, -1), color: Colors.black),
                Shadow(offset: Offset(-1, 1), color: Colors.black),
                Shadow(offset: Offset(1, 1), color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...roles.map((role) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  role,
                  style: const TextStyle(
                    fontFamily: 'Zubilo',
                    fontSize: 20,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(-1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, -1), color: Colors.black),
                      Shadow(offset: Offset(-1, 1), color: Colors.black),
                      Shadow(offset: Offset(1, 1), color: Colors.black),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
