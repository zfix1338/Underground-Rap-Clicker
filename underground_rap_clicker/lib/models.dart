// START OF FULL REVISED FILE: lib/models.dart
import 'dart:math'; // Понадобится для расчета стоимости/прироста, если захотите вернуть формулы

// --- Класс Апгрейда (из вашего файла) ---
class UpgradeItem {
  String title;
  String type; // 'click' or 'passive'
  int level;
  int cost; // Текущая стоимость (нужно будет обновлять извне!)
  int increment; // Текущий прирост (нужно будет обновлять извне!)
  // --- Поля для зависимостей ---
  final String? requirementTitle; // Название апгрейда, от которого зависим (может быть null)
  final int? requirementLevel;   // Требуемый уровень зависимого апгрейда (может быть null)
  // ----------------------------

  UpgradeItem({
    required this.title,
    required this.type,
    required this.level,
    required this.cost,     // Начальная стоимость при создании
    required this.increment, // Начальный прирост при создании
    this.requirementTitle, // Необязательный параметр
    this.requirementLevel, // Необязательный параметр
  });

  // Метод для преобразования в Map (для сохранения)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'level': level,
      'cost': cost,
      'increment': increment,
      'requirementTitle': requirementTitle,
      'requirementLevel': requirementLevel,
    };
  }

  // Фабричный конструктор для создания из Map (для загрузки)
  factory UpgradeItem.fromMap(Map<String, dynamic> map) {
    return UpgradeItem(
      title: map['title'] ?? 'Unknown Upgrade', // Значение по умолчанию
      type: map['type'] ?? 'click',             // Значение по умолчанию
      level: map['level'] ?? 0,                 // Значение по умолчанию
      cost: map['cost'] ?? 10,                  // Значение по умолчанию
      increment: map['increment'] ?? 1,         // Значение по умолчанию
      requirementTitle: map['requirementTitle'], // Может быть null
      requirementLevel: map['requirementLevel'], // Может быть null
    );
  }

  // --- ВАЖНО: ---
  // Логику увеличения стоимости (cost) и прироста (increment) при повышении уровня (level)
  // нужно будет реализовать ВНЕ этого класса, там, где вы управляете состоянием игры.
  // Например, при вызове onLevelUp в UpgradeScreen:
  // 1. Найти нужный UpgradeItem в списке.
  // 2. Увеличить его level.
  // 3. Пересчитать cost и increment по вашей формуле (например, cost = (cost * 1.15).round(); increment += 1;)
  // 4. Обновить состояние игры (setState или через стейт-менеджер).
  //----------------
}

// --- Класс Трека (из вашего файла) ---
class Track {
  final String title;
  final String artist;
  final String duration;
  final int cost;         // Стоимость покупки трека
  final String audioFile;  // Путь к аудио (относительно assets/)
  final String coverAsset; // Путь к обложке (относительно assets/)
  bool isPurchased;       // Куплен ли трек

  // --- ВАЖНО: ---
  // Поле isPlaying отсутствует. Его состояние нужно будет хранить
  // и управлять им отдельно, например, в AlbumDetailScreenState
  // или в общем состоянии игры, если музыка может играть в фоне.
  // --------------

  Track({
    required this.title,
    required this.artist,
    required this.duration,
    required this.cost,
    required this.audioFile,
    required this.coverAsset,
    this.isPurchased = false, // По умолчанию не куплен
  });

  // Для сохранения
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'duration': duration,
      'cost': cost,
      'audioFile': audioFile,
      'coverAsset': coverAsset,
      'isPurchased': isPurchased,
    };
  }

  // Для загрузки
  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      title: map['title'] ?? 'Unknown Track',
      artist: map['artist'] ?? 'Unknown Artist',
      duration: map['duration'] ?? '0:00',
      cost: map['cost'] ?? 100, // Стоимость по умолчанию
      audioFile: map['audioFile'] ?? '',
      coverAsset: map['coverAsset'] ?? 'assets/images/default_cover.png', // Укажите путь к обложке по умолчанию
      isPurchased: map['isPurchased'] ?? false,
    );
  }

  // Переопределение для сравнения треков (например, при проверке покупки)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track &&
        other.title == title &&
        other.artist == artist &&
        other.audioFile == audioFile;
  }
  @override
  int get hashCode => title.hashCode ^ artist.hashCode ^ audioFile.hashCode;
}

// --- Класс Альбома (из вашего файла) ---
class Album {
  final String title;
  final String coverAsset; // Обложка самого альбома
  final List<Track> tracks;

  Album({
    required this.title,
    required this.coverAsset,
    required this.tracks,
  });

  // Для сохранения
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'coverAsset': coverAsset,
      'tracks': tracks.map((track) => track.toMap()).toList(),
    };
  }

  // Для загрузки
  factory Album.fromMap(Map<String, dynamic> map) {
    var tracksList = <Track>[];
    if (map['tracks'] != null && map['tracks'] is List) { // Добавлена проверка типа
      tracksList = List<Track>.from(
          (map['tracks'] as List).map((trackMap) {
            // Добавим проверку, что trackMap действительно Map
            if (trackMap is Map<String, dynamic>) {
              return Track.fromMap(trackMap);
            } else {
              // Обработка ошибки или возврат трека по умолчанию
              print("Ошибка: элемент в списке треков не является картой: $trackMap");
              return Track.fromMap({}); // Возвращаем трек по умолчанию
            }
          })
      );
    }
    return Album(
      title: map['title'] ?? 'Unknown Album',
      coverAsset: map['coverAsset'] ?? 'assets/images/default_cover.png', // Обложка по умолчанию
      tracks: tracksList,
    );
  }
}

