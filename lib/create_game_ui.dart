import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'multiplayer.dart';
import 'network_discovery.dart';
import 'sync_test_game.dart';
import 'game_state_manager.dart';
import 'dart:convert';
import 'lan_card_game.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> with SingleTickerProviderStateMixin {
  final MultiplayerService _multiplayerService = MultiplayerService();
  final NetworkDiscovery _networkDiscovery = NetworkDiscovery();
  String? _gameCode;
  String? _localIp;
  String? _statusMessage;
  bool _playerConnected = false;
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initHosting();

    // Initialize the AnimationController for pulsing
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);
    
    _multiplayerService.connectionStatus.listen((status) {
      setState(() {
        _statusMessage = status;
        
        // Update connection status flag
        if (status.contains('Player connected')) {
          _playerConnected = true;
          
          // Show dialog automatically when player connects
          // Use a small delay to ensure UI is updated first
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted && _playerConnected) {
              _showStartGameDialog();
            }
          });
        } else if (status.contains('disconnected')) {
          _playerConnected = false;
        }
      });
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _initHosting() async {

    await _multiplayerService.initDeviceName();

    try {
      _localIp = await _networkDiscovery.getLocalIpAddress();
      final code = await _multiplayerService.createGameSession();
      setState(() {
        _gameCode = code;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to create game: $e';
      });
    }
  }
  
  void _copyAllInfoToClipboard() {
  if (_gameCode != null) {
    final allInfo = 'Game Code: $_gameCode\n'
        'IP Address: $_localIp\n'
        'Device Name: ${_multiplayerService.deviceName}';
    
    Clipboard.setData(ClipboardData(text: allInfo));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('All game information copied to clipboard')),
    // );
  }
}
  
  void _startGame() {
  if (_playerConnected == false) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Need a connected player to start')),
    );
    return;
  }
  
  // Use more reliable direct socket communication
  final gameStartCommand = {
    'type': 'game_start',
    'gameCode': _gameCode,
    'message': 'Game starting now!',
    'timestamp': DateTime.now().millisecondsSinceEpoch
  };
  
  print('HOST: Sending game start command: $gameStartCommand');
  
  // Send raw command to all clients
  final jsonStr = jsonEncode(gameStartCommand);
  
  try {
    // Send three times with newlines to ensure receipt
    for (final client in _multiplayerService.connectedClients) {
      client.write(jsonStr + '\n');
      
      // Short delay between sends
      Future.delayed(Duration(milliseconds: 10), () {
        client.write(jsonStr + '\n');
      });
    }
    
    // Add to game data for local listeners
    _multiplayerService.sendGameStartCommand(_gameCode ?? '');
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game starting...'))
    );
  } catch (e) {
    print('Error sending start command: $e');
  }
  
  // Delay navigation to ensure message is sent
  Future.delayed(const Duration(milliseconds: 1000), () {
    if (!mounted) return;
    
    print('HOST: Navigating to game');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanCardGame(
          multiplayerService: _multiplayerService,
          isHost: true,
          gameCode: _gameCode ?? '',
        ),
      ),
    );
  });
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Create Game"),
      backgroundColor: Colors.brown[700],
    ),
    backgroundColor: Colors.brown[100],
    // Add floating action button that only appears when players are connected
    // floatingActionButton: _playerConnected
    // ? AnimatedBuilder(
    //     animation: _animationController,
    //     builder: (context, child) {
    //       return Transform.scale(
    //         scale: 1.0 + (_animationController.value * 0.1), // Pulsing effect
    //         child: FloatingActionButton.extended(
    //           onPressed: _showStartGameDialog,
    //           label: const Text(
    //             'START GAME',
    //             style: TextStyle(color: Colors.white), // Text color set to white
    //           ),
    //           icon: const Icon(
    //             Icons.sports_esports,
    //             color: Colors.white, // Icon color set to white
    //           ),
    //           backgroundColor: Colors.brown[700], // Button remains brown
    //         ),
    //       );
    //     },
    //   )
    // : null,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_gameCode != null) ...[
              const Text(
                "Your Game Code:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _gameCode!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyAllInfoToClipboard(),
                          tooltip: 'Copy all info',
                        ),
                      ],
                    ),
                    Divider(color: const Color(0xFF8D6E63), thickness: 1),
                    Text(
                      "IP: $_localIp\nDevice: ${_multiplayerService.deviceName}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _statusMessage!.contains('connected') ? const Color.fromARGB(255, 0, 0, 0) : null,
                    fontWeight: _statusMessage!.contains('connected') ? FontWeight.bold : null,
                    fontSize: 20,
                  ),
                ),
              ],
              // Remove the existing START GAME button
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _statusMessage ?? "Creating game session...",
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

// Add new method to show the start game dialog
void _showStartGameDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and text section
          const Icon(
            Icons.check_circle,
            color: Color.fromARGB(255, 7, 7, 7),
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            'Player connected and ready!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24), // Increased spacing
          
          // Pulsing START GAME button - moved here from actions
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_animationController.value * 0.1), // Pulsing effect
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    _startGame(); // Start the game
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    minimumSize: const Size(180, 48), // Make button wider
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_esports,
                        color: Colors.white, // Set the icon color to white
                      ),
                      SizedBox(width: 8),
                      Text(
                        'START GAME',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Added missing comma
                          color: Colors.white, // Added missing comma
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16), // Spacing between buttons
          
          // CANCEL button 
          TextButton(
            onPressed: () async {
              // Send cancel command to clients first
              _multiplayerService.sendGameCancelCommand();
              
              // Small delay to ensure message is sent before closing connection
              await Future.delayed(Duration(milliseconds: 300));
              
              // Reset the connection and navigate if successful
              final success = await _multiplayerService.resetConnection();
              
              // Close the dialog
              Navigator.pop(context);
              
              if (success) {
                // Navigate to home screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                // Just update UI state if navigation fails
                setState(() {
                  _playerConnected = false;
                  _statusMessage = 'Game canceled. Network reset failed.';
                });
              }
            },
            child: const Text('CANCEL'),
          ),
        ],
      ),
      // Remove the actions section as we've moved both buttons to the content
      actions: [], // Empty actions
    ),
  );
}
}