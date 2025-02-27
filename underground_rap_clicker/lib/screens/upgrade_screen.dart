import 'dart:math';
import 'package:flutter/material.dart';
import '../models.dart';

class UpgradeScreen extends StatefulWidget {
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
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.02, -0.02),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // При нажатии на персонажа запускается анимация и вызывается onClick
  void _handleCharacterTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Фон через Stack
      body: Stack(
        children: [
          // Фоновое изображение
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // Компактная верхняя панель
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: Colors.black.withOpacity(0.6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Монеты: ${widget.monthlyListeners}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "+${widget.baseListenersPerClick} / tap, +${widget.passiveListenersPerSecond} / сек",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Зона с персонажем и анимацией
              Expanded(
                flex: 3,
                child: Center(
                  child: GestureDetector(
                    onTap: _handleCharacterTap,
                    child: AnimatedBuilder(
                      animation: _offsetAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _offsetAnimation.value * 50,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/images/osama.png',
                        width: 200,
                        height: 300,
                      ),
                    ),
                  ),
                ),
              ),
              // Список апгрейдов
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black.withOpacity(0.7),
                  child: ListView.builder(
                    itemCount: widget.upgrades.length,
                    itemBuilder: (context, index) {
                      final upgrade = widget.upgrades[index];
                      bool isUnlocked = true;
                      // Для "Extra Click Boost" проверяем зависимость от "Make New Beat"
                      if (upgrade.title == 'Extra Click Boost') {
                        final makeNewBeat = widget.upgrades.firstWhere(
                          (u) => u.title == 'Make New Beat',
                          orElse: () => UpgradeItem(title: '', type: 'click', level: 0, cost: 0, increment: 0),
                        );
                        if (makeNewBeat.level < 10) {
                          isUnlocked = false;
                        }
                      }
                      // Вычисляем текст кнопки: для click-апгрейдов показываем следующий бонус по формуле: 1.0 + 0.2 * текущий уровень
                      String buttonText;
                      if (upgrade.type == 'click') {
                        double nextBonus = 1.0 + 0.2 * upgrade.level;
                        buttonText = isUnlocked
                            ? "Level Up\n+${nextBonus.toStringAsFixed(1)}"
                            : "Unlock at Lvl 10 (Make New Beat)";
                      } else {
                        buttonText = "Level Up\n+${upgrade.increment}";
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Информация об апгрейде
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
                                    "Тип: ${upgrade.type}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Уровень: ${upgrade.level}",
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Стоимость: ${upgrade.cost}",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Кнопка повышения уровня
                            ElevatedButton(
                              onPressed: (widget.monthlyListeners >= upgrade.cost && isUnlocked)
                                  ? () => widget.onLevelUp(index)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                disabledBackgroundColor: Colors.grey.shade700,
                              ),
                              child: Text(
                                buttonText,
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
        ],
      ),
    );
  }
}