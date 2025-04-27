import 'package:flutter/material.dart';
import 'settings.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6F4E37), 
      appBar: AppBar(
        title: const Text(
          'Credits',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3E2723),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            CreditCategory(
              title: 'AI Design',
              names: [
                'Placeholder AI Designer 1',
                'Placeholder AI Designer 2',
              ],
            ),
            SizedBox(height: 20),
            CreditCategory(
              title: 'Multiplayer Design',
              names: [
                'Placeholder Multiplayer Designer 1',
                'Placeholder Multiplayer Designer 2',
              ],
            ),
            SizedBox(height: 20),
            CreditCategory(
              title: 'Game Design',
              names: [
                'Placeholder Game Designer 1',
                'Placeholder Game Designer 2',
              ],
            ),
            SizedBox(height: 20),
            CreditCategory(
              title: 'Graphic Art Design',
              names: [
                'Placeholder Graphic Artist 1',
                'Placeholder Graphic Artist 2',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreditCategory extends StatelessWidget {
  final String title;
  final List<String> names;

  const CreditCategory({
    super.key,
    required this.title,
    required this.names,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 8),
        ...names.map((name) => Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            )),
      ],
    );
  }
}
