// lib/screens/upgrade_screen.dart
import 'package:flutter/material.dart';
import '../models.dart';

class UpgradeScreen extends StatelessWidget {
  final int monthlyListeners;
  final int baseListenersPerClick;
  final int passiveListenersPerSecond;
  final List<UpgradeItem> upgrades;
  final VoidCallback onClick;
  final Function(int index) onLevelUp;

  const UpgradeScreen({
    super.key,
    required this.monthlyListeners,
    required this.baseListenersPerClick,
    required this.passiveListenersPerSecond,
    required this.upgrades,
    required this.onClick,
    required this.onLevelUp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text("Upgrade"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "Monthly Listeners: $monthlyListeners",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onClick,
            child: Text("Click (+$baseListenersPerClick)"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = upgrades[index];
                return ListTile(
                  title: Text(
                    upgrade.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Level: ${upgrade.level}  Cost: ${upgrade.cost}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => onLevelUp(index),
                    child: const Text("Upgrade"),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
