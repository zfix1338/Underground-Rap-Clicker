// START OF FULL CORRECTED FILE underground_rap_clicker/lib/main.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Убран импорт
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import 'models.dart';
import 'screens/upgrade_screen.dart'; // Импорт теперь будет использоваться
import 'screens/music_screen.dart';

// Главная функция приложения
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Корневой виджет приложения
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Underground Rap Clicker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Galindo', // Используем локальный шрифт
        textTheme: ThemeData(brightness: Brightness.dark).textTheme.apply(
              fontFamily: 'Galindo',
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ).copyWith(
               headlineSmall: ThemeData(brightness: Brightness.dark).textTheme.headlineSmall?.copyWith(fontFamily: 'Galindo'),
               titleLarge: ThemeData(brightness: Brightness.dark).textTheme.titleLarge?.copyWith(fontFamily: 'Galindo'),
            ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// Основной экран, управляющий вкладками и состоянием игры
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // --- Переменные состояния игры ---
  int monthlyListeners = 0;
  int baseListenersPerClick = 1;
  int passiveListenersPerSecond = 0;
  List<UpgradeItem> upgrades = [
    UpgradeItem(title: 'Make New Beat', type: 'click', level: 1, cost: 75, increment: 1),
    UpgradeItem(title: 'Release Track', type: 'click', level: 1, cost: 150, increment: 2),
    UpgradeItem(title: 'Collaborate with Top Artists', type: 'click', level: 1, cost: 300, increment: 3),
    UpgradeItem(title: 'Upgrade Studio Equipment', type: 'passive', level: 1, cost: 400, increment: 2),
    UpgradeItem(title: 'Promote on Social', type: 'passive', level: 1, cost: 200, increment: 1),
    UpgradeItem(title: 'Buy Ads', type: 'passive', level: 1, cost: 500, increment: 2),
    UpgradeItem(title: 'Social Media Campaign', type: 'passive', level: 1, cost: 600, increment: 3),
    UpgradeItem(title: 'Viral Challenge', type: 'click', level: 1, cost: 350, increment: 2),
    UpgradeItem( title: 'Extra Click Boost', type: 'click', level: 0, cost: 1000, increment: 5, requirementLevel: 10, requirementTitle: 'Make New Beat'),
  ];
  List<Album> albums = [
     Album( title: 'FLex musix', coverAsset: 'assets/images/blonde_cover.png', tracks: [
        Track(title: 'Blonde', artist: 'osamason', duration: '2:24', cost: 100, audioFile: 'audio/blonde.mp3', coverAsset: 'assets/images/blonde_cover.png'),
      ],
    ),
  ];
  Timer? _timer;
  late SharedPreferences _prefs;
  int _selectedTabIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- Методы жизненного цикла ---
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
    _saveData();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      _saveData();
    }
  }

  // --- Сохранение/Загрузка ---
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
  }

  void _loadData() {
    setState(() {
      monthlyListeners = _prefs.getInt('monthlyListeners') ?? 0;
      // Загрузка апгрейдов
      final upgradesJson = _prefs.getString('upgrades');
      if (upgradesJson != null) {
        try {
          final decoded = jsonDecode(upgradesJson) as List;
          final loadedUpgrades = decoded.map((e) => UpgradeItem.fromMap(e)).toList();
          if (loadedUpgrades.length == upgrades.length) { upgrades = loadedUpgrades; }
        } catch (e) { /* Ошибка */ }
      }
      // Загрузка альбомов
      final albumsJson = _prefs.getString('albums');
      if (albumsJson != null) {
        try {
          final decodedAlbums = jsonDecode(albumsJson) as List;
          List<Album> loadedAlbums = decodedAlbums.map((e) => Album.fromMap(e)).toList();
          if (loadedAlbums.isNotEmpty) { albums = loadedAlbums; }
        } catch (e) { /* Ошибка */ }
      }
    });
     _recalculateIncrements(); // Пересчет после загрузки
     // Загрузка сохраненных значений или использование пересчитанных
     setState(() {
        baseListenersPerClick = _prefs.getInt('baseListenersPerClick') ?? baseListenersPerClick;
        passiveListenersPerSecond = _prefs.getInt('passiveListenersPerSecond') ?? passiveListenersPerSecond;
     });
  }

   void _recalculateIncrements() {
    int calculatedClickPower = 1;
    int calculatedPassivePower = 0;
    for (var upgrade in upgrades) {
      if (upgrade.level > 0) {
        if (upgrade.type == 'click') { calculatedClickPower += upgrade.increment * upgrade.level; }
        else if (upgrade.type == 'passive') { calculatedPassivePower += upgrade.increment * upgrade.level; }
      }
    }
     if (mounted) {
       baseListenersPerClick = calculatedClickPower;
       passiveListenersPerSecond = calculatedPassivePower;
     } else {
       baseListenersPerClick = calculatedClickPower;
       passiveListenersPerSecond = calculatedPassivePower;
     }
  }

  void _saveData() {
    _prefs.setInt('monthlyListeners', monthlyListeners);
    _prefs.setInt('baseListenersPerClick', baseListenersPerClick);
    _prefs.setInt('passiveListenersPerSecond', passiveListenersPerSecond);
    final upgradesList = upgrades.map((u) => u.toMap()).toList();
    _prefs.setString('upgrades', jsonEncode(upgradesList));
    final albumsList = albums.map((a) => a.toMap()).toList();
    _prefs.setString('albums', jsonEncode(albumsList));
  }

  void _startPassiveIncomeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (passiveListenersPerSecond > 0) {
        if (mounted) { setState(() { monthlyListeners += passiveListenersPerSecond; }); }
        else { timer.cancel(); }
      }
    });
  }

  // --- Игровая логика ---
  void _handleClick() {
    if (mounted) { setState(() { monthlyListeners += baseListenersPerClick; }); }
  }

  void _handleLevelUp(int index) {
    final upgrade = upgrades[index];
    bool purchased = false;
    // Проверка зависимости
    if (upgrade.requirementTitle != null && upgrade.requirementLevel != null) {
      final requirement = upgrades.firstWhere((u) => u.title == upgrade.requirementTitle, orElse: () => UpgradeItem(title: '', type: '', level: -1, cost: 0, increment: 0));
      if (requirement.level < (upgrade.requirementLevel ?? 999)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Level up "${upgrade.requirementTitle}" to ${upgrade.requirementLevel} to unlock!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)), backgroundColor: Colors.red[700]));
        return;
      }
    }
    // Проверка средств
    if (monthlyListeners >= upgrade.cost) {
      if (mounted) {
        setState(() {
          monthlyListeners -= upgrade.cost;
          upgrade.level++;
          purchased = true;
          upgrade.cost = (upgrade.cost * 1.5).round();
          _recalculateIncrements();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not enough clout for ${upgrade.title}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)), backgroundColor: Colors.blueGrey[700], duration: const Duration(seconds: 1)));
    }
    if (purchased) {
      _saveData();
      _startPassiveIncomeTimer();
    }
  }

  // --- Взаимодействие с MusicScreen ---
  void _spendListeners(int cost) {
    if (monthlyListeners >= cost) {
      if (mounted) { setState(() { monthlyListeners -= cost; }); }
      else { monthlyListeners -= cost; }
      // Сохранение через _updateAlbums
    }
  }

  void _updateAlbums() {
    _saveData();
    if (mounted) { setState(() {}); }
  }

  // --- Навигация ---
  void _onItemTapped(int index) {
    setState(() { _selectedTabIndex = index; });
  }

  // --- Метод Build ---
  @override
  Widget build(BuildContext context) {
    // Список экранов для вкладок
    // --- ИСПРАВЛЕНО: Убрано const ---
    final screens = [
      UpgradeScreen( // Создаем экземпляр виджета
        monthlyListeners: monthlyListeners,
        baseListenersPerClick: baseListenersPerClick,
        passiveListenersPerSecond: passiveListenersPerSecond,
        upgrades: upgrades,
        onClick: _handleClick,
        onLevelUp: _handleLevelUp,
      ),
      MusicScreen( // Создаем экземпляр виджета
        audioPlayer: _audioPlayer,
        albums: albums,
        monthlyListeners: monthlyListeners,
        onSpend: _spendListeners,
        onAlbumUpdate: _updateAlbums,
      ),
    ];
    // ---------------------------------

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.upgrade),
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
// END OF FULL CORRECTED FILE underground_rap_clicker/lib/main.dart