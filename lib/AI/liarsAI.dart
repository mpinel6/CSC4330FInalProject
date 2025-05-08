import 'dart:math';
import 'game_context.dart';
import 'player_memory.dart';

/// AI logic for making decisions in the Liar's Deck game, such as playing cards or challenging claims.
class LiarsDeckAI {
  final Random _rng;
  final PlayerMemory memory = PlayerMemory();

  /// Constructs a new AI instance, optionally with a custom RNG (for testing).
  LiarsDeckAI({Random? rng}) : _rng = rng ?? Random();

  /// Determines the AI's next move based on the current [GameContext].
  ///
  /// Returns a map containing:
  /// - `"action"`: either `"play"` or `"challenge"`
  /// - `"count"`: number of cards to play (if playing)
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

  /// Evaluates whether to challenge the last claim based on memory and statistical analysis.
  ///
  /// Returns true if the AI should issue a challenge.
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

  /// Calculates whether to bluff and how many cards to play.
  ///
  /// [hand] - the AI's current cards
  /// [tableCard] - the card the AI must match or bluff
  /// [round] - current game round
  /// [maxClaim] - maximum number of cards that can be played
  ///
  /// Returns a map with `"action": "play"` and `"count"`: cards to claim.
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

  /// Checks if a card is valid for play by matching the table card or being a Joker.
  bool _isMatch(String card, String tableCard) => card == tableCard || card == 'Joker';

  /// Returns the number of cards in hand that match the table card.
  int _countMatchingCards(List<String> hand, String tableCard) {
    return hand.where((card) => _isMatch(card, tableCard)).length;
  }

  /// Records whether the AI's challenge was successful or not.
  ///
  /// [playerId] - the ID of the challenged player
  /// [wasLie] - whether the challenged claim was a lie
  void recordChallengeOutcome(int playerId, bool wasLie) {
    if (wasLie) {
      memory.recordLie(playerId);
    } else {
      memory.recordTruth(playerId);
    }
    memory.recordChallengeResult(playerId, wasLie);
  }

  /// Clears all player and game memory stored by the AI.
  void resetMemory() => memory.resetMemory();
}
