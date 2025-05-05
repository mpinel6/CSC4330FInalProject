import 'package:flutter/material.dart';
import 'dart:async';

mixin CollapsibleNavigationBarMixin<T extends StatefulWidget> on State<T> {
  bool _isNavBarVisible = false;
  Timer? _navBarTimer;

  void _startNavBarTimer() {
    _navBarTimer?.cancel();
    _navBarTimer = Timer(const Duration(seconds: 3), () {
      if (_isNavBarVisible && mounted) {
        setState(() {
          _isNavBarVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _navBarTimer?.cancel();
    super.dispose();
  }

  Widget buildCollapsibleNavigationBar(int selectedIndex, Function(int) onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isNavBarVisible ? 56.0 : 15.0,
      child: Column(
        children: [
          // Handle for expanding/collapsing
          GestureDetector(
            onTap: () {
              setState(() {
                _isNavBarVisible = !_isNavBarVisible;
                if (_isNavBarVisible) {
                  _startNavBarTimer();
                }
              });
            },
            child: Container(
              height: 15.0,
              decoration: const BoxDecoration(
                color: Color(0xFFD6D6D6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              child: Center(
                child: Icon(
                  _isNavBarVisible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: const Color(0xFF232323),
                  size: 18.0,
                ),
              ),
            ),
          ),
          // Actual navigation bar
          if (_isNavBarVisible)
            Expanded(
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    label: 'Rules',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
                currentIndex: selectedIndex,
                selectedItemColor: Color(0xFF232323),
                unselectedItemColor: Color(0xFFB0B0B0),
                backgroundColor: Color(0xFFD6D6D6),
                onTap: onTap,
              ),
            ),
        ],
      ),
    );
  }
}