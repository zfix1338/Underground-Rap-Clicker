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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Сделаем большую белую зону (2/3 экрана),
    // в верхней части которой компактный счётчик,
    // а остальное пространство – зона для тапа.

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Upgrade'),
      ),
      body: Column(
        children: [
          // Белая зона (2/3 высоты)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Счётчик наверху
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
                  // Остальное пространство – тапаем, чтобы увеличить
                  Expanded(
                    child: GestureDetector(
                      onTap: onClick,
                      child: Center(
                        child: Text(
                          "Tap Here!",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Список апгрейдов (1/3 высоты)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[850],
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
                    color: Colors.grey[900],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Описание апгрейда
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
                          onPressed: () => onLevelUp(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
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
