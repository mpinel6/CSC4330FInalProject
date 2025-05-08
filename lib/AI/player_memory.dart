import 'dart:math';

/// Tracks statistics and memory for players in Liar's Deck, including lie detection, bluffing, and trends.
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

  final List<bool> aiBluffOutcomes = [];
  final Map<String, int> seenCards = {};

  void recordClaim(int playerId, String card, int count) {
    claimHistory.putIfAbsent(playerId, () => []).add(count);
    final claims = cardClaims.putIfAbsent(playerId, () => {});
    claims[card] = (claims[card] ?? 0) + count;
    _updateEMAClaim(playerId, count);
  }

  void _updateEMAClaim(int playerId, int claim) {
    final previous = emaClaims[playerId] ?? claim.toDouble();
    emaClaims[playerId] = 0.8 * previous + 0.2 * claim;
  }

  double getEMAClaim(int playerId) => emaClaims[playerId] ?? 1.0;

  void updateBluffSuccessRate(int playerId, bool successful) {
    final previous = emaBluffSuccess[playerId] ?? 0.5;
    emaBluffSuccess[playerId] = 0.8 * previous + 0.2 * (successful ? 1.0 : 0.0);
  }

  double getBluffSuccessRate(int playerId) => emaBluffSuccess[playerId] ?? 0.5;

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
    final targetMap = correct ? correctChallenges : incorrectChallenges;
    targetMap[playerId] = (targetMap[playerId] ?? 0) + 1;
  }

  void recordAiBluffOutcome(bool success) {
    aiBluffOutcomes.add(success);
    if (aiBluffOutcomes.length > 50) {
      aiBluffOutcomes.removeAt(0);
    }
  }

  void observePlayedCards(List<String> cards) {
    for (final card in cards) {
      seenCards[card] = (seenCards[card] ?? 0) + 1;
    }
  }

  double challengeAccuracy(int playerId) {
    final correct = correctChallenges[playerId] ?? 0;
    final incorrect = incorrectChallenges[playerId] ?? 0;
    final total = correct + incorrect;
    return total == 0 ? 0.5 : correct / total;
  }

  double bayesianLieProbability(int playerId) {
    final lies = lieCounts[playerId] ?? 0;
    final truths = truthCounts[playerId] ?? 0;
    final total = lies + truths;
    return total == 0 ? 0.0 : lies / total;
  }

  double averageClaim(int playerId) {
    final history = claimHistory[playerId];
    if (history == null || history.isEmpty) return 1.0;
    return history.reduce((a, b) => a + b) / history.length;
  }

  int cardClaimCount(int playerId, String card) => cardClaims[playerId]?[card] ?? 0;

  double claimBiasForCard(int playerId, String card) {
    final totalClaims = claimHistory[playerId]?.fold(0, (sum, count) => sum + count) ?? 0;
    if (totalClaims == 0) return 0.0;
    return cardClaimCount(playerId, card) / totalClaims;
  }

  double estimatedTruthProbability(String card, int claimedCount) {
    final total = _defaultDeckCount(card) ?? 6;
    final seen = seenCards[card] ?? 0;
    final remaining = max(0, total - seen);
    final ratio = claimedCount / (remaining + 1);
    return 1.0 - ratio.clamp(0.0, 1.0);
  }

  int? _defaultDeckCount(String card) {
    const knownDeck = {'Ace': 6, 'King': 6, 'Queen': 6, 'Joker': 2};
    return knownDeck[card];
  }

  void decaySuspicionScores([double factor = 0.95]) {
    suspicionScores.updateAll((key, score) => (score * factor).clamp(0.0, 5.0));
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
    aiBluffOutcomes.clear();
    seenCards.clear();
  }
}