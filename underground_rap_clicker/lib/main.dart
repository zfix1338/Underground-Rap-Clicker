// START OF FULL CORRECTED FILE underground_rap_clicker/lib/main.dart
import 'dart:async';
import 'dart:convert'; // Для jsonEncode/jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Для сохранения данных
import 'package:audioplayers/audioplayers.dart'; // Для воспроизведения музыки

// Импортируем наши модели данных и экраны
import 'models.dart';
import 'screens/upgrade_screen.dart';
import 'screens/music_screen.dart';
// импорт 'screens/album_detail_screen.dart' больше не нужен

// Главная точка входа приложения
void main() async {
  // Убедимся, что Flutter инициализирован перед запуском runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Корневой виджет MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Underground Rap Clicker', // Название приложения
      debugShowCheckedModeBanner: false, // Убрать баннер Debug
      theme: ThemeData( // Настройка темы приложения
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange, // Базовый цвет для генерации палитры
          brightness: Brightness.dark, // Темная тема
          background: Colors.grey[900]!, // Цвет фона по умолчанию
        ),
        fontFamily: 'Galindo', // Название шрифта из pubspec.yaml
        // Применяем шрифт ко всем текстовым стилям темы
        textTheme: ThemeData(brightness: Brightness.dark).textTheme.apply(
              fontFamily: 'Galindo',
              bodyColor: Colors.white, // Цвет основного текста
              displayColor: Colors.white, // Цвет заголовков
            ).copyWith(
              // Можно дополнительно настроить конкретные стили, если нужно
              headlineSmall: ThemeData(brightness: Brightness.dark).textTheme.headlineSmall?.copyWith(fontFamily: 'Galindo'),
              titleLarge: ThemeData(brightness: Brightness.dark).textTheme.titleLarge?.copyWith(fontFamily: 'Galindo'),
              titleMedium: ThemeData(brightness: Brightness.dark).textTheme.titleMedium?.copyWith(fontFamily: 'Galindo'),
              labelLarge: ThemeData(brightness: Brightness.dark).textTheme.labelLarge?.copyWith(fontFamily: 'Galindo'),
              bodyMedium: ThemeData(brightness: Brightness.dark).textTheme.bodyMedium?.copyWith(fontFamily: 'Galindo'),
              bodySmall: ThemeData(brightness: Brightness.dark).textTheme.bodySmall?.copyWith(fontFamily: 'Galindo'),
            ),
        // Стилизация нижней навигационной панели
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withOpacity(0.85), // Фон панели
          selectedItemColor: Colors.orangeAccent[100], // Цвет активной иконки/текста
          unselectedItemColor: Colors.grey[600], // Цвет неактивной иконки/текста
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Galindo', fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Galindo', fontSize: 12),
          elevation: 8, // Тень панели
        ),
        useMaterial3: true, // Используем Material 3 дизайн
      ),
      home: const MainScreen(), // Стартовый экран
    );
  }
}

