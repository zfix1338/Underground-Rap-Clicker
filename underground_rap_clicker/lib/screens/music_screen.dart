import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models.dart';
import 'album_detail_screen.dart';

class MusicScreen extends StatelessWidget {
  final AudioPlayer audioPlayer; // Глобальный аудио плеер
  final List<Album> albums; // Список альбомов вместо треков
  final int monthlyListeners;
  final Function(int cost)? onSpend;
  final Function()? onAlbumUpdate;

  const MusicScreen({
    Key? key,
    required this.audioPlayer,
    required this.albums,
    required this.monthlyListeners,
    this.onSpend,
    this.onAlbumUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Albums"),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlbumDetailScreen(
                    album: album,
                    audioPlayer: audioPlayer,
                    monthlyListeners: monthlyListeners,
                    onSpend: onSpend,
                    onTrackUpdate: onAlbumUpdate,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(8),
              color: Colors.grey,
              child: Row(
                children: [
                  // Обложка альбома
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      album.coverAsset,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Название альбома
                  Text(
                    album.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