// ----- Инициализация Данных -----

// Общие значения для треков (можно изменить)
const String defaultAlbumCoverPath = 'assets/images/blonde_cover.png'; // Путь к обложке альбома и треков по умолчанию
const String defaultArtistName = "You"; // Имя артиста по умолчанию
const String defaultTrackDuration = "3:00"; // Длительность по умолчанию

// Создание экземпляра альбома со всеми треками
final Album blondeAlbum = Album(
  title: "Flex musix", // Название альбома
  coverAsset: defaultAlbumCoverPath, // Обложка альбома
  tracks: [
    // Первый трек
    Track( title: "Blonde", artist: defaultArtistName, duration: "2:19", cost: 1000, audioFile: 'audio/blonde.mp3', coverAsset: defaultAlbumCoverPath, ),
    // Новые треки
    Track( title: "For Da Flex", artist: defaultArtistName, duration: defaultTrackDuration, cost: 3000, audioFile: 'audio/For Da Flex.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "All Star", artist: defaultArtistName, duration: defaultTrackDuration, cost: 10000, audioFile: 'audio/All Star.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Baghdad", artist: defaultArtistName, duration: defaultTrackDuration, cost: 2000, audioFile: 'audio/Baghdad.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Congrats", artist: defaultArtistName, duration: defaultTrackDuration, cost: 2500, audioFile: 'audio/Congrats.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Talking 2 A Ghost", artist: defaultArtistName, duration: defaultTrackDuration, cost: 3000, audioFile: 'audio/Talking 2 A Ghost.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Pop", artist: defaultArtistName, duration: defaultTrackDuration, cost: 3050, audioFile: 'audio/Pop.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Str8 Flexin", artist: defaultArtistName, duration: defaultTrackDuration, cost: 4000, audioFile: 'audio/Str8 Flexin.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Me When", artist: defaultArtistName, duration: defaultTrackDuration, cost: 4500, audioFile: 'audio/Me When.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Uno", artist: defaultArtistName, duration: defaultTrackDuration, cost: 3000, audioFile: 'audio/Uno.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Kills", artist: defaultArtistName, duration: defaultTrackDuration, cost: 7000, audioFile: 'audio/Kills.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Kome Thru", artist: defaultArtistName, duration: defaultTrackDuration, cost: 3000, audioFile: 'audio/Kome Thru.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Boss Up", artist: defaultArtistName, duration: defaultTrackDuration, cost: 3000, audioFile: 'audio/Boss Up.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "3x", artist: defaultArtistName, duration: defaultTrackDuration, cost: 3000, audioFile: 'audio/3x.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Worst Part", artist: defaultArtistName, duration: defaultTrackDuration, cost: 3000, audioFile: 'audio/Worst Part.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Trenches", artist: defaultArtistName, duration: defaultTrackDuration, cost: 8000, audioFile: 'audio/Trenches.mp3', coverAsset: defaultAlbumCoverPath, ),
    Track( title: "Nothing", artist: defaultArtistName, duration: defaultTrackDuration, cost: 4000, audioFile: 'audio/Nothing.mp3', coverAsset: defaultAlbumCoverPath, ),
  ],
);

// Начальный список апгрейдов (Пример с зависимостями)
// Используйте этот список как начальное состояние вашей игры.
// При загрузке сохраненной игры, вы будете использовать UpgradeItem.fromMap для восстановления состояния.
List<UpgradeItem> initialUpgrades = [
  // Апгрейды клика
  UpgradeItem( title: "Better Mic", type: 'click', level: 0, cost: 25, increment: 1, ),
  UpgradeItem( title: "Hype Man", type: 'click', level: 0, cost: 150, increment: 5,
    // Пример зависимости: Hype Man доступен после 5 уровня Better Mic
    requirementTitle: "Better Mic",
    requirementLevel: 5,
  ),
  UpgradeItem( title: "Ghostwriter", type: 'click', level: 0, cost: 750, increment: 25,
    requirementTitle: "Hype Man",
    requirementLevel: 3,
  ),

  // Пассивные апгрейды
  UpgradeItem( title: "SoundCloud Upload", type: 'passive', level: 0, cost: 100, increment: 1, ),
  UpgradeItem( title: "Viral Promo", type: 'passive', level: 0, cost: 600, increment: 5,
    requirementTitle: "SoundCloud Upload",
    requirementLevel: 10,
  ),
  UpgradeItem( title: "Producer Deal", type: 'passive', level: 0, cost: 2000, increment: 20,
    requirementTitle: "Viral Promo",
    requirementLevel: 5,
  ),
  // Добавьте больше апгрейдов по аналогии...
];


// END OF FULL REVISED FILE: lib/models.dart
