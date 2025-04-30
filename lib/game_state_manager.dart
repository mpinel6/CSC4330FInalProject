import 'dart:async';
import 'multiplayer.dart';

class GameStateManager {
  // The current game state
  Map<String, dynamic> _gameState = {};
  
  // Reference to the multiplayer service
  final MultiplayerService _multiplayerService;
  
  // Stream subscription for game state updates
  StreamSubscription? _gameStateSubscription;
  
  // Stream controller to expose game state to UI
  final StreamController<Map<String, dynamic>> _stateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // Getter for the state stream
  Stream<Map<String, dynamic>> get stateStream => _stateController.stream;
  
  GameStateManager(this._multiplayerService) {
    // Listen to network updates
    _gameStateSubscription = _multiplayerService.gameStateStream.listen(_handleStateUpdate);
  }
  
  // Initialize the game state
  void initializeGameState(bool isHost, List<String> players) {
    _gameState = {
      'players': players,
      'currentTurn': 0,
      'cards': {}, // Map of player IDs to their cards
      'gamePhase': 'setup',
      // Add other game state properties
    };
    
    if (isHost) {
      // Host broadcasts the initial state
      _multiplayerService.updateGameState(_gameState);
    }
  }
  
  // Handle player action (called by UI)
  void handlePlayerAction(String playerId, String action, dynamic actionData) {
    if (_multiplayerService.isHost) {
      // Host applies the action directly
      _applyAction(playerId, action, actionData);
      _multiplayerService.updateGameState(_gameState);
    } else {
      // Client sends the action to host
      _multiplayerService.sendGameAction(action, {
        'playerId': playerId,
        'actionData': actionData
      });
    }
  }
  
  // Apply an action to the game state
  void _applyAction(String playerId, String action, dynamic actionData) {
    switch (action) {
      case 'startGame':
        _gameState['gamePhase'] = 'playing';
        _gameState['lastAction'] = '$playerId started the game';
        break;
        
      case 'incrementCounter':
        _gameState['counter'] = (_gameState['counter'] ?? 0) + (actionData['amount'] ?? 1);
        _gameState['lastAction'] = '$playerId incremented the counter';
        break;
        
      case 'playCard':
        // Apply card play logic
        // _gameState['cards'][playerId] = ...
        break;
        
      case 'endTurn':
        // Move to next player's turn
        _gameState['currentTurn'] = (_gameState['currentTurn'] + 1) % _gameState['players'].length;
        break;
      // Add other action types
    }
    
    // Notify UI of state change
    _stateController.add(_gameState);
  }
  
  // Handle incoming state update from network
  void _handleStateUpdate(Map<String, dynamic> newState) {
    _gameState = newState;
    _stateController.add(_gameState);
  }
  
  void dispose() {
    _gameStateSubscription?.cancel();
    _stateController.close();
  }
}