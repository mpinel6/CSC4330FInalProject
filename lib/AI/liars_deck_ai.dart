import 'dart:math';

class LiarsDeckAI {
  final Random _rng;
  final Map<int, List<int>> playerClaimHistory = {};

  LiarsDeckAI({Random? rng}) : _rng = rng ?? Random();

  Map<String, dynamic> decidePlay({
    required List<String> hand,
    required String tableCard,
    required int lastClaimCount,
    String mode = 'standard',
    int? lastPlayerId,
    int roundNumber = 1,
  }) {
    if (_shouldPlayDevil(hand, mode)) {
      return {"action": "play", "count": 1, "special": "Devil"};
    }

    final maxClaim = (mode == 'chaos') ? 1 : min(3, hand.length);

    if (_shouldChallenge(lastClaimCount, lastPlayerId, tableCard, mode)) {
      return {"action": "challenge"};
    }

    final play = _decideCardPlay(hand, tableCard, mode, roundNumber, maxClaim);

    if (lastPlayerId != null && lastClaimCount > 0) {
      playerClaimHistory.putIfAbsent(lastPlayerId, () => []).add(lastClaimCount);
    }

    return play;
  }

  bool _shouldPlayDevil(List<String> hand, String mode) {
    return mode == 'devil' && hand.contains('Devil') && _rng.nextBool();
  }

  bool _shouldChallenge(int lastClaimCount, int? lastPlayerId, String tableCard, String mode) {
    if (lastClaimCount == 0 || lastPlayerId == null) return false;
    final likelihood = _estimateTruthProbability(lastClaimCount, tableCard, mode);
    final avgClaim = _averageClaim(lastPlayerId);
    final isSuspicious = lastClaimCount > (avgClaim + 1);
    final threshold = isSuspicious ? 0.5 : 0.3;
    return likelihood < threshold;
  }

  Map<String, dynamic> _decideCardPlay(
    List<String> hand,
    String tableCard,
    String mode,
    int roundNumber,
    int maxClaim,
  ) {
    final matches = hand.where((card) => _isMatch(card, tableCard)).length;
    final safePlay = min(matches, maxClaim);

    bool canBluff = hand.length >= 2;
    double bluffChance = canBluff ? (0.4 + (roundNumber * 0.05)) : 0.0;
    if (safePlay == 0 && canBluff) bluffChance += 0.3;

    final shouldBluff = safePlay == 0 || _rng.nextDouble() < bluffChance.clamp(0.0, 0.95);
    final cardsToPlay = shouldBluff ? _rng.nextInt(maxClaim) + 1 : safePlay;

    if (mode == 'chaos') {
      if (hand.contains('Chaos') && _rng.nextDouble() < 0.2) {
        return {"action": "play", "count": 1, "special": "Chaos"};
      }
      if (hand.contains('Master') && _rng.nextDouble() < 0.2) {
        return {"action": "play", "count": 1, "special": "Master"};
      }
    }

    return {"action": "play", "count": cardsToPlay};
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