// Главный экран с вкладками и управлением состоянием игры
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Состояние главного экрана
class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // --- Игровое Состояние ---
  int monthlyListeners = 0;
  int baseListenersPerClick = 1;
  int passiveListenersPerSecond = 0;
  // Инициализируем копией дефолтных апгрейдов из models.dart
  List<UpgradeItem> upgrades = List.from(initialUpgrades);
  // Инициализируем копией дефолтного альбома из models.dart
  // Важно: Создаем копию, чтобы изменения isPurchased не затрагивали исходный объект
  // (хотя в данном случае у нас только один альбом, это хорошая практика)
  List<Album> albums = [
     Album(
         title: blondeAlbum.title,
         coverAsset: blondeAlbum.coverAsset,
         // Создаем копии треков, чтобы isPurchased можно было менять
         tracks: blondeAlbum.tracks.map((track) => Track(
            title: track.title,
            artist: track.artist,
            duration: track.duration,
            cost: track.cost,
            audioFile: track.audioFile,
            coverAsset: track.coverAsset,
            isPurchased: track.isPurchased // Начнем с дефолтного значения
         )).toList()
     )
  ];
  // --------------------------

  Timer? _timer; // Таймер пассивного дохода
  SharedPreferences? _prefs; // Экземпляр SharedPreferences (может быть null до инициализации)
  int _selectedTabIndex = 0; // Индекс активной вкладки
  final AudioPlayer _audioPlayer = AudioPlayer(); // Аудиоплеер

  // --- Жизненный цикл виджета ---
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Подписываемся на события жизненного цикла приложения
    _initPrefsAndLoad(); // Запускаем инициализацию и загрузку данных
    // Таймер запускается после загрузки данных
  }

  @override
  void dispose() {
    _timer?.cancel(); // Останавливаем таймер
    _audioPlayer.release(); // Освобождаем ресурсы плеера ЯВНО
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this); // Отписываемся от событий
    _saveData(); // Сохраняем данные при уничтожении виджета (например, закрытии приложения)
    super.dispose();
  }

  // Вызывается при изменении состояния приложения (свернуто, активно и т.д.)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Сохраняем данные, когда приложение не активно
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      _saveData();
    }
    // Можно добавить возобновление таймера при возвращении в приложение
    if (state == AppLifecycleState.resumed) {
      // Перезапускаем таймер, если есть пассивный доход
       _startPassiveIncomeTimer();
    }
  }

  // --- Сохранение и Загрузка Данных ---
  Future<void> _initPrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData(); // Загружаем данные
  }

  void _loadData() {
    if (_prefs == null) {
       print("Prefs not initialized yet!");
       return; // Не загружаем, если prefs еще не готовы
    }
    if (!mounted) return; // Проверка перед setState

    // Загрузка основных значений
    final loadedListeners = _prefs!.getInt('monthlyListeners') ?? 0;
    final loadedClickPower = _prefs!.getInt('baseListenersPerClick');
    final loadedPassivePower = _prefs!.getInt('passiveListenersPerSecond');

    // Загрузка апгрейдов
    final upgradesJson = _prefs!.getString('upgrades');
    List<UpgradeItem> loadedUpgrades = List.from(initialUpgrades); // Начальное значение
    if (upgradesJson != null) {
      try {
        final decoded = jsonDecode(upgradesJson) as List;
        final tempLoaded = decoded.map((e) => UpgradeItem.fromMap(e)).toList();
        // Простая проверка на совпадение количества
        if (tempLoaded.length == initialUpgrades.length) {
          loadedUpgrades = tempLoaded;
        } else { print("Warning: Mismatch in saved upgrades count."); }
      } catch (e) { print("Error loading upgrades: $e."); }
    }

    // Загрузка статуса купленных треков
    final purchasedTrackTitles = _prefs!.getStringList('purchasedTracks') ?? [];
    // Создаем копию дефолтного альбома и обновляем статус isPurchased
    Album currentAlbumState = Album(
        title: blondeAlbum.title,
        coverAsset: blondeAlbum.coverAsset,
        tracks: blondeAlbum.tracks.map((defaultTrack) {
           // Создаем копию трека и устанавливаем isPurchased из сохранения
           return Track(
              title: defaultTrack.title,
              artist: defaultTrack.artist,
              duration: defaultTrack.duration,
              cost: defaultTrack.cost,
              audioFile: defaultTrack.audioFile,
              coverAsset: defaultTrack.coverAsset,
              isPurchased: purchasedTrackTitles.contains(defaultTrack.title) // <- Загрузка статуса
           );
        }).toList()
    );


    // Применяем загруженные или начальные значения
    setState(() {
      monthlyListeners = loadedListeners;
      upgrades = loadedUpgrades;
      albums = [currentAlbumState]; // Применяем альбом с обновленным статусом покупок
      _recalculateIncrements(); // Пересчитываем приросты
      // Устанавливаем сохраненные значения прироста или оставляем пересчитанные
      baseListenersPerClick = loadedClickPower ?? baseListenersPerClick;
      passiveListenersPerSecond = loadedPassivePower ?? passiveListenersPerSecond;
    });

    _startPassiveIncomeTimer(); // Запускаем таймер
  }

  void _saveData() {
     if (_prefs == null) {
       print("Prefs not initialized, cannot save data.");
       return; // Не сохраняем, если prefs не готовы
    }
    _prefs!.setInt('monthlyListeners', monthlyListeners);
    _prefs!.setInt('baseListenersPerClick', baseListenersPerClick);
    _prefs!.setInt('passiveListenersPerSecond', passiveListenersPerSecond);

    // Сохраняем апгрейды
    final upgradesList = upgrades.map((u) => u.toMap()).toList();
    _prefs!.setString('upgrades', jsonEncode(upgradesList));

    // Сохраняем ТОЛЬКО идентификаторы купленных треков
    List<String> purchasedTrackTitles = [];
    for (var album in albums) {
       for (var track in album.tracks) {
          if (track.isPurchased) {
             purchasedTrackTitles.add(track.title);
          }
       }
    }
    _prefs!.setStringList('purchasedTracks', purchasedTrackTitles);

    print("Data saved!");
  }

  // Пересчет общего прироста от апгрейдов
  void _recalculateIncrements() {
    int calculatedClickPower = 1;
    int calculatedPassivePower = 0;
    for (var upgrade in upgrades) {
      if (upgrade.level > 0) {
        // Используем текущие значения cost и increment из модели
        // (Логика их изменения при level up находится в _handleLevelUp)
        if (upgrade.type == 'click') {
           calculatedClickPower += upgrade.increment; // Простая сумма прироста * уровень
        } else if (upgrade.type == 'passive') {
           calculatedPassivePower += upgrade.increment; // Простая сумма прироста * уровень
        }
      }
    }
    // Не вызываем setState здесь, т.к. вызывается из _loadData или _handleLevelUp
     baseListenersPerClick = calculatedClickPower;
     passiveListenersPerSecond = calculatedPassivePower;
  }

  // Запуск/перезапуск таймера
  void _startPassiveIncomeTimer() {
    _timer?.cancel();
    if (passiveListenersPerSecond > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() { monthlyListeners += passiveListenersPerSecond; });
        } else {
          timer.cancel();
        }
      });
    }
  }

  // --- Обработчики Игровых Действий ---
  void _handleClick() {
    if (mounted) { setState(() { monthlyListeners += baseListenersPerClick; }); }
  }

  void _handleLevelUp(int index) {
     if (index < 0 || index >= upgrades.length) return;
     final upgrade = upgrades[index];
     bool canPurchase = true;

     // Проверка зависимости
     if (upgrade.requirementTitle != null && upgrade.requirementLevel != null) {
       final requirement = upgrades.firstWhere((u) => u.title == upgrade.requirementTitle, orElse: () => UpgradeItem(title: '', type: '', level: -1, cost: 0, increment: 0));
       if (requirement.level < (upgrade.requirementLevel ?? 999)) {
         canPurchase = false;
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar( content: Text('Level up "${upgrade.requirementTitle}" to ${upgrade.requirementLevel} first!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)), backgroundColor: Colors.red[800], duration: const Duration(seconds: 2), ));
         }
       }
     }

     // Проверка средств
     if (canPurchase && monthlyListeners < upgrade.cost) {
       canPurchase = false;
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar( content: Text('Not enough clout for ${upgrade.title} (${upgrade.cost})', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)), backgroundColor: Colors.blueGrey[700], duration: const Duration(milliseconds: 1500), ));
       }
     }

     // Покупка
     if (canPurchase) {
       if (mounted) {
         setState(() {
           monthlyListeners -= upgrade.cost;
           upgrade.level++;
           // Обновляем стоимость и прирост для СЛЕДУЮЩЕГО уровня (пример)
           upgrade.cost = (upgrade.cost * 1.15).round(); // +15%
           // Обновляем прирост, если нужно (например, +1 за уровень)
           // upgrade.increment += 1;
           _recalculateIncrements(); // Пересчитываем общие значения
         });
         _startPassiveIncomeTimer(); // Перезапуск таймера
         _saveData(); // Сохраняем прогресс
       }
     }
   }

  // --- Обработчики для MusicScreen ---
  void _spendListeners(int cost) {
    if (monthlyListeners >= cost) {
      if (mounted) {
        setState(() { monthlyListeners -= cost; });
      } else { monthlyListeners -= cost; }
      // Сохранение вызывается через _updateAndSaveState
    }
  }

  // Вызывается из MusicScreen после покупки трека
  void _updateAndSaveState() {
    _saveData(); // Сохраняем ВСЕ состояние игры
    if (mounted) { setState(() {}); } // Обновляем UI, чтобы передать актуальные данные
  }

  // --- Навигация ---
  void _onItemTapped(int index) {
    if (_selectedTabIndex != index) {
      if (mounted) { setState(() { _selectedTabIndex = index; }); }
    }
  }

  // --- Сборка UI ---
  @override
  Widget build(BuildContext context) {
    // Список экранов для IndexedStack
    final List<Widget> screens = [
      // Экран Апгрейдов
      UpgradeScreen(
        monthlyListeners: monthlyListeners,
        baseListenersPerClick: baseListenersPerClick,
        passiveListenersPerSecond: passiveListenersPerSecond,
        upgrades: upgrades,
        onClick: _handleClick,
        onLevelUp: _handleLevelUp,
      ),
      // Экран Музыки
      MusicScreen(
        audioPlayer: _audioPlayer,
        albums: albums, // Передаем текущий список альбомов
        monthlyListeners: monthlyListeners,
        onSpend: _spendListeners,
        onAlbumUpdate: _updateAndSaveState, // Передаем функцию сохранения
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack( // Эффективно переключает вкладки
          index: _selectedTabIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Тип панели
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.upgrade_rounded), // Иконка для апгрейдов
            label: 'Upgrade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded), // Иконка для музыки
            label: 'Music',
          ),
        ],
      ),
    );
  }
}
// END OF FULL CORRECTED FILE underground_rap_clicker/lib/main.dart