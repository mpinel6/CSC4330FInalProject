import 'dart:async';
import 'package:flutter/material.dart';
import 'multiplayer.dart';
import 'network_discovery.dart';
import 'lan_card_game.dart';

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
  StreamSubscription? _stateSubscription;
  String? _connectedCode;
  
  bool _isScanning = false;
  bool _isNavigating = false;
  // FIXED: Changed from List<String> to Map<String, String> for IP->name mapping
  final Map<String, String> _availableHosts = {};
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
      // print('Client received message: $data');
      
      // Safely handle game start notification
      if (data != null && 
          data is Map<String, dynamic> && 
          data['type'] == 'game_start') {
        // print('Client received game start command');
        
        // Use the safer navigation method
        _safeNavigateToGame();
      }
    },
    onError: (error) {
      // print('Error in game data stream: $error');
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
    super.dispose();
  }
  
  // FIXED: Removed duplicate declaration of _availableHosts

void _scanForGames() async {
  setState(() {
    _isScanning = true;
    _statusMessage = 'Scanning for games...';
    _availableHosts.clear();
  });
  
  try {
    // Replace scanNetwork with getHostsWithNames to retrieve actual device names
    final Map<String, String> hostsWithNames = await _networkDiscovery.getHostsWithNames(8888);
    
    setState(() {
      // Use the actual device names returned by getHostsWithNames
      _availableHosts.addAll(hostsWithNames);
      _isScanning = false;
      _statusMessage = _availableHosts.isEmpty 
        ? 'No games found on local network.' 
        : 'Found ${_availableHosts.length} available games';
    });
  } catch (e) {
    setState(() {
      _isScanning = false;
      _statusMessage = 'Error scanning: $e';
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
  
  // FIXED: Removed unused _navigateToGame method

  // Safe navigation method
  void _safeNavigateToGame() {
    if (_isNavigating) return;
    _isNavigating = true;
    
    // Use Navigator.of(context).pushAndRemoveUntil for more stable navigation
    Future.delayed(Duration(milliseconds: 200), () {
      if (!mounted) {
        _isNavigating = false;
        return;
      }
      
      try {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LanCardGame(
              multiplayerService: _multiplayerService,
              isHost: false,
              gameCode: _connectedCode ?? 'unknown',
            ),
          ),
        );
      } catch (e) {
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
                        // FIXED: Properly access Map keys and values
                        final host = _availableHosts.keys.elementAt(index);
                        final deviceName = _availableHosts[host] ?? 'Unknown Device';
                        
                        return Card(
                          child: ListTile(
                            title: Text(deviceName),
                            subtitle: Text(host),
                            trailing: const Icon(Icons.videogame_asset),
                            onTap: () => _joinGame(host),
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