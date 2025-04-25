import 'dart:math';

/// AI logic for the Liars Deck card game.
///
/// This class implements strategic decision-making for a player in a turn-based card game.
/// It makes decisions such as playing honestly, bluffing, using special cards, or challenging
/// another player's move, based on the current game state and claim history.
class LiarsDeckAI {
  final Random _rng;
  final Map<int, List<int>> playerClaimHistory = {};

  /// Constructs a new instance of [LiarsDeckAI].
  ///
  /// Optionally takes a [Random] instance for deterministic behavior (useful for testing).
  LiarsDeckAI({Random? rng}) : _rng = rng ?? Random();

  /// Main AI decision-making method for a player's turn.
  ///
  /// Evaluates the hand, game state, and opponent history to determine an action.
  /// May return a play (with a card count or special card), or a challenge against the previous player.
  ///
  /// - [hand]: List of max 5 Strings representing the cards in the player's hand.
  ///       'Ace','King','Queen', and 'Joker' are the only valid members
  ///        Only of 2 jokers exist in game, 6 of everything else
  /// - [tableCard]: The card type that must be played this round.
  /// - [lastClaimCount]: The number of cards the last player claimed to have played.
  /// - [mode]: Game mode which may affect logic ('standard', 'chaos', 'devil').
  /// - [lastPlayerId]: ID of the last player who made a claim.
  ///         This is an integer 1-4 corresponding to the player's position at the table.
  ///         The player ID of a given AI is equal to (lastPlayerID + 1) modulus(num_total_players).
  ///         This will change as players are eliminated and vacant seats are formed
  ///
  /// - [roundNumber]: Current round number to help adjust bluffing likelihood over time.
  ///
  /// Returns a map with keys: 'action' (play/challenge), and optionally 'count' and 'special'.
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

    if (_shouldChallenge(lastClaimCount, lastPlayerId, tableCard, mode, hand)) {
      return {"action": "challenge"};
    }

    final play = _decideCardPlay(hand, tableCard, mode, roundNumber, maxClaim);

    if (lastPlayerId != null && lastClaimCount > 0) {
      playerClaimHistory
          .putIfAbsent(lastPlayerId, () => [])
          .add(lastClaimCount);
    }

    return play;
  }

  /// Determines whether the AI should play the 'Devil' card in 'devil' mode.
  ///
  /// Has a 50% chance of playing the 'Devil' card if it's in the hand and the mode is 'devil'.
  bool _shouldPlayDevil(List<String> hand, String mode) {
    return mode == 'devil' && hand.contains('Devil') && _rng.nextBool();
  }

  /// Decides whether to challenge the previous player's claim.
  ///
  /// returns false if the AI is the first player of the round
  /// returns false if the AI can play a hand better than the last played hand
  /// If the AI cannot play a better hand,
  /// the AI considers both the estimated truth probability of the claim
  /// and historical average claims from the player to determine if it appears suspicious.
  /// A higher claim than average increases suspicion.
  bool _shouldChallenge(int lastClaimCount, int? lastPlayerId, String tableCard,
      String mode, List<String> hand) {
    if (lastClaimCount == 0 || lastPlayerId == null) {
      return false;
    } else if (currentBestCount(hand, tableCard) > lastClaimCount) {
      return false;
    }

    final likelihood =
        _estimateTruthProbability(lastClaimCount, tableCard, mode);
    final avgClaim = _averageClaim(lastPlayerId);
    final isSuspicious = lastClaimCount > (avgClaim + 1);
    final threshold = isSuspicious ? 0.5 : 0.3;
    return likelihood < threshold;
  }

  /// Determines how many cards to play and whether to bluff.
  ///
  /// Bluffing becomes more likely with higher rounds or when no safe plays exist.
  /// May also opt to play special cards like 'Chaos' or 'Master' under certain conditions.
  Map<String, dynamic> _decideCardPlay(
    List<String> hand,
    String tableCard,
    String mode,
    int roundNumber,
    int maxClaim,
  ) {
    final bestCount = currentBestCount(hand, tableCard);
    final safePlay = min(bestCount, maxClaim);

    bool canBluff = hand.length >= 2;
    double bluffChance = canBluff ? (0.4 + (roundNumber * 0.05)) : 0.0;
    if (safePlay == 0 && canBluff) bluffChance += 0.3;

    final shouldBluff =
        safePlay == 0 || _rng.nextDouble() < bluffChance.clamp(0.0, 0.95);

    // Steven doesn't understand the line below this
    // could you write a comment to explain it ?
    final cardsToPlay = shouldBluff ? _rng.nextInt(maxClaim) + 1 : safePlay;

    /* this will probably never be used 
    if (mode == 'chaos') {
      if (hand.contains('Chaos') && _rng.nextDouble() < 0.2) {
        return {"action": "play", "count": 1, "special": "Chaos"};
      }
      if (hand.contains('Master') && _rng.nextDouble() < 0.2) {
        return {"action": "play", "count": 1, "special": "Master"};
      }
    }
    */

    return {"action": "play", "count": cardsToPlay};
  }

  /// Determines whether a card matches the target [tableCard].
  ///
  /// Matching cards are either the same as the table card, or are wild cards: 'Joker' or 'Devil'.
  bool _isMatch(String card, String tableCard) {
    return card == tableCard || card == 'Joker' || card == 'Devil';
  }

  /// Estimates the probability that a claim is truthful.
  ///
  /// Based on the total availability of the card type in the game pool.
  /// If a player claims more cards than typically exist, the probability decreases.
  /// Accounts for different game modes ('standard' vs. 'chaos') with different card pools.
  double _estimateTruthProbability(
      int claimCount, String tableCard, String mode) {
    const standardPool = {'Ace': 6, 'King': 6, 'Queen': 6, 'Joker': 2};
    const chaosPool = {'King': 5, 'Queen': 5, 'Chaos': 1, 'Master': 1};

    final pool = mode == 'chaos' ? chaosPool : standardPool;
    final total =
        (pool[tableCard] ?? 0) + (pool['Joker'] ?? 0) + (pool['Devil'] ?? 0);
    final ratio = claimCount / (total > 0 ? total : 1);
    return 1.0 - ratio.clamp(0.0, 1.0);
  }

  /// Computes the average number of cards claimed historically by a specific player.
  ///
  /// This historical average is used to detect claims that deviate significantly from
  /// the player's past behavior and may indicate bluffing.
  double _averageClaim(int playerId) {
    final history = playerClaimHistory[playerId];
    if (history == null || history.isEmpty) return 1.0;
    return history.reduce((a, b) => a + b) / history.length;
  }

  // computes the best amount of cards of a given type that the ai could play
  int currentBestCount(List<String> hand, String tableCard) {
    int bestCount = 0;
    for (int i = 0; i < hand.length; i++) {
      if (_isMatch(hand[i], tableCard)) {
        bestCount++;
      }
    }
    return bestCount;
  }
}
