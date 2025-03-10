// lib/models.dart

class UpgradeItem {
  String title;
  String type; // 'click' или 'passive'
  int level;
  int cost;
  int increment;
  int unlockLevel; // Минимальный уровень игрока для разблокировки апгрейда

  UpgradeItem({
    required this.title,
    required this.type,
    required this.level,
    required this.cost,
    required this.increment,
    this.unlockLevel = 1,
  });

  factory UpgradeItem.fromMap(Map<String, dynamic> map) {
    return UpgradeItem(
      title: map['title'],
      type: map['type'],
      level: map['level'],
      cost: map['cost'],
      increment: map['increment'],
      unlockLevel: map['unlockLevel'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'level': level,
      'cost': cost,
      'increment': increment,
      'unlockLevel': unlockLevel,
    };
  }
}

class Track {
  String title;
  String artist;
  String duration;
  int cost;
  String audioFile;  // например, "audio/blonde.mp3"
  String coverAsset; // например, "assets/images/blonde_cover.png"
  bool isUploaded;
  bool isPlaying;

  Track({
    required this.title,
    required this.artist,
    required this.duration,
    required this.cost,
    required this.audioFile,
    required this.coverAsset,
    this.isUploaded = false,
    this.isPlaying = false,
  });

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      title: map['title'],
      artist: map['artist'],
      duration: map['duration'],
      cost: map['cost'],
      audioFile: map['audioFile'],
      coverAsset: map['coverAsset'],
      isUploaded: map['isUploaded'] ?? false,
      isPlaying: map['isPlaying'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'duration': duration,
      'cost': cost,
      'audioFile': audioFile,
      'coverAsset': coverAsset,
      'isUploaded': isUploaded,
      'isPlaying': isPlaying,
    };
  }
}

class Album {
  String title;
  String coverAsset;
  List<Track> tracks;

  Album({
    required this.title,
    required this.coverAsset,
    required this.tracks,
  });
}