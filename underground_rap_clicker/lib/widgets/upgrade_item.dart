// START OF CORRECTED FILE underground_rap_clicker/lib/widgets/upgrade_item.dart
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Убедитесь, что эта строка удалена или закомментирована

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

    // Получаем текстовую тему (шрифт Galindo применен глобально в main.dart)
    final textTheme = Theme.of(context).textTheme;

    // --- Определяем стили на основе темы ---
    final titleStyle = textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
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

    // Стили для кнопки, также на основе темы. Убраны явные вызовы GoogleFonts
    final levelUpTextStyle = textTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6A3A1B),
        // fontFamily: 'Galindo', // Можно раскомментировать, если шрифт темы не подхватывается
    );
     final gainTextStyle = textTheme.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFF0B0),
        // fontFamily: 'Galindo', // Можно раскомментировать, если шрифт темы не подхватывается
    );
    // -----------------------------------------


    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      height: 78,
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
                  // Левая часть
                  Expanded(
                    flex: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text( widget.title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis ),
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
                  const Spacer(flex: 1),

                  // Правая часть (Кнопка)
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTapDown: canAfford ? (_) => setState(() => _isPressed = true) : null,
                      onTapUp: canAfford ? (_) { setState(() => _isPressed = false); widget.onUpgrade(); } : null,
                      onTapCancel: canAfford ? () => setState(() => _isPressed = false) : null,
                      child: Transform.scale(
                        scale: buttonScale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Спрайт кнопки
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                canAfford ? Colors.transparent : Colors.grey,
                                canAfford ? BlendMode.dst : BlendMode.saturation,
                              ),
                              child: Image.asset( upgradeButtonActivePath, height: 48, fit: BoxFit.contain ),
                            ),
                            // Текст "Level Up"
                            Positioned( top: 5, child: Text('Level Up', style: levelUpTextStyle) ),
                            // Текст "+ Прирост"
                            Positioned( bottom: 8, child: Text(
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
// END OF CORRECTED FILE underground_rap_clicker/lib/widgets/upgrade_item.dart