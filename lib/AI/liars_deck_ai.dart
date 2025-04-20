import 'dart:math';

class LiarsDeckAI {
  final Random _rng = Random();
  final Map<int, List<int>> playerClaimHistory = {}; // playerId -> list of claim counts

  /// Decide the AI's move: play X cards or challenge the previous player.
  /// [hand] - AI's hand of cards (e.g. "Ace", "King", "Queen", "Joker", "Devil", "Master", "Chaos")
  /// [tableCard] - Declared value for the round (e.g. "Ace")
  /// [lastClaimCount] - Number of cards last player claimed (0 if AI goes first)
  /// [mode] - "standard", "devil", or "chaos"
  /// [lastPlayerId] - ID of the last player who made a claim
  /// [roundNumber] - Current round number to adjust bluffing
  Map<String, dynamic> decidePlay({
    required List<String> hand,
    required String tableCard,
    required int lastClaimCount,
    String mode = 'standard',
    int? lastPlayerId,
    int roundNumber = 1,
  }) {
    final matches = hand.where((card) => _isMatch(card, tableCard)).length;

    if (mode == 'devil' && hand.contains('Devil')) {
      final playDevil = _rng.nextBool();
      if (playDevil) {
        return {"action": "play", "count": 1, "special": "Devil"};
      }
    }

    final maxClaim = (mode == 'chaos') ? 1 : min(3, hand.length);

    if (lastClaimCount > 0 && lastPlayerId != null) {
      final likelihood = _estimateTruthProbability(lastClaimCount, tableCard, mode);
      final avgClaim = _averageClaim(lastPlayerId);

      final isSuspicious = lastClaimCount > (avgClaim + 1);
      final threshold = isSuspicious ? 0.5 : 0.3;

      if (likelihood < threshold) {
        return {"action": "challenge"};
      }
    }

    int safePlay = min(matches, maxClaim);

    bool canBluff = hand.length >= 2;

    final bluffChance = canBluff ? (0.4 + (roundNumber * 0.05)) : 0.0;
    final shouldBluff = safePlay == 0 || _rng.nextDouble() < bluffChance.clamp(0.0, 0.9);
    final cardsToPlay = shouldBluff ? _rng.nextInt(maxClaim) + 1 : safePlay;

    if (mode == 'chaos') {
      if (hand.contains('Chaos') && _rng.nextDouble() < 0.2) {
        return {"action": "play", "count": 1, "special": "Chaos"};
      }
      if (hand.contains('Master') && _rng.nextDouble() < 0.2) {
        return {"action": "play", "count": 1, "special": "Master"};
      }
    }

    if (lastPlayerId != null && lastClaimCount > 0) {
      playerClaimHistory.putIfAbsent(lastPlayerId, () => []).add(lastClaimCount);
    }

    return {
      "action": "play",
      "count": cardsToPlay
    };
  }

  bool _isMatch(String card, String tableCard) {
    return card == tableCard || card == 'Joker' || card == 'Devil';
  }

  double _estimateTruthProbability(int claimCount, String tableCard, String mode) {
    const standardPool = {'Ace': 6, 'King': 6, 'Queen': 6, 'Joker': 2};
    const chaosPool = {'King': 5, 'Queen': 5, 'Chaos': 1, 'Master': 1};

    final pool = mode == 'chaos' ? chaosPool : standardPool;
    final total = (pool[tableCard] ?? 0) + (pool['Joker'] ?? 0) + (pool['Devil'] ?? 0);
    final ratio = claimCount / (total > 0 ? total : 1);
    return 1.0 - ratio.clamp(0.0, 1.0);
  }

  double _averageClaim(int playerId) {
    final history = playerClaimHistory[playerId];
    if (history == null || history.isEmpty) return 1.0;
    return history.reduce((a, b) => a + b) / history.length;
  }
}
