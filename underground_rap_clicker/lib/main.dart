import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import 'models.dart';
import 'screens/upgrade_screen.dart';
import 'screens/music_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Underground Rap Clicker',
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int monthlyListeners = 0;
  int baseListenersPerClick = 1;
  int passiveListenersPerSecond = 0;

  // Расширенный список апгрейдов.
  // Новый апгрейд "Extra Click Boost" даёт +5 за клик, но его можно купить только если "Make New Beat" достиг 10-го уровня.
  List<UpgradeItem> upgrades = [
    UpgradeItem(
      title: 'Make New Beat',
      type: 'click',
      level: 1,
      cost: 75,
      increment: 1,
    ),
    UpgradeItem(
      title: 'Release Track',
      type: 'click',
      level: 1,
      cost: 150,
      increment: 2,
    ),
    UpgradeItem(
      title: 'Collaborate with Top Artists',
      type: 'click',
      level: 1,
      cost: 300,
      increment: 3,
    ),
    UpgradeItem(
      title: 'Upgrade Studio Equipment',
      type: 'passive',
      level: 1,
      cost: 400,
      increment: 2,
    ),
    UpgradeItem(
      title: 'Promote on Social',
      type: 'passive',
      level: 1,
      cost: 200,
      increment: 1,
    ),
    UpgradeItem(
      title: 'Buy Ads',
      type: 'passive',
      level: 1,
      cost: 500,
      increment: 2,
    ),
    UpgradeItem(
      title: 'Social Media Campaign',
      type: 'passive',
      level: 1,
      cost: 600,
      increment: 3,
    ),
    UpgradeItem(
      title: 'Viral Challenge',
      type: 'click',
      level: 1,
      cost: 350,
      increment: 2,
    ),
    // Новый апгрейд, который даёт +5 за клик; его можно купить только после того, как "Make New Beat" достигнет 10-го уровня
    UpgradeItem(
      title: 'Extra Click Boost',
      type: 'click',
      level: 0, // начинаем с 0, так как ещё не куплен
      cost: 1000,
      increment: 5,
    ),
  ];

  // Пример списка альбомов
  List<Album> albums = [
    Album(
      title: 'FLex musix',
      coverAsset: 'assets/images/blonde_cover.png',
      tracks: [
        Track(
          title: 'Blonde',
          artist: 'osamason',
          duration: '2:24',
          cost: 10,
          audioFile: 'audio/blonde.mp3',
          coverAsset: 'assets/images/blonde_cover.png',
        ),
      ],
    ),
  ];

  Timer? _timer;
  late SharedPreferences _prefs;
  int _selectedTabIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPrefs();
    _startPassiveIncomeTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveData();
    }
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
  }

  void _loadData() {
    setState(() {
      monthlyListeners = _prefs.getInt('monthlyListeners') ?? 0;
      baseListenersPerClick = _prefs.getInt('baseListenersPerClick') ?? 1;
      passiveListenersPerSecond = _prefs.getInt('passiveListenersPerSecond') ?? 0;
      final upgradesJson = _prefs.getString('upgrades');
      if (upgradesJson != null) {
        try {
          final decoded = jsonDecode(upgradesJson) as List;
          upgrades = decoded.map((e) => UpgradeItem.fromMap(e)).toList();
        } catch (e) {
          print('Error loading upgrades: $e');
        }
      }
    });
  }

  void _saveData() {
    _prefs.setInt('monthlyListeners', monthlyListeners);
    _prefs.setInt('baseListenersPerClick', baseListenersPerClick);
    _prefs.setInt('passiveListenersPerSecond', passiveListenersPerSecond);
    final upgradesList = upgrades.map((u) => u.toMap()).toList();
    _prefs.setString('upgrades', jsonEncode(upgradesList));
  }

  void _startPassiveIncomeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (passiveListenersPerSecond > 0) {
        setState(() {
          monthlyListeners += passiveListenersPerSecond;
        });
      }
    });
  }

  // Обработка клика по персонажу
  void _handleClick() {
    setState(() {
      monthlyListeners += baseListenersPerClick;
    });
  }

  // Покупка апгрейда; для "Extra Click Boost" проверяем зависимость
  void _handleLevelUp(int index) {
    final upgrade = upgrades[index];

    // Если пытаемся купить "Extra Click Boost", проверяем, что "Make New Beat" достиг 10-го уровня
    if (upgrade.title == 'Extra Click Boost') {
      final makeNewBeat = upgrades.firstWhere((u) => u.title == 'Make New Beat', orElse: () => UpgradeItem(title: '', type: 'click', level: 0, cost: 0, increment: 0));
      if (makeNewBeat.level < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Разблокируйте Extra Click Boost, прокачав Make New Beat до 10 уровня!')),
        );
        return;
      }
    }

    if (monthlyListeners >= upgrade.cost) {
      setState(() {
        monthlyListeners -= upgrade.cost;
        // Если апгрейд типа "click"
        if (upgrade.type == 'click') {
          // Для обычных апгрейдов увеличиваем базовый доход
          baseListenersPerClick += upgrade.increment;
          // Для "Extra Click Boost" можем суммировать отдельно, здесь просто прибавляем +5 за клик
          upgrade.level++;
        } else {
          passiveListenersPerSecond += upgrade.increment;
          upgrade.level++;
        }
        upgrade.cost = (upgrade.cost * 1.5).round();
      });
    }
  }

  void _spendListeners(int cost) {
    setState(() {
      monthlyListeners -= cost;
      if (monthlyListeners < 0) monthlyListeners = 0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _updateAlbums() {
    _saveData();
    setState(() {}); // Обновляем UI при изменении данных альбомов/треков
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      UpgradeScreen(
        monthlyListeners: monthlyListeners,
        baseListenersPerClick: baseListenersPerClick,
        passiveListenersPerSecond: passiveListenersPerSecond,
        upgrades: upgrades,
        onClick: _handleClick,
        onLevelUp: _handleLevelUp,
      ),
      MusicScreen(
        audioPlayer: _audioPlayer,
        albums: albums,
        monthlyListeners: monthlyListeners,
        onSpend: _spendListeners,
        onAlbumUpdate: _updateAlbums,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_selectedTabIndex]),
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