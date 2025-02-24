import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Подключаем models.dart и экраны
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

  // Пример апгрейдов
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
  ];

  // Пример треков
  List<Track> tracks = [
    Track(
      title: 'Blonde',
      artist: 'osamason',
      duration: '2:24',
      cost: 10,
      // Важно: путь совпадает с тем, что прописано в pubspec.yaml
      audioFile: 'assets/audio/blonde.mp3',
      coverAsset: 'assets/images/blonde_cover.png',
    ),
  ];

  Timer? _timer;
  late SharedPreferences _prefs;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPrefs();
    _startPassiveIncomeTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
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
      passiveListenersPerSecond =
          _prefs.getInt('passiveListenersPerSecond') ?? 0;

      final upgradesJson = _prefs.getString('upgrades');
      if (upgradesJson != null) {
        final decoded = jsonDecode(upgradesJson) as List;
        upgrades = decoded.map((e) => UpgradeItem.fromMap(e)).toList();
      }

      final tracksJson = _prefs.getString('tracks');
      if (tracksJson != null) {
        final decoded = jsonDecode(tracksJson) as List;
        tracks = decoded.map((e) => Track.fromMap(e)).toList();
      }
    });
  }

  void _saveData() {
    _prefs.setInt('monthlyListeners', monthlyListeners);
    _prefs.setInt('baseListenersPerClick', baseListenersPerClick);
    _prefs.setInt('passiveListenersPerSecond', passiveListenersPerSecond);

    final upgradesList = upgrades.map((u) => u.toMap()).toList();
    _prefs.setString('upgrades', jsonEncode(upgradesList));

    final tracksList = tracks.map((t) => t.toMap()).toList();
    _prefs.setString('tracks', jsonEncode(tracksList));
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

  // Клик по белой зоне
  void _handleClick() {
    setState(() {
      monthlyListeners += baseListenersPerClick;
    });
  }

  // Улучшаем апгрейд
  void _handleLevelUp(int index) {
    final upgrade = upgrades[index];
    if (monthlyListeners >= upgrade.cost) {
      setState(() {
        monthlyListeners -= upgrade.cost;
        upgrade.level++;
        if (upgrade.type == 'click') {
          baseListenersPerClick += upgrade.increment;
        } else {
          passiveListenersPerSecond += upgrade.increment;
        }
        upgrade.cost = (upgrade.cost * 1.5).round();
      });
    }
  }

  // Списать слушателей
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

  // Обновление треков (сохранение)
  void _updateTracks() {
    _saveData();
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
        monthlyListeners: monthlyListeners,
        onSpend: _spendListeners,
        tracks: tracks,
        onTrackUpdate: _updateTracks,
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
