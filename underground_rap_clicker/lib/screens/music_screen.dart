// lib/screens/music_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models.dart';

class MusicScreen extends StatefulWidget {
  final List<Track> tracks;
  final VoidCallback? onTrackUpdate;
  final int monthlyListeners;
  final Function(int cost)? onSpend;

  const MusicScreen({
    super.key,
    required this.tracks,
    this.onTrackUpdate,
    required this.monthlyListeners,
    this.onSpend,
  });

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late AudioPlayer _audioPlayer;
  int _currentPlayingIndex = -1;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // NOTE: audioplayers v6+ больше не поддерживает onPlayerError, поэтому удаляем подписку

    _audioPlayer.onPositionChanged.listen((pos) {
      setState(() {
        _currentPosition = pos;
      });
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      setState(() {
        _totalDuration = dur;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startTrackPlayback(int index) async {
    final track = widget.tracks[index];
    if (!track.isUploaded) return;

    if (_currentPlayingIndex != -1 && _currentPlayingIndex != index) {
      widget.tracks[_currentPlayingIndex].isPlaying = false;
      await _audioPlayer.stop();
    }

    try {
      // Для веба используем UrlSource, для мобилки – AssetSource
      if (kIsWeb) {
        // На вебе путь должен быть как в assets, например "assets/audio/blonde.mp3"
        await _audioPlayer.setSource(UrlSource(track.audioFile));
      } else {
        await _audioPlayer.setSource(AssetSource(track.audioFile));
      }

      await _audioPlayer.resume();

      if (!mounted) return;
      setState(() {
        track.isPlaying = true;
        _currentPlayingIndex = index;
      });
      widget.onTrackUpdate?.call();
    } catch (e) {
      if (!mounted) return;
      debugPrint("Playback error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Playback Error: $e")),
      );
    }
  }

  Future<void> _togglePlayPause(int index) async {
    final track = widget.tracks[index];
    if (!track.isUploaded) return;

    if (track.isPlaying) {
      await _audioPlayer.pause();
      if (!mounted) return;
      setState(() {
        track.isPlaying = false;
      });
    } else {
      await _startTrackPlayback(index);
    }
    widget.onTrackUpdate?.call();
  }

  Future<void> _uploadTrack(int index) async {
    final track = widget.tracks[index];
    if (widget.monthlyListeners < track.cost) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough balance to upload track!")),
      );
      return;
    }
    // Списываем стоимость через callback
    widget.onSpend?.call(track.cost);
    setState(() {
      track.isUploaded = true;
    });
    await _startTrackPlayback(index);
    widget.onTrackUpdate?.call();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
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
            onTap: () => _togglePlayPause(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(8),
              color: Colors.grey[900],
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
                            backgroundColor: Colors.grey[700],
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
                          icon: Icon(
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
                      max: _totalDuration.inSeconds.toDouble() > 0
                          ? _totalDuration.inSeconds.toDouble()
                          : 1,
                      value: _currentPosition.inSeconds.toDouble().clamp(
                            0,
                            _totalDuration.inSeconds.toDouble(),
                          ),
                      activeColor: Colors.orange,
                      inactiveColor: Colors.grey,
                      onChanged: (value) async {
                        final newPos = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(newPos);
                        if (!mounted) return;
                        setState(() {
                          _currentPosition = newPos;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_currentPosition),
                            style: const TextStyle(color: Colors.white70)),
                        Text(_formatDuration(_totalDuration),
                            style: const TextStyle(color: Colors.white70)),
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
