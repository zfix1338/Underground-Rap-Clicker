import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;
  final AudioPlayer audioPlayer;
  final int monthlyListeners;
  final Function(int cost)? onSpend;
  final Function()? onTrackUpdate;

  const AlbumDetailScreen({
    Key? key,
    required this.album,
    required this.audioPlayer,
    required this.monthlyListeners,
    this.onSpend,
    this.onTrackUpdate,
  }) : super(key: key);

  @override
  AlbumDetailScreenState createState() => AlbumDetailScreenState();
}

class AlbumDetailScreenState extends State<AlbumDetailScreen> {
  int _currentPlayingIndex = -1;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;
  double _sliderValue = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    _loadPurchasedTracks();

    widget.audioPlayer.onPositionChanged.listen((pos) {
      if (mounted && !_isDragging) {
        setState(() {
          _currentPosition = pos;
          _sliderValue = pos.inSeconds.toDouble();
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

    _initSlider();
    _initDuration();

    for (int i = 0; i < widget.album.tracks.length; i++) {
      if (widget.album.tracks[i].isPlaying) {
        _currentPlayingIndex = i;
        break;
      }
    }
  }

  Future<void> _initSlider() async {
    try {
      Duration pos = await widget.audioPlayer.getCurrentPosition() ?? Duration.zero;
      if (mounted) {
        setState(() {
          _currentPosition = pos;
          _sliderValue = pos.inSeconds.toDouble();
        });
      }
    } catch (e) {
      // Обработка ошибки, если необходимо
    }
  }

  Future<void> _initDuration() async {
    try {
      Duration? duration = await widget.audioPlayer.getDuration();
      if (duration != null && mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    } catch (e) {
      // Обработка ошибки, если необходимо
    }
  }

  Future<void> _loadPurchasedTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasedIds = prefs.getStringList('purchasedTracks') ?? [];
    setState(() {
      for (var track in widget.album.tracks) {
        track.isUploaded = purchasedIds.contains(track.title);
      }
    });
  }

  Future<void> _savePurchasedTrack(String trackIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    final purchasedIds = prefs.getStringList('purchasedTracks') ?? [];
    if (!purchasedIds.contains(trackIdentifier)) {
      purchasedIds.add(trackIdentifier);
      await prefs.setStringList('purchasedTracks', purchasedIds);
    }
  }

  void _handleTrackEnd() {
    if (!mounted) return;
    setState(() {
      if (_currentPlayingIndex >= 0 && _currentPlayingIndex < widget.album.tracks.length) {
        widget.album.tracks[_currentPlayingIndex].isPlaying = false;
      }
      _currentPlayingIndex = -1;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _sliderValue = 0;
    });
    widget.onTrackUpdate?.call();
  }

  void _handleTrackStopped() {
    _handleTrackEnd();
  }

  Future<void> _startTrackPlayback(int index) async {
    if (_isLoading) return;
    final track = widget.album.tracks[index];
    if (!track.isUploaded) return;

    setState(() {
      _isLoading = true;
    });
    try {
      if (_currentPlayingIndex != -1 && _currentPlayingIndex != index) {
        setState(() {
          widget.album.tracks[_currentPlayingIndex].isPlaying = false;
        });
        await widget.audioPlayer.stop();
      }
      await widget.audioPlayer.stop();
      if (kIsWeb) {
        await widget.audioPlayer.setSource(UrlSource('assets/${track.audioFile}'));
      } else {
        await widget.audioPlayer.setSource(AssetSource(track.audioFile));
      }
      await widget.audioPlayer.resume();
      if (!mounted) return;
      setState(() {
        track.isPlaying = true;
        _currentPlayingIndex = index;
        _isLoading = false;
      });
      widget.onTrackUpdate?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Playback error: $e")));
    }
  }

  Future<void> _togglePlayPause(int index) async {
    if (_isLoading) return;
    final track = widget.album.tracks[index];
    if (!track.isUploaded) return;
    try {
      if (track.isPlaying) {
        await widget.audioPlayer.pause();
        if (!mounted) return;
        setState(() {
          track.isPlaying = false;
        });
      } else {
        if (_currentPlayingIndex == index) {
          await widget.audioPlayer.resume();
          if (!mounted) return;
          setState(() {
            track.isPlaying = true;
          });
        } else {
          await _startTrackPlayback(index);
        }
      }
      widget.onTrackUpdate?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Toggle error: $e")));
    }
  }

  Future<void> _uploadTrack(int index) async {
    if (_isLoading) return;
    final track = widget.album.tracks[index];
    if (widget.monthlyListeners < track.cost) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not enough balance to upload!")));
      return;
    }
    widget.onSpend?.call(track.cost);
    if (!mounted) return;
    setState(() {
      track.isUploaded = true;
    });
    await _savePurchasedTrack(track.title);
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
    double maxSliderValue = _totalDuration.inSeconds > 0
        ? _totalDuration.inSeconds.toDouble()
        : 1;
    double displaySliderValue = _isDragging
        ? _sliderValue
        : _currentPosition.inSeconds.toDouble();

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.album.title,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        itemCount: widget.album.tracks.length,
        itemBuilder: (context, index) {
          final track = widget.album.tracks[index];
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
                          icon: _isLoading && _currentPlayingIndex == index
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : Icon(
                                  track.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
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
                      max: maxSliderValue,
                      value: displaySliderValue.clamp(0, maxSliderValue),
                      activeColor: Colors.orange,
                      inactiveColor: Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          _isDragging = true;
                          _sliderValue = value;
                        });
                      },
                      onChangeEnd: (value) async {
                        setState(() {
                          _isDragging = false;
                        });
                        final newPos = Duration(seconds: value.toInt());
                        await widget.audioPlayer.seek(newPos);
                        // Явно вызываем resume, чтобы трек не перезапускался с начала
                        await widget.audioPlayer.resume();
                        setState(() {
                          _currentPosition = newPos;
                          _sliderValue = newPos.inSeconds.toDouble();
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