// music_screen.dart
// 
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:underground_rap_clicker/models.dart';
import 'dart:async';

class MusicScreen extends StatefulWidget {
  final int monthlyListeners;
  final Function(int cost) onSpend;
  final List<Track> tracks;
  final VoidCallback onTrackUpdate;

  const MusicScreen({
    super.key,
    required this.monthlyListeners,
    required this.onSpend,
    required this.tracks,
    required this.onTrackUpdate,
  });

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late StreamSubscription _playerCompleteSubscription;
  late StreamSubscription _playerStateSubscription;
  int _currentPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    // Устанавливаем режим, при котором плеер останавливается после завершения воспроизведения.
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        if (_currentPlayingIndex >= 0 && _currentPlayingIndex < widget.tracks.length) {
          widget.tracks[_currentPlayingIndex].isPlaying = false;
        }
        _currentPlayingIndex = -1;
      });
      widget.onTrackUpdate();
    });
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      // Здесь можно обновлять UI при изменении состояния плеера
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription.cancel();
    _playerStateSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Метод загрузки трека: после успешной загрузки трек сразу начинает воспроизводиться.
  void _uploadTrack(int index) async {
    final track = widget.tracks[index];
    if (widget.monthlyListeners >= track.cost) {
      widget.onSpend(track.cost);
      setState(() {
        track.isUploaded = true;
      });
      widget.onTrackUpdate();
      // Автоматически запускаем воспроизведение после загрузки.
      await _togglePlayPause(index);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough listeners to upload track')),
      );
    }
  }

  // Метод для переключения между воспроизведением и паузой
  Future<void> _togglePlayPause(int index) async {
    final track = widget.tracks[index];
    if (!track.isUploaded) return;

    if (track.isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        track.isPlaying = false;
      });
      widget.onTrackUpdate();
      return;
    }

    if (_currentPlayingIndex != -1 && _currentPlayingIndex != index) {
      widget.tracks[_currentPlayingIndex].isPlaying = false;
      await _audioPlayer.stop();
    }

    // Воспроизводим аудиофайл через AssetSource, используя правильный путь.
    await _audioPlayer.play(AssetSource(track.audioFile));

    setState(() {
      track.isPlaying = true;
      _currentPlayingIndex = index;
    });
    widget.onTrackUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(title: const Text('Music'), backgroundColor: Colors.black),
      body: ListView.builder(
        itemCount: widget.tracks.length,
        itemBuilder: (context, index) {
          final track = widget.tracks[index];
          String statusText;
          if (!track.isUploaded) {
            statusText = 'Cost: ${track.cost}';
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
                        'Upload\nCost: ${track.cost}',
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
                        // Дополнительные действия (например, удаление)
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