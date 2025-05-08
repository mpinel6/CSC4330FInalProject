import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finalproj4330/game_logic_test.dart'; 

void main() {
  group('GameLogic.countSelected', () {
    test('returns 0 when no trues', () {
      //build the map manually
      Map<String, bool> selections = Map<String, bool>();
      selections['a'] = false;
      selections['b'] = false;

      int result = GameLogic.countSelected(selections);

      expect(result, 0);
    });

    test('counts only true values', () {
      // Build the map manually
      Map<String, bool> selections = Map<String, bool>();
      selections['x'] = true;
      selections['y'] = false;
      selections['z'] = true;

      int result = GameLogic.countSelected(selections);

      expect(result, 2);
    });
  });

  group('GameLogic.player1WinsRound', () {
    test('true when tokens1 > tokens2', () {
      bool result = GameLogic.player1WinsRound(4, 3);
      expect(result, true);
    });

    test('false otherwise', () {
      bool resultA = GameLogic.player1WinsRound(2, 3);
      bool resultB = GameLogic.player1WinsRound(3, 3);
      expect(resultA, false);
      expect(resultB, false);
    });
  });

  group('GameLogic.dealCards', () {
    // Create a seeded Random for deterministic shuffling
    Random seed = Random(123);

    test('deals 5 cards to each when hasSecondPlayer=true', () {
      // Build a 20-card deck
      List<String> deck = <String>[];
      for (int i = 0; i < 20; i = i + 1) {
        deck.add('C' + i.toString());
      }

      DealResult result = GameLogic.dealCards(deck, hasSecondPlayer: true, random: seed,);
      //check hand sizes
      int p1Count = result.player1.length;
      int p2Count = result.player2.length;
      int remCount = result.remainingDeck.length;
      expect(p1Count, 5);
      expect(p2Count, 5);
      expect(remCount, 10);

      //build a set of all dealt cards manually
      Set<String> allDealt = Set<String>();
      for (int i = 0; i < result.player1.length; i = i + 1) {
        allDealt.add(result.player1[i]);
      }
      for (int i = 0; i < result.player2.length; i = i + 1) {
        allDealt.add(result.player2[i]);
      }

      //should be exactly 10 unique dealt cards
      expect(allDealt.length, 10);

      //Ensure no card in allDealt appears in remainingDeck
      bool overlapEmpty = true;
      for (String card in allDealt) {
        for (int j = 0; j < result.remainingDeck.length; j = j + 1) {
          if (card == result.remainingDeck[j]) {
            overlapEmpty = false;
          }
        }
      }
      expect(overlapEmpty, true);
    });

    test('deals 5 cards only to player1 when hasSecondPlayer=false', () {
      //Build a 12-card deck
      List<String> deck = <String>[];
      for (int i = 0; i < 12; i = i + 1) {
        deck.add('D' + i.toString());
      }

      DealResult result = GameLogic.dealCards(deck, hasSecondPlayer: false, random: seed,);
      //check hand and remainder sizes
      int p1Count = result.player1.length;
      bool p2Empty = result.player2.isEmpty;
      int remCount = result.remainingDeck.length;
      expect(p1Count, 5);
      expect(p2Empty, true);
      expect(remCount, 7);

      // Ensure no overlap between player1 and remainingDeck
      bool overlapEmpty = true;
      for (int i = 0; i < result.player1.length; i = i + 1) {
        String card = result.player1[i];
        for (int j = 0; j < result.remainingDeck.length; j = j + 1) {
          if (card == result.remainingDeck[j]) {
            overlapEmpty = false;
          }
        }
      }
      expect(overlapEmpty, true);
    });
  });
}