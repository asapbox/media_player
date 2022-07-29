class Media {
  final int id;
  final String title;
  final String videoId;

  Media({required this.id, required this.title, required this.videoId});

  factory Media.fromJson(dynamic json) => Media(
        id: json['id'] as int,
        title: json['title'] as String,
        videoId: json['video'] as String,
      );

  @override
  String toString() {
    return 'Media(id: $id, title: $title, videoId, $videoId)\n';
  }

}
