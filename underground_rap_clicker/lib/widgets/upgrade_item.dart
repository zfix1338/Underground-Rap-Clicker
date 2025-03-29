// START OF FULL FILE: lib/widgets/upgrade_item.dart
import 'package:flutter/material.dart';

// --- Пути к ассетам ---
const String upgradeRowBgPath = 'assets/images/upgrade_row_bg.png';
const String upgradeButtonActivePath = 'assets/images/upgrade_button_active.png';
const String cloutCoinPath = 'assets/images/clout_coin.png';
// ---------------------

class UpgradeItemWidget extends StatefulWidget {
  final String title;
  final int cost;
  final int currentLevel;
  final double upgradeGain;
  final int currentClout;
  final VoidCallback onUpgrade; // Колбэк для нажатия кнопки

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

    // Получаем текстовую тему (шрифт Galindo должен быть применен глобально в main.dart)
    final textTheme = Theme.of(context).textTheme;

    // --- Определяем стили на основе темы ---
    // Используем ?. для безопасного доступа и ?? для фоллбэка, если стиль не определен в теме
    final titleStyle = textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
          // fontFamily: 'Galindo', // Раскомментируйте, если тема не применилась
        ) ?? const TextStyle( // Фоллбэк стиль
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5
        );

    final detailStyle = textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          // fontFamily: 'Galindo',
        ) ?? const TextStyle( // Фоллбэк стиль
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12
        );

     final levelTextStyle = textTheme.bodySmall?.copyWith(
          color: Colors.grey[400],
          fontSize: 11,
          // fontFamily: 'Galindo',
     ) ?? TextStyle( // Фоллбэк стиль
          color: Colors.grey[400], fontSize: 11
     );

     const double iconSize = 14.0;

    // Стили для кнопки
    final levelUpTextStyle = textTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6A3A1B), // Темно-коричневый
        // fontFamily: 'Galindo',
    ) ?? const TextStyle( // Фоллбэк стиль
        fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6A3A1B)
    );

     final gainTextStyle = textTheme.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFF0B0), // Светло-желтый
        // fontFamily: 'Galindo',
    ) ?? const TextStyle( // Фоллбэк стиль
        fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFFF0B0)
    );
    // -----------------------------------------


    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0), // Отступ между элементами списка
      height: 78, // Фиксированная высота элемента
      child: Stack( // Используем Stack для наложения фона и контента
        alignment: Alignment.center,
        children: [
          // 1. Фон строки
          Positioned.fill( // Растягиваем фон на весь контейнер
            child: Image.asset(
              upgradeRowBgPath,
              fit: BoxFit.fill, // Масштабируем, чтобы заполнить, может исказить пропорции
              width: double.infinity, // Не обязательно с Positioned.fill
              height: double.infinity, // Не обязательно с Positioned.fill
            ),
          ),

          // 2. Контент строки (информация и кнопка)
          Positioned.fill( // Контент тоже растягиваем
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0, top: 6.0, bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Разносим левую и правую часть
                crossAxisAlignment: CrossAxisAlignment.center, // Выравниваем по вертикали
                children: [
                  // Левая часть: Название, Стоимость, Уровень
                  Expanded(
                    flex: 10, // Даем больше места левой части (примерно 2/3)
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Текст слева
                      mainAxisAlignment: MainAxisAlignment.center, // Центрируем колонку по вертикали
                      children: [
                        Text( widget.title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis ), // Название (1 строка)
                        const SizedBox(height: 5),
                        Row( // Стоимость и Уровень в строку
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(cloutCoinPath, width: iconSize, height: iconSize), // Иконка монеты
                            const SizedBox(width: 4),
                            Flexible(child: Text(widget.cost.toString(), style: detailStyle, overflow: TextOverflow.ellipsis)), // Стоимость (может быть длинной)
                            const SizedBox(width: 10),
                            Text('Level ${widget.currentLevel}', style: levelTextStyle), // Уровень
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Правая часть: Кнопка Улучшения
                  Expanded(
                    flex: 5, // Меньше места кнопке (примерно 1/3)
                    child: GestureDetector(
                      // Обработчики нажатия для визуального эффекта и действия
                      onTapDown: canAfford ? (_) => setState(() => _isPressed = true) : null,
                      onTapUp: canAfford ? (_) {
                        setState(() => _isPressed = false);
                        widget.onUpgrade(); // Вызов колбэка при отпускании
                      } : null,
                      onTapCancel: canAfford ? () => setState(() => _isPressed = false) : null,
                      child: Transform.scale( // Эффект нажатия (уменьшение)
                        scale: buttonScale,
                        child: Opacity( // Делаем кнопку полупрозрачной, если нельзя купить
                          opacity: canAfford ? 1.0 : 0.6, // Уменьшаем прозрачность если нельзя купить
                          child: IgnorePointer( // Игнорируем нажатия, если нельзя купить
                            ignoring: !canAfford,
                            child: Stack( // Stack для кнопки: фон + тексты
                              alignment: Alignment.center,
                              children: [
                                // Спрайт кнопки
                                Image.asset( upgradeButtonActivePath, height: 48, fit: BoxFit.contain ),
                                // Текст "Level Up" сверху
                                Positioned( top: 5, child: Text('Level Up', style: levelUpTextStyle) ),
                                // Текст "+ Прирост" снизу
                                Positioned( bottom: 8, child: Text(
                                    // Форматируем число: .0 если целое, .xx если дробное
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
// END OF FULL FILE: lib/widgets/upgrade_item.dart