// START OF FULL FILE: lib/screens/upgrade_screen.dart
import 'package:flutter/material.dart';
import '../models.dart'; // Убедитесь, что путь к вашим моделям правильный
import '../widgets/upgrade_item.dart'; // Убедитесь, что путь к виджету элемента правильный

// --- Пути к ассетам ---
const String gameBackgroundPath = 'assets/images/game_background.png';
const String clickableRapperPath = 'assets/images/clickable_rapper.png';
const String cloutCoinPath = 'assets/images/clout_coin.png';
// ---------------------

class UpgradeScreen extends StatelessWidget {
  // Входные данные для экрана
  final int monthlyListeners;
  final int baseListenersPerClick;
  final int passiveListenersPerSecond;
  final List<UpgradeItem> upgrades; // Список данных для апгрейдов
  // Функции обратного вызова для взаимодействия с основной логикой игры
  final VoidCallback onClick;       // Вызывается при клике на рэпера
  final Function(int) onLevelUp;    // Вызывается при нажатии кнопки Level Up, передает индекс апгрейда

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

    // Стили для счетчиков вверху экрана
    final counterTextStyle = textTheme.bodyMedium?.copyWith(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13,
      // Добавляем тень для лучшей читаемости на фоне
      shadows: [ Shadow( blurRadius: 2.0, color: Colors.black.withOpacity(0.7), offset: const Offset(1.0, 1.0)) ]
      // fontFamily: 'Galindo', // Раскомментируйте, если тема не применилась
    ) ?? TextStyle( // Фоллбэк стиль
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13,
      shadows: [ Shadow( blurRadius: 2.0, color: Colors.black.withOpacity(0.7), offset: const Offset(1.0, 1.0)) ]
    );

    final mainCounterStyle = textTheme.headlineSmall?.copyWith(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,
      shadows: [ Shadow( blurRadius: 3.0, color: Colors.black.withOpacity(0.8), offset: const Offset(1.5, 1.5)) ]
      // fontFamily: 'Galindo',
    ) ?? TextStyle( // Фоллбэк стиль
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,
      shadows: [ Shadow( blurRadius: 3.0, color: Colors.black.withOpacity(0.8), offset: const Offset(1.5, 1.5)) ]
    );

    // --- Используем Column как корневой виджет для вертикального расположения секций ---
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем дочерние элементы по ширине
      children: [

        // --- Верхняя секция: Рэпер, Фон, Статистика ---
        Expanded(
           flex: 5, // Задает пропорцию высоты для этой секции (5 из 11 общих частей)
           child: Stack( // Stack здесь нужен для наложения элементов друг на друга
            alignment: Alignment.center, // Выравниваем дочерние элементы Stack по центру
            children: [
              // 1. Фоновое изображение
              Positioned.fill( // Растягиваем фон на всю доступную область Stack
                child: Image.asset(
                  gameBackgroundPath,
                  fit: BoxFit.cover, // Покрываем всю область, обрезая лишнее
                  alignment: Alignment.topCenter, // Выравниваем изображение по верху, чтобы видеть нужную часть
                )
              ),

              // 2. Панель статистики (сверху)
              Positioned( // Позиционируем панель статистики сверху
                top: 5,
                left: 0,
                right: 0,
                child: Padding( // Добавляем отступы
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                  child: Row( // Располагаем счетчики в ряд
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Распределяем место между ними
                    crossAxisAlignment: CrossAxisAlignment.center, // Выравниваем по вертикали
                    children: [
                      // Счетчик "+X/tap"
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.touch_app, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('+$baseListenersPerClick/tap', style: counterTextStyle),
                      ]),
                      // Главный счетчик (слушатели)
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          Image.asset(cloutCoinPath, width: 24, height: 24), // Иконка
                          const SizedBox(width: 8),
                          Text(monthlyListeners.toString(), style: mainCounterStyle), // Значение
                      ]),
                      // Счетчик "+X/sec"
                      Row( mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.timer, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('+$passiveListenersPerSecond/sec', style: counterTextStyle),
                      ]),
                    ],
                  ),
                ),
              ),

              // 3. Кликабельный рэпер (по центру)
              Center( // Центрируем рэпера
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0), // Небольшой отступ снизу от центра Stack
                  child: GestureDetector( // Делаем изображение кликабельным
                    onTap: onClick, // Вызываем колбэк onClick при тапе
                    child: Image.asset(
                      clickableRapperPath,
                      // Высота рэпера зависит от высоты экрана для адаптивности
                      height: MediaQuery.of(context).size.height * 0.30, // Примерно 30% высоты экрана
                      fit: BoxFit.contain, // Сохраняем пропорции изображения
                    ),
                  ),
                ),
              ),
            ],
          ),
        ), // Конец верхней секции Expanded

        // --- Нижняя секция: Список Апгрейдов ---
        Expanded(
          flex: 6, // Задает пропорцию высоты (6 из 11 общих частей) - чуть больше места для списка
          child: Container( // Контейнер для фона и отступов списка
            width: double.infinity, // Занимаем всю ширину
            color: Colors.grey[850], // Темно-серый фон для области списка
            child: Padding( // Внутренние отступы для списка
              padding: const EdgeInsets.only(bottom: 5.0, left: 15.0, right: 15.0, top: 10.0),
              child: ListView.builder( // Создаем прокручиваемый список
                 padding: EdgeInsets.zero, // Убираем стандартный внутренний отступ ListView
                 // Определяем количество элементов: либо длина списка, либо 1 (для сообщения "No upgrades")
                 itemCount: upgrades.isNotEmpty ? upgrades.length : 1,
                 // Функция, строящая каждый элемент списка
                 itemBuilder: (context, index) {
                  // Если список апгрейдов пуст, показываем сообщение
                  if (upgrades.isEmpty) {
                    return const Center(
                       heightFactor: 5, // Отодвигаем текст от верха/низа
                       child: Text(
                         "No upgrades available...",
                         style: TextStyle(color: Colors.white54, fontSize: 16)
                       )
                    );
                  }

                  // Получаем данные для текущего апгрейда по индексу
                  final upgrade = upgrades[index];

                  // Возвращаем виджет для элемента апгрейда, передавая ему нужные данные
                  return UpgradeItemWidget(
                    // Ключ помогает Flutter эффективнее обновлять элементы списка
                    key: ValueKey('${upgrade.title}-${upgrade.level}'),
                    title: upgrade.title,
                    cost: upgrade.cost,
                    currentLevel: upgrade.level,
                    upgradeGain: upgrade.increment.toDouble(), // Убедимся, что тип double
                    currentClout: monthlyListeners, // Передаем текущий баланс для проверки возможности покупки
                    onUpgrade: () => onLevelUp(index), // Передаем функцию обратного вызова с ИНДЕКСОМ апгрейда
                  );
                },
              ),
            ),
          ),
        ), // Конец нижней секции Expanded

      ],
    ); // Конец корневого Column
  }
}
// END OF FULL FILE: lib/screens/upgrade_screen.dart