import 'package:test/test.dart';
import '../lib/ai/liars_deck_ai.dart';

// this file will test the ai without randomness turned on
// to see if it is working properly
// randomness would be quite difficult to test so I will
// not look into that at the moment

void main() {
  // create an instance of LiarsDeckAI for testing
  // late keyword means we're declaring it later
  late LiarsDeckAI liarsDeckAI;

  setUp(() {
    // this runs before ever 'test()'

    // in this we declare liarDeckAI as a new ai without randomness
    // this give us a fresh ai for each test without having to
    // rewrite the creation in every test
    liarsDeckAI = LiarsDeckAI();
  });

  //test to check that decidePlay actually runs
  test('decidePlay can execute', () {
    List<String> thisHand = ['Ace', 'King', 'Jack', 'King', 'Joker'];
    String tableCard = 'Queen';
    Map<String, dynamic> bestPlay = liarsDeckAI.decidePlay(
        hand: thisHand, tableCard: tableCard, lastClaimCount: 2);
    print(bestPlay);
  });
}
