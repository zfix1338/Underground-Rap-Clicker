import 'package:flutter/material.dart';

class TracksScreen extends StatelessWidget {
  final int listensCount;

  const TracksScreen({
    Key? key,
    required this.listensCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Фон – чёрный
      backgroundColor: Colors.black,

      // Верхняя панель
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        // Вместо "0" показываем реальное значение listensCount
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

      // Основная часть экрана
      // Используем SingleChildScrollView, чтобы не было переполнения
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Серый бар "Tracks"
            Container(
              color: Colors.grey[900],
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: const Center(
                child: Text(
                  'Tracks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Пример блока трека
            Container(
              color: Colors.grey[850],
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Вместо Image.network используем иконку, чтобы не было HTTP-ошибок
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.album,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Информация о треке
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Blonde',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'osamason\n2.8M • 2:24',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Цена
                  const Text(
                    '999&euro;',
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
                      backgroundColor: Colors.grey[700],
                    ),
                    child: const Text(
                      'Выпустить',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Можно добавить больше треков ниже...
            // ...

            // Кнопка "Close" (если нужно закрывать экран)
            Container(
              color: Colors.grey[900],
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Закрываем экран, если это отдельная страница.
                  // Если это вкладка, можно убрать эту кнопку вовсе.
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