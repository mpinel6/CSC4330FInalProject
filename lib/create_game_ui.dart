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

class _CreateGamePageState extends State<CreateGamePage> {
  final MultiplayerService _multiplayerService = MultiplayerService();
  final NetworkDiscovery _networkDiscovery = NetworkDiscovery();
  String? _gameCode;
  String? _localIp;
  String? _statusMessage;
  bool _playerConnected = false;
  
  @override
  void initState() {
    super.initState();
    _initHosting();
    
    _multiplayerService.connectionStatus.listen((status) {
      setState(() {
        _statusMessage = status;
        
        // Update connection status flag
        if (status.contains('Player connected')) {
          _playerConnected = true;
        } else if (status.contains('disconnected')) {
          _playerConnected = false;
        }
      });
    });
  }
  
  @override
  void dispose() {
    //_multiplayerService.dispose();
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
  
  void _copyCodeToClipboard() {
    if (_gameCode != null) {
      Clipboard.setData(ClipboardData(text: _gameCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game code copied to clipboard')),
      );
    }
  }
  
  void _startGame() {
  if (_playerConnected = false) {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_gameCode != null) ...[
                const Text(
                  "Your Game Code:",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                        onPressed: _copyCodeToClipboard,
                        tooltip: 'Copy code',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Your IP Address: $_localIp",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                // Text(
                //   "Players connected",
                //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage!,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    "START GAME",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
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
}