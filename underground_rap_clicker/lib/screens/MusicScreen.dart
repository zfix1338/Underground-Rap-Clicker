import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Track {
  final String title;
  final String artist;
  final String duration;
  final int cost;
  final String audioAsset; // например 'assets/audio/blonde.mp3'
  final String coverAsset; // например 'assets/images/blonde_cover.png'

  bool isUploaded;
  bool isPlaying;

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
    // (В старых версиях называется onPlayerCompletion)
    _audioPlayer.onPlayerCompletion.listen((_) {
      setState(() {
        // Сбрасываем флаги, когда трек доиграл
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

  /// Покупка (Upload) трека
  void _uploadTrack(int index) {
    final track = widget.tracks[index];
    final cost = track.cost;
    if (widget.monthlyListeners >= cost) {
      widget.onSpend(cost); // списываем стоимость
      setState(() {
        track.isUploaded = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough listeners to upload track')),
      );
    }
  }

  /// Воспроизведение / Пауза трека
  Future<void> _togglePlayPause(int index) async {
    final track = widget.tracks[index];
    if (!track.isUploaded) return; // не загружен - не играем

    // Если трек уже играет - ставим на паузу
    if (track.isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        track.isPlaying = false;
      });
      return;
    }

    // Иначе, если играет другой трек - остановим его
    if (_currentPlayingIndex != -1 && _currentPlayingIndex != index) {
      widget.tracks[_currentPlayingIndex].isPlaying = false;
      await _audioPlayer.stop();
    }

    // Пытаемся запустить текущий трек (локальный файл)
    // В старых версиях audioplayers нужно передать путь + isLocal: true
    final result = await _audioPlayer.play(
      track.audioAsset,
      isLocal: true, // важный флаг для локальных файлов
    );

    // В старых версиях: result == 1 => успех, 0 => ошибка
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
      // Если это просто вкладка без AppBar, можете убрать AppBar
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
                  // Обложка (локальное изображение)
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
                    // Меню (три точки), если хотите доп. опции
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        // ...
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