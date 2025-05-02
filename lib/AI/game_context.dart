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