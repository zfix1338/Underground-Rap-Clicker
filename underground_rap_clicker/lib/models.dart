// START OF MODIFIED FILE underground_rap_clicker/lib/models.dart

class UpgradeItem {
  String title;
  String type; // 'click' or 'passive'
  int level;
  int cost;
  int increment;
  // --- Новые необязательные поля для зависимостей ---
  final String? requirementTitle; // Название апгрейда, от которого зависим
  final int? requirementLevel;   // Требуемый уровень зависимого апгрейда
  // ---------------------------------------------

  UpgradeItem({
    required this.title,
    required this.type,
    required this.level,
    required this.cost,
    required this.increment,
    // --- Добавляем в конструктор ---
    this.requirementTitle,
    this.requirementLevel,
    // ----------------------------
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'level': level,
      'cost': cost,
      'increment': increment,
      // --- Добавляем в toMap ---
      'requirementTitle': requirementTitle,
      'requirementLevel': requirementLevel,
      // -----------------------
    };
  }

  factory UpgradeItem.fromMap(Map<String, dynamic> map) {
    return UpgradeItem(
      title: map['title'] ?? '',
      type: map['type'] ?? 'click',
      level: map['level'] ?? 0,
      cost: map['cost'] ?? 0,
      increment: map['increment'] ?? 0,
      // --- Добавляем в fromMap (с проверкой на null) ---
      requirementTitle: map['requirementTitle'], // Может быть null
      requirementLevel: map['requirementLevel'], // Может быть null
      // --------------------------------------------
    );
  }
}

class Track {
  final String title;
  final String artist;
  final String duration;
  final int cost;
  final String audioFile;
  final String coverAsset;
  bool isPurchased;

  Track({
    required this.title,
    required this.artist,
    required this.duration,
    required this.cost,
    required this.audioFile,
    required this.coverAsset,
    this.isPurchased = false,
  });

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

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      duration: map['duration'] ?? '',
      cost: map['cost'] ?? 100,
      audioFile: map['audioFile'] ?? '',
      coverAsset: map['coverAsset'] ?? '',
      isPurchased: map['isPurchased'] ?? false,
    );
  }

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

class Album {
  final String title;
  final String coverAsset;
  final List<Track> tracks;

  Album({
    required this.title,
    required this.coverAsset,
    required this.tracks,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'coverAsset': coverAsset,
      'tracks': tracks.map((track) => track.toMap()).toList(),
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    var tracksList = <Track>[];
    if (map['tracks'] != null) {
      tracksList = List<Track>.from(
          (map['tracks'] as List).map((trackMap) => Track.fromMap(trackMap)));
    }
    return Album(
      title: map['title'] ?? '',
      coverAsset: map['coverAsset'] ?? '',
      tracks: tracksList,
    );
  }
}
// END OF MODIFIED FILE underground_rap_clicker/lib/models.dart