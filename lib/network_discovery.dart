import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkDiscovery {
  final NetworkInfo _networkInfo = NetworkInfo();
  
  // Get the IP address of the current device
  Future<String?> getLocalIpAddress() async {
    return await _networkInfo.getWifiIP();
  }
  
  // Scan the local network for potential game hosts
  Future<List<String>> scanNetwork(int port) async {
    final ipAddress = await getLocalIpAddress();
    
    if (ipAddress == null) return [];
    
    // Extract the subnet (first 3 octets of the IP)
    final parts = ipAddress.split('.');
    if (parts.length != 4) return [];
    
    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
    final List<String> activeHosts = [];
    final List<Future<void>> scanFutures = [];
    
    // Scan the local network (1-254)
    for (int i = 1; i < 255; i++) {
      final host = '$subnet.$i';
      
      // Skip own IP
      if (host == ipAddress) continue;
      
      scanFutures.add(
        _checkHost(host, port).then((isActive) {
          if (isActive) {
            activeHosts.add(host);
          }
        })
      );
    }
    
    // Wait for all scans to complete (with timeout)
    await Future.wait(scanFutures)
        .timeout(const Duration(seconds: 3), onTimeout: () {
          return [];
        });
    
    // Return the list of active hosts
    return activeHosts;
  }
  
  // Check if a specific host has the game port open
  Future<bool> _checkHost(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, 
          timeout: const Duration(milliseconds: 300));
      await socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Add this method to get hosts with their device names
Future<Map<String, String>> getHostsWithNames(int port) async {
  final Map<String, String> hostsWithNames = {};
  
  // Get list of available hosts
  final List<String> hosts = await scanNetwork(port);
  
  // For each host, try to get its device name
  for (String host in hosts) {
    try {
      // Connect to the host
      final socket = await Socket.connect(host, port,
          timeout: const Duration(seconds: 1));
      
      // Request device info
      socket.write(jsonEncode({
        'type': 'device_info_request'
      }) + '\n');
      
      // Add to map with temporary name, will update when we get response
      hostsWithNames[host] = 'Host';
      
      // Listen for response
      socket.listen(
        (data) {
          try {
            final messages = utf8.decode(data).split('\n').where((m) => m.isNotEmpty);
            
            for (final rawMessage in messages) {
              try {
                final message = jsonDecode(rawMessage);
                if (message['type'] == 'device_info_response' && 
                    message.containsKey('deviceName')) {
                  hostsWithNames[host] = message['deviceName'];
                }
              } catch (e) {
                print('Error parsing message: $e');
              }
            }
          } catch (e) {
            print('Error processing response: $e');
          }
        },
        onDone: () {
          socket.close();
        },
        onError: (e) {
          print('Socket error: $e');
          socket.close();
        }
      );
      
      // Wait a bit for response before moving on
      await Future.delayed(const Duration(milliseconds: 300));
      
    } catch (e) {
      print('Error getting device name: $e');
      // If we can't get device info, still add the host with default name
      hostsWithNames[host] = 'Unknown Device';
    }
  }
  
  return hostsWithNames;
}
}