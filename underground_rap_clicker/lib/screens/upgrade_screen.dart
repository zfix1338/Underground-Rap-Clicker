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
    return Column(
      children: [
        // Верхняя панель
        Container(
          height: 80,
          color: Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'monthly listeners: $monthlyListeners',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '+$baseListenersPerClick/click | +$passiveListenersPerSecond/s',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Основная область: белая зона для кликов и список апгрейдов
        Expanded(
          child: Column(
            children: [
              // Белая зона (50% экрана)
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: onClick,
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: const Text(
                      'Tap Here',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              // Список апгрейдов (50% экрана)
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.grey[700],
                  child: ListView.builder(
                    itemCount: upgrades.length,
                    itemBuilder: (context, index) {
                      final item = upgrades[index];
                      final labelType = (item.type == 'click') ? 'Click Upgrade' : 'Passive';
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey[600],
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[400],
                              child: const Icon(Icons.image, color: Colors.black54),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item.title}\n$labelType\nlv. ${item.level} | cost: ${item.cost}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => onLevelUp(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[500],
                              ),
                              child: Text(
                                'Level Up\n+${item.increment}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
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
        ),
      ],
    );
  }
}