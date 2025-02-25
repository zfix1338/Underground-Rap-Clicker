import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models.dart';

class MusicScreen extends StatefulWidget {
  final AudioPlayer audioPlayer; // Используем глобальный аудио плеер
  final List<Track> tracks;
  final Function()? onTrackUpdate;
  final int monthlyListeners;
  final Function(int cost)? onSpend;

  const MusicScreen({
    Key? key,
    required this.audioPlayer,
    required this.tracks,
    this.onTrackUpdate,
    required this.monthlyListeners,
    this.onSpend,
  }) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  int _currentPlayingIndex = -1;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Подписываемся на события глобального плеера
    widget.audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    });

    widget.audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _totalDuration = dur;
        });
      }
    });

    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _handleTrackEnd();
      } else if (state == PlayerState.stopped) {
        _handleTrackStopped();
      }
    });

    // Если трек уже играет, продолжаем воспроизведение
    for (int i = 0; i < widget.tracks.length; i++) {
      if (widget.tracks[i].isPlaying) {
        _currentPlayingIndex = i;
        Future.microtask(() => _startTrackPlayback(i));
        break;
      }
    }
  }

  @override
  void dispose() {
    // НЕ вызываем widget.audioPlayer.dispose(), так как он управляется глобально
    super.dispose();
  }

  void _handleTrackEnd() {
    if (!mounted) return;
    setState(() {
      if (_currentPlayingIndex >= 0 && _currentPlayingIndex < widget.tracks.length) {
        widget.tracks[_currentPlayingIndex].isPlaying = false;
      }
      _currentPlayingIndex = -1;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });
    widget.onTrackUpdate?.call();
  }

  void _handleTrackStopped() {
    if (!mounted) return;
    setState(() {
      if (_currentPlayingIndex >= 0 && _currentPlayingIndex < widget.tracks.length) {
        widget.tracks[_currentPlayingIndex].isPlaying = false;
      }
      _currentPlayingIndex = -1;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });
    widget.onTrackUpdate?.call();
  }

  Future<void> _startTrackPlayback(int index) async {
    if (_isLoading) return;
    final track = widget.tracks[index];
    if (!track.isUploaded) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // Если другой трек уже играет, останавливаем его
      if (_currentPlayingIndex != -1 && _currentPlayingIndex != index) {
        setState(() {
          widget.tracks[_currentPlayingIndex].isPlaying = false;
        });
        await widget.audioPlayer.stop();
      }
      // Останавливаем и сбрасываем плеер
      await widget.audioPlayer.stop();
      if (kIsWeb) {
        await widget.audioPlayer.setSource(UrlSource('assets/${track.audioFile}'));
      } else {
        await widget.audioPlayer.setSource(AssetSource(track.audioFile));
      }
      // Запускаем воспроизведение
      await widget.audioPlayer.resume();
      setState(() {
        track.isPlaying = true;
        _currentPlayingIndex = index;
        _isLoading = false;
      });
      widget.onTrackUpdate?.call();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Playback error: $e")),
      );
    }
  }

  Future<void> _togglePlayPause(int index) async {
    if (_isLoading) return;
    final track = widget.tracks[index];
    if (!track.isUploaded) return;
    try {
      if (track.isPlaying) {
        await widget.audioPlayer.pause();
        setState(() {
          track.isPlaying = false;
        });
      } else {
        if (_currentPlayingIndex == index) {
          await widget.audioPlayer.resume();
          setState(() {
            track.isPlaying = true;
          });
        } else {
          await _startTrackPlayback(index);
        }
      }
      widget.onTrackUpdate?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Toggle error: $e")),
      );
    }
  }

  Future<void> _uploadTrack(int index) async {
    if (_isLoading) return;
    final track = widget.tracks[index];
    if (widget.monthlyListeners < track.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough balance to upload!")),
      );
      return;
    }
    widget.onSpend?.call(track.cost);
    setState(() {
      track.isUploaded = true;
    });
    await _startTrackPlayback(index);
    widget.onTrackUpdate?.call();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Music"),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: widget.tracks.length,
        itemBuilder: (context, index) {
          final track = widget.tracks[index];
          String statusText;
          if (!track.isUploaded) {
            statusText = "Cost: ${track.cost}";
          } else if (track.isPlaying) {
            statusText = "Playing";
          } else {
            statusText = "Paused";
          }
          return GestureDetector(
            onTap: () => track.isUploaded ? _togglePlayPause(index) : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(8),
              color: Colors.grey,
              child: Column(
                children: [
                  Row(
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
                            backgroundColor: Colors.grey,
                          ),
                          child: Text(
                            "Upload (${track.cost})",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        IconButton(
                          icon: _isLoading && _currentPlayingIndex == index
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : Icon(
                                  track.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                          onPressed: () => _togglePlayPause(index),
                        ),
                    ],
                  ),
                  if (track.isPlaying) ...[
                    const SizedBox(height: 8),
                    Slider(
                      min: 0,
                      max: _totalDuration.inSeconds > 0
                          ? _totalDuration.inSeconds.toDouble()
                          : 1,
                      value: _currentPosition.inSeconds.toDouble().clamp(
                                0,
                                _totalDuration.inSeconds > 0
                                    ? _totalDuration.inSeconds.toDouble()
                                    : 1,
                              ),
                      activeColor: Colors.orange,
                      inactiveColor: Colors.grey,
                      onChanged: (value) async {
                        final newPos = Duration(seconds: value.toInt());
                        await widget.audioPlayer.seek(newPos);
                        setState(() {
                          _currentPosition = newPos;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
