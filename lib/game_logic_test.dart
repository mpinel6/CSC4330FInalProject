import 'dart:math';

//holds the result of a deal: two hands plus whatever cards remain.
class DealResult {
  final List<String> player1;
  final List<String> player2;
  final List<String> remainingDeck;

  DealResult(List<String> player1, List<String> player2, List<String> remainingDeck)
      : this.player1 = player1,
        this.player2 = player2,
        this.remainingDeck = remainingDeck;
}

class GameLogic {
  //count how many cards are selected from deck(i.e. have value == true).
  static int countSelected(Map<String, bool> selections) {
    int count = 0;
    //inspect each entry in the map
    for (String key in selections.keys) {
      bool? value = selections[key];
      if (value == true) {
        count = count + 1;
      }
    }
    return count;
  }

  /// Compare two token counts; return true only if player1 strictly has more.
  static bool player1WinsRound(int tokens1, int tokens2) {
    if (tokens1 > tokens2) {
      return true;
    } else {
      return false;
    }
  }

  static DealResult dealCards(
    List<String> deck, {
    required bool hasSecondPlayer,
    Random? random,
  }) {
    // 1) Choose which Random to use
    Random rng;
    if (random != null) {
      rng = random;
    } else {
      rng = Random();
    }

    // 2) Make a mutable copy of the deck so we don't alter the original
    List<String> workingDeck = <String>[];
    for (int i = 0; i < deck.length; i = i + 1) {
      workingDeck.add(deck[i]);
    }

    // 3) Shuffle in place
    workingDeck.shuffle(rng);

    // 4) Build player1's hand (first 5 cards or fewer if deck was small)
    List<String> hand1 = <String>[];
    int numForPlayer1 = 5;
    if (workingDeck.length < numForPlayer1) {
      numForPlayer1 = workingDeck.length;
    }
    for (int i = 0; i < numForPlayer1; i = i + 1) {
      hand1.add(workingDeck[i]);
    }

    // 5) Build player2's hand if needed (next 5 cards)
    List<String> hand2 = <String>[];
    if (hasSecondPlayer == true) {
      int startForPlayer2 = 5;
      int endForPlayer2 = 10;
      if (workingDeck.length < endForPlayer2) {
        endForPlayer2 = workingDeck.length;
      }
      for (int i = startForPlayer2; i < endForPlayer2; i = i + 1) {
        hand2.add(workingDeck[i]);
      }
    }

    // 6) Everything else goes into remainingDeck
    List<String> leftover = <String>[];
    int startForLeftover = 5;
    if (hasSecondPlayer == true) {
      startForLeftover = 10;
    }
    for (int i = startForLeftover; i < workingDeck.length; i = i + 1) {
      leftover.add(workingDeck[i]);
    }

    // 7) Return the bundled result
    DealResult result = DealResult(hand1, hand2, leftover);
    return result;
  }
}
