import 'package:flutter/material.dart';
import 'multiplayer.dart';
import 'network_discovery.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({super.key});

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  final TextEditingController _codeController = TextEditingController();
  final NetworkDiscovery _networkDiscovery = NetworkDiscovery();
  final MultiplayerService _multiplayerService = MultiplayerService();
  bool _isScanning = false;
  List<String> _availableHosts = [];
  String? _statusMessage;
  
  @override
  void initState() {
    super.initState();
    _multiplayerService.connectionStatus.listen((status) {
      setState(() {
        _statusMessage = status;
      });
    });
  }
  
  @override
  void dispose() {
    _codeController.dispose();
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
        _isScanning = false;
        _statusMessage = hosts.isEmpty 
            ? 'No games found on local network' 
            : 'Found ${hosts.length} potential hosts';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scan error: $e';
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
      // Navigate to game screen
      // Navigator.of(context).push(...);
    }
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
            ElevatedButton(
              onPressed: _isScanning ? null : _scanForGames,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[400],
                foregroundColor: Colors.white,
              ),
              child: _isScanning 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('FIND GAMES ON LOCAL NETWORK'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.contains('error') || _statusMessage!.contains('Failed')
                      ? Colors.red
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
                        return Card(
                          child: ListTile(
                            title: Text('Game Host ${index + 1}'),
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