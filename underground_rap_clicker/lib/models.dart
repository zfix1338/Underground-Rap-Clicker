// models.dart
// 
class UpgradeItem {
  String title;
  String type; // 'click' или 'passive'
  int level;
  int cost;
  int increment;

  UpgradeItem({
    required this.title,
    required this.type,
    required this.level,
    required this.cost,
    required this.increment,
  });

  factory UpgradeItem.fromMap(Map<String, dynamic> map) => UpgradeItem(
        title: map['title'],
        type: map['type'],
        level: map['level'],
        cost: map['cost'],
        increment: map['increment'],
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'type': type,
        'level': level,
        'cost': cost,
        'increment': increment,
      };
}

class Track {
  String title;
  String artist;
  String duration;
  int cost;
  String audioFile;
  String coverAsset;
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

  factory Track.fromMap(Map<String, dynamic> map) => Track(
        title: map['title'],
        artist: map['artist'],
        duration: map['duration'],
        cost: map['cost'],
        audioFile: map['audioFile'],
        coverAsset: map['coverAsset'],
        isUploaded: map['isUploaded'] ?? false,
        isPlaying: map['isPlaying'] ?? false,
      );

  Map<String, dynamic> toMap() => {
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