// lib/ai_player.dart

class AIPlayer {
  final String id;
  List<Phase10Card> hand;
  int currentPhase;
  bool hasPlayedPhase;

  AIPlayer({
    required this.id,
    required this.hand,
    required this.currentPhase,
    this.hasPlayedPhase = false,
  });

  bool preferDiscard(Phase10Card topDiscard) {
    // TODO: Implement
    return false;
  }

  bool canPlayPhase() {
    // TODO: Implement
    return false;
  }

  List<Phase10Card> playPhase() {
    // TODO: Implement
    return [];
  }

  Phase10Card chooseDiscard() {
    // TODO: Implement
    return hand.first;
  }

  List<Phase10Card> hitsOnOtherPhases(List<List<Phase10Card>> otherPhases) {
    // TODO: Implement
    return [];
  }

  bool _cardHelpsPhase(Phase10Card card) {
    // TODO: Implement
    return false;
  }

  void takeTurn(Phase10Card topDiscard, List<List<Phase10Card>> othersPhases) {
    // TODO: Implement
  }

  Phase10Card _drawFromDeck() {
    // TODO: Stub
    return Phase10Card(number: 0, color: 'Red');
  }

  void _discard(Phase10Card card) {
    // TODO: Stub
  }
}

class Phase10Card {
  final int number;
  final String color;
  final bool isWild;
  final bool isSkip;

  Phase10Card({
    required this.number,
    required this.color,
    this.isWild = false,
    this.isSkip = false,
  });

  int get value => isSkip ? 15 : isWild ? 25 : number;
}

class Phase {
  static bool checkPhaseCompletion(List<Phase10Card> hand, int phase) {
    // TODO: Stub
    return false;
  }

  static List<Phase10Card> getPhaseCards(List<Phase10Card> hand, int phase) {
    // TODO: Stub
    return [];
  }

  static bool isCardValidHit(Phase10Card card, List<Phase10Card> phaseCards) {
    // TODO: Stub
    return false;
  }
}