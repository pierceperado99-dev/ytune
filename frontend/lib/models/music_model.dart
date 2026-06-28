class MusicModel {
  final String id;
  final String title;
  final String artist;
  final String thumbnail;
  final int duration;
  final String url;

  const MusicModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnail,
    required this.duration,
    required this.url,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) {
    return MusicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      thumbnail: json['thumbnail'] as String,
      duration: json['duration'] as int,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'thumbnail': thumbnail,
      'duration': duration,
      'url': url,
    };
  }
}
