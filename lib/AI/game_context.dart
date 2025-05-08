/// Represents the current state of the game used by the AI to make decisions.
class GameContext {
  /// Cards currently held by the AI.
  final List<String> hand;

  /// The top card on the table that must be matched or bluffed.
  final String tableCard;

  /// Number of cards claimed by the last player.
  final int lastClaimCount;

  /// ID of the last player who made a move (if any).
  final int? lastPlayerId;

  /// The current round number.
  final int roundNumber;

  const GameContext({
    required this.hand,
    required this.tableCard,
    required this.lastClaimCount,
    this.lastPlayerId,
    this.roundNumber = 1,
  });
}
