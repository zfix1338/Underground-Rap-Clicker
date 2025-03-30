// START OF FULL REVISED FILE: lib/screens/music_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart'; // Убедитесь, что путь к моделям правильный

const String cloutCoinPath = 'assets/clout_coin.png'; // Added constant for clout coin path

class MusicScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;         // Экземпляр плеера
  final List<Album> albums;              // Список альбомов
  final int monthlyListeners;          // Текущий баланс
  final Function(int cost)? onSpend;   // Функция списания валюты
  final Function()? onAlbumUpdate;     // Функция для сохранения состояния альбомов

  const MusicScreen({
    super.key,
    required this.audioPlayer,
    required this.albums,
    required this.monthlyListeners,
    this.onSpend,
    this.onAlbumUpdate,
  });

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  // Состояние воспроизведения (хранится здесь)
  String? _currentlyPlayingTrackIdentifier; // Идентификатор (например, title) играющего трека
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;
  double _sliderValue = 0;
  bool _isDragging = false;

  // Ключ для SharedPreferences
  static const String _purchasedTracksPrefKey = 'purchasedTracks';

  @override
  void initState() {
    super.initState();
    _loadPurchasedTracks(); // Загружаем статус покупок
    _setupAudioPlayerListeners(); // Настраиваем слушатели
    _checkCurrentlyPlaying(); // Проверяем активный трек при входе
  }

  // Настройка слушателей плеера
  void _setupAudioPlayerListeners() {
     widget.audioPlayer.onPositionChanged.listen((pos) {
      if (mounted && !_isDragging && widget.audioPlayer.state == PlayerState.playing) {
        setState(() {
          _currentPosition = pos;
          if (!_isDragging) {
            _sliderValue = pos.inSeconds.toDouble().clamp(0.0, _totalDuration.inSeconds.toDouble());
          }
        });
      }
    });

    widget.audioPlayer.onDurationChanged.listen((dur) {
      if (mounted && dur > Duration.zero) {
        setState(() { _totalDuration = dur; });
      }
    });

    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _handleTrackEnd();
      } else {
        setState(() {}); // Обновляем UI при паузе/возобновлении
      }
    });
  }

  // Проверка играющего трека при инициализации
  Future<void> _checkCurrentlyPlaying() async {
     String? currentAssetPath = await _getAudioPlayerCurrentSource(); // Получаем текущий источник
     if (currentAssetPath != null) {
        // Ищем трек с таким путем
        Track? foundTrack;
        for (var album in widget.albums) {
           try {
              foundTrack = album.tracks.firstWhere((t) => t.audioFile == currentAssetPath);
              break; // Нашли, выходим из цикла
           } catch (e) { /* Не найдено в этом альбоме */ }
        }

        if (foundTrack != null) {
           _currentlyPlayingTrackIdentifier = foundTrack.title; // Используем title как идентификатор
           try {
              final pos = await widget.audioPlayer.getCurrentPosition() ?? Duration.zero;
              final dur = await widget.audioPlayer.getDuration() ?? Duration.zero;
              if (mounted) {
                 setState(() {
                    _currentPosition = pos;
                    _totalDuration = dur;
                    _sliderValue = pos.inSeconds.toDouble().clamp(0.0, dur.inSeconds.toDouble());
                 });
              }
           } catch (e) { print("Error getting initial position/duration: $e"); }
        }
     }
  }

  // Вспомогательная функция для получения текущего источника плеера
  Future<String?> _getAudioPlayerCurrentSource() async {
    // Audioplayers не предоставляет прямого метода для получения текущего AssetSource/UrlSource.
    // Это ограничение пакета. Мы можем только предполагать на основе последнего запущенного трека.
    // Поэтому _checkCurrentlyPlaying будет работать корректно только если состояние
    // _currentlyPlayingTrackIdentifier сохраняется между перезапусками экрана (например, в MainScreen).
    // В данном случае, проще просто проверять состояние плеера, а не конкретный трек.
    // Возвращаем null, чтобы не полагаться на неточный метод.
    return null; // TODO: Найти способ надежно определять текущий трек плеера, если это критично
  }


  // Загрузка статуса покупок
  Future<void> _loadPurchasedTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasedIds = prefs.getStringList(_purchasedTracksPrefKey) ?? [];
      if (!mounted) return;
      // Не нужно вызывать setState здесь, т.к. albums передаются извне.
      // Вместо этого, убедимся, что MainScreen правильно загружает/передает albums.
      // Проверим, что у переданных треков правильный статус
      bool needsUpdate = false;
      for (var album in widget.albums) {
         for (var track in album.tracks) {
            bool shouldBePurchased = purchasedIds.contains(track.title);
            if (track.isPurchased != shouldBePurchased) {
               track.isPurchased = shouldBePurchased;
               needsUpdate = true; // Пометим, что нужно обновить UI, если нашли расхождение
            }
         }
      }
      if (needsUpdate && mounted) {
         setState(() {}); // Обновляем UI, если статус изменился
      }
    } catch (e) { /* Обработка ошибки */ print("Error loading tracks: $e"); }
  }

  // Сохранение статуса покупки
  Future<void> _savePurchasedTrack(String trackIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasedIds = prefs.getStringList(_purchasedTracksPrefKey) ?? [];
      if (!purchasedIds.contains(trackIdentifier)) {
        purchasedIds.add(trackIdentifier);
        await prefs.setStringList(_purchasedTracksPrefKey, purchasedIds);
      }
    } catch (e) { /* Обработка ошибки */ print("Error saving track: $e"); }
  }

  // Сброс состояния воспроизведения
  void _handleTrackEnd() {
    if (!mounted) return;
    setState(() {
      _currentlyPlayingTrackIdentifier = null;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _sliderValue = 0;
    });
  }

  // Запуск нового трека
  Future<void> _startTrackPlayback(Track track) async {
     if (_isLoading) return;
     if (!track.isPurchased) return;

     setState(() { _isLoading = true; });

     try {
       await widget.audioPlayer.stop(); // Останавливаем предыдущий
       final source = kIsWeb ? UrlSource('assets/${track.audioFile}') : AssetSource(track.audioFile);
       await widget.audioPlayer.setSource(source);
       await widget.audioPlayer.resume();

       if (!mounted) return;
       setState(() {
         _currentlyPlayingTrackIdentifier = track.title; // Сохраняем идентификатор
         _isLoading = false;
         _currentPosition = Duration.zero;
         // _totalDuration обновится через слушатель
       });
     } catch (e) {
       print("Error starting playback: $e");
       if (!mounted) return;
       setState(() { _isLoading = false; });
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Playback error: $e")));
       _handleTrackEnd();
     }
  }

  // Переключение Play/Pause
  Future<void> _togglePlayPause(Track track) async {
     if (_isLoading) return;
     if (!track.isPurchased) return;

     try {
       // Если играет текущий трек
       if (widget.audioPlayer.state == PlayerState.playing && _currentlyPlayingTrackIdentifier == track.title) {
         await widget.audioPlayer.pause();
       }
       // Если на паузе текущий трек
       else if (widget.audioPlayer.state == PlayerState.paused && _currentlyPlayingTrackIdentifier == track.title) {
         await widget.audioPlayer.resume();
       }
       // Если выбран другой трек или плеер остановлен
       else {
         await _startTrackPlayback(track);
       }
       // UI обновится через слушатель onPlayerStateChanged
     } catch (e) { print("Error toggling play/pause: $e"); }
  }

  // Покупка трека
  Future<void> _purchaseTrack(Track track) async {
     if (widget.monthlyListeners < track.cost) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Not enough clout!")));
       return;
     }

     widget.onSpend?.call(track.cost); // Списываем валюту через колбэк

     if (mounted) {
       setState(() { track.isPurchased = true; }); // Обновляем локальное состояние
       await _savePurchasedTrack(track.title); // Сохраняем в SharedPreferences
       widget.onAlbumUpdate?.call(); // Уведомляем MainScreen о необходимости сохранить ВСЕ данные
     }
  }

  // Форматирование времени
  String _formatDuration(Duration d) {
    if (d <= Duration.zero) return '0:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Получаем стили

    // Стиль для заголовка AppBar
    final appBarTitleStyle = textTheme.titleLarge?.copyWith(
      color: Colors.white, fontWeight: FontWeight.bold,
       shadows: [ Shadow( blurRadius: 1.0, color: Colors.black.withOpacity(0.5), offset: const Offset(1.0, 1.0)) ]
    );
    // Стиль для счетчика в AppBar
     final appBarCounterStyle = textTheme.titleMedium?.copyWith(
      color: Colors.orangeAccent, fontWeight: FontWeight.bold,
       shadows: [ Shadow( blurRadius: 1.0, color: Colors.black.withOpacity(0.5), offset: const Offset(1.0, 1.0)) ]
    );

    return Scaffold(
      backgroundColor: Colors.grey[900], // Фон экрана
      appBar: AppBar(
        title: Text('Music Library', style: appBarTitleStyle),
        backgroundColor: Colors.black87,
        elevation: 4,
        actions: [ // Отображаем баланс справа в AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(cloutCoinPath, width: 20, height: 20), // Иконка валюты
                const SizedBox(width: 8),
                Text(widget.monthlyListeners.toString(), style: appBarCounterStyle),
              ],
            ),
          )
        ],
      ),
      // Используем ListView для отображения альбомов
      body: ListView.builder(
        itemCount: widget.albums.length, // Количество альбомов
        itemBuilder: (context, albumIndex) {
          final album = widget.albums[albumIndex]; // Текущий альбом

          // ExpansionTile для каждого альбома
          return Card( // Обернем в Card для лучшего вида
             color: Colors.grey[850],
             margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
             elevation: 3,
             child: ExpansionTile(
                key: PageStorageKey(album.title), // Ключ для сохранения состояния раскрытия
                leading: ClipRRect( // Обложка альбома
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    album.coverAsset,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey[700]),
                  ),
                ),
                title: Text(
                  album.title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)
                       ?? const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                iconColor: Colors.orangeAccent, // Цвет стрелки
                collapsedIconColor: Colors.grey[400],
                // Строим список треков для этого альбома
                children: album.tracks.map((track) {
                    // Определяем, играет ли этот трек
                    bool isPlaying = widget.audioPlayer.state == PlayerState.playing && _currentlyPlayingTrackIdentifier == track.title;
                    bool isPaused = widget.audioPlayer.state == PlayerState.paused && _currentlyPlayingTrackIdentifier == track.title;
                    bool isActive = isPlaying || isPaused; // Активен ли трек (играет или на паузе)

                    return Padding( // Отступы для каждого трека
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 4.0, bottom: 4.0),
                      child: Column( // Колонка для трека и слайдера
                        children: [
                          ListTile(
                            dense: true, // Уменьшаем вертикальные отступы
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                            leading: track.isPurchased
                                ? Icon(Icons.music_note, color: isActive ? Colors.orangeAccent : Colors.white70, size: 24,)
                                : Icon(Icons.lock_outline, color: Colors.grey[600], size: 24),
                            title: Text(track.title, style: textTheme.bodyMedium?.copyWith(color: Colors.white) ?? const TextStyle(color: Colors.white)),
                            subtitle: Text(track.artist, style: textTheme.bodySmall?.copyWith(color: Colors.grey[400]) ?? const TextStyle(color: Colors.grey)),
                            trailing: track.isPurchased
                                // Кнопка Play/Pause
                                ? IconButton(
                                    icon: _isLoading && _currentlyPlayingTrackIdentifier == track.title
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                                      : Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                             color: Colors.white, size: 28),
                                    onPressed: () => _togglePlayPause(track),
                                    tooltip: isPlaying ? 'Pause' : 'Play',
                                  )
                                // Кнопка Покупки
                                : ElevatedButton.icon(
                                    icon: Image.asset(cloutCoinPath, width: 14, height: 14),
                                    label: Text(track.cost.toString()),
                                    onPressed: () => _purchaseTrack(track),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrangeAccent[100],
                                      foregroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      minimumSize: const Size(60, 28) // Минимальный размер кнопки
                                    ),
                                  ),
                          ),
                          // Слайдер и время (показываются только если трек активен)
                          if (isActive && _totalDuration > Duration.zero) ...[
                            const SizedBox(height: 4),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.orangeAccent,
                                inactiveTrackColor: Colors.grey[700],
                                thumbColor: Colors.orange,
                                overlayColor: Colors.orange.withOpacity(0.2),
                                trackHeight: 2.0,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                              ),
                              child: Slider(
                                min: 0.0,
                                max: _totalDuration.inSeconds.toDouble(),
                                value: _sliderValue.clamp(0.0, _totalDuration.inSeconds.toDouble()), // Используем _sliderValue
                                onChanged: (value) {
                                  if (!mounted) return;
                                  setState(() {
                                    _isDragging = true;
                                    _sliderValue = value;
                                    _currentPosition = Duration(seconds: value.round());
                                  });
                                },
                                onChangeEnd: (value) async {
                                  if (!mounted) return;
                                  setState(() { _isDragging = false; });
                                  try {
                                    await widget.audioPlayer.seek(Duration(seconds: value.round()));
                                  } catch (e) { print("Seek Error: $e"); }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(_currentPosition), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(_formatDuration(_totalDuration), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                             const SizedBox(height: 8), // Отступ после слайдера
                          ],
                        ],
                      ),
                    );
                }).toList(), // Конец map для треков
             ),
           );
        },
      ),
    );
  }
}
// END OF FULL REVISED FILE: lib/screens/music_screen.dart