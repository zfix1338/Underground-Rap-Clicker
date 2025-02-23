import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

/// ---------------------
/// Модель апгрейда (для вкладки Upgrade)
/// ---------------------
class UpgradeItem {
  String title;
  String type;       // 'click' или 'passive'
  int level;
  int cost;
  int increment;

  UpgradeItem({
    required this.title,
    required this.type,
    required this.level,
    required this.cost,
    required this.increment,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'level': level,
      'cost': cost,
      'increment': increment,
    };
  }

  static UpgradeItem fromMap(Map<String, dynamic> map) {
    return UpgradeItem(
      title: map['title'],
      type: map['type'],
      level: map['level'],
      cost: map['cost'],
      increment: map['increment'],
    );
  }
}

/// ---------------------
/// Модель трека (Music)
/// ---------------------
class Track {
  final String title;
  final String artist;
  final String duration;
  final int cost;

  /// Пути к локальным файлам (MP3 и картинка) в папке assets/
  final String audioAsset; // напр. 'assets/audio/blonde.mp3'
  final String coverAsset; // напр. 'assets/images/blonde_cover.png'

  bool isUploaded; // куплен?
  bool isPlaying;  // играет?

  Track({
    required this.title,
    required this.artist,
    required this.duration,
    required this.cost,
    required this.audioAsset,
    required this.coverAsset,
    this.isUploaded = false,
    this.isPlaying = false,
  });
}

/// ---------------------
/// Главное приложение
/// ---------------------
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clicker + Music (Old Audioplayers)',
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

/// ---------------------
/// Главный экран с 2 вкладками (Upgrade, Music)
/// ---------------------
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // Параметры кликера (сохраняются в SharedPreferences)
  int monthlyListeners = 0;
  int baseListenersPerClick = 1;
  int passiveListenersPerSecond = 0;

  // Список апгрейдов
  List<UpgradeItem> upgrades = [
    UpgradeItem(title: 'Make New Beat',    type: 'click',   level: 1, cost: 75,  increment: 1),
    UpgradeItem(title: 'Release Track',    type: 'click',   level: 1, cost: 150, increment: 2),
    UpgradeItem(title: 'Promote on Social',type: 'passive', level: 1, cost: 200, increment: 1),
    UpgradeItem(title: 'Buy Ads',          type: 'passive', level: 1, cost: 500, increment: 2),
  ];

  // Таймер для пассивного дохода
  Timer? _timer;

  // SharedPreferences
  late SharedPreferences _prefs;

  // Индекс вкладки
  int _selectedTabIndex = 0;

  // Список треков (Music)
  final List<Track> _tracks = [
    Track(
      title: 'Blonde',
      artist: 'osamason',
      duration: '2:24',
      cost: 1000,
      audioAsset: 'assets/audio/blonde.mp3',
      coverAsset: 'assets/images/blonde_cover.png',
    ),
    // Можно добавить ещё треки
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPreferences();
    _startPassiveIncomeTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  /// Сохраняем прогресс при сворачивании
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveData();
    }
  }

  // ---------------------
  // Инициализация SharedPreferences
  // ---------------------
  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
  }

  void _loadData() {
    setState(() {
      monthlyListeners        = _prefs.getInt('monthlyListeners') ?? 0;
      baseListenersPerClick   = _prefs.getInt('baseListenersPerClick') ?? 1;
      passiveListenersPerSecond = _prefs.getInt('passiveListenersPerSecond') ?? 0;

      final upgradesJson = _prefs.getString('upgrades');
      if (upgradesJson != null) {
        final List decoded = jsonDecode(upgradesJson);
        for (int i = 0; i < decoded.length; i++) {
          if (i < upgrades.length) {
            upgrades[i] = UpgradeItem.fromMap(decoded[i]);
          }
        }
      }
    });
  }

  void _saveData() {
    _prefs.setInt('monthlyListeners', monthlyListeners);
    _prefs.setInt('baseListenersPerClick', baseListenersPerClick);
    _prefs.setInt('passiveListenersPerSecond', passiveListenersPerSecond);

    final upgradesList = upgrades.map((u) => u.toMap()).toList();
    final upgradesJson = jsonEncode(upgradesList);
    _prefs.setString('upgrades', upgradesJson);
  }

  // ---------------------
  // Пассивный доход
  // ---------------------
  void _startPassiveIncomeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (passiveListenersPerSecond > 0) {
        setState(() {
          monthlyListeners += passiveListenersPerSecond;
        });
      }
    });
  }

  // ---------------------
  // Клик
  // ---------------------
  void _handleClick() {
    setState(() {
      monthlyListeners += baseListenersPerClick;
    });
  }

  // ---------------------
  // Покупка апгрейда
  // ---------------------
  void _handleLevelUp(int index) {
    final upgrade = upgrades[index];
    if (monthlyListeners >= upgrade.cost) {
      setState(() {
        monthlyListeners -= upgrade.cost;
        upgrade.level++;
        if (upgrade.type == 'click') {
          baseListenersPerClick += upgrade.increment;
        } else if (upgrade.type == 'passive') {
          passiveListenersPerSecond += upgrade.increment;
        }
        upgrade.cost = (upgrade.cost * 1.5).round();
      });
    }
  }

  // ---------------------
  // Расход для MusicScreen
  // ---------------------
  void _spendListeners(int cost) {
    setState(() {
      monthlyListeners -= cost;
      if (monthlyListeners < 0) {
        monthlyListeners = 0;
      }
    });
  }

  // ---------------------
  // Вкладки
  // ---------------------
  void _onItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      // Вкладка 1: Upgrade
      UpgradesDesignScreen(
        monthlyListeners: monthlyListeners,
        baseListenersPerClick: baseListenersPerClick,
        passiveListenersPerSecond: passiveListenersPerSecond,
        upgrades: upgrades,
        onClick: _handleClick,
        onLevelUp: _handleLevelUp,
      ),
      // Вкладка 2: Music
      MusicScreen(
        monthlyListeners: monthlyListeners,
        onSpend: _spendListeners,
        tracks: _tracks,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[_selectedTabIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward),
            label: 'Upgrade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Music',
          ),
        ],
      ),
    );
  }
}

