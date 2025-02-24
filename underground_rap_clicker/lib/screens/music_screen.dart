import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models.dart';

class MusicScreen extends StatefulWidget {
  final List<Track> tracks;
  final Function()? onTrackUpdate;
  final int monthlyListeners;
  final Function(int cost)? onSpend;

  const MusicScreen({
    Key? key,
    required this.tracks,
    this.onTrackUpdate,
    required this.monthlyListeners,
    this.onSpend,
  }): super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentPlayingIndex = -1;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

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

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _handleTrackEnd();
      } else if (state == PlayerState.stopped) {
        _handleTrackStopped();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleTrackEnd() {
    setState(() {
      widget.tracks[_currentPlayingIndex].isPlaying = false;
      _currentPlayingIndex = -1;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });
    widget.onTrackUpdate?.call();
  }

  void _handleTrackStopped() {
    setState(() {
      widget.tracks[_currentPlayingIndex].isPlaying = false;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });
    widget.onTrackUpdate?.call();
  }

  Future<void> _startTrackPlayback(int index) async {
    final track = widget.tracks[index];
    if (!track.isUploaded) return;

    if (_currentPlayingIndex!= -1 && _currentPlayingIndex!= index) {
      setState(() {
        widget.tracks[_currentPlayingIndex].isPlaying = false;
      });
      await _audioPlayer.stop();
    }

    try {
      if (kIsWeb) {
        await _audioPlayer.setSource(UrlSource(track.audioFile));
      } else {
        await _audioPlayer.setSource(AssetSource(track.audioFile));
      }
      await _audioPlayer.resume();

      setState(() {
        track.isPlaying = true;
        _currentPlayingIndex = index;
      });
      widget.onTrackUpdate?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Playback error: $e")),
      );
    }
  }

  Future<void> _togglePlayPause(int index) async {
    final track = widget.tracks[index];
    if (!track.isUploaded) return;

    if (track.isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _startTrackPlayback(index);
    }
    setState(() {
      track.isPlaying =!track.isPlaying;
    });
    widget.onTrackUpdate?.call();
  }

  Future<void> _uploadTrack(int index) async {
    final track = widget.tracks[index];
    if (widget.monthlyListeners < track.cost) {
      if (!mounted) return;
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
            onTap: () => _togglePlayPause(index),
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
                                color: track.isPlaying
                                  ? Colors.orange
                                  : Colors.white70,
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
                          icon: Icon(
                            track.isPlaying? Icons.pause: Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () => _togglePlayPause(index),
                        ),
                    ],
                  ),
                  if (track.isPlaying)...[
                    const SizedBox(height: 8),
                    Slider(
                      min: 0,
                      max: _totalDuration.inSeconds > 0
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