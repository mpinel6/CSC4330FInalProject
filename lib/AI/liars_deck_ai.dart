import 'dart:math';

class GameContext {
  final List<String> hand;
  final String tableCard;
  final int lastClaimCount;
  final int? lastPlayerId;
  final int roundNumber;

  GameContext({
    required this.hand,
    required this.tableCard,
    required this.lastClaimCount,
    this.lastPlayerId,
    this.roundNumber = 1,
  });
}

class PlayerMemory {
  final Map<int, List<int>> claimHistory = {};
  final Map<int, double> suspicionScores = {};
  final Map<int, int> lieCounts = {};
  final Map<int, int> truthCounts = {};
  final Map<int, Map<String, int>> cardClaims = {};
  final Map<int, int> correctChallenges = {};
  final Map<int, int> incorrectChallenges = {};
  final Map<int, double> emaClaims = {};
  final Map<int, double> emaBluffSuccess = {};

  void recordClaim(int playerId, String card, int count) {
    claimHistory.putIfAbsent(playerId, () => []).add(count);
    final map = cardClaims.putIfAbsent(playerId, () => {});
    map[card] = (map[card] ?? 0) + count;
    updateEMAClaim(playerId, count);
  }

  void updateEMAClaim(int playerId, int claim) {
    double prev = emaClaims[playerId] ?? claim.toDouble();
    emaClaims[playerId] = 0.8 * prev + 0.2 * claim;
  }

  double getEMAClaim(int playerId) {
    return emaClaims[playerId] ?? 1.0;
  }

  void updateBluffSuccessRate(int playerId, bool successful) {
    double previous = emaBluffSuccess[playerId] ?? 0.5;
    emaBluffSuccess[playerId] = 0.8 * previous + 0.2 * (successful ? 1.0 : 0.0);
  }

  double getBluffSuccessRate(int playerId) {
    return emaBluffSuccess[playerId] ?? 0.5;
  }

  void recordLie(int playerId) {
    suspicionScores[playerId] = (suspicionScores[playerId] ?? 0.0) + 1.0;
    lieCounts[playerId] = (lieCounts[playerId] ?? 0) + 1;
    updateBluffSuccessRate(playerId, false);
  }

  void recordTruth(int playerId) {
    suspicionScores[playerId] = (suspicionScores[playerId] ?? 0.0) - 0.5;
    truthCounts[playerId] = (truthCounts[playerId] ?? 0) + 1;
    updateBluffSuccessRate(playerId, true);
  }

  void recordChallengeResult(int playerId, bool correct) {
    final map = correct ? correctChallenges : incorrectChallenges;
    map[playerId] = (map[playerId] ?? 0) + 1;
  }

  double challengeAccuracy(int playerId) {
    final correct = correctChallenges[playerId] ?? 0;
    final incorrect = incorrectChallenges[playerId] ?? 0;
    final total = correct + incorrect;
    if (total == 0) return 0.5;
    return correct / total;
  }

  double bayesianLieProbability(int playerId) {
    int lies = lieCounts[playerId] ?? 0;
    int truths = truthCounts[playerId] ?? 0;
    int total = lies + truths;
    if (total == 0) return 0.0;
    return lies / total;
  }

  double averageClaim(int playerId) {
    final history = claimHistory[playerId];
    if (history == null || history.isEmpty) return 1.0;
    return history.reduce((a, b) => a + b) / history.length;
  }

  int cardClaimCount(int playerId, String card) {
    return cardClaims[playerId]?[card] ?? 0;
  }

  double claimBiasForCard(int playerId, String card) {
    final totalClaims = claimHistory[playerId]?.fold(0, (sum, c) => sum + c) ?? 0;
    if (totalClaims == 0) return 0.0;
    final cardClaimsCount = cardClaimCount(playerId, card);
    return cardClaimsCount / totalClaims;
  }

  void decaySuspicionScores([double factor = 0.95]) {
    suspicionScores.updateAll((key, value) => (value * factor).clamp(0.0, 5.0));
  }

  void resetMemory() {
    claimHistory.clear();
    lieCounts.clear();
    truthCounts.clear();
    cardClaims.clear();
    suspicionScores.clear();
    correctChallenges.clear();
    incorrectChallenges.clear();
    emaClaims.clear();
    emaBluffSuccess.clear();
  }
}

class LiarsDeckAI {
  final Random _rng;
  final PlayerMemory memory = PlayerMemory();

  LiarsDeckAI({Random? rng}) : _rng = rng ?? Random();

