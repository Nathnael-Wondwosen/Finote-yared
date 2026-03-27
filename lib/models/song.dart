class Song {
  final String title;
  final String category;
  final String lyrics;

  Song({required this.title, required this.category, required this.lyrics});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      category: json['category'],
      lyrics: json['lyrics'],
    );
  }
}
