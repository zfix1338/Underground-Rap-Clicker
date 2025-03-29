// START OF FULL FILE underground_rap_clicker/lib/screens/upgrade_screen.dart
import 'package:flutter/material.dart';
import '../models.dart'; // Убедитесь, что путь к models.dart верный
import '../widgets/upgrade_item.dart'; // Убедитесь, что путь к upgrade_item.dart верный

// --- Пути к ассетам (Проверьте имена ваших файлов!) ---
const String gameBackgroundPath = 'assets/images/game_background.png';
const String clickableRapperPath = 'assets/images/clickable_rapper.png';
const String cloutCoinPath = 'assets/images/clout_coin.png';
// ------------------------------------------------------

// --- Убедитесь, что класс называется ИМЕННО ТАК и наследуется от StatelessWidget ---
class UpgradeScreen extends StatelessWidget {
  final int monthlyListeners;
  final int baseListenersPerClick;
  final int passiveListenersPerSecond;
  final List<UpgradeItem> upgrades;
  final VoidCallback onClick;
  final Function(int) onLevelUp;

  // --- Убедитесь, что конструктор называется ТАК ЖЕ, как класс ---
  const UpgradeScreen({
    super.key,
    required this.monthlyListeners,
    required this.baseListenersPerClick,
    required this.passiveListenersPerSecond,
    required this.upgrades,
    required this.onClick,
    required this.onLevelUp,
  });
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final counterTextStyle = textTheme.bodyMedium?.copyWith(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13,
      shadows: [ Shadow( blurRadius: 2.0, color: Colors.black.withOpacity(0.7), offset: const Offset(1.0, 1.0)) ]
    );
    final mainCounterStyle = textTheme.headlineSmall?.copyWith(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,
      shadows: [ Shadow( blurRadius: 3.0, color: Colors.black.withOpacity(0.8), offset: const Offset(1.5, 1.5)) ]
    );

    // Основная структура Column
    return Column(
      children: [
        // --- Верхняя секция ---
        Expanded(
          flex: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Фоновое изображение
              Positioned.fill(
                child: Image.asset( gameBackgroundPath, fit: BoxFit.cover, alignment: Alignment.topCenter ),
              ),
              // Верхний ряд счетчиков
              Positioned(
                top: 5, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.touch_app, color: Colors.white, size: 16), const SizedBox(width: 4),
                          Text('+${baseListenersPerClick}/tap', style: counterTextStyle),
                        ] ),
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          Image.asset(cloutCoinPath, width: 24, height: 24), const SizedBox(width: 8),
                          Text(monthlyListeners.toString(), style: mainCounterStyle),
                        ] ),
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.timer, color: Colors.white, size: 16), const SizedBox(width: 4),
                          Text('+${passiveListenersPerSecond}/sec', style: counterTextStyle),
                        ] ),
                    ],
                  ),
                ),
              ),
              // Кликабельный Рэпер
              Center(
                child: GestureDetector(
                  onTap: onClick,
                  child: Image.asset( clickableRapperPath, height: MediaQuery.of(context).size.height * 0.30, fit: BoxFit.contain ),
                ),
              ),
            ],
          ),
        ),
        // --- Нижняя секция (Список апгрейдов) ---
        Expanded(
          flex: 6,
          child: Container(
            color: Colors.grey[850], // Серый фон для списка
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0, left: 15.0, right: 15.0, top: 10.0),
              child: ListView.builder(
                itemCount: upgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = upgrades[index];
                  // Используем виджет UpgradeItemWidget
                  return UpgradeItemWidget(
                    key: ValueKey(upgrade.title + upgrade.level.toString()),
                    title: upgrade.title,
                    cost: upgrade.cost,
                    currentLevel: upgrade.level,
                    upgradeGain: upgrade.increment.toDouble(),
                    currentClout: monthlyListeners,
                    onUpgrade: () => onLevelUp(index),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// END OF FULL FILE underground_rap_clicker/lib/screens/upgrade_screen.dart