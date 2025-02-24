import 'package:flutter/material.dart';

import '../models.dart';

class TracksScreen extends StatelessWidget {
  final List<Track> tracks; // Добавлено поле tracks
  final int listensCount;

  const TracksScreen({
    super.key,
    required this.tracks, // Передаем список tracks
    required this.listensCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          '$listensCount',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Действие при нажатии на иконку ноты
            },
            icon: const Icon(Icons.music_note, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.grey,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: const Center(child: Text(
'Tracks',
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
),
),
// Используем ListView.builder для отображения треков из списка
ListView.builder(
shrinkWrap: true, // Добавлено shrinkWrap
physics: const NeverScrollableScrollPhysics(), // Добавлено отключение скролла
itemCount: tracks.length,
itemBuilder: (context, index) {
final track = tracks[index];
return Container(
color: Colors.grey,
padding: const EdgeInsets.all(12),
child: Row(
children: [
// Обложка трека (используем Image.asset)
Image.asset(
track.coverAsset,
width: 60,
height: 60,
fit: BoxFit.cover,
),
const SizedBox(width: 12),
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
SizedBox(height: 4),
Text(
'${track.artist}\n${track.duration}',
style: TextStyle(
color: Colors.white70,
fontSize: 14,
height: 1.3,
),
),
],
),
),
// Цена трека
Text(
'${track.cost}€',
style: TextStyle(
color: Colors.white,
fontSize: 16,
),
),
const SizedBox(width: 8),
// Кнопка "Выпустить"
ElevatedButton(
onPressed: () {
// Действие при нажатии
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey,
),
child: const Text(
'Выпустить',
style: TextStyle(color: Colors.white),
),
),
],
),
);
},
),
// Кнопка "Close"
Container(
color: Colors.grey,
width: double.infinity,
child: TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text(
'Close',
style: TextStyle(color: Colors.white),
),
),
),
],
),
),
);
}
}