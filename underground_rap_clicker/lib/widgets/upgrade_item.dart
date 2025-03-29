import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Пути к ассетам (используйте ваши реальные имена файлов) ---
const String upgradeRowBgPath = 'assets/images/upgrade_row_bg.png';
const String upgradeButtonActivePath = 'assets/images/upgrade_button_active.png';
const String cloutCoinPath = 'assets/images/clout_coin.png';
// ---------------------------------------------

class UpgradeItemWidget extends StatefulWidget {
  final String title;
  final int cost;
  final int currentLevel;
  final double upgradeGain;
  final int currentClout;
  final VoidCallback onUpgrade;

  const UpgradeItemWidget({
    super.key,
    required this.title,
    required this.cost,
    required this.currentLevel,
    required this.upgradeGain,
    required this.currentClout,
    required this.onUpgrade,
  });

  @override
  State<UpgradeItemWidget> createState() => _UpgradeItemWidgetState();
}

class _UpgradeItemWidgetState extends State<UpgradeItemWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool canAfford = widget.currentClout >= widget.cost;
    final double buttonScale = _isPressed ? 0.95 : 1.0;

    // Стили текста (уже используют Galindo из темы)
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
        );
    final detailStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );
     final levelTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[400],
          fontSize: 11,
     );
     const double iconSize = 14.0;

    // Стили для кнопки (можно использовать GoogleFonts явно, если нужно)
    final levelUpTextStyle = GoogleFonts.galindo(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6A3A1B), // Темно-коричневый из кнопки
    );
     final gainTextStyle = GoogleFonts.galindo(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFF0B0), // Светло-желтый из кнопки
    );


    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      height: 78, // Высота строки
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Фон строки
          Image.asset(
            upgradeRowBgPath,
            fit: BoxFit.fill,
            width: double.infinity,
          ),

          // 2. Контент
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0, top: 6.0, bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Левая часть: Название, Стоимость, Уровень
                  Expanded(
                    flex: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: titleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(cloutCoinPath, width: iconSize, height: iconSize),
                            const SizedBox(width: 4),
                            Text(widget.cost.toString(), style: detailStyle),
                            const SizedBox(width: 8),
                            Text('Level ${widget.currentLevel}', style: levelTextStyle),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1), // Небольшой отступ

                  // Правая часть: Кнопка Level Up
                  // --- Возвращаем логику с GestureDetector и спрайтом ---
                  Expanded(
                    flex: 5,
                    child: GestureDetector( // Обертка для обработки нажатий
                      onTapDown: canAfford ? (_) => setState(() => _isPressed = true) : null,
                      onTapUp: canAfford ? (_) {
                        setState(() => _isPressed = false);
                        widget.onUpgrade(); // Вызов функции апгрейда
                      } : null,
                      onTapCancel: canAfford ? () => setState(() => _isPressed = false) : null,
                      child: Transform.scale( // Для эффекта нажатия
                        scale: buttonScale,
                        child: Stack( // Используем Stack для наложения текста на спрайт
                          alignment: Alignment.center,
                          children: [
                            // Спрайт кнопки (окрашивается если недоступно)
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                canAfford ? Colors.transparent : Colors.grey,
                                canAfford ? BlendMode.dst : BlendMode.saturation,
                              ),
                              child: Image.asset(
                                upgradeButtonActivePath, // Путь к спрайту кнопки
                                height: 48, // Высота спрайта кнопки
                                fit: BoxFit.contain, // Или BoxFit.fill
                              ),
                            ),
                            // Текст "Level Up" поверх спрайта
                            Positioned(
                              top: 5, // Точная подгонка положения
                              child: Text('Level Up', style: levelUpTextStyle),
                            ),
                            // Текст "+ Прирост" поверх спрайта
                            Positioned(
                              bottom: 8, // Точная подгонка положения
                              child: Text(
                                '+${widget.upgradeGain.toStringAsFixed(widget.upgradeGain.truncateToDouble() == widget.upgradeGain ? 1 : 2)}', // Показываем .0 если целое
                                style: gainTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ------------------------------------------------------
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// END OF MODIFIED FILE underground_rap_clicker/lib/widgets/upgrade_item.dart