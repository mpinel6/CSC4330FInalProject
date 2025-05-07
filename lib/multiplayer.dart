import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:device_info_plus/device_info_plus.dart';

class MultiplayerService {

  String _deviceName = "Unknown Device";
  String get deviceName => _deviceName;

  // Server socket for the host
  ServerSocket? _serverSocket;
  
  // Client sockets for connections
  List<Socket> _connectedClients = [];
  
  // The game session code (6 digits)
  String? _sessionCode;

  int _playerCount = 1;
  
  // Port to use for the connection
  final int _port = 8888;
  
  // Track whether this instance is a host
  bool _isHost = false;
  bool get isHost => _isHost;

  List<Socket> get connectedClients => _connectedClients;
  
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
      //_connectionStatusController.add('Hosting game with code: $_sessionCode');
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
    
    // Store the socket for later use
    _connectedClients = [socket];
    
    // Send the code for verification
    socket.write(jsonEncode({
      'type': 'join',
      'code': code,
      'playerName': 'Player${Random().nextInt(1000)}'
    }) + '\n');
    
    // Connection feedback
    _connectionStatusController.add('Connected to host at $hostIp');
    
    // Listen for messages from the host
    socket.listen(
      (data) {
        // Split by newline to handle multiple messages in one packet
        final messages = utf8.decode(data).split('\n').where((m) => m.isNotEmpty);
        
        for (final rawMessage in messages) {
          try {
            print('CLIENT SOCKET RAW: $rawMessage');
            
            try {
              final message = jsonDecode(rawMessage);
              print('CLIENT SOCKET PARSED: $message');
              
              if (message is Map<String, dynamic>) {
                if (message.containsKey('type')) {
                  // Handle game start messages
                  if (message['type'] == 'game_start') {
                    print('CLIENT SOCKET: Detected game_start command!');
                    _gameDataController.add(message);
                    _connectionStatusController.add('Game is starting!');
                  }
                  // Handle join response
                  else if (message['type'] == 'join_response') {
                    _connectionStatusController.add('Connected! Waiting for host to start the game...');
                  }
                  // Handle game state updates
                  else if (message['type'] == 'game_data' || message['type'] == 'game_state_update') {
                    print('CLIENT: Received game state update');
                    _gameDataController.add(message);
                  }
                  // Handle click updates
                  else if (message['type'] == 'game_action') {
                    print('CLIENT: Received game action from host');
                    _gameDataController.add(message);
                  }
                }
              }
            } catch (jsonError) {
              print('Error parsing JSON: $jsonError');
              
              // Try handling as raw text (last resort)
              if (rawMessage.contains('game_start')) {
                print('CLIENT: Detected game_start in raw text');
                _gameDataController.add({
                  'type': 'game_start',
                  'rawMessage': rawMessage
                });
                _connectionStatusController.add('Game is starting! (raw message)');
              }
            }
          } catch (e) {
            print('Error handling socket message: $e');
          }
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
  // Don't immediately announce a connection
  // Wait for proper join message first
  bool isVerifiedClient = false;
  
  // Listen for messages from this client
  socket.listen(
    (data) {
      try {
        // Split by newline to handle multiple messages in one packet
        final messages = utf8.decode(data).split('\n').where((m) => m.isNotEmpty);
        
        for (final rawMessage in messages) {
          try {
            print('HOST received raw: $rawMessage');
            final message = jsonDecode(rawMessage);
            
            if (message['type'] == 'join') {
              // Process join message
              final code = message['code'];
              if (code == _sessionCode) {
                // NOW we can add the client as it's officially joining
                if (!isVerifiedClient) {
                  _connectedClients.add(socket);
                  _playerCount = _connectedClients.length;
                  _connectionStatusController.add('Player connected!');
                  isVerifiedClient = true;
                }
                
                socket.write(jsonEncode({
                  'type': 'join_response',
                  'success': true,
                  'message': 'Connected to game',
                  'deviceName': _deviceName
                }) + '\n');
              }
            }
            // Handle device info request
            else if (message['type'] == 'device_info_request') {
              // Send device info to client
              socket.write(jsonEncode({
                'type': 'device_info_response',
                'deviceName': _deviceName
              }) + '\n');
            } 
            // ADD THIS SECTION - Handle game actions from client
            else if (message['type'] == 'game_action') {
              print('HOST: Received game action: ${message['action']}');
              
              // Forward all game actions to the game state manager via stream
              _gameDataController.add(message);
              
              // Specific handling for critical actions
              if (message['action'] == 'clientReadyToggle') {
                print('HOST: Received client ready toggle: ${message['data']}');
              }
            }
          } catch (e) {
            print('Error parsing client message: $e');
          }
        }
      } catch (e) {
        print('Error reading from client: $e');
      }
    },
    onDone: () {
      // Only announce disconnection for verified clients
      if (isVerifiedClient) {
        _connectedClients.remove(socket);
        _playerCount = _connectedClients.length;
        _connectionStatusController.add('Player disconnected!');
      }
    },
    onError: (error) {
      print('Socket error: $error');
      _connectedClients.remove(socket);
      _playerCount = _connectedClients.length;
      _connectionStatusController.add('Connection error: $error');
    }
  );
}

  // Broadcast the current player list to all clients
  void _broadcastPlayerList() {
    final playerListMessage = jsonEncode({
      'type': 'player_list',
      'count': _connectedClients.length , // +1 for the host
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
  // Send a game action to the host
void sendGameAction(String action, Map<String, dynamic> actionData) {
  try {
    if (!_isHost && _connectedClients.isNotEmpty) {
      // Format the action message with the data field included
      final gameAction = {
        'type': 'game_action',
        'action': action,
        'data': actionData,  // THIS IS THE CRITICAL FIX - include the actionData
        'timestamp': DateTime.now().millisecondsSinceEpoch
      };
      
      print('CLIENT: Sending action: $action');
      
      // Send twice for critical actions like ready status
      final jsonMessage = jsonEncode(gameAction) + '\n';
      _connectedClients.first.write(jsonMessage);
      
      // For clientReadyToggle, send a second time for reliability
      if (action == 'clientReadyToggle') {
        Future.delayed(Duration(milliseconds: 100), () {
          _connectedClients.first.write(jsonMessage);
        });
      }
      
      print('CLIENT: Action sent successfully');
    }
  } catch (e) {
    print('Error sending game action: $e');
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

  // Send a direct game command without wrapping
void sendGameCommand(Map<String, dynamic> commandData) {// may not be needed?
  final command = jsonEncode(commandData);
  
  // Print for debugging
  print('Sending command: $command');
  
  for (final client in _connectedClients) {
    client.write(command);
  }
  
  // Also notify the host's listeners
  if (commandData['type'] == 'game_start') {
    _gameDataController.add(commandData);
  }
}

// Safe method to send game start command
void sendGameStartCommand(String gameCode) {
  try {
    // Create a simple, stable command format
    final command = {
      'type': 'game_start',
      'gameCode': gameCode,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    // Use raw socket write for reliability
    final jsonStr = jsonEncode(command);
    for (final socket in _connectedClients) {
      socket.write(jsonStr + '\n'); // Add newline for consistency
    }
    
    // Also notify local listeners through controller
    _gameDataController.add(command);
  } catch (e) {
    print('Error sending game start command: $e');
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

  Stream<String> get messageStream {
  // Create a transformer that converts game data to string messages
  final controller = StreamController<String>.broadcast();
  
  gameDataStream.listen((data) {
    try {
      // Convert the data to a JSON string
      controller.add(jsonEncode(data));
    } catch (e) {
      controller.addError('Error encoding message: $e');
    }
  }, 
  onError: (e) => controller.addError(e),
  onDone: () => controller.close());
  
  return controller.stream;
}

// Add a method to send messages
void sendMessage(String message) {
  try {
    // Parse message to determine what kind of data it is
    final data = jsonDecode(message);
    
    if (data['type'] == 'state_update') {
      // Use existing method to update game state
      updateGameState(data['state']);
    } else {
      // Generic game update
      sendGameUpdate(data);
    }
  } catch (e) {
    _connectionStatusController.add('Error sending message: $e');
  }
}

void broadcastRawMessage(String jsonMessage) {
  try {
    print('Broadcasting raw message: $jsonMessage');
    for (final client in _connectedClients) {
      // Add newline character to ensure proper transmission
      client.write(jsonMessage + '\n');
    }
    
    // Also process the message locally
    try {
      final data = jsonDecode(jsonMessage);
      _gameDataController.add(data);
    } catch (e) {
      print('Error parsing local message: $e');
    }
  } catch (e) {
    print('Error broadcasting message: $e');
  }
}
void addToGameData(Map<String, dynamic> data) {
  _gameDataController.add(data);
}

// Add this method to initialize the device name
Future<void> initDeviceName() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      _deviceName = androidInfo.model; // e.g., "Pixel 6"
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _deviceName = iosInfo.name; // e.g., "iPhone 13"
    } else {
      _deviceName = 'Desktop Device';
    }
    
    print('Device name initialized: $_deviceName');
  } catch (e) {
    print('Error getting device name: $e');
    _deviceName = 'Flutter Device';
  }
}
}