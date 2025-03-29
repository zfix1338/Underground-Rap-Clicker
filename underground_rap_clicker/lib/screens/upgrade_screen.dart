// START OF FULL UPDATED FILE underground_rap_clicker/lib/widgets/upgrade_item.dart
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Убран импорт GoogleFonts

// --- Пути к ассетам (убедитесь, что имена файлов верны) ---
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

    // Получаем текстовую тему (шрифт Galindo уже применен глобально)
    final textTheme = Theme.of(context).textTheme;

    // --- Определяем стили на основе темы ---
    // Используем подходящие базовые стили и настраиваем их
    final titleStyle = textTheme.titleMedium?.copyWith( // titleMedium может подойти лучше для заголовка
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.5, // Размер, подобранный ранее
        );
    final detailStyle = textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );
     final levelTextStyle = textTheme.bodySmall?.copyWith(
          color: Colors.grey[400],
          fontSize: 11,
     );
     const double iconSize = 14.0;

    // Стили для кнопки, также на основе темы
    final levelUpTextStyle = textTheme.labelLarge?.copyWith( // labelLarge часто используется для кнопок
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6A3A1B), // Темно-коричневый цвет текста кнопки
        fontFamily: 'Galindo', // Можно явно указать, если тема не применилась
    );
     final gainTextStyle = textTheme.bodySmall?.copyWith( // bodySmall или labelMedium для подписи
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFF0B0), // Светло-желтый цвет текста прироста
        fontFamily: 'Galindo', // Можно явно указать
    );
    // -----------------------------------------


    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0), // Вертикальный отступ между рядами
      height: 78, // Высота ряда (может потребоваться подстройка)
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Фоновое изображение ряда
          Image.asset(
            upgradeRowBgPath, // Путь к фону ряда
            fit: BoxFit.fill,   // Растянуть фон на весь контейнер
            width: double.infinity,
          ),

          // 2. Контент поверх фона
          Positioned.fill(
            child: Padding(
              // Внутренние отступы контента от краев фона
              padding: const EdgeInsets.only(left: 15.0, right: 10.0, top: 6.0, bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Распределить место
                crossAxisAlignment: CrossAxisAlignment.center,      // Выровнять по вертикали
                children: [
                  // Левая часть: Название, Стоимость, Уровень
                  Expanded(
                    flex: 10, // Дать больше места тексту
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,  // Выровнять текст влево
                      mainAxisAlignment: MainAxisAlignment.center, // Центрировать по вертикали
                      children: [
                        // Название апгрейда
                        Text(
                          widget.title,
                          style: titleStyle,
                          maxLines: 2, // Позволить перенос на 2 строки
                          overflow: TextOverflow.ellipsis, // Многоточие, если не влезает
                        ),
                        const SizedBox(height: 3), // Маленький отступ
                        // Строка со стоимостью и уровнем
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(cloutCoinPath, width: iconSize, height: iconSize), // Иконка монеты
                            const SizedBox(width: 4),
                            Text(widget.cost.toString(), style: detailStyle), // Стоимость
                            const SizedBox(width: 8),
                            Text('Level ${widget.currentLevel}', style: levelTextStyle), // Уровень
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1), // Небольшой гибкий отступ

                  // Правая часть: Кнопка Level Up
                  Expanded(
                    flex: 5, // Дать меньше места кнопке
                    child: GestureDetector( // Для обработки нажатий
                      onTapDown: canAfford ? (_) => setState(() => _isPressed = true) : null, // Нажатие вниз (если можно купить)
                      onTapUp: canAfford ? (_) { // Отпускание пальца (если можно купить)
                        setState(() => _isPressed = false);
                        widget.onUpgrade(); // Вызов функции апгрейда
                      } : null,
                      onTapCancel: canAfford ? () => setState(() => _isPressed = false) : null, // Отмена нажатия
                      child: Transform.scale( // Для визуального эффекта нажатия
                        scale: buttonScale,
                        child: Stack( // Для наложения текста на спрайт кнопки
                          alignment: Alignment.center,
                          children: [
                            // Спрайт кнопки
                            ColorFiltered( // Применяем фильтр, если нельзя купить
                              colorFilter: ColorFilter.mode(
                                canAfford ? Colors.transparent : Colors.grey, // Прозрачный или серый
                                canAfford ? BlendMode.dst : BlendMode.saturation, // Режим наложения
                              ),
                              child: Image.asset(
                                upgradeButtonActivePath, // Путь к спрайту кнопки
                                height: 48, // Высота кнопки
                                fit: BoxFit.contain, // Масштабирование спрайта
                              ),
                            ),
                            // Текст "Level Up" поверх кнопки
                            Positioned(
                              top: 5, // Подгонка положения текста
                              child: Text('Level Up', style: levelUpTextStyle),
                            ),
                            // Текст "+ Прирост" поверх кнопки
                            Positioned(
                              bottom: 8, // Подгонка положения текста
                              child: Text(
                                // Форматируем число: показываем .0 только если нужно
                                '+${widget.upgradeGain.toStringAsFixed(widget.upgradeGain.truncateToDouble() == widget.upgradeGain ? 1 : 2)}',
                                style: gainTextStyle,
                              ),
                            ),
                          ],
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
// END OF FULL UPDATED FILE underground_rap_clicker/lib/widgets/upgrade_item.dart