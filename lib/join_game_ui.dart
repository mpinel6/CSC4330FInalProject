import 'dart:async';
import 'package:flutter/material.dart';
import 'multiplayer.dart';
import 'network_discovery.dart';
import 'sync_test_game.dart';
import 'game_state_manager.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({super.key});

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  final TextEditingController _codeController = TextEditingController();
  final NetworkDiscovery _networkDiscovery = NetworkDiscovery();
  final MultiplayerService _multiplayerService = MultiplayerService();
  
  // Game state management
  GameStateManager? _gameStateManager;
  StreamSubscription? _stateSubscription;
  String? _connectedCode;
  
  bool _isScanning = false;
  bool _isNavigating = false;
  List<String> _availableHosts = [];
  String? _statusMessage;
  
 @override
void initState() {
  super.initState();
  _multiplayerService.connectionStatus.listen((status) {
    if (mounted) {
      setState(() {
        _statusMessage = status;
      });
    }
  });
  
  // Add listener for game data updates with better error handling
  _multiplayerService.gameDataStream.listen(
    (data) {
      // Debug print
      print('Client received message: $data');
      
      // Safely handle game start notification
      if (data != null && 
          data is Map<String, dynamic> && 
          data['type'] == 'game_start') {
        print('Client received game start command');
        
        // Use the safer navigation method
        _safeNavigateToGame();
      }
    },
    onError: (error) {
      print('Error in game data stream: $error');
      if (mounted) {
        setState(() {
          _statusMessage = 'Connection error: $error';
        });
      }
    }
  );
}

  
  @override
  void dispose() {
    _codeController.dispose();
    _stateSubscription?.cancel();
    _multiplayerService.dispose();
    super.dispose();
  }
  
  Future<void> _scanForGames() async {
    setState(() {
      _isScanning = true;
      _availableHosts = [];
    });
    
    try {
      final hosts = await _networkDiscovery.scanNetwork(8888);
      
      setState(() {
        _availableHosts = hosts;
        // Always add the emulator host option
        if (!_availableHosts.contains('10.0.2.2')) {
          _availableHosts.add('10.0.2.2');
        }
        
        _isScanning = false;
        _statusMessage = hosts.isEmpty 
            ? 'No games found on local network. Try the emulator option (10.0.2.2).' 
            : 'Found ${hosts.length} potential hosts';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scan error: $e';
        // Add emulator host option even after error
        if (_availableHosts.isEmpty) {
          _availableHosts.add('10.0.2.2');
        }
      });
    }
  }
  
  Future<void> _joinGame(String hostIp) async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() {
        _statusMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }
    
    setState(() {
      _statusMessage = 'Connecting to host...';
    });
    
    final success = await _multiplayerService.joinGameSession(code, hostIp);
    
    if (success) {
      _connectedCode = code;
      // Wait for host to start the game
      setState(() {
        _statusMessage = 'Connected! Waiting for host to start the game...';
      });
    }
  }
  
  void _navigateToGame() {
    // Prevent multiple navigations
    if (_stateSubscription == null) return;
    
    _stateSubscription!.cancel();
    _stateSubscription = null;
    
    // Navigate to the game screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SyncTestGame(
          multiplayerService: _multiplayerService,
          isHost: false,
          gameCode: _connectedCode!,
        ),
      ),
    );
  }

  // Add this method to safely navigate to the game
void _safeNavigateToGame() {
  if (_isNavigating) return;
  _isNavigating = true;
  
  print('Preparing for safe navigation to game...');
  
  // Use Navigator.of(context).pushAndRemoveUntil for more stable navigation
  Future.delayed(Duration(milliseconds: 200), () {
    if (!mounted) {
      print('Widget not mounted, aborting navigation');
      _isNavigating = false;
      return;
    }
    
    try {
      print('Attempting navigation to SyncTestGame...');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SyncTestGame(
            multiplayerService: _multiplayerService,
            isHost: false,
            gameCode: _connectedCode ?? 'unknown',
          ),
        ),
      );
    } catch (e) {
      print('Navigation failed: $e');
      _isNavigating = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation error: $e')),
        );
      }
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Game"),
        backgroundColor: Colors.brown[700],
      ),
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter 6-digit game code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _scanForGames,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[400],
                      foregroundColor: Colors.white,
                    ),
                    child: _isScanning 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('FIND GAMES ON NETWORK'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _joinGame('10.0.2.2'), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('EMULATOR TEST'),
                ),
              ],
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.contains('error') || _statusMessage!.contains('Failed')
                      ? Colors.red
                      : _statusMessage!.contains('Connected!')
                          ? Colors.green[900]
                          : Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            const Text('Available Games:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: _availableHosts.isEmpty
                  ? const Center(child: Text('No games found'))
                  : ListView.builder(
                      itemCount: _availableHosts.length,
                      itemBuilder: (context, index) {
                        final isEmulator = _availableHosts[index] == '10.0.2.2';
                        return Card(
                          color: isEmulator ? Colors.amber[100] : null,
                          child: ListTile(
                            title: Text(isEmulator ? 'Emulator Test Host' : 'Game Host ${index + 1}'),
                            subtitle: Text(_availableHosts[index]),
                            trailing: const Icon(Icons.videogame_asset),
                            onTap: () => _joinGame(_availableHosts[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}