// START OF FULL REVISED FILE: lib/widgets/upgrade_item.dart
import 'package:flutter/material.dart';

// --- Пути к ассетам ---
const String upgradeRowBgPath = 'assets/images/upgrade_row_bg.png'; // Фон строки
// const String upgradeButtonActivePath = 'assets/images/upgrade_button_active.png'; // Старый путь, не используется
const String newLevelUpButtonPath = 'assets/images/upgrade_button_active.png'; // <--- ПУТЬ К НОВОЙ КНОПКЕ ИЗ КАРТИНКИ
const String cloutCoinPath = 'assets/images/clout_coin.png'; // Иконка валюты
// ---------------------

class UpgradeItemWidget extends StatefulWidget {
  final String title;
  final int cost;
  final int currentLevel;
  final double upgradeGain; // Используем double для прироста
  final int currentClout;
  final VoidCallback onUpgrade; // Функция, вызываемая при нажатии

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
  bool _isPressed = false; // Состояние для эффекта нажатия кнопки

  @override
  Widget build(BuildContext context) {
    final bool canAfford = widget.currentClout >= widget.cost; // Можно ли купить апгрейд?
    final double buttonScale = _isPressed ? 0.95 : 1.0; // Масштаб для эффекта нажатия
    final textTheme = Theme.of(context).textTheme; // Получаем стили текста из темы

    // --- Стили текста (используем фоллбэки на случай отсутствия темы) ---
    final titleStyle = textTheme.titleMedium?.copyWith(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5,
        ) ?? const TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5 );
    final detailStyle = textTheme.bodyMedium?.copyWith(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12,
        ) ?? const TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12 );
     final levelTextStyle = textTheme.bodySmall?.copyWith(
          color: Colors.grey[400], fontSize: 11,
     ) ?? TextStyle( color: Colors.grey[400], fontSize: 11 );
     const double iconSize = 14.0; // Размер иконки валюты

    // Стили для текста на кнопке
    final levelUpTextStyle = textTheme.labelLarge?.copyWith(
        fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF6A3A1B), // Темно-коричневый
    ) ?? const TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6A3A1B) );
     final gainTextStyle = textTheme.bodySmall?.copyWith(
        fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFD4A97B), // Более светлый коричнево-желтый для "+X"
    ) ?? const TextStyle( fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD4A97B) );
    // --------------------------------------------------------------------

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0), // Внешний отступ элемента
      height: 78, // Фиксированная высота
      child: Stack( // Используем Stack для наложения фона и контента
        alignment: Alignment.center,
        children: [
          // 1. Фон строки
          Positioned.fill(
            child: Image.asset(
              upgradeRowBgPath,
              fit: BoxFit.fill, // Растягиваем фон
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 2. Контент (информация и кнопка)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0, top: 6.0, bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Левая часть: Название, Стоимость, Уровень
                  Expanded(
                    flex: 10, // Занимает больше места
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text( widget.title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(cloutCoinPath, width: iconSize, height: iconSize),
                            const SizedBox(width: 4),
                            Flexible(child: Text(widget.cost.toString(), style: detailStyle, overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 10),
                            Text('Level ${widget.currentLevel}', style: levelTextStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Правая часть: Кнопка Level Up
                  Expanded(
                    flex: 5, // Занимает меньше места
                    child: GestureDetector( // Обрабатываем нажатия
                      onTapDown: canAfford ? (_) => setState(() => _isPressed = true) : null,
                      onTapUp: canAfford ? (_) { setState(() => _isPressed = false); widget.onUpgrade(); } : null,
                      onTapCancel: canAfford ? () => setState(() => _isPressed = false) : null,
                      child: Transform.scale( // Анимация нажатия
                        scale: buttonScale,
                        child: Opacity( // Делаем кнопку недоступной визуально
                          opacity: canAfford ? 1.0 : 0.6,
                          child: IgnorePointer( // Блокируем нажатия, если нельзя купить
                            ignoring: !canAfford,
                            child: Stack( // Stack для изображения кнопки и текстов на ней
                              alignment: Alignment.center,
                              children: [
                                // --- ИСПОЛЬЗУЕМ НОВЫЙ АССЕТ КНОПКИ ---
                                Image.asset(
                                  newLevelUpButtonPath, // <--- Вот здесь используется новая кнопка
                                  height: 55, // ПОДБЕРИТЕ ВЫСОТУ для вашей новой кнопки
                                  fit: BoxFit.contain, // Сохраняем пропорции
                                ),
                                // ------------------------------------

                                // Текст "Level Up" поверх кнопки
                                Positioned(
                                  top: 8, // ПОДБЕРИТЕ ОТСТУП сверху для текста
                                  child: Text('Level Up', style: levelUpTextStyle)
                                ),
                                // Текст "+Прирост" поверх кнопки
                                Positioned(
                                  bottom: 10, // ПОДБЕРИТЕ ОТСТУП снизу для текста
                                  // Используем toDouble() и форматирование для прироста
                                  child: Text(
                                    '+${widget.upgradeGain.toStringAsFixed(widget.upgradeGain.truncateToDouble() == widget.upgradeGain ? 1 : 2)}',
                                    style: gainTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// END OF FULL REVISED FILE: lib/widgets/upgrade_item.dart
