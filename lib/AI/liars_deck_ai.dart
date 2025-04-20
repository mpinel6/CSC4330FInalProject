import 'dart:math';

class LiarsDeckAI {
  final Random _rng = Random();

  /// Decide the AI's move: play X cards or challenge the previous player.
  ///
  /// [hand] - AI's hand of cards ("Ace", "King", "Queen", "Joker")
  /// [tableCard] - Declared value for the round
  /// [lastClaimCount] - Number of cards last player claimed (0 if AI goes first)
  Map<String, dynamic> decidePlay({
    required List<String> hand,
    required String tableCard,
    required int lastClaimCount,
  }) {
    final matches = hand.where((card) => card == tableCard || card == 'Joker').length;

    
    if (lastClaimCount > 0) {
      final likelihood = _estimateTruthProbability(lastClaimCount, tableCard);

      
      if (likelihood < 0.3) {
        return {"action": "challenge"};
      }
    }

    final maxClaim = min(3, hand.length);
    int safePlay = min(matches, maxClaim);

    bool bluff = safePlay == 0 || _rng.nextDouble() > 0.7;
    int cardsToPlay = bluff ? _rng.nextInt(maxClaim) + 1 : safePlay;

    return {
      "action": "play",
      "count": cardsToPlay,
    };
  }

  double _estimateTruthProbability(int claimCount, String tableCard) {
    const cardPool = {
      'Ace': 6,
      'King': 6,
      'Queen': 6,
      'Joker': 2
    };

    final total = cardPool[tableCard]! + cardPool['Joker']!;
    final ratio = claimCount / total;
    return 1.0 - ratio.clamp(0.0, 1.0);
  }
}
