class ReelModel {
  final String id;
  final String videoUrl;
  final String thumbnail;
  final String title;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnail,
    required this.title,
  });

  factory ReelModel.fromMap(String id, Map<String, dynamic> map) {
    return ReelModel(
      id: id,
      videoUrl: map['videoUrl'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      title: map['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'thumbnail': thumbnail,
      'title': title,
    };
  }
}
