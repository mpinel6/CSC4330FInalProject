import 'dart:math';

/// Represents the current state of the game used by the AI to make a decision.
class GameContext {
  /// The cards currently held by the AI.
  final List<String> hand;

  /// The top card on the table which the player must match or bluff.
  final String tableCard;

  /// The number of cards claimed by the last player.
  final int lastClaimCount;

  /// The ID of the last player who made a move.
  final int? lastPlayerId;

  /// Current round number of the game.
  final int roundNumber;

  GameContext({
    required this.hand,
    required this.tableCard,
    required this.lastClaimCount,
    this.lastPlayerId,
    this.roundNumber = 1,
  });
}

/// Maintains memory and statistics for all players, including lie detection, truth accuracy, and claim trends.
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

  /// Tracks the AI's bluff outcomes over time.
  final List<bool> aiBluffOutcomes = [];

  /// Tracks the count of seen/played cards for estimating remaining deck distribution.
  final Map<String, int> seenCards = {};

  /// Tracks a player's card claim and updates related memory and statistics.
  void recordClaim(int playerId, String card, int count) {
    claimHistory.putIfAbsent(playerId, () => []).add(count);
    final map = cardClaims.putIfAbsent(playerId, () => {});
    map[card] = (map[card] ?? 0) + count;
    updateEMAClaim(playerId, count);
  }

  /// Updates EMA (exponential moving average) of a player's claims.
  void updateEMAClaim(int playerId, int claim) {
    double prev = emaClaims[playerId] ?? claim.toDouble();
    emaClaims[playerId] = 0.8 * prev + 0.2 * claim;
  }

  /// Gets the smoothed average of a player's claimed card counts.
  double getEMAClaim(int playerId) {
    return emaClaims[playerId] ?? 1.0;
  }

  /// Updates EMA of a player's bluff success rate.
  void updateBluffSuccessRate(int playerId, bool successful) {
    double previous = emaBluffSuccess[playerId] ?? 0.5;
    emaBluffSuccess[playerId] = 0.8 * previous + 0.2 * (successful ? 1.0 : 0.0);
  }

  /// Gets the current smoothed bluff success rate for the player.
  double getBluffSuccessRate(int playerId) {
    return emaBluffSuccess[playerId] ?? 0.5;
  }

  /// Increases suspicion and lie count for a player.
  void recordLie(int playerId) {
    suspicionScores[playerId] = (suspicionScores[playerId] ?? 0.0) + 1.0;
    lieCounts[playerId] = (lieCounts[playerId] ?? 0) + 1;
    updateBluffSuccessRate(playerId, false);
  }

  /// Decreases suspicion and increases truth count for a player.
  void recordTruth(int playerId) {
    suspicionScores[playerId] = (suspicionScores[playerId] ?? 0.0) - 0.5;
    truthCounts[playerId] = (truthCounts[playerId] ?? 0) + 1;
    updateBluffSuccessRate(playerId, true);
  }

  /// Records whether a challenge was successful or not for a player.
  void recordChallengeResult(int playerId, bool correct) {
    final map = correct ? correctChallenges : incorrectChallenges;
    map[playerId] = (map[playerId] ?? 0) + 1;
  }

  /// Records the outcome of a bluff by the AI.
  void recordAiBluffOutcome(bool success) {
    aiBluffOutcomes.add(success);
    if (aiBluffOutcomes.length > 50) {
      aiBluffOutcomes.removeAt(0);
    }
  }

  /// Logs the cards played and increments their seen count for deck estimation.
  void observePlayedCards(List<String> cards) {
    for (var card in cards) {
      seenCards[card] = (seenCards[card] ?? 0) + 1;
    }
  }

  /// Returns the accuracy ratio of a player's challenges.
  double challengeAccuracy(int playerId) {
    final correct = correctChallenges[playerId] ?? 0;
    final incorrect = incorrectChallenges[playerId] ?? 0;
    final total = correct + incorrect;
    if (total == 0) return 0.5;
    return correct / total;
  }

  /// Returns the Bayesian estimated probability that a player is lying.
  double bayesianLieProbability(int playerId) {
    int lies = lieCounts[playerId] ?? 0;
    int truths = truthCounts[playerId] ?? 0;
    int total = lies + truths;
    if (total == 0) return 0.0;
    return lies / total;
  }

  /// Returns the average of a player's claim history.
  double averageClaim(int playerId) {
    final history = claimHistory[playerId];
    if (history == null || history.isEmpty) return 1.0;
    return history.reduce((a, b) => a + b) / history.length;
  }

  /// Returns the number of times a player has claimed a specific card.
  int cardClaimCount(int playerId, String card) {
    return cardClaims[playerId]?[card] ?? 0;
  }

  /// Returns the fraction of a player's total claims that involved a specific card.
  double claimBiasForCard(int playerId, String card) {
    final totalClaims = claimHistory[playerId]?.fold(0, (sum, c) => sum + c) ?? 0;
    if (totalClaims == 0) return 0.0;
    final cardClaimsCount = cardClaimCount(playerId, card);
    return cardClaimsCount / totalClaims;
  }

  /// Returns the probability that a given claim count for a card is truthful
  /// based on how many of that card have already been seen played.
  double estimatedTruthProbability(String card, int claimedCount) {
    const fallbackDefault = 6;
    final total = _defaultDeckCount(card) ?? fallbackDefault;
    final seen = seenCards[card] ?? 0;
    final remaining = max(0, total - seen);
    final ratio = claimedCount / (remaining + 1);
    return (1.0 - ratio.clamp(0.0, 1.0));
  }

  /// Helper to return default known deck count for standard cards.
  int? _defaultDeckCount(String card) {
    const deck = {'Ace': 6, 'King': 6, 'Queen': 6, 'Joker': 2};
    return deck[card];
  }

  /// Reduces all suspicion scores by a decay factor to simulate forgetting.
  void decaySuspicionScores([double factor = 0.95]) {
    suspicionScores.updateAll((key, value) => (value * factor).clamp(0.0, 5.0));
  }

  /// Clears all memory and resets state.
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
    aiBluffOutcomes.clear();
    seenCards.clear();
  }
}
