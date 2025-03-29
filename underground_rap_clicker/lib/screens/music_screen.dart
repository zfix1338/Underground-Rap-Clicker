// START OF MODIFIED FILE underground_rap_clicker/lib/screens/music_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models.dart';

class MusicScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final List<Album> albums;
  final int monthlyListeners;
  final Function(int) onSpend;
  final VoidCallback onAlbumUpdate;

  const MusicScreen({
    super.key,
    required this.audioPlayer,
    required this.albums,
    required this.monthlyListeners,
    required this.onSpend,
    required this.onAlbumUpdate,
  });

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  Track? _currentlyPlaying;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero; // Общая длительность трека
  Duration _position = Duration.zero; // Текущая позиция воспроизведения

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _durationSubscription; // Подписка на длительность
  StreamSubscription? _positionSubscription; // Подписка на позицию

  final int trackPurchaseCost = 100;

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения состояния плеера
    _playerStateSubscription = widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          if (state == PlayerState.stopped || state == PlayerState.completed) {
            _currentlyPlaying = null;
            _position = Duration.zero; // Сбрасываем позицию при остановке/завершении
          }
        });
      }
    }, onError: (msg) {
       print('Audio player state error: $msg');
       if (mounted) {
         setState(() { _playerState = PlayerState.stopped; _currentlyPlaying = null; _position = Duration.zero; });
       }
    });

    // Подписываемся на завершение воспроизведения
    _playerCompleteSubscription = widget.audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() { _currentlyPlaying = null; _playerState = PlayerState.completed; _position = Duration.zero; });
      }
    });

    // --- Подписки на длительность и позицию ---
    _durationSubscription = widget.audioPlayer.onDurationChanged.listen((d) {
      if (mounted && d.inMilliseconds > 0) { // Игнорируем нулевую длительность
        setState(() => _duration = d);
      }
    });

    _positionSubscription = widget.audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });
    // -----------------------------------------
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _durationSubscription?.cancel(); // Отписываемся
    _positionSubscription?.cancel(); // Отписываемся
    super.dispose();
  }

  // Метод для покупки трека (без изменений)
  void _purchaseTrack(Track track) {
    if (widget.monthlyListeners >= trackPurchaseCost) {
      widget.onSpend(trackPurchaseCost);
      setState(() => track.isPurchased = true);
      widget.onAlbumUpdate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${track.title} purchased!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough clout to buy ${track.title} ($trackPurchaseCost)'), backgroundColor: Colors.red),
      );
    }
  }

  // Метод для воспроизведения/паузы (без изменений в логике play/pause)
  Future<void> _playPauseTrack(Track track) async {
    if (!track.isPurchased) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase this track first!')),
      );
      return;
    }
    try {
      if (_currentlyPlaying == track && _playerState == PlayerState.playing) {
        await widget.audioPlayer.pause();
      } else if (_currentlyPlaying == track && _playerState == PlayerState.paused) {
        await widget.audioPlayer.resume();
      } else {
        // При старте нового трека сбрасываем позицию и длительность
         if (mounted) {
           setState(() {
             _position = Duration.zero;
             _duration = Duration.zero;
           });
         }
        await widget.audioPlayer.play(AssetSource(track.audioFile));
        if (mounted) setState(() => _currentlyPlaying = track);
      }
    } catch (e) {
       print("Error playing/pausing track: $e");
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error processing audio: ${e.toString()}')));
        if (mounted) setState(() { _currentlyPlaying = null; _playerState = PlayerState.stopped; _position = Duration.zero; _duration = Duration.zero; });
    }
  }

  // Метод для остановки (без изменений)
  Future<void> _stopTrack() async {
    try {
       await widget.audioPlayer.stop();
       // Состояние и _currentlyPlaying обновятся через listener
    } catch (e) { print("Error stopping track: $e"); }
  }

  // --- Хелпер для форматирования Duration в MM:SS ---
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Library'),
        backgroundColor: colorScheme.surfaceVariant,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Image.asset('assets/images/clout_coin.png', width: 20, height: 20),
                const SizedBox(width: 5),
                Text(widget.monthlyListeners.toString(), style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          )
        ],
      ),
      // Используем Column для добавления плеера внизу
      body: Column(
        children: [
          // Список альбомов и треков
          Expanded(
            child: ListView.builder(
              itemCount: widget.albums.length,
              itemBuilder: (context, albumIndex) {
                final album = widget.albums[albumIndex];
                return ExpansionTile(
                  leading: Image.asset(album.coverAsset, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(album.title, style: textTheme.titleLarge),
                  children: album.tracks.map((track) {
                    final bool isThisPlaying = _currentlyPlaying == track && _playerState == PlayerState.playing;
                    final bool isThisPaused = _currentlyPlaying == track && _playerState == PlayerState.paused;
                    final bool isCurrentTrack = _currentlyPlaying == track;

                    Widget trailingWidget;
                    IconData leadingIcon;
                    VoidCallback onTapAction;

                    if (track.isPurchased) {
                      leadingIcon = isThisPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill;
                      trailingWidget = Text(track.duration, style: textTheme.bodySmall);
                      onTapAction = () => _playPauseTrack(track);
                    } else {
                      leadingIcon = Icons.lock_outline;
                      trailingWidget = ElevatedButton.icon(
                        icon: Image.asset('assets/images/clout_coin.png', width: 16, height: 16),
                        label: Text(trackPurchaseCost.toString()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          textStyle: textTheme.labelSmall,
                          backgroundColor: widget.monthlyListeners >= trackPurchaseCost ? colorScheme.primaryContainer : Colors.grey[700],
                          foregroundColor: widget.monthlyListeners >= trackPurchaseCost ? colorScheme.onPrimaryContainer : Colors.grey[400],
                        ),
                        onPressed: () => _purchaseTrack(track),
                      );
                      onTapAction = () => _purchaseTrack(track);
                    }

                    return ListTile(
                      leading: Icon(
                        leadingIcon,
                        color: isThisPlaying ? colorScheme.secondary : (track.isPurchased ? colorScheme.primary : Colors.grey),
                        size: 35,
                      ),
                      title: Text(track.title, style: textTheme.bodyLarge),
                      subtitle: Text(track.artist, style: textTheme.bodyMedium),
                      trailing: trailingWidget,
                      onTap: onTapAction,
                      tileColor: isThisPlaying || isThisPaused ? colorScheme.primary.withOpacity(0.1) : null,
                      selected: isCurrentTrack, // Выделяем текущий трек
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // --- Панель управления текущим треком ---
          if (_currentlyPlaying != null) // Показываем только если трек выбран
            Container(
               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
               color: colorScheme.surfaceVariant.withOpacity(0.8), // Полупрозрачный фон
               child: Column(
                 mainAxisSize: MainAxisSize.min, // Занимать минимум места по вертикали
                 children: [
                   // Название текущего трека
                    Text(
                        'Now Playing: ${_currentlyPlaying!.title}',
                         style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                         overflow: TextOverflow.ellipsis,
                     ),
                    const SizedBox(height: 4),
                   // Ползунок
                   SliderTheme( // Настраиваем внешний вид слайдера
                      data: SliderTheme.of(context).copyWith(
                         trackHeight: 2.0,
                         thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                         overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                         activeTrackColor: colorScheme.primary,
                         inactiveTrackColor: colorScheme.primary.withOpacity(0.3),
                         thumbColor: colorScheme.primary,
                      ),
                      child: Slider(
                        min: 0.0,
                        max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0, // Избегаем деления на 0
                        // Ограничиваем значение позиции, чтобы оно не выходило за рамки
                        value: (_position.inSeconds.toDouble() > 0 && _position <= _duration)
                               ? _position.inSeconds.toDouble()
                               : 0.0,
                        onChanged: (value) {
                           final newPosition = Duration(seconds: value.toInt());
                           widget.audioPlayer.seek(newPosition); // Перемотка
                        },
                      ),
                   ),
                   // Время: Текущее / Общее
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(_formatDuration(_position), style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                       Text(_formatDuration(_duration), style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                     ],
                   ),
                   // Кнопка Stop (можно добавить еще кнопки)
                    IconButton(
                       icon: const Icon(Icons.stop_circle_outlined),
                       color: colorScheme.onSurfaceVariant,
                       iconSize: 30,
                       onPressed: _stopTrack,
                    )
                 ],
               ),
            ),
          // ----------------------------------------
        ],
      ),
      // Убрали плавающую кнопку Stop, т.к. панель теперь внизу
    );
  }
}
// END OF MODIFIED FILE underground_rap_clicker/lib/screens/music_screen.dart