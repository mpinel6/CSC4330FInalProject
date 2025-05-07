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
  
  // Add the game data stream listener right here
  _multiplayerService.gameDataStream.listen(
  (data) {
    if (data != null && data is Map<String, dynamic>) {
      // Handle game start
      if (data['type'] == 'game_start') {
        _safeNavigateToGame();
      }
      // Handle game state update with cancellation flag
      else if (data['type'] == 'game_state_update' && 
              data.containsKey('data') &&
              data['data'] is Map<String, dynamic> &&
              data['data']['gameCancelled'] == true) {
        
        print("CLIENT: Detected game cancellation via state update");
        
        // Show message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Host canceled the game'))
        );
        
        // Reset connection
        _multiplayerService.resetConnection();
        
        // Restart page
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const JoinGamePage())
          );
        }
      }
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
  
  Future<void> _joinGame(String hostIp, String code) async {
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
    setState(() {
      _statusMessage = 'Connected! Waiting for host to start the game...';
    });
  }
}

void _showGameCodeDialog(String host, String deviceName) {
  final codeController = TextEditingController();
  bool isConnecting = false;
  bool isConnected = false;
  
  showDialog(
    context: context,
    barrierDismissible: true, // Always allow barrier dismissal
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        // REMOVE the problematic code block:
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (Navigator.canPop(context)) {
        //     Navigator.of(context).setCanPop(!isConnected);
        //   }
        // });
        
        // Wrap the AlertDialog with WillPopScope to control dismissibility
        return WillPopScope(
          // Only allow pop if not connected
          onWillPop: () async => !isConnected,
          child: AlertDialog(
            title: Text('Connect to $deviceName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter the 6-digit game code:'),
                const SizedBox(height: 8),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '000000',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  enabled: !isConnecting && !isConnected,
                ),
              ],
            ),
            // Rest of the dialog implementation remains unchanged
            actions: [
              // Only show Cancel button AFTER successful connection
              // if (isConnected) 
              //   TextButton(
              //     onPressed: () => Navigator.pop(context),
              //     child: Text('Cancel', style: TextStyle(color: Colors.black)),
              //   ),
              Center(
    child: ElevatedButton(
      // Fix the button implementation by adding actual functionality
      onPressed: isConnecting || isConnected ? null : () async {
        // Get the code and validate
        final code = codeController.text.trim();
        if (code.length != 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid 6-digit code'))
          );
          return;
        }
        
        // Set connecting state
        setState(() {
          isConnecting = true;
        });
        
        // Attempt to join game
        final success = await _multiplayerService.joinGameSession(code, host);
        
        // Handle result
        if (success) {
          // Update parent state
          _connectedCode = code;
          this.setState(() {
            _statusMessage = 'Connected! Waiting for host to start the game...';
          });
          
          // Update dialog state
          setState(() {
            isConnecting = false;
            isConnected = true;
          });
        } else {
          // Show error and reset
          setState(() {
            isConnecting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect. Please try again.'))
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected ? Colors.green[600] : Colors.brown[600],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: isConnecting 
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              ),
              const SizedBox(width: 12),
              const Text('Connecting...', style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ))
            ],
          )
        : isConnected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Success! Waiting for host...', style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              ],
            )
          : const Text(
              'Connect',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
    ),
  ),
            ],
          ),
        );
      },
    ),
  );
  
  // Set up listeners to close dialog on game events
// Set up listeners to close dialog on game events
_multiplayerService.gameDataStream.where((data) => 
  data is Map<String, dynamic> && 
  (data['type'] == 'game_start' || 
   (data['type'] == 'game_state_update' && 
    data.containsKey('data') && 
    data['data'] is Map<String, dynamic> &&
    data['data']['gameCancelled'] == true))
).listen((data) {
  if (!Navigator.canPop(context)) return;
  
  if (data['type'] == 'game_state_update' && 
      data['data']['gameCancelled'] == true) {
    Navigator.pop(context); // Close the dialog
  } else if (data['type'] == 'game_start') {
    Navigator.pop(context);
  }
});
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
            // TextField(
            //   controller: _codeController,
            //   decoration: const InputDecoration(
            //     labelText: 'Enter 6-digit game code',
            //     border: OutlineInputBorder(),
            //   ),
            //   keyboardType: TextInputType.number,
            //   maxLength: 6,
            // ),
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
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
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
                            onTap: () => _showGameCodeDialog(host, deviceName),
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