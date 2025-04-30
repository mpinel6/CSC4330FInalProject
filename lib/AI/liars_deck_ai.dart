import 'dart:math';

/// AI logic for the Liars Bar card game.
/// Implements decision-making for a player's turn: play honestly, bluff, or challenge.
class LiarsDeckAI {
  final Random _rng;
  final Map<int, List<int>> playerClaimHistory = {};

  LiarsDeckAI({Random? rng}) : _rng = rng ?? Random();

  /// Main AI decision-making method.
  /// 
  /// - [hand]: List of cards ('Ace', 'King', 'Queen', 'Joker').
  /// - [tableCard]: Card type that must be played.
  /// - [lastClaimCount]: Last player's claim.
  /// - [lastPlayerId]: Last player ID.
  /// - [roundNumber]: Current round number.
  Map<String, dynamic> decidePlay({
    required List<String> hand,
    required String tableCard,
    required int lastClaimCount,
    int? lastPlayerId,
    int roundNumber = 1,
  }) {
    final maxClaim = min(3, hand.length);

    if (_shouldChallenge(lastClaimCount, lastPlayerId, tableCard, hand)) {
      return {"action": "challenge"};
    }

    final play = _decideCardPlay(hand, tableCard, roundNumber, maxClaim);

    if (lastPlayerId != null && lastClaimCount > 0) {
      playerClaimHistory.putIfAbsent(lastPlayerId, () => []).add(lastClaimCount);
    }

    return play;
  }

  /// Decides whether to challenge based on hand strength and claim history.
  bool _shouldChallenge(int lastClaimCount, int? lastPlayerId, String tableCard, List<String> hand) {
    if (lastClaimCount == 0 || lastPlayerId == null) return false;
    if (currentBestCount(hand, tableCard) > lastClaimCount) return false;

    final likelihood = _estimateTruthProbability(lastClaimCount, tableCard);
    final avgClaim = _averageClaim(lastPlayerId);
    final isSuspicious = lastClaimCount > (avgClaim + 1);
    final threshold = isSuspicious ? 0.5 : 0.3;

    return likelihood < threshold;
  }

  /// Determines how many cards to play and whether to bluff.
  Map<String, dynamic> _decideCardPlay(List<String> hand, String tableCard, int roundNumber, int maxClaim) {
    final bestCount = currentBestCount(hand, tableCard);
    final safePlay = min(bestCount, maxClaim);

    bool canBluff = hand.length >= 2;
    double bluffChance = canBluff ? (0.4 + (roundNumber * 0.05)) : 0.0;
    if (safePlay == 0 && canBluff) bluffChance += 0.3;

    final shouldBluff = safePlay == 0 || _rng.nextDouble() < bluffChance.clamp(0.0, 0.95);

    // Randomize number of cards if bluffing, otherwise play best safe play.
    final cardsToPlay = shouldBluff ? (_rng.nextInt(maxClaim) + 1) : safePlay;

    return {"action": "play", "count": cardsToPlay};
  }

  /// Checks if a card matches the target card (Jokers are wild).
  bool _isMatch(String card, String tableCard) {
    return card == tableCard || card == 'Joker';
  }

  /// Estimates probability that a claim is truthful based on card distribution.
  double _estimateTruthProbability(int claimCount, String tableCard) {
    const pool = {'Ace': 6, 'King': 6, 'Queen': 6, 'Joker': 2};
    final total = (pool[tableCard] ?? 0) + (pool['Joker'] ?? 0);
    final ratio = claimCount / (total > 0 ? total : 1);
    return 1.0 - ratio.clamp(0.0, 1.0);
  }

  /// Computes a player's average historical claim.
  double _averageClaim(int playerId) {
    final history = playerClaimHistory[playerId];
    if (history == null || history.isEmpty) return 1.0;
    return history.reduce((a, b) => a + b) / history.length;
  }

  /// Computes the best amount of matching cards the AI can play.
  int currentBestCount(List<String> hand, String tableCard) {
    return hand.where((card) => _isMatch(card, tableCard)).length;
  }
}
