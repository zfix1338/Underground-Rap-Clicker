// START OF FULL UPDATED FILE underground_rap_clicker/lib/screens/upgrade_screen.dart
import 'package:flutter/material.dart';
import '../models.dart'; // Убедитесь, что путь к models.dart верный
import '../widgets/upgrade_item.dart'; // Убедитесь, что путь к upgrade_item.dart верный

// --- Пути к ассетам (Проверьте имена ваших файлов!) ---
const String gameBackgroundPath = 'assets/images/game_background.png';
const String clickableRapperPath = 'assets/images/clickable_rapper.png';
const String cloutCoinPath = 'assets/images/clout_coin.png';
// ------------------------------------------------------

// --- Класс экрана апгрейдов ---
class UpgradeScreen extends StatelessWidget {
  // Входные данные и колбэки от родительского виджета (MainScreen)
  final int monthlyListeners;
  final int baseListenersPerClick;
  final int passiveListenersPerSecond;
  final List<UpgradeItem> upgrades;
  final VoidCallback onClick; // Функция, вызываемая при клике на рэпера
  final Function(int) onLevelUp; // Функция, вызываемая при нажатии на кнопку апгрейда

  // Конструктор
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
    // Получаем текстовую тему для консистентности стилей
    final textTheme = Theme.of(context).textTheme;

    // Стили для верхних счетчиков
    final counterTextStyle = textTheme.bodyMedium?.copyWith(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13,
      shadows: [ Shadow( blurRadius: 2.0, color: Colors.black.withOpacity(0.7), offset: const Offset(1.0, 1.0)) ]
    );
    // Стиль для главного счетчика монет
    final mainCounterStyle = textTheme.headlineSmall?.copyWith(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,
      shadows: [ Shadow( blurRadius: 3.0, color: Colors.black.withOpacity(0.8), offset: const Offset(1.5, 1.5)) ]
    );

    // Основной layout экрана - вертикальная колонка
    return Column(
      children: [
        // --- Верхняя секция (Кликабельная область) ---
        Expanded(
          flex: 5, // Определяет долю экрана для этой секции
          child: Stack( // Используем Stack для наложения элементов
            alignment: Alignment.center, // Выравнивание по центру
            children: [
              // Фоновое изображение
              Positioned.fill( // Растягиваем фон на всю доступную область Stack
                child: Image.asset(
                  gameBackgroundPath,
                  fit: BoxFit.cover, // Масштабируем, чтобы покрыть область
                  alignment: Alignment.topCenter, // Выравниваем по верхнему краю
                ),
              ),

              // Верхний ряд счетчиков (/tap, общий, /sec)
              Positioned(
                top: 5, // Отступ сверху
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Распределяем по краям и центру
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Счетчик "/tap"
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.touch_app, color: Colors.white, size: 16), const SizedBox(width: 4),
                          Text('+${baseListenersPerClick}/tap', style: counterTextStyle),
                        ] ),
                      // Общий счетчик монет
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          Image.asset(cloutCoinPath, width: 24, height: 24), const SizedBox(width: 8),
                          Text(monthlyListeners.toString(), style: mainCounterStyle),
                        ] ),
                      // Счетчик "/sec"
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.timer, color: Colors.white, size: 16), const SizedBox(width: 4),
                          Text('+${passiveListenersPerSecond}/sec', style: counterTextStyle),
                        ] ),
                    ],
                  ),
                ),
              ),

              // Кликабельный Рэпер (в центре Stack)
              Center(
                child: GestureDetector( // Обрабатываем нажатия
                  onTap: onClick, // Вызываем переданную функцию
                  child: Image.asset(
                    clickableRapperPath,
                    height: MediaQuery.of(context).size.height * 0.30, // Динамический размер
                    fit: BoxFit.contain, // Масштабируем с сохранением пропорций
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- Нижняя секция (Список апгрейдов) ---
        Expanded(
          flex: 6, // Определяет долю экрана для этой секции
          child: Container( // Контейнер для фона и списка
            width: double.infinity, // Занимает всю ширину
            color: Colors.grey[850], // Устанавливаем серый фон
            child: Padding( // Отступы для списка внутри контейнера
              padding: const EdgeInsets.only(bottom: 5.0, left: 15.0, right: 15.0, top: 10.0),
              // ИСПОЛЬЗУЕМ ListView.builder для эффективного построения списка
              child: ListView.builder(
                // shrinkWrap: false, // Важно НЕ использовать shrinkWrap внутри Expanded
                // physics: const AlwaysScrollableScrollPhysics(), // Обеспечивает скролл всегда
                itemCount: upgrades.isNotEmpty ? upgrades.length : 1, // Количество элементов или 1 для заглушки
                itemBuilder: (context, index) {
                  // Если список пуст, показываем заглушку
                  if (upgrades.isEmpty) {
                    return const Center(
                        heightFactor: 5, // Чтобы текст был примерно по центру серой области
                        child: Text("Loading upgrades or none available...",
                                     style: TextStyle(color: Colors.white54))
                    );
                  }

                  // Получаем данные для текущего элемента
                  final upgrade = upgrades[index];

                  // Возвращаем виджет для одного элемента апгрейда
                  return UpgradeItemWidget(
                    // Ключ помогает Flutter эффективно обновлять элементы
                    key: ValueKey('${upgrade.title}-${upgrade.level}-${upgrade.cost}'),
                    title: upgrade.title,
                    cost: upgrade.cost,
                    currentLevel: upgrade.level,
                    upgradeGain: upgrade.increment.toDouble(), // Передаем как double
                    currentClout: monthlyListeners, // Передаем текущее кол-во монет
                    onUpgrade: () => onLevelUp(index), // Передаем колбэк с индексом
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
// END OF FULL UPDATED FILE underground_rap_clicker/lib/screens/upgrade_screen.dart