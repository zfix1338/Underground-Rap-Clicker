import 'package:flutter/material.dart';
import '../models.dart';

class UpgradeScreen extends StatelessWidget {
  final int monthlyListeners;
  final int baseListenersPerClick;
  final int passiveListenersPerSecond;
  final List<UpgradeItem> upgrades;
  final VoidCallback onClick;
  final Function(int) onLevelUp;

  const UpgradeScreen({
    Key? key,
    required this.monthlyListeners,
    required this.baseListenersPerClick,
    required this.passiveListenersPerSecond,
    required this.upgrades,
    required this.onClick,
    required this.onLevelUp,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onClick,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text(
                            "Monthly: $monthlyListeners",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "+$baseListenersPerClick / tap, +$passiveListenersPerSecond / sec",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey,
              child: ListView.builder(
                itemCount: upgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = upgrades[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                upgrade.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Type: ${upgrade.type}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Level: ${upgrade.level}",
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Cost: ${upgrade.cost}",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: monthlyListeners >= upgrade.cost 
                              ? () => onLevelUp(index) 
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            disabledBackgroundColor: Colors.grey.shade700,
                          ),
                          child: Text(
                            "Level Up\n+${upgrade.increment}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}