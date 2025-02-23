import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Track {
  final String title;
  final String artist;
  final String duration;
  final int cost;
  /// Только имя файла, например 'blonde.mp3'
  final String audioAsset;
  final String coverAsset;

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

    // Когда трек доиграл
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        if (_currentPlayingIndex >= 0 &&
            _currentPlayingIndex < widget.tracks.length) {
          widget.tracks[_currentPlayingIndex].isPlaying = false;
        }
        _currentPlayingIndex = -1;
      });
    });

    // Если хотите следить за состоянием (playing, paused, stopped):
    _audioPlayer.onPlayerStateChanged.listen((state) {
      // state - это PlayerState, может быть playing, paused, stopped, completed
      // Можно обновлять UI при необходимости
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

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

  /// Воспроизведение / Пауза локального файла (assets/audio/filename.mp3)
  Future<void> _togglePlayPause(int index) async {
    final track = widget.tracks[index];
    if (!track.isUploaded) return; // если не куплен

    // Если трек уже играет -> пауза
    if (track.isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        track.isPlaying = false;
      });
      return;
    }

    // Если другой трек играет -> стоп
    if (_currentPlayingIndex != -1 && _currentPlayingIndex != index) {
      widget.tracks[_currentPlayingIndex].isPlaying = false;
      await _audioPlayer.stop();
    }

    // Устанавливаем источник (AssetSource требует только имя файла)
    await _audioPlayer.setSource(
      AssetSource(track.audioAsset),
    );

    // Запускаем
    await _audioPlayer.resume(); // начинаем воспроизведение

    // Успех
    setState(() {
      track.isPlaying = true;
      _currentPlayingIndex = index;
    });
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
                  // Обложка
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

                  // Инфа
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
                            color: track.isPlaying ? Colors.orange : Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!track.isUploaded)
                    ElevatedButton(
                      onPressed: () => _uploadTrack(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                      ),
                      child: Text(
                        'Upload\ncost: ${track.cost}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  else
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

class AssetSource {
  AssetSource(String audioAsset);
}

extension on AudioPlayer {
  get onPlayerComplete => null;

  setSource(assetSource) {}
}