/// ---------------------
/// Виджет вкладки Upgrade
/// ---------------------
class UpgradesDesignScreen extends StatelessWidget {
  final int monthlyListeners;
  final int baseListenersPerClick;
  final int passiveListenersPerSecond;
  final List<UpgradeItem> upgrades;

  final VoidCallback onClick;
  final Function(int index) onLevelUp;

  const UpgradesDesignScreen({
    Key? key,
    required this.monthlyListeners,
    required this.baseListenersPerClick,
    required this.passiveListenersPerSecond,
    required this.upgrades,
    required this.onClick,
    required this.onLevelUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // (1) Верхняя панель
        Container(
          height: 80,
          color: Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'monthly listeners: $monthlyListeners',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

        // (2) Основная часть
        Expanded(
          child: Column(
            children: [
              // Белая зона (половина экрана)
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: onClick,
                  child: Container(
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
              ),

              // Список апгрейдов (половина экрана)
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.grey[700],
                  child: ListView.builder(
                    itemCount: upgrades.length,
                    itemBuilder: (context, index) {
                      final item = upgrades[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey[600],
                        child: Row(
                          children: [
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

                            Expanded(
                              child: Text(
                                '${item.title}\n'
                                '${item.type == 'click' ? 'Click Upgrade' : 'Passive'}\n'
                                'lv. ${item.level} | cost: ${item.cost}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () => onLevelUp(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[500],
                              ),
                              child: Text(
                                'Level Up\n+${item.increment}',
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
      ],
    );
  }
}

/// ---------------------
/// Виджет вкладки Music (c учётом старой версии audioplayers)
/// ---------------------
class MusicScreen extends StatefulWidget {
  final int monthlyListeners;
  final Function(int cost) onSpend;
  final List<Track> tracks;

  const MusicScreen({
    Key? key,
    required this.monthlyListeners,
    required this.onSpend,
    required this.tracks,
  }) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    // Подписываемся на событие завершения трека
    _audioPlayer.onPlayerCompletion.listen((_) {
      setState(() {
        // Сбрасываем флаг, когда трек закончил играть
        if (_currentPlayingIndex >= 0 &&
            _currentPlayingIndex < widget.tracks.length) {
          widget.tracks[_currentPlayingIndex].isPlaying = false;
        }
        _currentPlayingIndex = -1;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Покупка (Upload)
  void _uploadTrack(int index) {
    final track = widget.tracks[index];
    final cost = track.cost;
    if (widget.monthlyListeners >= cost) {
      widget.onSpend(cost);
      setState(() {
        track.isUploaded = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough listeners to upload track')),
      );
    }
  }

  /// Воспроизведение / Пауза
  Future<void> _togglePlayPause(int index) async {
    final track = widget.tracks[index];
    if (!track.isUploaded) return; // не загружен – не воспроизводим

    // Если трек уже играет – ставим на паузу
    if (track.isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        track.isPlaying = false;
      });
      return;
    }

    // Если играет другой трек, останавливаем его
    if (_currentPlayingIndex != -1 && _currentPlayingIndex != index) {
      widget.tracks[_currentPlayingIndex].isPlaying = false;
      await _audioPlayer.stop();
    }

    // Запускаем текущий трек (локальный файл)
    // В старых версиях: play(путь, isLocal: true)
    final result = await _audioPlayer.play(
      track.audioAsset,
      isLocal: true,
    );

    // result == 1 => успех, 0 => ошибка
    if (result == 1) {
      setState(() {
        track.isPlaying = true;
        _currentPlayingIndex = index;
      });
    } else {
      debugPrint('Error playing track (result=$result)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('Music'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: widget.tracks.length,
        itemBuilder: (context, index) {
          final track = widget.tracks[index];
          String statusText;
          if (!track.isUploaded) {
            statusText = 'cost: ${track.cost}';
          } else if (track.isPlaying) {
            statusText = 'Now Playing';
          } else {
            statusText = 'Paused';
          }

          return GestureDetector(
            onTap: () => _togglePlayPause(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(8),
              color: Colors.grey[900],
              child: Row(
                children: [
                  // Обложка (Image.asset)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      track.coverAsset,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Информация о треке
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          track.artist,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          track.duration,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: track.isPlaying
                                ? Colors.orange
                                : Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Кнопка Upload, если не загружен
                  if (!track.isUploaded)
                    ElevatedButton(
                      onPressed: () => _uploadTrack(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                      ),
                      child: Text(
                        'Upload\ncost: ${track.cost}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        // Доп. действия
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete track'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}