  Map<String, dynamic> decidePlay(GameContext ctx) {
    final maxClaim = min(3, ctx.hand.length);
    final bestCount = currentBestCount(ctx.hand, ctx.tableCard);
    final suspicion = (ctx.lastPlayerId != null) ? (memory.suspicionScores[ctx.lastPlayerId] ?? 0.0) : 0.0;

    if (bestCount == 0 && suspicion >= 1.5) {
      return {"action": "challenge"};
    }

    if (_shouldChallenge(ctx)) {
      return {"action": "challenge"};
    }

    final play = _decideCardPlay(ctx.hand, ctx.tableCard, ctx.roundNumber, maxClaim);

    if (ctx.lastPlayerId != null && ctx.lastClaimCount > 0) {
      memory.recordClaim(ctx.lastPlayerId!, ctx.tableCard, ctx.lastClaimCount);
    }

    return play;
  }

  bool _shouldChallenge(GameContext ctx) {
    if (ctx.lastClaimCount == 0 || ctx.lastPlayerId == null) return false;
    if (currentBestCount(ctx.hand, ctx.tableCard) > ctx.lastClaimCount) return false;

    final likelihood = _estimateTruthProbability(ctx.lastClaimCount, ctx.tableCard);
    final emaClaim = memory.getEMAClaim(ctx.lastPlayerId!);
    final suspicion = memory.suspicionScores[ctx.lastPlayerId!] ?? 0.0;
    final lieProbability = memory.bayesianLieProbability(ctx.lastPlayerId!);
    final accuracy = memory.challengeAccuracy(ctx.lastPlayerId!);

    final isSuspiciousClaim = ctx.lastClaimCount > (emaClaim + 1);
    double baseThreshold = isSuspiciousClaim ? 0.5 : 0.3;
    double adjustedThreshold = baseThreshold - (suspicion * 0.2) - (lieProbability * 0.2) + ((0.5 - accuracy) * 0.2);
    adjustedThreshold = adjustedThreshold.clamp(0.05, 0.9);

    return likelihood < adjustedThreshold;
  }

  Map<String, dynamic> _decideCardPlay(List<String> hand, String tableCard, int roundNumber, int maxClaim) {
    final bestCount = currentBestCount(hand, tableCard);
    final safePlay = min(bestCount, maxClaim);
    bool canBluff = hand.length >= 2;
    double successRate = memory.getBluffSuccessRate(-1);

    double bluffChance = _calculateBluffChance(roundNumber, safePlay, canBluff, successRate);

    final shouldBluff = safePlay == 0 || _rng.nextDouble() < bluffChance;
    final cardsToPlay = shouldBluff ? (_rng.nextInt(maxClaim) + 1) : safePlay;

    return {"action": "play", "count": cardsToPlay};
  }

  double _calculateBluffChance(int round, int safePlay, bool canBluff, double successRate) {
    if (!canBluff) return 0.0;
    double base = 0.4 + (round * 0.05);
    if (safePlay == 0) base += 0.3;
    base += (successRate - 0.5) * 0.4;
    return base.clamp(0.0, 0.95);
  }

  bool _isMatch(String card, String tableCard) {
    return card == tableCard || card == 'Joker';
  }

  double _estimateTruthProbability(int claimCount, String tableCard) {
    const pool = {'Ace': 6, 'King': 6, 'Queen': 6, 'Joker': 2};
    final total = (pool[tableCard] ?? 0) + (pool['Joker'] ?? 0);
    final ratio = claimCount / (total > 0 ? total : 1);
    return 1.0 - ratio.clamp(0.0, 1.0);
  }

  int currentBestCount(List<String> hand, String tableCard) {
    return hand.where((card) => _isMatch(card, tableCard)).length;
  }

  void recordLie(int playerId) => memory.recordLie(playerId);
  void recordTruth(int playerId) => memory.recordTruth(playerId);
  void decaySuspicionScores([double factor = 0.95]) => memory.decaySuspicionScores(factor);

  void recordChallengeOutcome(int playerId, bool wasLie) {
    if (wasLie) {
      recordLie(playerId);
    } else {
      recordTruth(playerId);
    }
    memory.recordChallengeResult(playerId, wasLie);
  }

  Map<String, dynamic> explainLastDecision(GameContext ctx) {
    return {
      'emaClaim': memory.getEMAClaim(ctx.lastPlayerId!),
      'suspicion': memory.suspicionScores[ctx.lastPlayerId] ?? 0.0,
      'lieProbability': memory.bayesianLieProbability(ctx.lastPlayerId!),
      'truthProbability': _estimateTruthProbability(ctx.lastClaimCount, ctx.tableCard),
      'challengeAccuracy': memory.challengeAccuracy(ctx.lastPlayerId!),
      'aiBluffSuccess': memory.getBluffSuccessRate(-1),
    };
  }

  void resetMemory() => memory.resetMemory();
}
