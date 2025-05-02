import 'dart:math';
import 'game_context.dart';
import 'player_memory.dart';

/// The core AI class responsible for deciding whether to play or challenge in Liar's Deck.
class LiarsDeckAI {
  final Random _rng;
  final PlayerMemory memory = PlayerMemory();

  LiarsDeckAI({Random? rng}) : _rng = rng ?? Random();

  /// Makes a decision based on the current game context: play or challenge.
  Map<String, dynamic> decidePlay(GameContext ctx) {
    final maxClaim = min(3, ctx.hand.length);
    final bestCount = _currentBestCount(ctx.hand, ctx.tableCard);
    final suspicion = (ctx.lastPlayerId != null)
        ? (memory.suspicionScores[ctx.lastPlayerId] ?? 0.0)
        : 0.0;

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

  /// Determines whether to challenge the last player's claim.
  bool _shouldChallenge(GameContext ctx) {
    if (ctx.lastClaimCount == 0 || ctx.lastPlayerId == null) return false;
    if (_currentBestCount(ctx.hand, ctx.tableCard) > ctx.lastClaimCount) return false;

    final likelihood = memory.estimatedTruthProbability(ctx.tableCard, ctx.lastClaimCount);
    final avgClaim = memory.getEMAClaim(ctx.lastPlayerId!);
    final suspicion = memory.suspicionScores[ctx.lastPlayerId!] ?? 0.0;
    final lieProbability = memory.bayesianLieProbability(ctx.lastPlayerId!);
    final accuracy = memory.challengeAccuracy(ctx.lastPlayerId!);

    final isSuspicious = ctx.lastClaimCount > (avgClaim + 1);
    double threshold = (isSuspicious ? 0.5 : 0.3)
        - suspicion * 0.2
        - lieProbability * 0.2
        + (0.5 - accuracy) * 0.2;
    threshold = threshold.clamp(0.05, 0.9);

    return likelihood < threshold;
  }

  /// Determines how many cards to play or if a bluff is needed.
  Map<String, dynamic> _decideCardPlay(List<String> hand, String tableCard, int round, int maxClaim) {
    final matchCount = _currentBestCount(hand, tableCard);
    final safePlay = min(matchCount, maxClaim);
    bool canBluff = hand.length >= 2;
    double bluffRate = memory.getBluffSuccessRate(-1); // Use -1 for AI

    double bluffChance = 0.4 + round * 0.05 + (safePlay == 0 ? 0.3 : 0.0);
    bluffChance += (bluffRate - 0.5) * 0.4;
    bluffChance = bluffChance.clamp(0.0, 0.95);

    final shouldBluff = safePlay == 0 || _rng.nextDouble() < bluffChance;
    final count = shouldBluff ? (_rng.nextInt(maxClaim) + 1) : safePlay;

    return {"action": "play", "count": count};
  }

  /// Determines if the card matches the target table card.
  bool _isMatch(String card, String tableCard) => card == tableCard || card == 'Joker';

  /// Counts how many cards in hand match the table card.
  int _currentBestCount(List<String> hand, String tableCard) {
    return hand.where((card) => _isMatch(card, tableCard)).length;
  }

  /// Records the result of a challenge by the AI.
  void recordChallengeOutcome(int playerId, bool wasLie) {
    if (wasLie) {
      memory.recordLie(playerId);
    } else {
      memory.recordTruth(playerId);
    }
    memory.recordChallengeResult(playerId, wasLie);
  }

  /// Clears internal memory to reset the AI state.
  void resetMemory() => memory.resetMemory();
}
