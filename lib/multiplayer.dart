import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';

class MultiplayerService {
  // Server socket for the host
  ServerSocket? _serverSocket;
  
  // Client sockets for connections
  List<Socket> _connectedClients = [];
  
  // The game session code (6 digits)
  String? _sessionCode;
  
  // Port to use for the connection
  final int _port = 8888;
  
  // Track whether this instance is a host
  bool _isHost = false;
  bool get isHost => _isHost;
  
  // Game data stream controller
  final _gameDataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get gameDataStream => _gameDataController.stream;
  
  // Connection status stream
  final _connectionStatusController = StreamController<String>.broadcast();
  Stream<String> get connectionStatus => _connectionStatusController.stream;
  
  // Game state stream for state manager
  Stream<Map<String, dynamic>> get gameStateStream => gameDataStream.where(
    (event) => event['type'] == 'game_state_update'
  ).map((event) => event['data'] as Map<String, dynamic>);
  
  // Create a new game session as host
  Future<String> createGameSession() async {
    try {
      // Generate a random 6-digit code
      final random = Random();
      _sessionCode = (100000 + random.nextInt(900000)).toString();
      
      // Start the server
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, _port);
      _connectionStatusController.add('Hosting game with code: $_sessionCode');
      _isHost = true;
      
      // Listen for client connections
      _serverSocket!.listen((socket) {
        _handleClientConnection(socket);
      });
      
      return _sessionCode!;
    } catch (e) {
      _connectionStatusController.add('Failed to create game: $e');
      rethrow;
    }
  }
  
  // Join an existing game session
  Future<bool> joinGameSession(String code, String hostIp) async {
    try {
      // Connect to the host
      final socket = await Socket.connect(hostIp, _port);
      _isHost = false;
      
      // Send the code for verification
      socket.write(jsonEncode({
        'type': 'join',
        'code': code,
        'playerName': 'Player${Random().nextInt(1000)}'
      }));
      
      // Listen for messages from the host
      socket.listen(
        (data) {
          final message = jsonDecode(utf8.decode(data));
          
          if (message['type'] == 'join_response') {
            if (message['accepted']) {
              _connectionStatusController.add('Joined game successfully!');
            } else {
              _connectionStatusController.add('Failed to join: ${message['reason']}');
              socket.close();
            }
          } else if (message['type'] == 'game_data' || 
                     message['type'] == 'game_state_update') {
            _gameDataController.add(message);
          }
        },
        onDone: () {
          _connectionStatusController.add('Disconnected from host');
        },
        onError: (error) {
          _connectionStatusController.add('Connection error: $error');
        }
      );
      
      return true;
    } catch (e) {
      _connectionStatusController.add('Failed to join game: $e');
      return false;
    }
  }
  
  // Handle a new client connection
  void _handleClientConnection(Socket socket) {
    // Listen for messages from this client
    socket.listen(
      (data) {
        final message = jsonDecode(utf8.decode(data));
        
        if (message['type'] == 'join') {
          // Verify the code
          if (message['code'] == _sessionCode) {
            // Accept the client
            socket.write(jsonEncode({
              'type': 'join_response',
              'accepted': true
            }));
            
            _connectedClients.add(socket);
            _connectionStatusController.add('Player connected: ${message['playerName']}');
            
            // Broadcast the updated player list to all clients
            _broadcastPlayerList();
          } else {
            // Reject the client
            socket.write(jsonEncode({
              'type': 'join_response',
              'accepted': false,
              'reason': 'Invalid game code'
            }));
          }
        } else if (message['type'] == 'game_action') {
          // Process game action and broadcast updated state
          // This will be handled by the GameStateManager
          _gameDataController.add(message);
          _broadcastGameAction(message, socket);
        }
      },
      onDone: () {
        _connectedClients.remove(socket);
        _connectionStatusController.add('A player disconnected');
        _broadcastPlayerList();
      },
      onError: (error) {
        _connectedClients.remove(socket);
        _connectionStatusController.add('Client error: $error');
        _broadcastPlayerList();
      }
    );
  }
  
  // Broadcast the current player list to all clients
  void _broadcastPlayerList() {
    final playerListMessage = jsonEncode({
      'type': 'player_list',
      'count': _connectedClients.length + 1, // +1 for the host
    });
    
    for (final client in _connectedClients) {
      client.write(playerListMessage);
    }
  }
  
  // Broadcast a game action to all clients except the sender
  void _broadcastGameAction(Map<String, dynamic> action, Socket sender) {
    final actionMessage = jsonEncode(action);
    
    for (final client in _connectedClients) {
      if (client != sender) {
        client.write(actionMessage);
      }
    }
  }
  
  // Send a game action to the host (from a client)
  void sendGameAction(String action, Map<String, dynamic> actionData) {
    if (!_isHost) {
      // Only clients should send actions to host
      _connectedClients.first.write(jsonEncode({
        'type': 'game_action',
        'action': action,
        'data': actionData
      }));
    }
  }
  
  // Update and broadcast game state (from host)
  void updateGameState(Map<String, dynamic> gameState) {
    if (_isHost) {
      // Only the host should broadcast state updates
      final stateUpdate = jsonEncode({
        'type': 'game_state_update',
        'data': gameState
      });
      
      for (final client in _connectedClients) {
        client.write(stateUpdate);
      }
      
      // Also update the host's own state
      _gameDataController.add({
        'type': 'game_state_update',
        'data': gameState
      });
    }
  }
  
  // Send a game update to all connected clients
  void sendGameUpdate(Map<String, dynamic> gameData) {
    final gameUpdate = jsonEncode({
      'type': 'game_data',
      ...gameData
    });
    
    for (final client in _connectedClients) {
      client.write(gameUpdate);
    }
  }
  
  // Clean up resources
  void dispose() {
    _serverSocket?.close();
    for (final client in _connectedClients) {
      client.close();
    }
    _gameDataController.close();
    _connectionStatusController.close();
  }
}