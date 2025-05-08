import 'dart:math';
import 'game_context.dart';
import 'player_memory.dart';

/// AI logic for deciding moves in Liar's Deck game.
class LiarsDeckAI {
  final Random _rng;
  final PlayerMemory memory = PlayerMemory();

  LiarsDeckAI({Random? rng}) : _rng = rng ?? Random();

  /// Decides to either play or challenge based on the game context.
  Map<String, dynamic> decidePlay(GameContext ctx) {
    final int maxClaim = min(3, ctx.hand.length);
    final int bestCount = _countMatchingCards(ctx.hand, ctx.tableCard);
    final double suspicion = ctx.lastPlayerId != null
        ? (memory.suspicionScores[ctx.lastPlayerId] ?? 0.0)
        : 0.0;

    if (bestCount == 0 && suspicion >= 1.5) {
      return {"action": "challenge"};
    }

    if (_shouldChallenge(ctx)) {
      return {"action": "challenge"};
    }

    final playDecision = _decideCardPlay(
      hand: ctx.hand,
      tableCard: ctx.tableCard,
      round: ctx.roundNumber,
      maxClaim: maxClaim,
    );

    if (ctx.lastPlayerId != null && ctx.lastClaimCount > 0) {
      memory.recordClaim(ctx.lastPlayerId!, ctx.tableCard, ctx.lastClaimCount);
    }

    return playDecision;
  }

  /// Determines whether the AI should challenge the last claim.
  bool _shouldChallenge(GameContext ctx) {
    if (ctx.lastClaimCount == 0 || ctx.lastPlayerId == null) return false;

    if (_countMatchingCards(ctx.hand, ctx.tableCard) > ctx.lastClaimCount) {
      return false;
    }

    final double likelihood = memory.estimatedTruthProbability(ctx.tableCard, ctx.lastClaimCount);
    final double avgClaim = memory.getEMAClaim(ctx.lastPlayerId!);
    final double suspicion = memory.suspicionScores[ctx.lastPlayerId!] ?? 0.0;
    final double lieProbability = memory.bayesianLieProbability(ctx.lastPlayerId!);
    final double accuracy = memory.challengeAccuracy(ctx.lastPlayerId!);

    final bool isSuspicious = ctx.lastClaimCount > (avgClaim + 1);

    double threshold = (isSuspicious ? 0.5 : 0.3)
        - (suspicion * 0.2)
        - (lieProbability * 0.2)
        + ((0.5 - accuracy) * 0.2);

    return likelihood < threshold.clamp(0.05, 0.9);
  }

  /// Decides how many cards to play or if to bluff.
  Map<String, dynamic> _decideCardPlay({
    required List<String> hand,
    required String tableCard,
    required int round,
    required int maxClaim,
  }) {
    final int matchCount = _countMatchingCards(hand, tableCard);
    final int safePlay = min(matchCount, maxClaim);
    final bool canBluff = hand.length >= 2;
    final double bluffRate = memory.getBluffSuccessRate(-1);

    double bluffChance = 0.4 + round * 0.05 + (safePlay == 0 ? 0.3 : 0.0);
    bluffChance += (bluffRate - 0.5) * 0.4;
    bluffChance = bluffChance.clamp(0.0, 0.95);

    final bool shouldBluff = canBluff && (safePlay == 0 || _rng.nextDouble() < bluffChance);
    final int count = shouldBluff ? (_rng.nextInt(maxClaim) + 1) : safePlay;

    return {"action": "play", "count": count};
  }

  /// Checks if a card matches the current table card.
  bool _isMatch(String card, String tableCard) => card == tableCard || card == 'Joker';

  /// Counts how many cards in hand match the table card.
  int _countMatchingCards(List<String> hand, String tableCard) {
    return hand.where((card) => _isMatch(card, tableCard)).length;
  }

  /// Updates memory based on challenge outcome.
  void recordChallengeOutcome(int playerId, bool wasLie) {
    if (wasLie) {
      memory.recordLie(playerId);
    } else {
      memory.recordTruth(playerId);
    }
    memory.recordChallengeResult(playerId, wasLie);
  }

  /// Clears all memory of the AI.
  void resetMemory() => memory.resetMemory();
}
