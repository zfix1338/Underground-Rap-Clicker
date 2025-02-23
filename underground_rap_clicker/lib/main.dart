import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Главное приложение
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clicker with Passive Upgrades',
      debugShowCheckedModeBanner: false,
      home: const UpgradesDesignScreen(),
    );
  }
}

/// Экран с логикой кликов, пассивного дохода и апгрейдов
class UpgradesDesignScreen extends StatefulWidget {
  const UpgradesDesignScreen({Key? key}) : super(key: key);

  @override
  State<UpgradesDesignScreen> createState() => _UpgradesDesignScreenState();
}

class _UpgradesDesignScreenState extends State<UpgradesDesignScreen> {
  // Текущее количество &laquo;слушателей&raquo;
  int monthlyListeners = 0;

  // Прирост за клик
  int baseListenersPerClick = 1;

  // Прирост в секунду (пассивный доход)
  int passiveListenersPerSecond = 0;

  // Таймер, который каждую секунду добавляет passiveListenersPerSecond
  Timer? _timer;

  // Индекс выбранной &laquo;кнопки&raquo; снизу (Upgrade / Music)
  int _selectedTabIndex = 0;

  // Список апгрейдов
  //   - type: 'click' или 'passive'
  //   - cost: цена покупки
  //   - level: текущий уровень
  //   - increment: насколько увеличивает baseListenersPerClick или passiveListenersPerSecond
  //   - title: название апгрейда
  List<Map<String, dynamic>> upgrades = [
    {
      'title': 'Make New Beat',
      'type': 'click', // увеличивает baseListenersPerClick
      'level': 1,
      'cost': 50,
      'increment': 1,
    },
    {
      'title': 'Release Track',
      'type': 'click',
      'level': 1,
      'cost': 150,
      'increment': 2,
    },
    {
      'title': 'Promote on Social',
      'type': 'passive', // увеличивает passiveListenersPerSecond
      'level': 1,
      'cost': 200,
      'increment': 1,
    },
    {
      'title': 'Buy Ads',
      'type': 'passive',
      'level': 1,
      'cost': 500,
      'increment': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Запускаем таймер для пассивного дохода
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (passiveListenersPerSecond > 0) {
        setState(() {
          monthlyListeners += passiveListenersPerSecond;
        });
      }
    });
  }

  @override
  void dispose() {
    // Останавливаем таймер при выходе
    _timer?.cancel();
    super.dispose();
  }

  /// Обработка клика в белой зоне
  void _handleClick() {
    setState(() {
      monthlyListeners += baseListenersPerClick;
    });
    // Для отладки смотрим, вызывается ли метод
    debugPrint('Tap! monthlyListeners = $monthlyListeners');
  }

  /// Покупка (Level Up) апгрейда
  void _handleLevelUp(int index) {
    setState(() {
      final upgrade = upgrades[index];
      final cost = upgrade['cost'] as int;
      final type = upgrade['type'] as String;
      if (monthlyListeners >= cost) {
        // Вычитаем цену
        monthlyListeners -= cost;
        // Увеличиваем уровень
        upgrade['level'] = (upgrade['level'] as int) + 1;

        // Если это click-апгрейд, увеличиваем baseListenersPerClick
        // Если это passive-апгрейд, увеличиваем passiveListenersPerSecond
        if (type == 'click') {
          baseListenersPerClick += upgrade['increment'] as int;
        } else if (type == 'passive') {
          passiveListenersPerSecond += upgrade['increment'] as int;
        }

        // Увеличиваем стоимость (например, в 1.5 раза)
        upgrade['cost'] = (cost * 1.5).round();
      }
    });
  }

  // Обработка нажатия на нижние кнопки (Upgrade / Music)
  void _onBottomTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    // Можно добавить логику переключения экрана
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Фон общий – серый
      backgroundColor: Colors.grey[800],
      // Убираем AppBar, делаем свою верхнюю панель
      appBar: null,
      body: Column(
        children: [
          // ---------- (1) Верхняя панель ( ~80 px ) ----------
          Container(
            height: 80,
            color: Colors.grey[700],
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // monthly listeners
                  Text(
                    'monthly listeners: $monthlyListeners',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // +X/click | +Y/s
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

          // ---------- (2) Основная область ----------
          // Делим на две части: белая зона для кликов (не прокручивается)
          // и список апгрейдов (прокручивается)
          Expanded(
            child: Column(
              children: [
                // Белая зона для кликов
                GestureDetector(
                  onTap: _handleClick,
                  child: Container(
                    height: 200, // высота зоны для кликов
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

                // Список апгрейдов – прокручиваемый
                Expanded(
                  child: Container(
                    color: Colors.grey[700],
                    child: ListView.builder(
                      itemCount: upgrades.length,
                      itemBuilder: (context, index) {
                        final item = upgrades[index];
                        final title = item['title'] as String;
                        final type = item['type'] as String;
                        final level = item['level'] as int;
                        final cost = item['cost'] as int;
                        final increment = item['increment'] as int;

                        // Отображаем "click" или "passive"
                        final typeLabel =
                            (type == 'click') ? 'Click Upgrade' : 'Passive';

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[600],
                          child: Row(
                            children: [
                              // Квадрат для картинки (заглушка)
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[400],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Информация об апгрейде
                              Expanded(
                                child: Text(
                                  '$title\n$typeLabel\nlv. $level | cost: $cost',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ),

                              // Кнопка "Level Up"
                              ElevatedButton(
                                onPressed: () => _handleLevelUp(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[500],
                                ),
                                child: Text(
                                  'Level Up\n+$increment',
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

          // ---------- (3) Нижняя панель (~60 px) ----------
          Container(
            height: 60,
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // &laquo;Upgrade&raquo;
                GestureDetector(
                  onTap: () => _onBottomTabTapped(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: _selectedTabIndex == 0
                            ? Colors.white
                            : Colors.white54,
                      ),
                      Text(
                        'Upgrade',
                        style: TextStyle(
                          color: _selectedTabIndex == 0
                              ? Colors.white
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // &laquo;Music&raquo;
                GestureDetector(
                  onTap: () => _onBottomTabTapped(1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        color: _selectedTabIndex == 1
                            ? Colors.white
                            : Colors.white54,
                      ),
                      Text(
                        'Music',
                        style: TextStyle(
                          color: _selectedTabIndex == 1
                              ? Colors.white
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}