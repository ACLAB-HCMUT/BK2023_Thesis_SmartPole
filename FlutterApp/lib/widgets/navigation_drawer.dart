import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomNavigationDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const CustomNavigationDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  _CustomNavigationDrawerState createState() => _CustomNavigationDrawerState();
}

class _CustomNavigationDrawerState extends State<CustomNavigationDrawer> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 80, end: 250).animate(_animationController);
  }

  void _handleMouseEnter(bool isEntering) {
    setState(() {
      _isExpanded = isEntering;
      isEntering ? _animationController.forward() : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleMouseEnter(true),
      onExit: (_) => _handleMouseEnter(false),
      child: AnimatedBuilder(
        animation: _widthAnimation,
        builder: (context, child) {
          return Container(
            width: _widthAnimation.value,
            color: const Color(0xFF7A40F2),
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                _buildDrawerItem(0, Icons.home, 'Home'),
                _buildDrawerItem(1, Icons.apps, 'Main Dashboard'),
                _buildDrawerItem(2, Icons.lightbulb_outline, 'Light Control'),
                _buildDrawerItem(3, Icons.schedule, 'Lighting Schedule'),
                _buildDrawerItem(4, Icons.videocam, 'Security Cameras'),
                _buildDrawerItem(5, Icons.tv, 'Advertisement Schedule'),
                _buildDrawerItem(6, Icons.thermostat, 'Environmental Sensors'),
                _buildDrawerItem(7, Icons.bar_chart, 'Historical Data'),
                _buildDrawerItem(8, Icons.exit_to_app, 'Exit'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    bool isSelected = widget.selectedIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: const Color(0xFFF9F9F9),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(icon, color: Colors.white, size: 35),
      ),
      title: _isExpanded
          ? Text(
        title,
        style: TextStyle(fontSize: 20, color: isSelected ? Colors.black : Colors.white),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )
          : null,
      onTap: () => widget.onDestinationSelected(index),
    );
  }
}
